local mx = -6.825
local timer = 0
local trailTimer = 0

local firePattern

function OnInitialise()
    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }

    if timer > 3 and timer <= 12 then
        mx = mx + 0.035
    elseif timer > 12 and timer <= 20 then
        mx = mx + 0.02
    elseif timer > 20 and timer <= 325 then
        mx = mx + 0.025
    end

    local smokePos = { x = self.worldPosition.x - 73, y = self.worldPosition.y + 2 }

    timer = timer + 1
    trailTimer = trailTimer - 1
    if trailTimer <= 0 and timer > 348 then
        trailTimer = 35

        local smokeArgs = NewJSONObject()
        local smokeTrail = 2

        smokeArgs.AddFieldFloat("mx", smokeTrail)
        SpawnEntityWorld("smokeRing1", smokePos, smokeArgs)
    end

    if CanFire() then
        firePattern.Tick()
        if firePattern.CanFire() then
            firePattern.MarkFired()
            PlaySound("s_woosh")

            local missilePos1 = { x = self.worldPosition.x + 66, y = self.worldPosition.y + 56}
            local missilePos2 = { x = self.worldPosition.x + 66, y = self.worldPosition.y - 56}

            local missileArgs1 = NewJSONObject()
            local missileArgs2 = NewJSONObject()
            missileArgs1.AddFieldInt("homingDelay", 30)
            missileArgs1.AddFieldInt("currentAngle", -40)
            missileArgs2.AddFieldInt("homingDelay", 30)
            missileArgs2.AddFieldInt("currentAngle", 40)

            SpawnEntityWorld("homingMissile", missilePos1, missileArgs1)
            SpawnEntityWorld("homingMissile", missilePos2, missileArgs2)
        end
    end

    if self.position.x > 860 then self.Deactivate() end

    local damageframe = self.GetDamageFrame(self.hitPoints)
    self.animator.AnimateTo(damageframe)
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return timer > 120
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= 29
end
