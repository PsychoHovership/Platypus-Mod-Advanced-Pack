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
local ignoreEnemyShotSpeed
local globalEnemyShotSpeed
local fruitSets = {}

function OnInitialise()
    if self.customBehaviourData.HasField("fruitSets") then
        local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end

    mx = self.commandArgs.GetFieldFloat("mx", -7)
    my = self.commandArgs.GetFieldFloat("my",  0)

    turretData = NewTurretDataFromEntityData(self.data)
    bullets = turretData.bulletCount.Get()
    speed = turretData.bulletSpeed.Get()
    entity = turretData.bulletEntity
    spreadAngle = turretData.bulletSpreadAngle
    spawnDistance = turretData.bulletSpawnDistance
    originOffX = turretData.bulletOriginOffX
    originOffY = turretData.bulletOriginOffY
    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")

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
    if fireSFX ~= "" then PlaySound(fireSFX) end
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }
    mx = mx + 0.06

    local spriteIndex = math.floor(Lerp(0, self.animator.totalFrames, (mx + 1) / (1 + 1)))
    self.animator.GoTo(spriteIndex)

    firePattern.Tick()
    if mx > 0 and firePattern.CanFire() and self.lifetime % 3 == 0 then
        firePattern.MarkFired()
        Fire()
    end

    if mx > 0 and self.position.x > AdjustXToWideScreen(700) then self.Deactivate() end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(4, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x < AdjustXToWideScreen(640)
end
