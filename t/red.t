
local red,err = require('songpengfei/gate/gate/red'):new("127.0.0.1","9700","")

if not red then
    ngx.say("failed to connect: ", err)
    return
end

local key = 'test1'
local res, err = red:set(key,12)
ngx.say(tostring(res)..tostring(err))

local res, err = red:get(key)
ngx.say(tostring(res)..tostring(err))

local key2 = 'test2'
local res,err = red:mget(key,key2)
for i,v in ipairs(res) do
    ngx.say("i:"..tostring(i)..' v:'..tostring(v))
end

local res,err = red:setnx("test3",1)
ngx.say(tostring(res)..tostring(err))

local res,err = red:setex("test3",1,5)
ngx.say(tostring(res)..tostring(err))

local res,err = red:exists("test1")
ngx.say(tostring(res)..tostring(err))

local res,err = red:hmset("test_hash_1",'key1',1,'key2',2)
ngx.say(tostring(res)..tostring(err))

local res,err = red:hmget('test_hash_1','key1','key2')
for i,v in ipairs(res) do
    ngx.say("i:"..tostring(i)..' v:'..tostring(v))
end

local res,err = red:hgetall('test_hash_1')
for i,v in ipairs(res) do
    ngx.say("i:"..tostring(i)..' v:'..tostring(v))
end

red:close()
