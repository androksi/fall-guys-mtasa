local loader = {}
local playerDownload = {}

function loadMap(gameId, mapName)
    local metaXml = xmlLoadFile(":" .. mapName .. "/meta.xml")

    if metaXml then
        loader[gameId] = {
            objects = {},
            markers = {},
            peds = {},
            scripts = {},
            files = {},
            hashes = {},
            mapName = mapName,
            mapTime = 12,
            mapWeather = 0
        }

        local settings = xmlFindChild(metaXml, "settings", 0)

        if settings then
            for _, node in pairs(xmlNodeGetChildren(settings)) do
                local name = xmlNodeGetAttribute(node, "name")
                local value = xmlNodeGetAttribute(node, "value")

                if name == "#time" then
                    loader[gameId].mapTime = string.match(value, "(%d+):(%d+)")
                elseif name == "#weather" then
                    loader[gameId].mapWeather = string.match(value, "(%d+)")
                end
            end
        end

        local children = xmlNodeGetChildren(metaXml)

        if children then
            for i, v in pairs(children) do
                local name = xmlNodeGetName(v)

                if name == "map" then
                    local src = xmlNodeGetAttribute(v, "src")

                    if src then
                        local mapFile = xmlLoadFile(":" .. mapName .. "/" .. src)

                        if mapFile then
                            local mapChildren = xmlNodeGetChildren(mapFile)

                            for _, node in pairs(mapChildren) do
                                local nodeName = xmlNodeGetName(node)

                                if nodeName == "object" then
                                    table.insert(loader[gameId].objects, {
                                        id = xmlNodeGetAttribute(node, "id") or "0",
                                        breakable = xmlNodeGetAttribute(node, "breakable") or "false",
                                        interior = xmlNodeGetAttribute(node, "interior") or 0,
                                        alpha = xmlNodeGetAttribute(node, "alpha") or 255,
                                        model = xmlNodeGetAttribute(node, "model") or 1337,
                                        doublesided = xmlNodeGetAttribute(node, "doublesided") or "false",
                                        scale = xmlNodeGetAttribute(node, "scale") or 1,
                                        dimension = xmlNodeGetAttribute(node, "dimension") or 0,
                                        collisions = xmlNodeGetAttribute(node, "collisions") or "true",
                                        posX = xmlNodeGetAttribute(node, "posX") or 0,
                                        posY = xmlNodeGetAttribute(node, "posY") or 0,
                                        posZ = xmlNodeGetAttribute(node, "posZ") or 0,
                                        rotX = xmlNodeGetAttribute(node, "rotX") or 0,
                                        rotY = xmlNodeGetAttribute(node, "rotY") or 0,
                                        rotZ = xmlNodeGetAttribute(node, "rotZ") or 0
                                    })
                                elseif nodeName == "marker" then
                                    table.insert(loader[gameId].markers, {
                                        id = xmlNodeGetAttribute(node, "id") or "0",
                                        type = xmlNodeGetAttribute(node, "type") or "cylinder",
                                        color = xmlNodeGetAttribute(node, "color") or "#ffb0d4",
                                        size = xmlNodeGetAttribute(node, "size") or 1,
                                        interior = xmlNodeGetAttribute(node, "interior") or 0,
                                        dimension = xmlNodeGetAttribute(node, "dimension") or 0,
                                        alpha = xmlNodeGetAttribute(node, "alpha") or 255,
                                        posX = xmlNodeGetAttribute(node, "posX") or 0,
                                        posY = xmlNodeGetAttribute(node, "posY") or 0,
                                        posZ = xmlNodeGetAttribute(node, "posZ") or 0,
                                        rotX = xmlNodeGetAttribute(node, "rotX") or 0,
                                        rotY = xmlNodeGetAttribute(node, "rotY") or 0,
                                        rotZ = xmlNodeGetAttribute(node, "rotZ") or 0
                                    })
                                elseif nodeName == "ped" then
                                    table.insert(loader[gameId].peds, {
                                        id = xmlNodeGetAttribute(node, "id") or "0",
                                        dimension = xmlNodeGetAttribute(node, "dimension") or 0,
                                        model = xmlNodeGetAttribute(node, "model") or 0,
                                        interior = xmlNodeGetAttribute(node, "interior") or 0,
                                        rotZ = xmlNodeGetAttribute(node, "rotZ") or 0,
                                        alpha = xmlNodeGetAttribute(node, "alpha") or 255,
                                        posX = xmlNodeGetAttribute(node, "posX") or 0,
                                        posY = xmlNodeGetAttribute(node, "posY") or 0,
                                        posZ = xmlNodeGetAttribute(node, "posZ") or 0,
                                        rotX = xmlNodeGetAttribute(node, "rotX") or 0,
                                        rotY = xmlNodeGetAttribute(node, "rotY") or 0
                                    })
                                end
                            end

                            xmlUnloadFile(mapFile)
                        end
                    end
                elseif name == "script" then
                    local src = xmlNodeGetAttribute(v, "src")
                    local type = xmlNodeGetAttribute(v, "type")

                    if src and type == "client" then
                        local scriptFile = fileOpen(":" .. mapName .. "/" .. src)

                        if scriptFile then
                            local content = fileRead(scriptFile, fileGetSize(scriptFile))

                            if content then
                                table.insert(loader[gameId].scripts, {
                                    path = mapName .. "/" .. src,
                                    content = content
                                })
                                table.insert(loader[gameId].hashes, {
                                    path = mapName .. "/" .. src,
                                    hash = md5(content)
                                })
                            end

                            fileClose(scriptFile)
                        end
                    end
                elseif name == "file" then
                    local src = xmlNodeGetAttribute(v, "src")

                    if src then
                        local file = fileOpen(":" .. mapName .. "/" .. src)

                        if file then
                            local content = fileRead(file, fileGetSize(file))

                            if content then
                                table.insert(loader[gameId].files, {
                                    path = mapName .. "/" .. src,
                                    content = content
                                })
                                table.insert(loader[gameId].hashes, {
                                    path = mapName .. "/" .. src,
                                    hash = md5(content)
                                })
                            end

                            fileClose(file)
                        end
                    end
                end
            end
        end

        xmlUnloadFile(metaXml)
        return true
    end

    return false
