local queue = {}
local maxPlayers = 1
local isSettingAGameUp = false

function addPlayerInQueue(player)
    table.insert(queue, player)

    updateLobby(queue, {playersInQueue = #queue, maxPlayers = maxPlayers})
    updateLobby(player, {inQueue = true})
end

function removePlayerFromQueue(player)
    for i, v in pairs(queue) do
        if v == player then
            table.remove(queue, i)
            break
        end
    end

    updateLobby(queue, {playersInQueue = #queue, maxPlayers = maxPlayers})
    updateLobby(player, {inQueue = false})
end

function isPlayerInQueue(player)
    for i, v in pairs(queue) do
        if v == player then
            return true
        end
    end

    return false
end

function resetQueue(err)
    if err then
        updateLobby(queue, {inQueue = false, playersInQueue = #queue, maxPlayers = maxPlayers})
    end

    queue = {}
    isSettingAGameUp = false
end

function checkQueue()
    if #queue >= maxPlayers and isSettingAGameUp == false then
        isSettingAGameUp = true
        
        local status, gameId = exports.fg_game:createGame() -- Criar o jogo

        if status then
            exports.fg_game:prepareGame(gameId, queue) -- Preparar o jogo
            
            setTimer(function(p)
                updateLobby(p, {inLobby = false})
            end, 3000, 1, queue)

            setTimer(function()
                resetQueue(false)
            end, 5000, 1)
        else
            resetQueue(true)
        end
    end
end

function updateLobby(element, data)
    triggerClientEvent(element, "lobby:updateInfo", resourceRoot, data)
end

function showLobby(element)
    triggerClientEvent(element, "lobby:updateInfo", resourceRoot, {inLobby = true})
end

function hideLobby(element)
    triggerClientEvent(element, "lobby:updateInfo", resourceRoot, {inLobby = false})
end

addEventHandler("onPlayerQuit", root, function()
    if isPlayerInQueue(source) then
        removePlayerFromQueue(source)
    end
end)

addEvent("lobby:addClientInQueue", true)
addEventHandler("lobby:addClientInQueue", resourceRoot, function()
    if isPlayerInQueue(client) then
        return false
    end

    if #queue >= maxPlayers or isSettingAGameUp then
        return false
    end

    addPlayerInQueue(client)
    checkQueue()
end)

addEvent("lobby:removeClientFromQueue", true)
addEventHandler("lobby:removeClientFromQueue", resourceRoot, function()
    if not isPlayerInQueue(client) then
        return false
    end

    removePlayerFromQueue(client)
end)