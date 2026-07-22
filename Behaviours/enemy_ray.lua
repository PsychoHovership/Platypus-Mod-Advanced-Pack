local my = 0
local yAcceleration = 0
local direction
local spriteIndex = 0
local splashed = false
local mathSign = 0
local fruitSets = {}

function OnInitialise()
    if self.customBehaviourData.HasField("fruitSets") then
        local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end

    direction = self.commandArgs.GetFieldInt("direction", 0)
    if direction == 0 then yAcceleration = math.random(1, 2) == 1 and -0.0001 or 0.0001
    elseif direction == 1 then yAcceleration = -0.0001
    elseif direction == 2 then yAcceleration = 0.0001
    end
end

function OnTick()
    if Globals.createSplashes and not splashed and self.position.y <= -580 then
        self.CreateFancySplashes()
        splashed = true
    end
    self.movement = { x = -4, y = -my, z = 0 }
    my = my + yAcceleration
    if my > 0 then mathSign = 1 elseif my < 0 then mathSign = -1 else mathSign = 0 end 
    if yAcceleration < 0.1 and yAcceleration > -0.1 then yAcceleration = yAcceleration * 1.05 end

    if math.abs(my * 0.02) > math.abs(3) then
        local spriteCounter = Round(4 * (18 / self.animator.totalFrames))
        if self.lifetime % spriteCounter == 0 then spriteIndex = spriteIndex + my <= 0 and 1 or -1 end
    else spriteIndex = Round(math.pi * -8 * math.pow(math.abs(my * 0.02), 1.5) % 1 * self.animator.totalFrames * mathSign) end

    spriteIndex = (spriteIndex + self.animator.totalFrames) % self.animator.totalFrames
    self.animator.GoTo(spriteIndex)

    if self.position.x < -50 then self.Deactivate() end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(4, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x <= 640
end
