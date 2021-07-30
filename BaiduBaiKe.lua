local botoy = require 'Plugins/lib/botoy'
local http = botoy.http
local log = botoy.log

-- Reference: https://github.com/opq-osc/lua-plugins/blob/master/%E7%99%BE%E7%A7%91.lua
local function search(word)
  local resp, err = http.get('http://baike.baidu.com/api/openapi/BaikeLemmaCardApi', {
    params = { bk_key = word },
    query = 'scope=103&format=json&appid=379020&bk_length=600',
    timeout = 20,
  })
  if err then
    log.error('百度百科插件网络请求出错', err)
    return
  end

  if resp.text:find '"errno":2' then
    return
  end

  local data = resp:json()

  return string.format('【%s】\n%s %s', data.title, data.abstract, data.url)
end

ReceiveGroupMsg = botoy.group(function(qq, data, action)
  if qq == data.FromUserId or data.Content:find '百科' ~= 1 then
    return 1
  end

  local word = data.Content:gsub('百科', '', 1)

  local result
  local retry = 0

  while not result and retry < 5 do
    retry = retry + 1
    result = search(word)
  end

  if result then
    action:sendGroupText(data.FromGroupId, result)
  end
end)

function ReceiveFriendMsg()
  return 1
end

function ReceiveEvents()
  return 1
end
