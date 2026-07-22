local mx = 0
local my = 0
local focusX
local focusY
local baseAcceleration
local focusAcceleration
local movementThreshold
local hangtime
local invulnTime
local firstShotDelay
local backSprite
local backOffX
local backOffY
local backSortOrder
local backAnimator
local fruitSets = {}

function OnInitialise()
    if self.commandArgs.HasField("fruitSets") then
        local f = self.commandArgs.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else
        if self.customBehaviourData.HasField("fruitSets") then
            local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
            for i = 1, #f do fruitSets[i] = f[i] or 0 end
        else fruitSets = nil end
    end

    focusX = self.commandArgs.GetFieldFloat("focus_x", 500)
    focusY = -self.commandArgs.GetFieldFloat("focus_y", 240)
    baseAcceleration = self.customBehaviourData.GetFieldFloat("baseAcceleration", 0)
    focusAcceleration = self.customBehaviourData.GetFieldFloat("focusAcceleration", 0)
    movementThreshold = self.customBehaviourData.GetFieldFloat("movementThreshold", 0)
    hangtime = self.customBehaviourData.GetFieldInt("hangtime", 900)
    invulnTime = self.customBehaviourData.GetFieldInt("invulnTime", 0)
    firstShotDelay = self.customBehaviourData.GetFieldInt("firstShotDelay", 0)

    backSprite = self.customBehaviourData.GetFieldString("backSprite", "")
    backOffX = self.customBehaviourData.GetFieldFloat("backOffX", 0)
    backOffY = self.customBehaviourData.GetFieldFloat("backOffY", 0)
    backSortOrder = self.customBehaviourData.GetFieldInt("backSortOrder", -1)
    if backSprite ~= "" then
        backAnimator = self.SpawnAttachedSpriteAnimator(backSprite, backSortOrder)
        backAnimator.position = { x = backOffX, y = backOffY }
    end
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }
    mx = mx + RandRangeF(-baseAcceleration, baseAcceleration)
    my = my + RandRangeF(-baseAcceleration, baseAcceleration)

    if self.position.x > focusX and mx > -movementThreshold then mx = mx - focusAcceleration end
    if self.position.x < focusX and mx < movementThreshold then mx = mx + focusAcceleration end
    if self.position.y > focusY and my > -movementThreshold then my = my - focusAcceleration end
    if self.position.y < focusY and my < movementThreshold then my = my + focusAcceleration end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)
    if backSprite ~= "" then
        local backFrame = math.floor(backAnimator.totalFrames * backAnimator.timePerFrame)
        local backIndex = self.lifetime % backFrame / backFrame * backAnimator.totalFrames
        backAnimator.enabled = backIndex ~= backAnimator.totalFrames
        if backAnimator.enabled then backAnimator.GoTo(math.floor(backIndex)) end
    end

    if self.lifetime > hangtime then
        focusX = -1000
        if self.position.x < -200 then self.Deactivate() end
    end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    self.SpawnShipShards(30, -9, 3, -15, 5, 0, 0, 2, 2, 2, 2)
    self.SpawnShipDebris(3, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
end

function CanFire()
    return self.lifetime > firstShotDelay
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.lifetime > invulnTime
end
