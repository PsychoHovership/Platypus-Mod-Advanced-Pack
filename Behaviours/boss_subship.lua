local mx = 0
local my = 0
local targetX
local targetY
local currentFrame = 0
local deathFallbackTick = 0
local hangtime
local fireSFX
local topMissileOffX
local topMissileOffY
local bottomMissileOffX
local bottomMissileOffY
local spawnedEntity
local spawnOffX
local spawnOffY
local hatchSprite
local hatchAnimator
local hatchOffX
local hatchOffY
local fruitSets = {}

function OnInitialise()
    if self.customBehaviourData.HasField("fruitSets") then
        local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end

	targetX = self.commandArgs.GetFieldFloat("targetX", AdjustXToWideScreen(640))
	targetY = self.commandArgs.GetFieldFloat("targetY", 300)
	hangtime = self.customBehaviourData.GetFieldInt("hangtime", 7000)
	fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    topMissileOffX = self.customBehaviourData.GetFieldFloat("topMissileOffX", 0)
    topMissileOffY = self.customBehaviourData.GetFieldFloat("topMissileOffY", 0)
    bottomMissileOffX = self.customBehaviourData.GetFieldFloat("bottomMissileOffX", 0)
    bottomMissileOffY = self.customBehaviourData.GetFieldFloat("bottomMissileOffY", 0)
	spawnedEntity = self.customBehaviourData.GetFieldString("spawnedEntity", "")
    spawnOffX = self.customBehaviourData.GetFieldFloat("spawnOffX", 0)
    spawnOffY = self.customBehaviourData.GetFieldFloat("spawnOffY", 0)
	hatchSprite = self.customBehaviourData.GetFieldString("hatchSprite", "")
	hatchOffX = self.customBehaviourData.GetFieldFloat("hatchOffX", 0)
	hatchOffY = self.customBehaviourData.GetFieldFloat("hatchOffY", 0)
	if hatchSprite ~= "" then
		hatchAnimator = self.SpawnAttachedSpriteAnimator(hatchSprite, self.data.sortOrder - 201, true)
		hatchAnimator.position = { x = hatchOffX, y = hatchOffY }
	end
end

function OnTick()
	mx = mx + RandRangeF(-0.1, 0.1)
	my = my + RandRangeF(-0.1, 0.1)
	if self.position.x > targetX + 80 and mx > -3 then mx = mx - 0.3 end
	if self.position.x < targetX - 80 and mx < 3 then mx = mx + 0.3 end
	if self.position.y < -targetY - 50 and my < 3 then my = my + 0.2 end
	if self.position.y > -targetY + 120 and my > -3 then my = my - 0.2 end
	self.movement = { x = mx, y = my, z = 0 }
	if self.hitPoints > 0 then
		if self.data.maxHitPoints - self.hitPoints > 300 then
			local spawnDelay = NewDiffDictInt(16, 16, 12, 8, 8).Get()
			if self.lifetime % spawnDelay == 0 and mx > 0 and self.lifetime % 600 < 400 then
				local spawnArgs = NewJSONObject()
				local dx = mx - 2
				local dy = RandRangeF(-3, 3)
				if dx > -5 then dx = -5 elseif dx < -8 then dx = -8 end
				spawnArgs.AddFieldFloat("mx", dx)
				spawnArgs.AddFieldFloat("my", my + dy)
				if spawnedEntity ~= "" then SpawnEntityWorld(spawnedEntity, { x = self.worldPosition.x + spawnOffX, y = self.worldPosition.y + spawnOffY + RandRangeF(-50, 50) }, spawnArgs) end
			end
			if self.lifetime % 35 == 0 and self.lifetime % 600 > 450 then
            	local missileArgs1 = NewJSONObject()
            	local missileArgs2 = NewJSONObject()
            	missileArgs1.AddFieldInt("homingDelay", 30)
            	missileArgs1.AddFieldInt("currentAngle", -80)
            	missileArgs1.AddFieldInt("var5", math.random(0, 360))
            	missileArgs2.AddFieldInt("homingDelay", 30)
            	missileArgs2.AddFieldInt("currentAngle", 80)
            	missileArgs2.AddFieldInt("var5", math.random(0, 360))
				SpawnEntityWorld("homingMissile", { x = self.worldPosition.x + topMissileOffX, y = self.worldPosition.y + topMissileOffY }, missileArgs1)
				SpawnEntityWorld("homingMissile", { x = self.worldPosition.x + bottomMissileOffX, y = self.worldPosition.y + bottomMissileOffY }, missileArgs2)
				if fireSFX ~= "" then PlaySound(fireSFX) end
			end
		end
		if self.lifetime > hangtime then
			targetX = -1000
			if self.position.x < AdjustXToWideScreen(-200) then self.Deactivate() end
		end
		local oldFrame = currentFrame
		currentFrame = self.GetDamageFrame(self.hitPoints)
		self.HandleDamageEffects(currentFrame, oldFrame)
		self.animator.GoTo(currentFrame)
		if oldFrame ~= currentFrame then CreateExplosionSquare(self.worldPosition.x - 30, self.worldPosition.y - 80, 174, 246) end
	end
	if self.hitPoints > -200 and self.hitPoints <= 0 then
		if self.data.endKillTimerOnDeath then self.EndKillTimer() end
		self.hitPoints = self.hitPoints - 1
		if self.lifetime % 10 == 0 and math.random(-200, 0) > self.hitPoints then SpawnEntityWorld("explosionMedium", { x = self.worldPosition.x + math.random(-30, 144), y = self.worldPosition.y + math.random(-80, 166) }) end
		if self.hitPoints == -200 and self.worldPosition.x > 500 and deathFallbackTick < 300 then
            deathFallbackTick = deathFallbackTick + 1
			self.hitPoints = -199
        end
	end
	if self.hitPoints <= -200 then self.Kill() end
end

function HasCollision()
	return self.hitPoints > 0
end

function IsKilledManually()
	return true
end

function OnHitByBullet(bulletEntity)
	self.hitPoints = math.max(self.hitPoints, 0)
end

function OnHitByPlayer(player)
	self.hitPoints = math.max(self.hitPoints, 0)
end

function ShouldKillPlayerOnTouch()
	return self.lifetime > 70
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x - 50, self.worldPosition.y - 100, fruitSets[i]) end
    end
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y - 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y - 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y + 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y + 50 })
	self.SpawnShipShards(160, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
    self.SpawnShipDebris(40, -24, 16, -44, 10, 0, 40, 2, 6, 2, 6)
end

function CanFire()
	return self.lifetime > 70 and self.hitPoints > 0
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
