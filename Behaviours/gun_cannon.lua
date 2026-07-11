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
local yStrength

local firePattern
local fireSFX

function OnInitialise()
    sprite = self.data.spriteName
    barrel = self.SpawnAttachedSpriteAnimator(sprite, -100, false)
    barrel.position = { x = 0.5, y = 0 }
    self.animator.Initialise("empty")

    turretData = NewTurretDataFromEntityData(self.data)
    bullets = turretData.bulletCount.Get()
    speed = turretData.bulletSpeed.Get()
    entity = turretData.bulletEntity
    spreadAngle = turretData.bulletSpreadAngle
    spawnDistance = turretData.bulletSpawnDistance
    originOffX = turretData.bulletOriginOffX
    originOffY = turretData.bulletOriginOffY
    yStrength = self.customBehaviourData.GetFieldFloat("yStrength", 0)

    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
end

function OnTick()
    barrel.position = { x = 0.5, y = recoil }
    if recoil < 0 then recoil = recoil + 1 end

    if CanFire() then
        firePattern.Tick()
        if firePattern.CanFire() then
            firePattern.MarkFired()
            if fireSFX ~= "" then PlaySound(fireSFX) end
            recoil = -29
            barrel.position = { x = 0.5, y = -28 }

            for i = 0, bullets - 1 do
                local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
                local shotAngle = 90 - spreadAngle / 2 + t * spreadAngle
                local fireArgs = NewJSONObject()
                fireArgs.AddFieldFloat("mx", math.cos(math.rad(shotAngle)) * speed - 0.5)
                fireArgs.AddFieldFloat("my", math.sin(math.rad(shotAngle)) * (speed + yStrength))
                SpawnEntityWorld(entity, { x = self.worldPosition.x + (math.cos(math.rad(shotAngle)) * spawnDistance) + originOffX, y = self.worldPosition.y + (math.sin(math.rad(shotAngle)) * spawnDistance) + originOffY }, fireArgs)
            end
        end
    end
end

function CanFire()
    return self.parent.CanFire()
end
