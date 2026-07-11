local mx
local wakeSprite
local wakePosX
local wakePosY
local wakeAnimator
local fruitSets = {}

function OnInitialise()
    if self.customBehaviourData.HasField("fruitSets") then
        local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end

    mx = self.commandArgs.GetFieldFloat("speed", 0.3)
    wakeSprite = self.customBehaviourData.GetFieldString("wakeSprite", "")
    wakePosX = self.customBehaviourData.GetFieldFloat("wakePosX", 0)
    wakePosY = self.customBehaviourData.GetFieldFloat("wakePosY", 0)

    if wakeSprite ~= "" then
        if mx > -2.5 then
            wakeAnimator = self.SpawnAttachedSpriteAnimator(wakeSprite, 1)
            wakeAnimator.position = { x = wakePosX, y = wakePosY }
            wakeAnimator.LoopAnimation()
        end
    end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.position.x < AdjustXToWideScreen(-200) or self.position.x > AdjustXToWideScreen(850) then self.Deactivate() end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    self.SpawnShipShards(40, -6, 0, -15, 5, 30, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(40, -12, 8, -22, 5, 0, 40, 2, 6, 2, 6)

    SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 20, y = self.worldPosition.y })
    SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 80, y = self.worldPosition.y })
end

function CanFire()
    return self.position.x >= 154.5 and mx > 0 or self.position.x <= 770.5 and mx < 0
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x > -50 or mx <= 0
end
