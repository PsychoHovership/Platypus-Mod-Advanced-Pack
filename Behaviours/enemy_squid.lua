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
local entityType
local bottomSprite
local bottomOffX
local bottomOffY
local bottomSortOrder
local bottomAnimator
local bottomCollider
local eyeSprite
local eyeOffX
local eyeOffY
local eyeSortOrder
local eyeAnimator
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

    focusX = self.commandArgs.GetFieldFloat("focus_x", 350)
    focusY = -self.commandArgs.GetFieldFloat("focus_y", 500)
    baseAcceleration = self.customBehaviourData.GetFieldFloat("baseAcceleration", 0)
    focusAcceleration = self.customBehaviourData.GetFieldFloat("focusAcceleration", 0)
    movementThreshold = self.customBehaviourData.GetFieldFloat("movementThreshold", 0)
    hangtime = self.customBehaviourData.GetFieldInt("hangtime", 0)
    invulnTime = self.customBehaviourData.GetFieldInt("invulnTime", 0)
    firstShotDelay = self.customBehaviourData.GetFieldInt("firstShotDelay", 0)
    entityType = self.customBehaviourData.GetFieldInt("entityType", 0)

    bottomSprite = self.customBehaviourData.GetFieldString("bottomSprite", "")
    bottomOffX = self.customBehaviourData.GetFieldFloat("bottomOffX", 0)
    bottomOffY = self.customBehaviourData.GetFieldFloat("bottomOffY", 0)
    bottomSortOrder = self.customBehaviourData.GetFieldInt("bottomSortOrder", -1)
    if bottomSprite ~= "" then
        bottomAnimator = self.SpawnAttachedSpriteAnimator(bottomSprite, bottomSortOrder)
        bottomAnimator.position = { x = bottomOffX, y = bottomOffY - (GetSpriteDimensions(self.animator.currentSheet, 0).y / 2) - (GetSpriteDimensions(bottomAnimator.currentSheet, 0).y / 2) }
        bottomAnimator.LoopAnimation()
        bottomCollider = bottomAnimator.AddCollider()
        bottomCollider = bottomAnimator.AddCollider()
    end
    eyeSprite = self.customBehaviourData.GetFieldString("eyeSprite", "")
    eyeOffX = self.customBehaviourData.GetFieldFloat("eyeOffX", 0)
    eyeOffY = self.customBehaviourData.GetFieldFloat("eyeOffY", 0)
    eyeSortOrder = self.customBehaviourData.GetFieldInt("eyeSprite", -2)
    if eyeSprite ~= "" then
        eyeAnimator = self.SpawnAttachedSpriteAnimator(eyeSprite, eyeSortOrder)
        eyeAnimator.position = { x = eyeOffX, y = eyeOffY }
        eyeAnimator.LoopAnimation()
    end
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0}
    mx = mx + (math.random() * (2 * baseAcceleration) - baseAcceleration)
    my = my + (math.random() * (2 * baseAcceleration) - baseAcceleration)

    if self.position.x > focusX and mx > -movementThreshold then mx = mx - focusAcceleration end
    if self.position.x < focusX and mx < movementThreshold then mx = mx + focusAcceleration end
    if self.position.y > focusY and my > -movementThreshold then my = my - focusAcceleration end
    if self.position.y < focusY and my < movementThreshold then my = my + focusAcceleration end

    self.CheckCollision(bottomCollider)
    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.lifetime > hangtime then
        focusX = -1000
        if self.position.x < -200 then self.Deactivate() end
    end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    if entityType == 1 then
        self.SpawnShipShards(80, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
        self.SpawnShipDebris(4, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
    else
        self.SpawnShipShards(40, -9, 3, -15, 5, 0, 0, 2, 2, 2, 2)
        self.SpawnShipDebris(4, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
    end
end

function CanFire()
    if entityType == 2 then
        if self.lifetime > firstShotDelay and self.lifetime < hangtime + 200 then return self.lifetime % 500 < 450 end
    else
        if self.lifetime > firstShotDelay then return self.position.x > 60 end
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.lifetime > invulnTime
end
