local botoy = require 'Plugins/lib/botoy'
local http = botoy.http
local log = botoy.log

local function olympic()
  local resp, err = http.get('https://act.e.mi.com/olympic/medal_rank', { timeout = 20 })
  if err then
    log.error('奥运数据获取失败: ', err)
    return
  end

  local info = resp:json()
  if not info or info.status ~= 0 then
    return
  end

  local results = {}

  for _, countryData in ipairs(info.data) do
    if #results > 10 then
      break
    end
    local name = countryData.country_name
    if name == '中国' then
      name = '🇨🇳' .. name
    end
    local gold = countryData.medal_gold_count
    local silver = countryData.medal_silver_count
    local bronze = countryData.medal_bronze_count
    local total = countryData.medal_sum_count

    table.insert(
      results,
      string.format('%s 🏅%d 🥇%d 🥈%d 🥉%d', name, total, gold, silver, bronze)
    )
  end

  return table.concat(results, '\n')
end

ReceiveGroupMsg = botoy.group(function(qq, data, action)
  if qq == data.FromUserId or data.Content ~= '奥运' then
    return 1
  end

  local text = olympic()
  if text then
    action:sendGroupText(data.FromGroupId, text)
  end

  return 1
end)

ReceiveFriendMsg = botoy.friend(function(qq, data, action)
  if qq == data.FromUserId or data.Content ~= '奥运' then
    return 1
  end

  local text = olympic()
  if text then
    action:sendFriendText(data.FromUin, text)
  end

  return 1
end)

function ReceiveEvents()
  return 1
end
