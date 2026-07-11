local mx = 4
local my = 0
local yAcceleration = 1
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY
local fruitSets = {}

function OnInitialise()
    if self.customBehaviourData.HasField("fruitSets") then
        local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end

    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldFloat("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldFloat("smokeTrailPosY", 0)
end

function OnTick()
    self.movement = { x = mx * 1.35, y = my / 16, z = 0 }
    if self.lifetime < 370 then mx = mx - 0.013 elseif self.lifetime > 545 then mx = mx + 0.005 end
    my = my + yAcceleration
    if my > 30.0 then yAcceleration = -1.0 end
    if my < -30.0 then yAcceleration = 1.0 end

	-- Smoke ring every 26 frames when not retreating fast
    if smokeTrailEntity ~= "" and self.lifetime % 26 == 0 and mx > -0.5 then
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 2)
        smokeArgs.AddFieldInt("layer", 1)
        smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
        SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
    end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.position.x > AdjustXToWideScreen(750) then self.Deactivate() end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    self.SpawnShipShards(40, -9, 3, -15, 5, 0, 0, 2, 2, 2, 2)
    self.SpawnShipDebris(4, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
end

function CanFire()
    return self.lifetime >= 160
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x > 110
end
