import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

local playerSprite
local screenWidth = 400
local screenHeight = 240

local playerX, playerY = 200, 200
local score = 0

local initialFallSpeed = 2
local fallSpeedIncrement = 0.2

local windSprite

local function initialize()
    local playerImage = gfx.image.new("images/player0")
    if not playerImage then
        print("Failed to load player image.")
        return
    end

    playerSprite = gfx.sprite.new(playerImage)
    if not playerSprite then
        print("Failed to create player sprite.")
        return
    end

    playerSprite:moveTo(playerX, playerY)
    playerSprite:setImage(playerImage)
    playerSprite.moveSpeed = 10
    playerSprite:add()
end

initialize()

local hairSprites = {}
local currentFallSpeed = initialFallSpeed

local function createHairSprite()
    local hairImage = gfx.image.new("images/hair")
    local startX = math.random(0, screenWidth)

    local hairSprite = gfx.sprite.new(hairImage)
    hairSprite:moveTo(startX, 0)
    hairSprite:add()

    hairSprite.fallSpeed = currentFallSpeed
    table.insert(hairSprites, {sprite = hairSprite, x = startX, y = 0})
end

createHairSprite()

local hairTimer = pd.timer.keyRepeatTimerWithDelay(3500, 3500, function()
    createHairSprite()
    currentFallSpeed = currentFallSpeed + fallSpeedIncrement
end)

local function checkOverlap(hair)
    local playerX, playerY, playerWidth, playerHeight = playerSprite:getBounds()
    local hairX, hairY, hairWidth, hairHeight = hair.sprite:getBounds()

    local overlapX = playerX < hairX + hairWidth and playerX + playerWidth > hairX
    local overlapY = playerY < hairY + hairHeight and playerY + playerHeight > hairY

    return overlapX and overlapY
end

local function drawScore()
    gfx.setFont(gfx.getSystemFont())  -- 使用默认字体
    gfx.drawText("Score: " .. tostring(score), 10, 10)
end

local function showWindSprite(position, isLeft)
    if not windSprite then
        local windImage
        if isLeft then
            windImage = gfx.image.new("images/windLeft")  -- 左侧风的图像
            position = position + 30  -- 向内移动一点
        else
            windImage = gfx.image.new("images/windRight")  -- 右侧风的图像
            position = position - 30  -- 向内移动一点
        end

        windSprite = gfx.sprite.new(windImage)
        windSprite:moveTo(position, screenHeight / 2)  -- 在画布左侧或右侧正中位置
        windSprite:add()
    else
        windSprite:moveTo(position, screenHeight / 2)  -- 移动风的精灵到新位置
    end

    pd.timer.performAfterDelay(200, function()
        if windSprite then
            windSprite:setVisible(false)  -- 让精灵不可见
        end
    end)
end

function playdate.update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    if pd.buttonIsPressed(pd.kButtonLeft) then
        playerX = playerX - playerSprite.moveSpeed
        playerSprite:moveTo(playerX, playerY)
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        playerX = playerX + playerSprite.moveSpeed
        playerSprite:moveTo(playerX, playerY)
    end

    if playerX < 0 then
        playerX = 0
        playerSprite:moveTo(playerX, playerY)
    elseif playerX > screenWidth then
        playerX = screenWidth
        playerSprite:moveTo(playerX, playerY)
    end

    -- 获取摇杆的变化量
    local crankChange = playdate.getCrankChange()
    local crankSpeed = crankChange / 10  -- 将旋转速度调整为一个合适的范围

    for i = #hairSprites, 1, -1 do
        local hair = hairSprites[i]
        hair.y = hair.y + hair.sprite.fallSpeed
        hair.sprite:moveTo(hair.x, hair.y)

        -- 根据摇动方向和速度调整hair的x坐标
        hair.x = hair.x + crankSpeed  -- 根据变化量偏移
        hair.sprite:moveTo(hair.x, hair.y)  -- 更新hair的坐标

        if checkOverlap(hair) then
            score = score + 1
            hair.sprite:remove()
            table.remove(hairSprites, i)
        end

        if hair.y > screenHeight then
            hair.sprite:remove()
            table.remove(hairSprites, i)
        end
    end

    drawScore()

    -- 根据摇动方向显示风的精灵
    if crankChange > 0 then
        showWindSprite(0, true)  -- 顺时针摇动，在左侧显示风的精灵
    elseif crankChange < 0 then
        showWindSprite(screenWidth, false)  -- 逆时针摇动，在右侧显示风的精灵
    else
        if windSprite then
            windSprite:setVisible(false)  -- 停止摇动时让风的精灵不可见
        end
    end
end
