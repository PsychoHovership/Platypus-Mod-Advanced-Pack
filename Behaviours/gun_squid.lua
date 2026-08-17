local frame = 0
local targetFrame = 0
local frameCounter = 0
local framesSinceFire = 0
local recoilTargetFrame
local firstShotDelay = 20
local fireSFX
local turretData
local bullets
local speed
local entity
local spreadAngle
local spawnDistance
local originOffX
local originOffY
local firePattern
local ignoreEnemyShotSpeed
local globalEnemyShotSpeed

function OnInitialise()
	recoilTargetFrame = IsOriginalVersion() and 3 or 7
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser")
    turretData = NewTurretDataFromEntityData(self.data)
    bullets = turretData.bulletCount.Get()
    speed = turretData.bulletSpeed.Get()
    entity = turretData.bulletEntity
    spreadAngle = turretData.bulletSpreadAngle
    spawnDistance = turretData.bulletSpawnDistance
    originOffX = turretData.bulletOriginOffX
    originOffY = turretData.bulletOriginOffY
    firePattern = NewFirePatternFromEntityData(self.data)
    ignoreEnemyShotSpeed = self.customBehaviourData.GetFieldBool("ignoreEnemyShotSpeed", false)
    if ignoreEnemyShotSpeed == false then globalEnemyShotSpeed = Globals.enemyShotSpeedMultiplier else globalEnemyShotSpeed = 1 end

    self.sortingGroup.SetSortingOrder(2)
end

function Fire()
    for i = 0, bullets - 1 do
        local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
        local shotAngle = 180 - spreadAngle / 2 + t * spreadAngle
        local fireArgs = NewJSONObject()
        fireArgs.AddFieldFloat("mx", math.cos(math.rad(shotAngle)) * speed * globalEnemyShotSpeed)
        fireArgs.AddFieldFloat("my", math.sin(math.rad(shotAngle)) * speed * globalEnemyShotSpeed)
        SpawnEntityWorld(entity, { x = self.worldPosition.x + math.cos(math.rad(shotAngle)) * spawnDistance + originOffX, y = self.worldPosition.y + math.sin(math.rad(shotAngle)) * spawnDistance + originOffY }, fireArgs)
    end
    PlaySound(fireSFX)
end

function Sign(x)
	if x > 0 then return 1
	elseif x < 0 then return -1
	else return 0 end
end

function MoveTowards(current, target, maxDelta)
	local diff = target - current
	if math.abs(diff) <= maxDelta then return target end
	return current + Sign(diff) * maxDelta
end

function OnTick()
	if CanFire() then
		firePattern.Tick()
		if firstShotDelay > 0 then firstShotDelay = firstShotDelay - 1 end
		framesSinceFire = framesSinceFire + 1
		if framesSinceFire > 20 then targetFrame = 0 end
		if framesSinceFire <= 20 and framesSinceFire > 10 then targetFrame = self.animator.totalFrames - 1 end
		if firePattern.GetTicksTillFire() < 30 then targetFrame = self.animator.totalFrames - 1
		end
		if firePattern.CanFire() and firstShotDelay == 0 then
			targetFrame = recoilTargetFrame
			frameCounter = 0
			framesSinceFire = 0
			firePattern.MarkFired()
			Fire()
		end
		frameCounter = frameCounter + 1
		if frameCounter >= 2 then
			frameCounter = 0
			frame = Round(MoveTowards(frame, targetFrame, 1))
			self.animator.GoTo(frame)
		end
	end
end

function CanFire()
	return self.worldPosition.x > 0 and self.parent.CanFire()
end
