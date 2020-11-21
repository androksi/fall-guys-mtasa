local firstGate = createObject(7657, 3613.6000976563, -1511.3000488281, 5.3000001907349)
local secondGate = createObject(7657, 3639.8000488281, -1511.3000488281, 5.3000001907349)

local firstCrate = createObject(3798, 3671.1955566406, -1516.4547119141, 7.80016040802)
local secondCrate = createObject(3798, 3691.1960449219, -1516.4543457031, 7.80016040802)
local thirdCrate = createObject(3798, 3711.1960449219, -1516.4543457031, 7.80016040802)

local firstWall = createObject(6959, 3846.3999023438, -1511.5, 16.799999237061)

local firstSpinner = createObject(982, 3893.3999023438, -1494.4000244141, 13.499999809265)
local secondSpinner = createObject(982, 3887, -1529.1999511719, 13.499999809265)
local thirdSpinner = createObject(982, 3909.5, -1514, 13.499999809265)
local fourthSpinner = createObject(982, 3936.3999023438, -1514.3000488281, 13.499999809265)

-- firstGate settings
local firstGateSpeed = 10000
local firstGateOriginalPosition = Vector3(getElementPosition(firstGate))
local firstGateTargetPosition = Vector3(3636.3999023438, -1511.3000488281, 5.3000001907349)

setElementRotation(firstGate, 270, 0, 270)

-- secondGate settings
local secondGateSpeed = 3000
local secondGateOriginalPosition = Vector3(getElementPosition(secondGate))
local secondGateTargetPosition = Vector3(3660.8999023438, -1511.3000488281, 5.3000001907349)

setElementRotation(secondGate, 270, 0, 270)

-- firstCrate settings
local firstCrateSpeed = 1000
local firstCrateOriginalPosition = Vector3(getElementPosition(firstCrate))
local firstCrateTargetPosition = Vector3(3671.1999511719, -1511.3000488281, 7.8000001907349)

setElementRotation(firstCrate, 270, 270, 0)
setObjectScale(firstCrate, 1)
setElementCollisionsEnabled(firstCrate, true)
setObjectBreakable(firstCrate, false)
setObjectMass(firstCrate, 999)

-- secondCrate settings
local secondCrateSpeed = 2000
local secondCrateOriginalPosition = Vector3(getElementPosition(secondCrate))
local secondCrateTargetPosition = Vector3(3691.1999511719, -1511.3000488281, 7.8000001907349)

setElementRotation(secondCrate, 270, 270, 0)
setObjectScale(secondCrate, 1)
setElementCollisionsEnabled(secondCrate, true)
setObjectBreakable(secondCrate, false)
setObjectMass(secondCrate, 999)

-- thirdCrate settings
local thirdCrateSpeed = 500
local thirdCrateOriginalPosition = Vector3(getElementPosition(thirdCrate))
local thirdCrateTargetPosition = Vector3(3711.1999511719, -1511.3000488281, 7.8000001907349)

setElementRotation(thirdCrate, 270, 270, 0)
setObjectScale(thirdCrate, 1)
setElementCollisionsEnabled(thirdCrate, true)
setObjectBreakable(thirdCrate, false)
setObjectMass(thirdCrate, 999)

-- firstWall settings
local firstWallSpeed = 5000
local firstWallOriginalPosition = Vector3(getElementPosition(firstWall))
local firstWallTargetPosition = Vector3(3846.3999023438, -1511.5, -5.8000001907349)

setElementRotation(firstWall, 0, 90, 0)

-- firstSpinner settings
local firstSpinnerRotation = 0
local firstSpinnerSpeed = 0.4

setElementCollisionsEnabled(firstSpinner, true)
setObjectBreakable(firstSpinner, false)
setObjectMass(firstSpinner, 999)

-- secondSpinner settings
local secondSpinnerRotation = 0
local secondSpinnerSpeed = 0.6

setElementCollisionsEnabled(secondSpinner, true)
setObjectBreakable(secondSpinner, false)
setObjectMass(secondSpinner, 999)

-- thirdSpinner settings
local thirdSpinnerRotation = 0
local thirdSpinnerSpeed = 0.8

setElementCollisionsEnabled(thirdSpinner, true)
setObjectBreakable(thirdSpinner, false)
setObjectMass(thirdSpinner, 999)

-- fourthSpinner settings
local fourthSpinnerRotation = 0
local fourthSpinnerSpeed = 1.0

setElementCollisionsEnabled(fourthSpinner, true)
setObjectBreakable(fourthSpinner, false)
setObjectMass(fourthSpinner, 999)

