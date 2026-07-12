local mx
local my
local targetY
local currentFrame = 0
local recoil = 0
local oktofire = false
local deathFallbackTick = 0
local wakeAnimator
local barrelAnimator
local fireSFX
local turretData
local bulletCount
local bulletSpeed
local bulletEntity
local spreadAngle
local spawnDistance
local originOffX
local originOffY
local xStrength = 0
local yStrength = 0
local missileOffX
local missileOffY
local missileSFX
local subOffX
local subOffY
local subEntity

function OnInitialise()
	mx = self.commandArgs.GetFieldFloat("mx", 1)
    my = self.position.y
	targetY = self.commandArgs.GetFieldFloat("targetY", self.position.y)
	wakeAnimator = self.SpawnAttachedSpriteAnimator("Effects/Water/boat wake", 1)
	barrelAnimator = self.SpawnAttachedSpriteAnimator("Sprites/Boss 1/big barrel", -1)
	fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    turretData = NewTurretDataFromEntityData(self.data)
    bulletCount = turretData.bulletCount.Get()
    bulletSpeed = turretData.bulletSpeed.Get()
    bulletEntity = turretData.bulletEntity
    spreadAngle = turretData.bulletSpreadAngle
    spawnDistance = turretData.bulletSpawnDistance
    originOffX = turretData.bulletOriginOffX
    originOffY = turretData.bulletOriginOffY
	missileOffX = self.customBehaviourData.GetFieldFloat("missileOffX", 0)
	missileOffY = self.customBehaviourData.GetFieldFloat("missileOffY", 0)
	missileSFX = self.customBehaviourData.GetFieldString("missileSFX", "")
	subOffX = self.customBehaviourData.GetFieldFloat("subOffX", 0)
	subOffY = self.customBehaviourData.GetFieldFloat("subOffY", 0)
	subEntity = self.customBehaviourData.GetFieldString("subEntity", "")
	if IsOriginalVersion() then CreateTurret("legacyTurret", 5, -95, self, Globals.firewait) else
        if Globals.difficulty <= GameDifficulty.Medium then
            CreateTurret("turretNastySingle", 25, -70, self, Globals.firewait)
        else CreateTurret("turretTripleSmall", 25, -70, self, Globals.firewait) end
    end
end

function Fire()
	for i = 0, bulletCount - 1 do
		local t = (bulletCount > 1) and (i / (bulletCount - 1)) or 0.5
		local shotAngle = 90 - spreadAngle / 2 + t * spreadAngle
		local fireArgs = NewJSONObject()
		fireArgs.AddFieldFloat("mx", math.cos(math.rad(shotAngle)) * (bulletSpeed + xStrength) + mx)
		fireArgs.AddFieldFloat("my", math.sin(math.rad(shotAngle)) * (bulletSpeed + yStrength))
		SpawnEntityWorld(bulletEntity, { x = self.worldPosition.x + (math.cos(math.rad(shotAngle)) * spawnDistance) + (originOffX - 8), y = self.worldPosition.y + (math.sin(math.rad(shotAngle)) * spawnDistance) + (originOffY - 10) }, fireArgs)
		if fireSFX ~= "" then PlaySound(fireSFX) end
	end
end

