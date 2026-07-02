local mx = 0
local my = 0
local topGunY
local topGunX
local bottomGunY
local bottomGunX
local fireSFX
local bulletEntity
local bulletSpeed
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY

function OnInitialise()
    if self.commandArgs.HasField("fruit_set") then self.fruitSet = self.commandArgs.GetFieldInt("fruit_set") else
        if self.customBehaviourData.HasField("fruitSet") then self.fruitSet = self.customBehaviourData.GetFieldInt("fruitSet") end
    end

	mx = -math.abs(self.data.speed)
	topGunY = self.customBehaviourData.GetFieldFloat("topGunY", 0)
	topGunX = self.customBehaviourData.GetFieldFloat("topGunX", 0)
	bottomGunY = self.customBehaviourData.GetFieldFloat("bottomGunY", 0)
	bottomGunX = self.customBehaviourData.GetFieldFloat("bottomGunX", 0)
	fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser")
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
	local targetX = (self.lifetime < 750) and 600 or 1000
	if self.position.x > targetX then
		if mx > -math.abs(self.data.speed) then mx = mx - 0.03 else mx = -math.abs(self.data.speed) end
	elseif self.position.x < targetX then
		if mx < math.abs(self.data.speed) then mx = mx + 0.03 else mx = math.abs(self.data.speed) end
	end
	my = math.sin(self.lifetime * 0.01) * 0.5

	-- Smoke ring every 26 frames when moving right
	if smokeTrailEntity ~= "" and self.lifetime % 26 == 0 and mx > -0.5 then
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 2)
        smokeArgs.AddFieldInt("layer", 1)
		smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
        SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
	end

	-- Bullet bursts at specific lifetime windows
	local inWindow1 = (self.lifetime > 200) and (self.lifetime < 250)
	local inWindow2 = (self.lifetime > 450) and (self.lifetime < 500)
	local inWindow3 = (self.lifetime > 700) and (self.lifetime < 750)
	if (inWindow1 or inWindow2 or inWindow3) and self.lifetime % 10 == 0 then
		local fireArgs = NewJSONObject()
		fireArgs.AddFieldFloat("mx", -bulletSpeed * Globals.enemyShotSpeedMultiplier)
		fireArgs.AddFieldFloat("my", 0)
		SpawnEntityWorld(bulletEntity, { x = self.worldPosition.x + topGunX, y = self.worldPosition.y + topGunY }, fireArgs)
		SpawnEntityWorld(bulletEntity, { x = self.worldPosition.x + bottomGunX, y = self.worldPosition.y + bottomGunY }, fireArgs)
		PlaySound(fireSFX)
	end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

	-- Deactivate when off-screen right
	if self.position.x > AdjustXToWideScreen(680) and mx > 0 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(80, -14, 7, -22, 4, 0, -40, 2, 5, 2, 5)
    self.SpawnShipDebris(8, -14, 7, -22, 4, 0, -40, 2, 5, 2, 5)
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
