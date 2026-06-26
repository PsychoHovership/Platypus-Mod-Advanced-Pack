local mx
local my
local turretData
local bullets
local speed
local entity
local spreadAngle
local spawnDistance
local originOffX
local originOffY
local firePattern
local fireSFX
local spriteIndex = 0
local ignoreEnemyShotSpeed
local globalEnemyShotSpeed

function OnInitialise()
    mx = self.commandArgs.GetFieldFloat("mx", -7)
    my = self.commandArgs.GetFieldFloat("my",  0)

    -- TURRET
    turretData = NewTurretDataFromEntityData(self.data)
    bullets = turretData.bulletCount.Get()
    speed = turretData.bulletSpeed.Get()
    entity = turretData.bulletEntity
    spreadAngle = turretData.bulletSpreadAngle
    spawnDistance = turretData.bulletSpawnDistance
    originOffX = turretData.bulletOriginOffX
    originOffY = turretData.bulletOriginOffY
    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser2")

    ignoreEnemyShotSpeed = self.customBehaviourData.GetFieldBool("ignoreEnemyShotSpeed", false)
    if ignoreEnemyShotSpeed == false then globalEnemyShotSpeed = Globals.enemyShotSpeedMultiplier else globalEnemyShotSpeed = 1 end
end

function Fire()
    for i = 0, bullets - 1 do
        local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
        local angleDeg = 180 - spreadAngle / 2 + t * spreadAngle
        local angleRad = math.rad(angleDeg)
        local dx = math.cos(angleRad) * spawnDistance
        local dy = math.sin(angleRad) * spawnDistance

        local fireArgs = NewJSONObject()
        fireArgs.AddFieldFloat("mx", math.cos(angleRad) * speed * globalEnemyShotSpeed - 1)
        fireArgs.AddFieldFloat("my", math.sin(angleRad) * speed * globalEnemyShotSpeed)
        SpawnEntityWorld(entity, { x = self.worldPosition.x + dx + originOffX, y = self.worldPosition.y + dy + originOffY }, fireArgs)
    end
    PlaySound(fireSFX)
end

function OnTick()
    -- MOVEMENT
    local mxT = mx
    mx = mx + 0.06
    self.movement = { x = mxT, y = my, z = 0 }

    -- ANIMATION
    if mx > -1 then spriteIndex = spriteIndex + 1 end
    self.animator.GoTo(spriteIndex / 3.35)

    -- SHOT
    if CanFire() then
        firePattern.Tick()
        if firePattern.CanFire() then
            firePattern.MarkFired()
            Fire()
        end
    end

    -- DESPAWN
    if mx > 0 and self.position.x > 800 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end

function CanFire()
    return spriteIndex >= 18
end
