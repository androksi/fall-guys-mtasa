local games = {}
local playerGame = {}

local serverMaps = {"fg_map2"}

function createGame()
    local newId = #games + 1

    if not games[newId] then
        games[newId] = {}

        return true, newId
    end

    return false
end

function prepareGame(gameId, queue)
    if games[gameId] then
        -- Configurações de jogo
        games[gameId].playersInSpectate = {}
        games[gameId].playersInMatch = queue
        games[gameId].playersInFinish = {}
        games[gameId].gameTimers = {}
        games[gameId].mapSpawns = {}
        games[gameId].mapFinish = false
        games[gameId].countdownStatus = 3
        games[gameId].amountOfPlayersToEndMatch = math.max(math.floor(#games[gameId].playersInMatch * 0.75), 1)

        for index, player in pairs(games[gameId].playersInMatch) do
            if isElement(player) and not playerGame[player] then
                playerGame[player] = gameId
            end
        end

        processGame(gameId)
    end
end

function processGame(gameId)
    exports.fg_maploader:unloadMap(gameId)
    local map = exports.fg_maploader:loadMap(gameId, serverMaps[math.random(#serverMaps)])

    if map then
        local all = getPlayersAndSpectatorsInMatch(gameId)
        exports.fg_maploader:removeMap(all)

        local timer = setTimer(function(gameId, players)
            local finish = exports.fg_maploader:getMapFinishPoint(gameId)

            if finish then
                games[gameId].mapFinish = createMarker(finish.posX, finish.posY, finish.posZ, "corona", 2, 255, 255, 255, 255)

                if games[gameId].mapFinish then
                    setElementDimension(games[gameId].mapFinish, gameId)
                    addEventHandler("onMarkerHit", games[gameId].mapFinish, finishMap)
                end
            end

            exports.fg_maploader:createMap(players, gameId)
            spawnPlayersInMatch(gameId)
        end, 3000, 1, gameId, all)

        table.insert(games[gameId].gameTimers, timer)
    end
end

function startGame(gameId)
    for index, player in pairs(games[gameId].playersInMatch) do
        if isElement(player) then
            setElementFrozen(player, false)
            toggleAllControls(player, true, true, false)
        end
    end
end

function spawnPlayersInMatch(gameId)
    games[gameId].mapSpawns = exports.fg_maploader:getMapSpawns(gameId)

    if #games[gameId].mapSpawns > 0 then
        for index, player in pairs(games[gameId].playersInMatch) do
            local randomLocation = games[gameId].mapSpawns[math.random(#games[gameId].mapSpawns)]

            spawnPlayer(player, randomLocation.posX, randomLocation.posY, randomLocation.posZ)
            setElementDimension(player, gameId)
            setElementFrozen(player, true)
            setElementRotation(player, randomLocation.rotX, randomLocation.rotY, randomLocation.rotZ or 0)
            setCameraTarget(player)
            toggleAllControls(player, false, true, false)
        end

        local all = getPlayersAndSpectatorsInMatch(gameId)
        updateMatch(all, {inMatch = true, playersInFinish = #games[gameId].playersInFinish, amountOfPlayersToEndMatch = games[gameId].amountOfPlayersToEndMatch})

        local timer = setTimer(startCountdown, math.random(5000, 10000), 1, gameId)
        table.insert(games[gameId].gameTimers, timer)
    end
end

function startCountdown(gameId)
    local timer = setTimer(function(gameId)
        local status = games[gameId].countdownStatus

        if status == 0 then
            -- Iniciar partida
            startGame(gameId)
        end

        local all = getPlayersAndSpectatorsInMatch(gameId)

        exports.fg_countdown:syncCountdown(all, {status = status})
        games[gameId].countdownStatus = games[gameId].countdownStatus - 1
    end, 1000, 4, gameId)

    table.insert(games[gameId].gameTimers, timer)
end

function finishMap(theElement, theDimension)
    if getElementType(theElement) == "player" and theDimension then
        local vehicle = getPedOccupiedVehicle(theElement)

        if not vehicle then
            local gameId = playerGame[theElement]

            if gameId then
                local all = getPlayersAndSpectatorsInMatch(gameId)

                toggleAllControls(theElement, false, true, false)
                setElementFrozen(theElement, true)
                table.insert(games[gameId].playersInFinish, theElement)
                updateMatch(all, {playersInFinish = #games[gameId].playersInFinish, amountOfPlayersToEndMatch = games[gameId].amountOfPlayersToEndMatch})
                checkFinish(gameId)
            end
        end
    end
end

function checkFinish(gameId)
    if #games[gameId].playersInFinish >= games[gameId].amountOfPlayersToEndMatch then
        for i, v in pairs(games[gameId].playersInMatch) do
            if not isPlayerInFinish(v) then
                removePlayerFromMatch(v)
                table.insert(games[gameId].playersInSpectate, v)
            end
        end

        if isElement(games[gameId].mapFinish) then
            removeEventHandler("onMarkerHit", games[gameId].mapFinish, finishMap)
            destroyElement(games[gameId].mapFinish)
        end

        games[gameId].playersInMatch = games[gameId].playersInFinish
        games[gameId].playersInFinish = {}
        games[gameId].countdownStatus = 3
        games[gameId].amountOfPlayersToEndMatch = math.max(math.floor(#games[gameId].playersInMatch * 0.75), 1)

        if #games[gameId].playersInMatch > 1 then
            local timer = setTimer(processGame, 8000, 1, gameId)
            table.insert(games[gameId].gameTimers, timer)
        else
            local all = getPlayersAndSpectatorsInMatch(gameId)

            if isElement(games[gameId].playersInMatch[1]) then
                updateMatch(all, {theWinner = getPlayerName(games[gameId].playersInMatch[1])})
            end

            for i, v in pairs(all) do
                removePlayerFromMatch(v)
                removePlayerFromGame(v)
                exports.fg_maploader:removeMap(v)
                exports.fg_lobby:showLobby(v)
            end

            removeAllTimers(gameId)
            games[gameId] = nil
        end
    end
end

function removeAllTimers(gameId)
    for i, v in pairs(games[gameId].gameTimers) do
        if isTimer(v) then
            killTimer(v)
        end
    end
end

function updateMatch(element, data)
    triggerClientEvent(element, "game:updateMatch", resourceRoot, data)
end

function isPlayerInMatch(player)
    local gameId = playerGame[player]

    if gameId then
        for i, v in pairs(games[gameId].playersInMatch) do
            if isElement(v) and v == player then
                return true
            end
        end
    end

    return false
end

function isPlayerInFinish(player)
    local gameId = playerGame[player]

    if gameId then
        for i, v in pairs(games[gameId].playersInFinish) do
            if isElement(v) and v == player then
                return true
            end
        end
    end

    return false
end

function isPlayerInSpectate(player)
    local gameId = playerGame[player]

    if gameId then
        for i, v in pairs(games[gameId].playersInSpectate) do
            if isElement(v) and v == player then
                return true
            end
        end
    end

    return false
end

function removePlayerFromMatch(player)
    local gameId = playerGame[player]

    if gameId then
        for i, v in pairs(games[gameId].playersInMatch) do
            if isElement(v) and v == player then
                table.remove(games[gameId].playersInMatch, i)
                break
            end
        end
    end
end

function removePlayerFromGame(player)
    local gameId = playerGame[player]

    if gameId then
        updateMatch(player, {theWinner = false})
        playerGame[player] = nil
    end
end

function getPlayersAndSpectatorsInMatch(gameId)
    local cache = {}

    for i, v in pairs(games[gameId].playersInMatch) do
        if isElement(v) then
            table.insert(cache, v)
        end
    end

    for i, v in pairs(games[gameId].playersInSpectate) do
        if isElement(v) then
            table.insert(cache, v)
        end
    end

    return cache
end

addEventHandler("onPlayerQuit", root, function()
    if isPlayerInMatch(source) then
        removePlayerFromMatch(source)
        removePlayerFromGame(source)
    end
end)