local mx = -2
local my = 0
local topGunY
local topGunX
local bottomGunY
local bottomGunX
local middleGunX
local middleGunY
local fireSFX
local bulletEntity
local bulletSpeed
local laserCounter = 0
local lightningAudio = nil
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY

function OnInitialise()
    if self.commandArgs.HasField("fruit_set") then self.fruitSet = self.commandArgs.GetFieldInt("fruit_set") else
        if self.customBehaviourData.HasField("fruitSet") then self.fruitSet = self.customBehaviourData.GetFieldInt("fruitSet") end
    end
	topGunY = self.customBehaviourData.GetFieldFloat("topGunY", 0)
	topGunX = self.customBehaviourData.GetFieldFloat("topGunX", 0)
	bottomGunY = self.customBehaviourData.GetFieldFloat("bottomGunY", 0)
	bottomGunX = self.customBehaviourData.GetFieldFloat("bottomGunX", 0)
	middleGunX = self.customBehaviourData.GetFieldFloat("middleGunX", 0)
	middleGunY = self.customBehaviourData.GetFieldFloat("middleGunY", 0)
	fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
	bulletEntity = self.customBehaviourData.GetFieldString("bulletEntity", "")
    if self.customBehaviourData.HasField("bulletSpeed") then
        local s = self.customBehaviourData.GetFieldFloatArray("bulletSpeed")
        bulletSpeed = NewDiffDictFloat(s[1], s[2], s[3], s[4], s[5]).Get()
    else bulletSpeed = NewDiffDictFloat(0, 0, 0, 0, 0).Get() end

    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldFloat("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldFloat("smokeTrailPosY", 0)
end
function OnTick()
	self.movement = { x = mx, y = my, z = 0 }
	local targetX = (self.lifetime < 2500) and AdjustXToWideScreen(500) or AdjustXToWideScreen(-200)
	if self.position.x > targetX then
		if mx > -2 then mx = mx - 0.03 else mx = -2 end
	else
		if mx < 2 then mx = mx + 0.03 else mx = 2 end
	end
	my = math.sin(self.lifetime * 0.01) * 0.5

	if smokeTrailEntity ~= "" and self.lifetime % 26 == 0 and mx > -0.5 then
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 2)
        smokeArgs.AddFieldInt("layer", 1)
		smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
        SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
	end

	-- Laser attack logic
	if self.lifetime > 200 and self.CanFire() and Globals.difficulty > GameDifficulty.Easy then
		laserCounter = laserCounter + 1
		local firewait = laserCounter % 400
		if firewait == 154 and lightningAudio == nil then
			lightningAudio = PlaySoundRaw("s_enemy_kazap")
			lightningAudio.loop = true
		end
		if firewait > 145 then
			local frame = math.random(2, 9)
			if firewait > 100 then
				if firewait < 165 then frame = 1 end
				if firewait < 155 then frame = 0 end
			end
			local zapArgs = NewJSONObject()
			zapArgs.AddFieldInt("frame", frame)
			zapArgs.AddFieldInt("angle", 180)
			SpawnEntityWorld("enemyZap", { x = self.worldPosition.x + topGunX, y = self.worldPosition.y + topGunY }, zapArgs)
			SpawnEntityWorld("enemyZap", { x = self.worldPosition.x + bottomGunX, y = self.worldPosition.y + bottomGunY }, zapArgs)
		else
			if lightningAudio ~= nil then
				lightningAudio.Stop()
				lightningAudio = nil
			end
		end
	end

	-- Bullet spread attack every 200 frames
	if self.lifetime > 220 and self.lifetime % 200 == 0 then
		for i = 120, 240, 20 do
			local rad = i * (math.pi / 180.0)
        	local fireArgs = NewJSONObject()
        	fireArgs.AddFieldFloat("mx", math.cos(rad) * bulletSpeed * Globals.enemyShotSpeedMultiplier - 1)
        	fireArgs.AddFieldFloat("my", (-math.sin(rad)) * bulletSpeed * Globals.enemyShotSpeedMultiplier)
        	SpawnEntityWorld(bulletEntity, { x = self.worldPosition.x + middleGunX, y = self.worldPosition.y + middleGunY }, fireArgs)
			if fireSFX ~= "" then PlaySound(fireSFX) end
		end
	end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

	-- Deactivate when off-screen left
	if self.position.x < AdjustXToWideScreen(-150) and mx < 0 then self.Deactivate() end
end

function OnDeinitialise()
	if lightningAudio ~= nil then lightningAudio.Stop() end
end

function OnDestroy()
	if lightningAudio ~= nil then lightningAudio.Stop() end
end

function OnKill()
    self.SpawnShipShards(80, -14, 7, -22, 4, 0, -40, 2, 5, 2, 5)
    self.SpawnShipDebris(8, -14, 7, -22, 4, 0, -40, 2, 5, 2, 5)
	MakeBonuses(self.worldPosition.x, self.worldPosition.y, 3)
	MakeBonuses(self.worldPosition.x, self.worldPosition.y, 5)
end

function CanFire()
	return self.lifetime >= 70
end

function HasCollision()
	return true
end

function ShouldKillPlayerOnTouch()
	return self.lifetime > 70
end
