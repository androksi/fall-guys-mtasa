local screenX, screenY = guiGetScreenSize()
local matchInfo = {}

function draw()
    if matchInfo.inMatch then
        dxDrawText(matchInfo.playersInFinish .. " / " .. matchInfo.amountOfPlayersToEndMatch, 1, 1, screenX - 5 + 1, screenY + 1, tocolor(10, 10, 10, 255), 2.20, "default-bold", "right", "top")
        dxDrawText(matchInfo.playersInFinish .. " / " .. matchInfo.amountOfPlayersToEndMatch, 0, 0, screenX - 5, screenY, tocolor(255, 255, 255, 255), 2.20, "default-bold", "right", "top")
    end
    if matchInfo.theWinner then
        dxDrawText(matchInfo.theWinner:gsub("#%x%x%x%x%x%x", "") .. " venceu!", 0 + 1, 0 + 1, screenX + 1, screenY + 1, tocolor(10, 10, 10, 255), 2.50, "default-bold", "center", "center", false, false, false, false)
        dxDrawText(matchInfo.theWinner .. " #ffffffvenceu!", 0, 0, screenX, screenY, tocolor(255, 255, 255, 255), 2.50, "default-bold", "center", "center", false, false, false, true)
    end
end

function reset()
    matchInfo.playersInFinish = 0
    matchInfo.amountOfPlayersToEndMatch = 0
    matchInfo.inMatch = false
    matchInfo.theWinner = false
end

function showInfo()
    removeEventHandler("onClientRender", root, draw)
    addEventHandler("onClientRender", root, draw)

    matchInfo.inMatch = true
end

function hideInfo()
    removeEventHandler("onClientRender", root, draw)
    reset()
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    reset()
end)

addEvent("game:updateMatch", true)
addEventHandler("game:updateMatch", resourceRoot, function(data)
    if data.playersInFinish ~= nil then
        matchInfo.playersInFinish = data.playersInFinish
    end
    if data.amountOfPlayersToEndMatch ~= nil then
        matchInfo.amountOfPlayersToEndMatch = data.amountOfPlayersToEndMatch
    end
    if data.inMatch ~= nil then
        if data.inMatch then
            showInfo()
        else
            hideInfo()
        end
    end
    if data.theWinner ~= nil then
        if matchInfo.theWinner == false then
            matchInfo.theWinner = data.theWinner
            setTimer(hideInfo, 5000, 1)
        end
    end
end)