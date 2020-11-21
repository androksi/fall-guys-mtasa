-- Custom Objects
local spinning = createObject(3458, 3647.8000488281, -1039, 1.7000000476837)
local chinese = createObject(3533, 3811, -1039.0999755859, 8.1000003814697)

-- Custom Objects Settings
local spinningRotation = 0
local spinningVelocity = 0.2

local chineseDefaultPosition = Vector3(getElementPosition(chinese))
local chineseTargetPosition = Vector3(3842.1999511719, -1039.0999755859, 8.1000003814697)

function start()
    chineseGo()
end

function chineseGo()
    moveObject(chinese, 10000, chineseTargetPosition.x, chineseTargetPosition.y, chineseTargetPosition.z)
    setTimer(chineseBack, 13000, 1)
end

function chineseBack()
    moveObject(chinese, 10000, chineseDefaultPosition.x, chineseDefaultPosition.y, chineseDefaultPosition.z)
    setTimer(chineseGo, 13000, 1)
end

addEventHandler("onClientRender", root, function()
    -- Spinning
    spinningRotation = spinningRotation + spinningVelocity

    if isElement(spinning) then
        setElementRotation(spinning, 0, 0, spinningRotation)
    end
end)

setTimer(start, 3000, 1)