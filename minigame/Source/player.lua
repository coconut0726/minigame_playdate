import "CoreLibs/object"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:new(x, y, image)
    local obj = Player.super.new(self)
    obj:moveTo(x, y)
    obj:setImage(image)

    obj.moveSpeed = 10
    obj.projectileSpeed = 1

    return obj
end

function Player:update()
    Player.super.update(self)
    print("Player update called")

    if pd.buttonIsPressed(pd.kButtonLeft) then
        self:moveBy(-self.moveSpeed, 0)
        print("Left button pressed")

    elseif pd.buttonIsPressed(pd.kButtonRight) then
        print("Right button pressed")
        self:moveBy(self.moveSpeed, 0)
    end
end
