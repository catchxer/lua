--[[
--
--   red.lua
--
--   一个服务用来完成redis连接
--   参数：host, port, pass, timeout(default 500)
--
--
--   返回值1(red) nil or true
--
--   返回值2(err) 出错的错误信息(string)  没有错误就返回 nil
--
--   usage：
--
--   local red, err = require('gate/red'):new(host, port, pass, timeout)
--
--   if not red then
--      ngx.say("failed to connect: ", err)
--      return
--   end
--   local get, err = red:get(key)
--
--   red:close() -- 显性CLOSE 才可以用到连接池
--
--
--   More demo -> src/lua/t/red.t
--]]

local redis, _M = require "resty.redis", {}

_M._VERSION = '0.01'

local common_cmds = {
    "get",      "set",          "mget",     "mset",
    "del",      "incr",         "decr",     "setnx",
    "setex",    "incrby",                               -- Strings
    "llen",     "lindex",       "lpop",     "lpush",
    "lrange",   "linsert",                              -- Lists
    "hexists",  "hget",         "hset",     "hmget",
    "hmset",    "hdel",         "hgetall",              -- Hashes
    "smembers", "sismember",    "sadd",     "srem",
    "sdiff",    "sinter",       "sunion",               -- Sets
    "zrange",   "zrangebyscore", "zrank",   "zadd",
    "zrem",     "zincrby",                              -- Sorted Sets
    "auth",     "eval",         "expire",   "script",
    "sort",     "exists",        "ttl",                 -- Others
}

function _M:new (host, port, pass, timeout)
    local _redis = redis:new()
    _redis:set_timeout(timeout or 500) -- 0.5 sec
    local ok, err = _redis:connect(host, port)

    if not ok then
        ngx.log(ngx.ERR, 'redis connect error: '..tostring(err)..' host:'..tostring(host)..' port:'..tostring(port))
        return nil, err
    end

    local times, err = _redis:get_reused_times()
    -- ngx.say(tostring(times))
    if times == nil or times == 0 then
        if pass ~= nil and pass ~='' and pass ~= ngx.null  then
            local res, err = _redis:auth(pass)
            if err then
                ngx.log(ngx.ERR, 'redis auth error: '..tostring(err)..' host:'..tostring(host)..' port:'..tostring(port))
                return nil, err
            end
        end
    end

    return setmetatable({ redis = _redis }, { __index = _M})
end

for i = 1, #common_cmds do
    local cmd = common_cmds[i]

    _M[cmd] =
        function (self, ...)
            local redis = rawget(self,"redis")
            -- ngx.say("cmd"..cmd)
            -- local arg={...}
            -- for i,v in ipairs(arg) do
            --     ngx.say("v"..tostring(v))
            -- end
            return redis[cmd](redis,...)
        end
end

function _M:close()
    local redis = rawget(self,"redis")
    if redis then
        local ok, err = redis:set_keepalive(10000, 100)
        if not ok then redis:close() end
    end
end

return _M
