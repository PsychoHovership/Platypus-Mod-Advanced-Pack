
local mx =             -7 -- -6.8
local mxa =            0.06
local mxt = mx

local timer = 0

local turretData
local firePattern
local fireSFX
local firstShotDelay = 118

local goldframe = 0

--local fireTimer = 100




function OnInitialise()

    -- TURRET
    turretData  = NewTurretDataFromEntityData(self.data)
    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX     = self.customBehaviourData.GetFieldString("fireSFX", "s_laser")

end

function OnTick()

    timer = timer + 1

    mxt = mx

    mx = mx + mxa

    -- MOVEMENT
    self.movement = { x = mxt, y = 0, z = 0 }

    -- ANIMATION

    if timer > 100 then

        goldframe = goldframe + 1

    end

    self.animator.AnimateTo(goldframe / 3.35)


    -- SHOT

    --if fireTimer > 0 then fireTimer = fireTimer - 1 end
    if timer == 120 then
        return CanFire()
    end

    if firstShotDelay > 0 then firstShotDelay = firstShotDelay - 1 end

    if CanFire() then
        firePattern.Tick()
        if firePattern.CanFire() and firstShotDelay == 0 then
            firePattern.MarkFired()
            Fire()
        end
    end

    -- DESPAWN

    if self.position.x < -160 or self.position.x > 1000 then
        self.Deactivate()
    end

end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function Fire()
    for _, bulletParams in ipairs(turretData.CalculateBulletParams(self.worldPosition, angle)) do
        SpawnEntityWorld(bulletParams.bulletEntity, bulletParams.spawnPosition, bulletParams.args)
    end
    PlaySound(fireSFX)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end

function CanFire()
    return firstShotDelay <= 30
end

function CreateBullet(x, y, angle)
    local args = NewJSONObject()
    args.AddFieldInt("var5", RandRange(0, 360))
    args.AddFieldInt("currentAngle", -angle)
    args.AddFieldInt("homingDelay", 30)

    PlaySound(fireSFX)
    SpawnEntityWorld("homingMissile", {x=x, y=y}, args)
end