function OnTick()
    UpdateWake()
	barrelAnimator.position = { x = originOffX, y = originOffY - recoil }
    self.movement = { x = mx, y = my - self.position.y, z = 0 }
	if self.position.x > 420 then mx = mx - 0.01 end
	if self.position.x < 220 then mx = mx + 0.01 end
	if self.lifetime % 3 ~= 0 then
        if targetY < -448 and self.lifetime >= 600 then targetY = targetY + 1 elseif targetY < -652 then targetY = targetY + 1 end
    end
	if targetY < -640 and self.data.maxHitPoints - self.hitPoints > 500 then self.hitPoints = self.data.maxHitPoints - 500 end
	my = targetY - (5 + math.cos(math.rad(Globals.levelLifetime * 2 % 360)) * 5)
	if recoil > 0 then recoil = recoil - 1 end
	if self.hitPoints > 0 then
        if targetY >= -448 then oktofire = true end
		if oktofire then
			local missileWait = (Globals.difficulty <= GameDifficulty.Medium) and 260 or 200
			if self.lifetime % 35 == 0 and self.lifetime % 350 > missileWait then
                local missileArgs = NewJSONObject()
                missileArgs.AddFieldInt("homingDelay", 30)
                missileArgs.AddFieldInt("currentAngle", -80)
                missileArgs.AddFieldInt("var5", math.random(0, 360))
				SpawnEntityWorld("homingMissile", { x = self.worldPosition.x + missileOffX, y = self.worldPosition.y + missileOffY }, missileArgs)
                if missileSFX ~= "" then PlaySound(missileSFX) end
            end
			if Globals.difficulty > GameDifficulty.Easy then
			    if self.lifetime % 350 == 100 or self.lifetime % 350 == 200 then
				    recoil = 20
					xStrength = 0
					yStrength = 2.5
					Fire()
                end
				if self.lifetime % 350 == 150 then
					recoil = 40
					xStrength = -1
					yStrength = 6
					Fire()
				end
			else
			    if self.lifetime % 350 == 100 then
                    recoil = 40
					yStrength = 4
					Fire()
				end
				if self.lifetime % 350 == 200 and Globals.difficulty == GameDifficulty.Easy then
				    recoil = 40
					yStrength = 5
					Fire()
				end
			end
		end
		local oldFrame = currentFrame
		currentFrame = self.GetDamageFrame(self.hitPoints)
		self.HandleDamageEffects(currentFrame, oldFrame)
		self.animator.GoTo(currentFrame)
		if oldFrame ~= currentFrame then CreateExplosionSquare(self.worldPosition.x - 200, self.worldPosition.y - 40, 400, 80) end
    end
	if self.hitPoints > -200 and self.hitPoints <= 0 then
		if self.data.endKillTimerOnDeath then self.EndKillTimer() end
		oktofire = false
		self.hitPoints = self.hitPoints - 1
		if self.lifetime % 10 == 0 and math.random(-200, 0) > self.hitPoints then
		    SpawnEntityWorld("explosionMedium", { x = self.worldPosition.x + math.random(-200, 200), y = self.worldPosition.y + math.random(-40, 40) })
		    SpawnEntityWorld("explosionMedium", { x = self.worldPosition.x + math.random(-200, 200), y = self.worldPosition.y + math.random(-40, 40) })
        end
		if self.hitPoints == -200 and self.worldPosition.x > 500 and deathFallbackTick < 300 then
            deathFallbackTick = deathFallbackTick + 1
			self.hitPoints = -199
        end
	end
	if self.hitPoints <= -200 then self.Kill() end
end

function UpdateWake()
	local text = ""
	local offset = 0
	if self.position.y >= -701 then
	    if self.position.y < -677 then
            text = "Effects/Water/water spray"
			offset = -10
		elseif self.position.y < -651 then
		    text = "Effects/Water/water spray"
		    offset = -30
		elseif self.position.y < -579 then
		    text = "Effects/Water/boat wake"
			offset = -30
		elseif self.position.y < -557 then
		    text = "Effects/Water/boat wake 2"
		    offset = -50
		elseif self.position.y < -521 then
            text = "Effects/Water/boat wake 3"
		    offset = 120
        elseif self.position.y < -471 then
			text = "Effects/Water/boat wake 3"
			offset = -80
		else
			text = "Effects/Water/boat wake 3"
			offset = -40
        end
    end
	if text ~= "" and wakeAnimator.currentSheet ~= text then
		wakeAnimator.Initialise(text, 1)
		wakeAnimator.ApplyLayerMaterial(self.layer)
    end
	wakeAnimator.position = { x = offset, y = (Globals.horizonLevels[self.layer] / 1.5) - (self.worldPosition.y + 145) }
end

function HasCollision()
	return self.hitPoints > 0
end

function IsKilledManually()
	return true
end

function OnHitByBullet(bulletEntity)
	if self.lifetime < 1200 then self.hitPoints = self.hitPoints + (bulletEntity.BulletConsume(self) * 0.7) end
	self.hitPoints = math.max(self.hitPoints, 0)
end

function OnHitByPlayer(player)
	self.hitPoints = math.max(self.hitPoints, 0)
end

function ShouldKillPlayerOnTouch()
	return self.lifetime > 70
end

function OnKill()
    local subArgs = NewJSONObject()
    subArgs.AddFieldInt("targetX", 600)
    subArgs.AddFieldInt("targetY", 300)
	if subEntity ~= "" then SpawnEntityWorld(subEntity, { x = self.worldPosition.x + subOffX, y = self.worldPosition.y + subOffY }, subArgs) end
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 150, y = self.worldPosition.y - 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x +  50, y = self.worldPosition.y - 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x -  50, y = self.worldPosition.y + 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 150, y = self.worldPosition.y + 50 })
	self.SpawnShipShards(160, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
    self.SpawnShipDebris(40, -24, 16, -44, 10, 0, 40, 2, 6, 2, 6)
end

function CanFire()
	return oktofire
end

function CreateExplosionSquare(x, y, width, height)
	local ny = y + height + 50
	local nx = x + width - 50
	local p = 80
	for ox = x, nx, p do
		for oy = ny, y, p do
			SpawnEntityWorld("explosionMedium", { x = ox + RandRangeF(0, 50), y = oy + RandRangeF(0, 50) })
        end
    end
end
