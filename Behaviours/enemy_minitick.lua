local mx = 0
local my = 0
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

    bottomSprite = self.customBehaviourData.GetFieldString("bottomSprite", "")
    bottomOffX = self.customBehaviourData.GetFieldFloat("bottomOffX", 0)
    bottomOffY = self.customBehaviourData.GetFieldFloat("bottomOffY", 0)
    bottomSortOrder = self.customBehaviourData.GetFieldInt("bottomSortOrder", -1)
    if bottomSprite ~= "" then
        bottomAnimator = self.SpawnAttachedSpriteAnimator(bottomSprite, bottomSortOrder)
        bottomAnimator.position = { x = bottomOffX, y = bottomOffY - (GetSpriteDimensions(self.animator.currentSheet, 0).y / 2) - (GetSpriteDimensions(bottomAnimator.currentSheet, 0).y / 2) }
        bottomAnimator.LoopAnimation()
        bottomCollider = bottomAnimator.AddCollider()
    end
    eyeSprite = self.customBehaviourData.GetFieldString("eyeSprite", "")
    eyeOffX = self.customBehaviourData.GetFieldFloat("eyeOffX", 0)
    eyeOffY = self.customBehaviourData.GetFieldFloat("eyeOffY", 0)
    eyeSortOrder = self.customBehaviourData.GetFieldInt("eyeSortOrder", -2)
    if eyeSprite ~= "" then
        eyeAnimator = self.SpawnAttachedSpriteAnimator(eyeSprite, eyeSortOrder)
        eyeAnimator.position = { x = eyeOffX, y = eyeOffY }
        eyeAnimator.LoopAnimation()
    end
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }
    if mx > -1.2 then mx = mx - 0.1 end
    my = math.sin(self.lifetime * 0.05)

    self.CheckCollision(bottomCollider)
    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.position.x < -200 then self.Deactivate() end
end

function OnHitByBullet()
    if self.position.x < 700 then mx = 1.5 end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    self.SpawnShipShards(40, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
    self.SpawnShipDebris(4, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
end

function CanFire()
    return self.position.x < 770
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.lifetime > 130
end