function start()
    firstGateGo()
    secondGateGo()
    firstCrateGo()
    secondCrateGo()
    thirdCrateGo()
    firstWallGo()
    spinnersStart()
end

-- firstGate functions
function firstGateGo()
    moveObject(firstGate, firstGateSpeed, firstGateTargetPosition.x, firstGateTargetPosition.y, firstGateTargetPosition.z)
    setTimer(firstGateBack, firstGateSpeed + 2000, 1)
end

function firstGateBack()
    moveObject(firstGate, firstGateSpeed, firstGateOriginalPosition.x, firstGateOriginalPosition.y, firstGateOriginalPosition.z)
    setTimer(firstGateGo, firstGateSpeed + 2000, 1)
end

-- secondGate functions
function secondGateGo()
    moveObject(secondGate, secondGateSpeed, secondGateTargetPosition.x, secondGateTargetPosition.y, secondGateTargetPosition.z)
    setTimer(secondGateBack, secondGateSpeed + 2000, 1)
end

function secondGateBack()
    moveObject(secondGate, secondGateSpeed, secondGateOriginalPosition.x, secondGateOriginalPosition.y, secondGateOriginalPosition.z)
    setTimer(secondGateGo, secondGateSpeed + 2000, 1)
end

-- firstCrate functions
function firstCrateGo()
    moveObject(firstCrate, firstCrateSpeed, firstCrateTargetPosition.x, firstCrateTargetPosition.y, firstCrateTargetPosition.z)
    setTimer(firstCrateBack, firstCrateSpeed + 2000, 1)
end

function firstCrateBack()
    moveObject(firstCrate, firstCrateSpeed, firstCrateOriginalPosition.x, firstCrateOriginalPosition.y, firstCrateOriginalPosition.z)
    setTimer(firstCrateGo, firstCrateSpeed + 2000, 1)
end

-- secondCrate functions
function secondCrateGo()
    moveObject(secondCrate, secondCrateSpeed, secondCrateTargetPosition.x, secondCrateTargetPosition.y, secondCrateTargetPosition.z)
    setTimer(secondCrateBack, secondCrateSpeed + 2000, 1)
end

function secondCrateBack()
    moveObject(secondCrate, secondCrateSpeed, secondCrateOriginalPosition.x, secondCrateOriginalPosition.y, secondCrateOriginalPosition.z)
    setTimer(secondCrateGo, secondCrateSpeed + 2000, 1)
end

-- thirdCrate functions
function thirdCrateGo()
    moveObject(thirdCrate, thirdCrateSpeed, thirdCrateTargetPosition.x, thirdCrateTargetPosition.y, thirdCrateTargetPosition.z)
    setTimer(thirdCrateBack, thirdCrateSpeed + 2000, 1)
end

function thirdCrateBack()
    moveObject(thirdCrate, thirdCrateSpeed, thirdCrateOriginalPosition.x, thirdCrateOriginalPosition.y, thirdCrateOriginalPosition.z)
    setTimer(thirdCrateGo, thirdCrateSpeed + 2000, 1)
end

-- firstWall functions
function firstWallGo()
    moveObject(firstWall, firstWallSpeed, firstWallTargetPosition.x, firstWallTargetPosition.y, firstWallTargetPosition.z)
    setTimer(firstWallBack, firstWallSpeed + 2000, 1)
end

function firstWallBack()
    moveObject(firstWall, firstWallSpeed, firstWallOriginalPosition.x, firstWallOriginalPosition.y, firstWallOriginalPosition.z)
    setTimer(firstWallGo, firstWallSpeed + 2000, 1)
end

function spinnersStart()
    addEventHandler("onClientRender", root, rotateSpinners)
end

function rotateSpinners()
    firstSpinnerRotation = firstSpinnerRotation + firstSpinnerSpeed
    secondSpinnerRotation = secondSpinnerRotation + secondSpinnerSpeed
    thirdSpinnerRotation = thirdSpinnerRotation + thirdSpinnerSpeed
    fourthSpinnerRotation = fourthSpinnerRotation + fourthSpinnerSpeed

    setElementRotation(firstSpinner, 0, 0, firstSpinnerRotation)
    setElementRotation(secondSpinner, 0, 0, secondSpinnerRotation)
    setElementRotation(thirdSpinner, 0, 0, thirdSpinnerRotation)
    setElementRotation(fourthSpinner, 0, 0, fourthSpinnerRotation)
end

--[[addEvent("objects:start", true)
addEventHandler("objects:start", root, function()
    start()
end)]]

addEventHandler("onClientResourceStart", resourceRoot, function()
    start()
end)