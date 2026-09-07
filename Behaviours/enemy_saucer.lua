local my
local myMax
local yAcceleration
local aimAngle = 0
local turretData
local bullets
local speed
local entity
local spreadAngle
local spawnDistance
local originOffX
local originOffY
local allowedToShoot
local oktofire
local firePattern
local fireSFX
local ignoreEnemyShotSpeed
local globalEnemyShotSpeed

function OnInitialise()
    my = self.commandArgs.GetFieldFloat("speedY", self.data.speed)
    myMax = self.commandArgs.GetFieldFloat("maxSpeedY", self.data.speed * 1.2501)
    yAcceleration = myMax / 25

    allowedToShoot = self.customBehaviourData.GetFieldBool("allowedToShoot", true)
    if allowedToShoot then
        turretData = NewTurretDataFromEntityData(self.data)
        bullets = turretData.bulletCount.Get()
        speed = turretData.bulletSpeed.Get()
        entity = turretData.bulletEntity
        spreadAngle = turretData.bulletSpreadAngle
        spawnDistance = turretData.bulletSpawnDistance
        originOffX = turretData.bulletOriginOffX
        originOffY = turretData.bulletOriginOffY
        ignoreEnemyShotSpeed = self.customBehaviourData.GetFieldBool("ignoreEnemyShotSpeed", false)
        if not ignoreEnemyShotSpeed then globalEnemyShotSpeed = Globals.enemyShotSpeedMultiplier else globalEnemyShotSpeed = 1 end

        oktofire = math.random(0, 99) < Globals.firingChanceSaucer.Get()
        firePattern = NewFirePatternFromEntityData(self.data)
        fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser2")
    end
end

function Fire()
    for i = 0, bullets - 1 do
        local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
        local shotAngle = aimAngle - spreadAngle / 2 + t * spreadAngle
        local fireArgs = NewJSONObject()
        fireArgs.AddFieldFloat("mx", math.cos(math.rad(shotAngle)) * speed * globalEnemyShotSpeed)
        fireArgs.AddFieldFloat("my", math.sin(math.rad(shotAngle)) * speed * globalEnemyShotSpeed)
        SpawnEntityWorld(entity, { x = self.worldPosition.x + math.cos(math.rad(shotAngle)) * spawnDistance + originOffX, y = self.worldPosition.y + math.sin(math.rad(shotAngle)) * spawnDistance + originOffY }, fireArgs)
    end
    PlaySound(fireSFX)
end

function OnTick()
    if math.abs(my) >= myMax then yAcceleration = -yAcceleration end
    my = my + yAcceleration
    self.movement = { x = -self.data.speed, y = my, z = 0 }
    local spriteIndex = Round((1 + (my / myMax)) * (self.animator.totalFrames - 1) * 0.7)
    spriteIndex = Clamp(spriteIndex, 0, self.animator.totalFrames - 1)
    self.animator.AnimateTo(spriteIndex)
    local sourcePos = self.worldPosition
    local targetPos = { x = 0, y = 0 }
    if GetActivePlayerCount() > 0 then
        local player = GetRandomActivePlayer()
        if player ~= nil then targetPos = player.worldPosition end
    end
    local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
    aimAngle = MoveTowardsAngle(aimAngle, targetAngle, 360)
    if CanFire() then
        firePattern.Tick()
        if firePattern.CanFire() then
            firePattern.MarkFired()
            Fire()
        end
    end
    if self.position.x < AdjustXToWideScreen(-60) then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function CanFire()
    if allowedToShoot and oktofire and self.position.x > 60 then return self.position.x < 620 end
    return false
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
