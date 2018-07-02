lua-resty-redis

## https://github.com/openresty/lua-resty-redis

##Usage

 local red, err = require('red'):new(host, port, pass, timeout)

 if not red then
    ngx.say("failed to connect: ", err)
    return
 end
 local get, err = red:get(key)

 red:close() -- 显性CLOSE 才可以用到连接池

 More demo -> src/lua/t/red.t


######Last, qqq