end

function unloadMap(gameId)
    if loader[gameId] then
        loader[gameId] = nil
        collectgarbage()
    end
end

function createMap(player, gameId)
    if loader[gameId] then
        triggerLatentClientEvent(player, "loader:createMapStuff", 1024 * 1024 * 0.5, false, resourceRoot, loader[gameId].objects, loader[gameId].markers, loader[gameId].peds, loader[gameId].hashes, loader[gameId].mapName, gameId, loader[gameId].mapTime, loader[gameId].mapWeather)
    end
end

function removeMap(player)
    if isElement(player) then
        local handlers = getLatentEventHandles(player)

        if #handlers > 0 then
            for i = 1, #handlers do
                cancelLatentEvent(player, handlers[i])
            end
        end
    else
        for k, v in pairs(player) do
            local handlers = getLatentEventHandles(v)

            if #handlers > 0 then
                for i = 1, #handlers do
                    cancelLatentEvent(v, handlers[i])
                end
            end
        end
    end

    triggerClientEvent(player, "loader:removeMapStuff", resourceRoot)
end

function getMapSpawns(gameId)
    return loader[gameId].peds
end

function getMapFinishPoint(gameId)
    if #loader[gameId].markers > 0 then
        for i, v in pairs(loader[gameId].markers) do
            if tostring(v.type) == "corona" and tonumber(v.size) == 2 and tostring(v.color) == "#FFFFFFFF" then
                return loader[gameId].markers[i]
            end
        end
    end
end

addEvent("loader:requestFiles", true)
addEventHandler("loader:requestFiles", resourceRoot, function(gameId)
    if loader[gameId] then
        triggerLatentClientEvent(client, "loader:sendFiles", 1024 * 1024 * 1, false, resourceRoot, loader[gameId].scripts, loader[gameId].files)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if playerDownload[source] then
        playerDownload[source] = nil
    end

    removeMap(source)
end)