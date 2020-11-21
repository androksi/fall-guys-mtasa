local stuff = {}

-- Funções que serão substituídas
local _createObject = createObject
local _createMarker = createMarker
local _createPed = createPed
local _setTimer = setTimer
local _addEventHandler = addEventHandler
local _dxCreateShader = dxCreateShader
local _dxCreateTexture = dxCreateTexture
local _engineLoadTXD = engineLoadTXD
local _engineLoadDFF = engineLoadDFF
local _engineLoadCOL = engineLoadCOL
local _playSound = playSound

-- Funções que serão excluídas
local _triggerServerEvent = triggerServerEvent

-- Funções substituídas
function createObject(modelid, x, y, z, ...)
    local new = _createObject(modelid, x, y, z, ...)

    if new then
        setElementDimension(new, getElementDimension(localPlayer))
        table.insert(stuff, {"object", new})
        return new
    end

    return false
end

function createMarker(x, y, z, ...)
    local new = _createMarker(x, y, z, ...)

    if new then
        setElementDimension(new, getElementDimension(localPlayer))
        table.insert(stuff, {"marker", new})
        return new
    end

    return false
end

function createPed(modelid, x, y, z, ...)
    local new = _createPed(x, y, z, ...)

    if new then
        setElementDimension(new, getElementDimension(localPlayer))
        table.insert(stuff, {"ped", new})
        return new
    end

    return false
end

function setTimer(theFunction, timeInterval, timesToExecute, ...)
    local new = _setTimer(theFunction, timeInterval, timesToExecute, ...)

    if new then
        table.insert(stuff, {"timer", new})
        return new
    end

    return false
end

function addEventHandler(eventName, attachedTo, handlerFunction, ...)
    local new = {eventName, attachedTo, handlerFunction}

    if type(new[3]) == "function" then
        if new[1] == "onClientResourceStart" then
            setTimer(new[3], 1000, 1, ...)
        end

        table.insert(stuff, {"event", new})
        return _addEventHandler(new[1], new[2], new[3], ...)
    end

    return false
end

function dxCreateShader(filepath, ...)
    local new

    if type(filepath) ~= "string" and fileExists("storage/" .. stuff.mapName .. "/" .. filepath) then
        new = _dxCreateShader("storage/" .. stuff.mapName .. "/" .. filepath, ...)
    else
        new = _dxCreateShader(filepath, ...)
    end

    if new then
        table.insert(stuff, {"shader", new})
        return new
    end

    return false
end

function dxCreateTexture(filepath, ...)
    local new = _dxCreateTexture("storage/" .. stuff.mapName .. "/" .. filepath, ...)

    if new then
        table.insert(stuff, {"texture", new})
        return new
    end

    return false
end

function engineLoadTXD(txd_file, ...)
    local new = _engineLoadTXD("storage/" .. stuff.mapName .. "/" .. txd_file, ...)

    if new then
        table.insert(stuff, {"txd", new})
        return new
    end

    return false
end

function engineLoadDFF(dff_file, ...)
    local new = _engineLoadDFF("storage/" .. stuff.mapName .. "/" .. dff_file, ...)

    if new then
        table.insert(stuff, {"dff", new})
        return new
    end

    return false
end

function engineLoadCOL(col_file, ...)
    local new = _engineLoadCOL("storage/" .. stuff.mapName .. "/" .. col_file, ...)

    if new then
        table.insert(stuff, {"col", new})
        return new
    end

    return false
end

function playSound(soundPath, ...)
    local new = _playSound("storage/" .. stuff.mapName .. "/" .. soundPath, ...)

    if new then
        table.insert(stuff, {"sound", new})
        return new
    end

    return false
end

-- Funções excluídas
function triggerServerEvent(...)
    return false
end

-- Funções do loader
function requestMapFiles(gameId)
    _triggerServerEvent("loader:requestFiles", resourceRoot, gameId)
end

function loadMapFiles(scripts)
    if #scripts > 0 then
        for i, v in pairs(scripts) do
            if string.find(v.path, ".lua") then
                local file = fileOpen("storage/" .. v.path)

                if file then
                    local content = fileRead(file, fileGetSize(file))

                    if content then
                        local str = loadstring(content)

                        if str then
                            pcall(str)
                            setfenv(str, stuff.sandbox)
                        end
                    end

                    fileClose(file)
                end
            end
        end
    end
end

function deleteCorruptedFiles(data)
    for i, v in pairs(data) do
        if fileExists("storage/" .. v[2]) then
            fileDelete("storage/" .. v[2])
        end
    end
end

