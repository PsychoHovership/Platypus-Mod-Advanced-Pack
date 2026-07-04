local mx
local smokeTrailCounter = 0
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY
local expertTurretEntity
local expertTurretPosX
local expertTurretPosY

function OnInitialise()
    mx = self.data.speed
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldFloat("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldFloat("smokeTrailPosY", 0)
    expertTurretEntity = self.customBehaviourData.GetFieldString("expertTurretEntity", "")
    expertTurretPosX = self.customBehaviourData.GetFieldFloat("expertTurretPosX", 0)
    expertTurretPosY = self.customBehaviourData.GetFieldFloat("expertTurretPosY", 0)
    if Globals.difficulty > 1 then
        if expertTurretEntity ~= "" then CreateTurret(expertTurretEntity, expertTurretPosX, expertTurretPosY, self, Globals.firewait) end
    end
end

function OnTick()
    self.movement = { x = mx * 1.3 - 0.5, y = 0, z = 0 }
    if self.lifetime > 140 and self.lifetime < 430 then mx = mx - 0.015 elseif self.lifetime > 430 and self.lifetime < 700 then mx = mx + 0.015 end

    smokeTrailCounter = smokeTrailCounter + 1
    if smokeTrailCounter > 45 - mx * 10 and mx > -1 then
        smokeTrailCounter = 0
        if smokeTrailEntity ~= "" then
            local smokeArgs = NewJSONObject()
            smokeArgs.AddFieldFloat("mx", 2)
            smokeArgs.AddFieldInt("layer", 1)
            smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
            SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
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
    return self.lifetime > 200
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x > -20
end
