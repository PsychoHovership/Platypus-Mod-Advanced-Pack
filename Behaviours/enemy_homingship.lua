local mx
local firePattern
local fireSFX
local topMissileOffX
local topMissileOffY
local bottomMissileOffX
local bottomMissileOffY
local smokeTrailCounter = 0
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY

function OnInitialise()
    if self.commandArgs.HasField("fruit_set") then self.fruitSet = self.commandArgs.GetFieldInt("fruit_set") else
        if self.customBehaviourData.HasField("fruitSet") then self.fruitSet = self.customBehaviourData.GetFieldInt("fruitSet") end
    end
    mx = self.commandArgs.GetFieldFloat("mx", -5.5)
    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    topMissileOffX = self.customBehaviourData.GetFieldFloat("topMissileOffX", 0)
    topMissileOffY = self.customBehaviourData.GetFieldFloat("topMissileOffY", 0)
    bottomMissileOffX = self.customBehaviourData.GetFieldFloat("bottomMissileOffX", 0)
    bottomMissileOffY = self.customBehaviourData.GetFieldFloat("bottomMissileOffY", 0)
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldFloat("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldFloat("smokeTrailPosY", 0)
end

function OnTick()
    self.movement = { x = mx * 1.25, y = 0, z = 0 }
    if mx < 1 then mx = mx + 0.02 end

    smokeTrailCounter = smokeTrailCounter + 1
    if smokeTrailCounter > 45 - mx * 10 and mx > 0 then
        smokeTrailCounter = 0
        if smokeTrailEntity ~= "" then
            local smokeArgs = NewJSONObject()
            smokeArgs.AddFieldFloat("mx", 2)
            smokeArgs.AddFieldInt("layer", 1)
            smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
            SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
        end
    end

    if CanFire() then
        firePattern.Tick()
        if firePattern.CanFire() then
            firePattern.MarkFired()
            local missileArgs1 = NewJSONObject()
            local missileArgs2 = NewJSONObject()
            missileArgs1.AddFieldInt("homingDelay", 30)
            missileArgs1.AddFieldInt("currentAngle", -40)
            missileArgs1.AddFieldInt("var5", math.random(0, 360))
            missileArgs2.AddFieldInt("homingDelay", 30)
            missileArgs2.AddFieldInt("currentAngle", 40)
            missileArgs2.AddFieldInt("var5", math.random(0, 360))
            SpawnEntityWorld("homingMissile", { x = self.worldPosition.x + topMissileOffX + mx * 5, y = self.worldPosition.y + topMissileOffY}, missileArgs1)
            SpawnEntityWorld("homingMissile", { x = self.worldPosition.x + bottomMissileOffX + mx * 5, y = self.worldPosition.y + bottomMissileOffY}, missileArgs2)
            if fireSFX ~= "" then PlaySound(fireSFX) end
        end
    end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.position.x > AdjustXToWideScreen(750) then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(80, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
    self.SpawnShipDebris(4, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
end

function CanFire()
    return self.lifetime >= 120
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