-- Eventos
addEvent("loader:createMapStuff", true)
_addEventHandler("loader:createMapStuff", resourceRoot, function(objects, markers, peds, hashes, mapName, gameId, mapTime, mapWeather)
    -- Atribuir valores à tabela
    stuff = {}
    stuff.mapName = mapName
    stuff.gameId = gameId
    stuff.sandbox = {}

    -- Weather
    setTime(mapTime, 0)
    setWeather(mapWeather)

    -- Carregar coisas do mapa
    if #objects > 0 then
        for i, v in pairs(objects) do
            local object = createObject(tonumber(v.model), tonumber(v.posX), tonumber(v.posY), tonumber(v.posZ))

            if object then
                setObjectScale(object, tonumber(v.scale))
                setElementAlpha(object, tonumber(v.alpha))
                setElementRotation(object, tonumber(v.rotX), tonumber(v.rotY), tonumber(v.rotZ))

                if tostring(v.collisions) == "false" then
                    setElementCollisionsEnabled(object, false)
                end

                if tostring(v.doublesided) == "true" then
                    setElementDoubleSided(object, true)
                end
            end
        end
    end

    if #markers > 0 then
        for i, v in pairs(markers) do
            local marker = createMarker(tonumber(v.posX), tonumber(v.posY), tonumber(v.posZ))

            if marker then
                setMarkerType(marker, tostring(v.type))
                setMarkerSize(marker, tonumber(v.size))
                setMarkerColor(marker, getColorFromString(v.color))
                setElementAlpha(marker, tonumber(v.alpha))
                setElementRotation(marker, tonumber(v.rotX), tonumber(v.rotY), tonumber(v.rotZ))
            end
        end 
    end

    --[[if #peds > 0 then
        for i, v in pairs(peds) do
            local ped = createPed(tonumber(v.model), tonumber(v.posX), tonumber(v.posY), tonumber(v.posZ))

            if ped then
                setElementAlpha(ped, tonumber(v.alpha))
                setElementRotation(ped, tonumber(v.rotX), tonumber(v.rotY), tonumber(v.rotZ))
            end
        end 
    end]]

    -- Verificar hashes
    local wrongStuff = {}

    for i, v in pairs(hashes) do
        if fileExists("storage/" .. v.path) then
            local file = fileOpen("storage/" .. v.path)

            if file then
                local contentHash = md5(fileRead(file, fileGetSize(file)))

                if v.hash ~= contentHash then
                    table.insert(wrongStuff, {v.hash, v.path})
                end

                fileClose(file)
            end
        else
            table.insert(wrongStuff, {v.hash, v.path})
        end
    end

    if #wrongStuff > 0 then
        deleteCorruptedFiles(wrongStuff)
        requestMapFiles(gameId)
    else
        loadMapFiles(hashes)
    end
end)

addEvent("loader:removeMapStuff", true)
_addEventHandler("loader:removeMapStuff", resourceRoot, function()
    if #stuff > 0 then
        for i, v in pairs(stuff) do
            if v[1] and type(v[1]) == "string" then
                if v[1] == "object" and isElement(v[2]) then
                    destroyElement(v[2])
                elseif v[1] == "marker" and isElement(v[2]) then
                    destroyElement(v[2])
                elseif v[1] == "ped" and isElement(v[2]) then
                    destroyElement(v[2])
                elseif v[1] == "timer" and isTimer(v[2]) then
                    killTimer(v[2])
                elseif v[1] == "event" and type(v[2][3]) == "function" then
                    removeEventHandler(v[2][1], v[2][2], v[2][3])
                elseif v[1] == "txd" and isElement(v[2]) then
                    destroyElement(v[2])
                elseif v[1] == "dff" and isElement(v[2]) then
                    destroyElement(v[2])
                elseif v[1] == "col" and isElement(v[2]) then
                    destroyElement(v[2])
                elseif v[1] == "sound" and isElement(v[2]) then
                    destroyElement(v[2])
                end
            end
        end
    end

    resetFarClipDistance()
    resetFogDistance()
    resetHeatHaze()
    resetMoonSize()
    resetRainLevel()
    resetSkyGradient()
    resetSunColor()
    resetSunSize()
    resetWaterColor()
    resetWaterLevel()
    resetWindVelocity()
    restoreAllWorldModels()

    setTime(12, 0)
    setWeather(0)
    setGameSpeed(1)
    setGravity(0.008)
end)

addEvent("loader:sendFiles", true)
_addEventHandler("loader:sendFiles", resourceRoot, function(scripts, files)
    if #scripts > 0 then
        for i, v in pairs(scripts) do
            if not fileExists("storage/" .. v.path) then
                local file = fileCreate("storage/" .. v.path)

                if file then
                    local write = fileWrite(file, v.content)

                    if write then
                        fileClose(file)
                    end
                end
            end
        end
    end
    if #files > 0 then
        for i, v in pairs(files) do
            if not fileExists("storage/" .. v.path) then
                local file = fileCreate("storage/" .. v.path)

                if file then
                    local write = fileWrite(file, v.content)

                    if write then
                        fileClose(file)
                    end
                end
            end
        end
    end

    loadMapFiles(scripts)
end)