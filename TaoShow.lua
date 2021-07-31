local botoy = require 'Plugins/lib/botoy'
local http = botoy.http
local log = botoy.log

ReceiveGroupMsg = botoy.group(function(qq, data, action)
  if qq == data.FromUserId or data.Content:find '买家秀' ~= 1 then
    return 1
  end

  local resp, err = http.get(
    'https://api.vvhan.com/api/tao',
    { params = { ['type'] = 'json' }, timeout = 10 }
  )
  if err then
    log.error('TaoShow: ', err)
    return 1
  end

  local data = resp:json()
  if data then
    action:sendGroupUrlPic(data.FromGroupId, data.pic, data.title)
  end

  return 1
end)

function ReceiveFriendMsg()
  return 1
end

function ReceiveEvents()
  return 1
end
