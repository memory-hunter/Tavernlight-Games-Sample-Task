local jumpieWindow
local jumpieButton
local jumpieInsideButton
local windowWidth
local windowHeight
local windowX
local windowY
local buttonWidth
local buttonHeight
local minClampX
local maxClampX
local minClampY
local maxClampY
local delay = 200
local speed = 10

function init()
    jumpieWindow = g_ui.displayUI('jumpie')
    jumpieInsideButton = jumpieWindow:getChildById('jumpieInsideButton')
    jumpieWindow:hide()

    jumpieButton = modules.client_topmenu.addRightGameToggleButton('jumpieButton', tr('Jumpie'), '/images/topbuttons/jumpie', toggleJumpie)
    jumpieButton:setOn(false)

end

function terminate()
    jumpieButton:destroy()
    jumpieButton = nil

    jumpieWindow:destroy()
    jumpieWindow = nil
end

function toggleJumpie()
    if jumpieWindow:isVisible() then
        jumpieWindow:hide()
        jumpieButton:setOn(false)
    else
        jumpieWindow:show()
        jumpieButton:setOn(true)
        placeButtonRandomly()
        moveButtonToLeft()
    end
end

function moveButtonToLeft()
    local x = jumpieInsideButton:getX()
    jumpieInsideButton:setX(x - speed)
    if jumpieInsideButton:getX() < minClampX then
        jumpieInsideButton:setX(maxClampX)
    end
    if jumpieWindow:isVisible() then
        scheduleEvent(moveButtonToLeft, delay)
    end
end

function placeButtonRandomly()
    updatePositionValues()
    local randomY = math.random(minClampY, maxClampY)
    jumpieInsideButton:setPosition({x = maxClampX, y = randomY})
    return true
end

function updatePositionValues()
    windowWidth = jumpieWindow:getWidth()
    windowHeight = jumpieWindow:getHeight()
    windowX = jumpieWindow:getX()
    windowY = jumpieWindow:getY()
    buttonWidth = jumpieInsideButton:getWidth()
    buttonHeight = jumpieInsideButton:getHeight()
    
    minClampX = windowX + 16
    maxClampX = windowX + windowWidth - buttonWidth - 16
    minClampY = windowY + 36
    maxClampY = windowY + windowHeight - buttonHeight - 16
end