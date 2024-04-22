-- Q1

function onLogout(player)
    local value = player:getStorageValue(1000)
    if value ~= nil and value == 1 then
        player:setStorageValue(1000, -1)
    end
end

-- Q2

function printSmallGuildNames(memberCount)
    local selectGuildQuery = string.format("SELECT name FROM guilds WHERE max_members < %d;", memberCount)
    
    local resultId = db.storeQuery(selectGuildQuery)
    if resultId ~= false then
        repeat
            local guildName = result.getString(resultId, "name")
            print(guildName)
        until not result.next(resultId)
        result.free(resultId)
    end
end

-- Q3

function removePlayerFromParty(playerId)
    local party = player:getParty()
    local playerName = Player(playerId):getName()
    local member = party:getMembers()[playerName]
    
    if member ~= nil then
      party:removeMember(playerName)
    end
end



