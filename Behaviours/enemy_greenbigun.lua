local mx
local xAcceleration
local trailTimer = 0
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

    if smokeTrailEntity ~= "" then
        trailTimer = trailTimer - 1
        if trailTimer <= 0 then
            trailTimer = 16
            local smokeArgs = NewJSONObject()
            smokeArgs.AddFieldFloat("mx", 1)
            SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
        end
    end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.position.x > 800 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return self.position.x >= 120
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= 29
end
