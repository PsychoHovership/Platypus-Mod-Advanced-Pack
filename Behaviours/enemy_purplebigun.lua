local mx
local smokeTrailCounter = 0
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY
local expertTurretEntity1
local expertTurretPosX1
local expertTurretPosY1
local expertTurretEntity2
local expertTurretPosX2
local expertTurretPosY2

function OnInitialise()
    mx = self.data.speed
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldFloat("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldFloat("smokeTrailPosY", 0)
    expertTurretEntity1 = self.customBehaviourData.GetFieldString("expertTurretEntity1", "")
    expertTurretPosX1 = self.customBehaviourData.GetFieldFloat("expertTurretPosX1", 0)
    expertTurretPosY1 = self.customBehaviourData.GetFieldFloat("expertTurretPosY1", 0)
    expertTurretEntity2 = self.customBehaviourData.GetFieldString("expertTurretEntity2", "")
    expertTurretPosX2 = self.customBehaviourData.GetFieldFloat("expertTurretPosX2", 0)
    expertTurretPosY2 = self.customBehaviourData.GetFieldFloat("expertTurretPosY2", 0)
    if Globals.difficulty > 1 then
        if expertTurretEntity1 ~= "" then CreateTurret(expertTurretEntity1, expertTurretPosX1, expertTurretPosY1, self, Globals.firewait) end
        if expertTurretEntity2 ~= "" then CreateTurret(expertTurretEntity2, expertTurretPosX2, expertTurretPosY2, self, Globals.firewait) end
    end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }
    if self.lifetime > 490 and self.lifetime < 700 then mx = mx - 0.015 elseif self.lifetime > 900 and self.lifetime < 1250 then mx = mx + 0.01 end

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

    if self.position.x > AdjustXToWideScreen(950) then self.Deactivate() end
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
