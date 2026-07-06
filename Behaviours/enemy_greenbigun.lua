local mx
local xAcceleration
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY
local expertTurretEntity
local expertTurretPosX
local expertTurretPosY

function OnInitialise()
    mx = self.data.speed
    xAcceleration = self.commandArgs.GetFieldFloat("acceleration", 0.002)
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldInt("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldInt("smokeTrailPosY", 0)
    expertTurretEntity = self.customBehaviourData.GetFieldString("expertTurretEntity", "")
    expertTurretPosX = self.customBehaviourData.GetFieldInt("expertTurretPosX", 0)
    expertTurretPosY = self.customBehaviourData.GetFieldInt("expertTurretPosY", 0)
    if Globals.difficulty > 1 then
        if expertTurretEntity ~= "" then CreateTurret(expertTurretEntity, expertTurretPosX, expertTurretPosY, self, Globals.firewait) end
    end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }
    mx = mx + xAcceleration

    if smokeTrailEntity ~= "" and self.lifetime % 16 == 0 then
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 1)
        smokeArgs.AddFieldInt("layer", 1)
        smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
        SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
    end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.position.x > 800 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(40, -9, 3, -15, 5, 0, 0, 2, 2, 2, 2)
    self.SpawnShipDebris(4, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
end

function CanFire()
    return self.position.x >= 200
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x > 30
end
