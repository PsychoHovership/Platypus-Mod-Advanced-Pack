local mx
local my = 0
local yAcceleration = 0
local maxYAcceleration = 0.06
local direction
local bullets
local speed
local entity
local originOffset
local spawnDistance
local spreadAngle
local aimAngle = 0
local allowedToShoot
local firePattern
local fireSFX
local ignoreEnemyShotSpeed
local globalEnemyShotSpeed
local splashed = false

function OnInitialise()
    mx = -self.data.speed
    direction = self.commandArgs.GetFieldInt("direction", 0)
    if direction == 0 then yAcceleration = math.random(1, 2) == 1 and -0.0003 or 0.0003
    elseif direction == 1 then yAcceleration = 0.0001
    elseif direction == 2 then yAcceleration = -0.0001
    end

    if self.customBehaviourData.HasField("bulletCount") then
        local c = self.customBehaviourData.GetFieldFloatArray("bulletCount")
        bullets = NewDiffDictFloat(c[1], c[2], c[3], c[4], c[5]).Get()
    else bullets = NewDiffDictFloat(0, 0, 0, 0, 0).Get() end
    if self.customBehaviourData.HasField("bulletSpeed") then
        local s = self.customBehaviourData.GetFieldFloatArray("bulletSpeed")
        speed = NewDiffDictFloat(s[1], s[2], s[3], s[4], s[5]).Get()
    else speed = NewDiffDictFloat(0, 0, 0, 0, 0).Get() end
    entity = self.customBehaviourData.GetFieldString("bulletEntity", "")
    originOffset = self.customBehaviourData.GetFieldFloat("bulletOriginOffset", 0)
    spawnDistance = self.customBehaviourData.GetFieldFloat("bulletSpawnDistance", 0)
    spreadAngle = self.customBehaviourData.GetFieldFloat("bulletSpreadAngle", 0)
    ignoreEnemyShotSpeed = self.customBehaviourData.GetFieldBool("ignoreEnemyShotSpeed", false)
    if not ignoreEnemyShotSpeed then globalEnemyShotSpeed = Globals.enemyShotSpeedMultiplier else globalEnemyShotSpeed = 1 end

    allowedToShoot = math.random(0, 99) < Globals.firingChanceRandomFishFighter.Get()
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser")
    firePattern = NewFirePatternFromEntityData(self.data)
end

function Fire()
    for i = 0, bullets - 1 do
        local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
        local shotAngle = aimAngle - spreadAngle / 2 + t * spreadAngle
        local fireArgs = NewJSONObject()
        fireArgs.AddFieldFloat("mx", math.cos(math.rad(shotAngle)) * speed * globalEnemyShotSpeed)
        fireArgs.AddFieldFloat("my", math.sin(math.rad(shotAngle)) * speed * globalEnemyShotSpeed)
        SpawnEntityWorld(entity, { x = self.worldPosition.x + (math.cos(math.rad(aimAngle)) * originOffset) + (math.cos(math.rad(shotAngle)) * spawnDistance), y = self.worldPosition.y + (math.sin(math.rad(aimAngle)) * originOffset) + (math.sin(math.rad(shotAngle)) * spawnDistance) }, fireArgs)
    end
    PlaySound(fireSFX)
end

function OnTick()
    if not IsOriginalVersion() and (self.position.y > -150 and yAcceleration > 0) or (self.position.y < -400 and yAcceleration < 0) then yAcceleration = -yAcceleration end
    if not IsOriginalVersion() or self.position.x < 500 then my = my + yAcceleration end
    self.movement = { x = mx, y = my, z = 0 }
    if (math.abs(yAcceleration) < maxYAcceleration) then yAcceleration = yAcceleration * (IsOriginalVersion() and 1.1 or 1.05) end
    if Globals.createSplashes and not splashed and self.position.y < -580 then
        self.CreateFancySplashes()
        splashed = true
    end
    local frame = 0
    frame = (not (my < 0)) and ((32 - my) / 2) or ((0 - my) / 2)
    if frame >= 16 then frame = 0 end
    if frame > 3 and frame < 9 then frame = 3 end
    if frame < 13 and frame > 9 then frame = 13 end
    if CanFire() then
        firePattern.Tick()
    	if firePattern.CanFire() then
            aimAngle = math.floor(((frame + 8) % 16 * 22.5))
            firePattern.MarkFired()
            Fire()
        end
    end
    if self.position.x < AdjustXToWideScreen(-80) or self.position.y > 150 or self.position.y < -600 then self.Deactivate() end
    local spriteIndex = math.floor(((16 - frame) / 16 * self.animator.totalFrames) + 0.5)
    self.animator.GoTo(spriteIndex)
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function CanFire()
    if allowedToShoot and Globals.fishFire then return self.position.x < 600 end
    return false
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
