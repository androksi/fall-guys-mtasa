local screenX, screenY = guiGetScreenSize()
local countInfo = {}

function drawCountdown()
    local imageWidth = 256
    local imageHeight = 256
    local imageX = screenX / 2 - imageWidth / 2
    local imageY = screenY / 2 - imageHeight / 2

    dxDrawImage(imageX, imageY, imageWidth, imageHeight, "assets/images/" .. countInfo.status .. ".png")
end

function showCountdown()
    removeEventHandler("onClientRender", root, drawCountdown)
    addEventHandler("onClientRender", root, drawCountdown)
end

function hideCountdown()
    removeEventHandler("onClientRender", root, drawCountdown)
end

addEvent("countdown:sync", true)
addEventHandler("countdown:sync", resourceRoot, function(data)
    if data.status ~= nil then
        countInfo.status = data.status

        if data.status == 3 then
            showCountdown()
        end

        if data.status > 0 then
            playSoundFrontEnd(44)
        else
            playSoundFrontEnd(45)
            setTimer(hideCountdown, 2000, 1)
        end
    end
end)