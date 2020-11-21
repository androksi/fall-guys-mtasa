local screenX, screenY = guiGetScreenSize()
local lobbyInfo = {}
local lobbyIntervals = {}

local playButtonWidth = screenX
local playButtonHeight = 64
local playButtonX = 0
local playButtonY = screenY - playButtonHeight

local queueBarWidth = screenX
local queueBarHeight = 32
local queueBarX = 0
local queueBarY = playButtonY - queueBarHeight

local loadingBarWidth = screenX
local loadingBarHeight = 32
local loadingBarX = 0
local loadingBarY = queueBarY - loadingBarHeight
local loadingIconRotation = 0

function drawLobby() -- Renderizar lobby
    dxDrawRectangle(0, 0, screenX, screenY, tocolor(10, 10, 10, 100), false)

    dxDrawRectangle(playButtonX, playButtonY, playButtonWidth, playButtonHeight, tocolor(10, 10, 10, 200), false)
    dxDrawText(lobbyInfo.inQueue and "SAIR DA FILA" or "JOGAR", playButtonX, playButtonY, playButtonX + playButtonWidth, playButtonY + playButtonHeight, tocolor(255, 255, 255, 255), 2.50, "default-bold", "center", "center")

    if isHover(playButtonX, playButtonY, playButtonWidth, playButtonHeight) then
        dxDrawRectangle(playButtonX, playButtonY, playButtonWidth, playButtonHeight, tocolor(255, 255, 255, 20), false)
    end

    if lobbyInfo.inQueue then
        dxDrawRectangle(queueBarX, queueBarY, queueBarWidth, queueBarHeight, tocolor(10, 10, 10, 200), false)
        dxDrawRectangle(queueBarX, queueBarY + queueBarHeight, queueBarWidth, 1, tocolor(255, 255, 255, 20), false)
        dxDrawText("Aguardando outros jogadores... " .. lobbyInfo.playersInQueue .. " / " .. lobbyInfo.maxPlayers, queueBarX, queueBarY, queueBarX + queueBarWidth, queueBarY + queueBarHeight, tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center")
        
        if lobbyInfo.isLoading then
            loadingIconRotation = loadingIconRotation - 4

            dxDrawRectangle(loadingBarX, loadingBarY, loadingBarWidth, loadingBarHeight, tocolor(10, 10, 10, 200), false)
            dxDrawRectangle(loadingBarX, loadingBarY + loadingBarHeight, loadingBarWidth, 1, tocolor(255, 255, 255, 20), false)
            dxDrawImage(loadingBarX + (loadingBarWidth / 2 - 12), loadingBarY + (loadingBarHeight / 2 - 12), 24, 24, "assets/images/loader.png", loadingIconRotation)
        end
    end
end

function setupClient() -- Ajustar o cliente
    showCursor(true)
    showChat(false)
    fadeCamera(true)
    setTime(12, 0)
    setMinuteDuration(60000 * 60 * 24)
    setCloudsEnabled(false)
    setOcclusionsEnabled(false)
    toggleControl("action", false)
    setPlayerHudComponentVisible("all", false)
    setElementPosition(localPlayer, -225.7728, 2372.3603, 110.7917)
    setElementRotation(localPlayer, 0, 0, 60)
    setElementDimension(localPlayer, math.random(50000, 60000))
    setPedAnimation(localPlayer, "DANCING", "dance_loop", -1, true, false)
    setCameraMatrix(-229.7728, 2375.3603, 110.7917, -225.7728, 2372.3603, 110.7917)

    lobbyInfo.playersInQueue = 0
    lobbyInfo.maxPlayers = 0
    lobbyInfo.inQueue = false
    lobbyInfo.isLoading = false

    lobbyIntervals.clickTime = 0
end

function showLobby() -- Mostrar o lobby, ajustar o cliente e renderizar informações
    setupClient()
    removeEventHandler("onClientRender", root, drawLobby)
    addEventHandler("onClientRender", root, drawLobby)

    lobbyInfo.inLobby = true
end

function hideLobby() -- Esconder o lobby
    showCursor(false)
    removeEventHandler("onClientRender", root, drawLobby)

    lobbyInfo.inLobby = false
    lobbyInfo.playersInQueue = 0
    lobbyInfo.maxPlayers = 0
end

function isHover ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

addEventHandler("onClientResourceStart", resourceRoot, function() -- Quando o resource iniciar para o cliente
    showLobby()
end)

addEventHandler("onClientClick", root, function(button, state)
    if lobbyInfo.inLobby then
        local isLeft = button == "left"

        if isLeft then
            if state == "up" then
                if isHover(playButtonX, playButtonY, playButtonWidth, playButtonHeight) and lobbyIntervals.clickTime + (3000) <= getTickCount() and lobbyInfo.isLoading == false then
                    lobbyIntervals.clickTime = getTickCount()

                    if lobbyInfo.inQueue then
                        return triggerServerEvent("lobby:removeClientFromQueue", resourceRoot)
                    end

                    triggerServerEvent("lobby:addClientInQueue", resourceRoot)
                end
            end
        end
    end
end)

addEvent("lobby:updateInfo", true)
addEventHandler("lobby:updateInfo", resourceRoot, function(data)
    if data.inQueue ~= nil then
        lobbyInfo.inQueue = data.inQueue
    end
    if data.playersInQueue ~= nil then
        lobbyInfo.playersInQueue = data.playersInQueue
    end
    if data.maxPlayers ~= nil then
        lobbyInfo.maxPlayers = data.maxPlayers
    end
    if lobbyInfo.playersInQueue == lobbyInfo.maxPlayers then
        lobbyInfo.isLoading = true
    end
    if data.inLobby ~= nil then
        if data.inLobby then
            showLobby()
        else
            hideLobby()
        end
    end
end)