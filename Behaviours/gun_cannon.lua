local barrelSprite
local barrelAnimator
local barrelOffset = -1
local recoil

local turretData
local bullets
local speed
local entity
local spreadAngle
local spawnDistance
local originOffX
local originOffY
local xMovement
local yStrength

local firePattern
local fireSFX

function OnInitialise()
    barrelSprite = self.data.spriteName
    barrelAnimator = self.SpawnAttachedSpriteAnimator(barrelSprite, -100, false)
    barrelAnimator.position = { x = 0.5, y = 0 }
    self.animator.Initialise("empty")
    recoil = math.abs(self.customBehaviourData.GetFieldInt("recoil", 0))

    turretData = NewTurretDataFromEntityData(self.data)
    bullets = turretData.bulletCount.Get()
    speed = turretData.bulletSpeed.Get()
    entity = turretData.bulletEntity
    spreadAngle = turretData.bulletSpreadAngle
    spawnDistance = turretData.bulletSpawnDistance
    originOffX = turretData.bulletOriginOffX
    originOffY = turretData.bulletOriginOffY
    xMovement = self.customBehaviourData.GetFieldFloat("xMovement", 0)
    yStrength = self.customBehaviourData.GetFieldFloat("yStrength", 0)

    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
end

function OnTick()
    barrelAnimator.position = { x = 0.5, y = barrelOffset }
    if barrelOffset < 0 then barrelOffset = barrelOffset + 1 end

    if CanFire() then
        firePattern.Tick()
        if firePattern.CanFire() then
            firePattern.MarkFired()
            if fireSFX ~= "" then PlaySound(fireSFX) end
            barrelOffset = -recoil - 1
            barrelAnimator.position = { x = 0.5, y = -recoil }

            for i = 0, bullets - 1 do
                local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
                local shotAngle = 90 - spreadAngle / 2 + t * spreadAngle
                local fireArgs = NewJSONObject()
                fireArgs.AddFieldFloat("mx", math.cos(math.rad(shotAngle)) * speed + xMovement)
                fireArgs.AddFieldFloat("my", math.sin(math.rad(shotAngle)) * (speed + yStrength))
                SpawnEntityWorld(entity, { x = self.worldPosition.x + (math.cos(math.rad(shotAngle)) * spawnDistance) + originOffX, y = self.worldPosition.y + (math.sin(math.rad(shotAngle)) * spawnDistance) + originOffY }, fireArgs)
            end
        end
    end
end

function CanFire()
    return self.parent.CanFire()
end
