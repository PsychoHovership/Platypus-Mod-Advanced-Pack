local direction = 90

local sprite
local barrel
local recoil = -1

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

function OnInitialise()
    sprite = self.data.spriteName
    barrel = self.SpawnAttachedSpriteAnimator(sprite, -100, false)
    barrel.position = { x = 0.5, y = -1 }
    self.animator.Initialise("empty")

    turretData = NewTurretDataFromEntityData(self.data)
    bullets = turretData.bulletCount.Get()
    speed = turretData.bulletSpeed.Get()
    entity = turretData.bulletEntity
    spreadAngle = turretData.bulletSpreadAngle
    spawnDistance = turretData.bulletSpawnDistance
    originOffX = turretData.bulletOriginOffX
    originOffY = turretData.bulletOriginOffY

    if self.commandArgs.HasField("fireSFX") then fireSFX = self.commandArgs.GetFieldString("fireSFX") else fireSFX = "s_laser" end
    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    barrel.position = { x = 0.5, y = recoil }
    if recoil <= -1 then
        recoil = recoil + 1
    end
    
    if CanFire() then
        firePattern.Tick()
        if firePattern.CanFire() then
            firePattern.MarkFired()
            PlaySound(fireSFX)
            recoil = -29
            barrel.position = { x = 0.5, y = -28 }

            for i = 0, bullets - 1 do
                local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
                local angleDeg = direction - spreadAngle / 2 + t * spreadAngle
                local angleRad = math.rad(angleDeg)

                local dx = math.cos(angleRad) * spawnDistance
                local dy = math.sin(angleRad) * spawnDistance
                local mxb = math.cos(angleRad) * speed - 0.535
                local myb = math.sin(angleRad) * speed + 3.1

                local firePos = { x = self.worldPosition.x + dx + originOffX, y = self.worldPosition.y + dy + originOffY}
            
                local fireArgs = NewJSONObject()
                fireArgs.AddFieldFloat("mx", mxb * 0.93)
                fireArgs.AddFieldFloat("my", myb)

                SpawnEntityWorld(entity, firePos, fireArgs)
            end
        end
    end
end

function CanFire()
    return self.parent.CanFire()
end