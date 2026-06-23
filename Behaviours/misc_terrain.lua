local mx
local my

function OnInitialise()
    if self.commandArgs.HasField("speedX") then mx = self.commandArgs.GetFieldFloat("speedX") else mx = -3
    end
    if self.commandArgs.HasField("speedY") then my = self.commandArgs.GetFieldFloat("speedY") else my = 0
    end
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }

    if self.position.x < -500 then
        self.Deactivate()
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
