local mx = 0
local my = 0
local targetX
local targetY
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

	targetX = self.commandArgs.GetFieldFloat("focus_x", AdjustXToWideScreen(600))
	targetY = self.commandArgs.GetFieldFloat("focus_y", 300)
	hangtime = self.customBehaviourData.GetFieldInt("hangtime", 4500)
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
	self.movement = { x = mx + RandRangeF(-0.01, 0.01), y = my + RandRangeF(-0.005, 0.005), z = 0 }
	if self.position.x > targetX + 25 and mx > -4 then mx = mx - 0.098 end
	if self.position.x < targetX - 25 and mx < 4 then mx = mx + 0.098 end
	if self.position.y < -targetY - 10 and my < 2 then my = my + 0.049 end
	if self.position.y > -targetY + 10 and my > -2 then my = my - 0.049 end
	local spawnDelay = NewDiffDictInt(20, 20, 13, 10, 10).Get()
	if self.lifetime > 100 and mx > 0 and self.position.x < (targetX - 40) and self.lifetime % spawnDelay == 0 and self.lifetime % 600 < 500 then
		local spawnArgs = NewJSONObject()
		spawnArgs.AddFieldFloat("mx", RandRangeF(-8, -35))
		spawnArgs.AddFieldFloat("my", RandRangeF(-12, 12))
		spawnArgs.AddFieldInt("start_length", 50)
		spawnArgs.AddFieldInt("invulnCounter", 60)
		spawnArgs.AddFieldInt("string_length", math.random(80, 300))
		spawnArgs.AddFieldInt("deadly", math.random(0, 2))
		if spawnedEntity ~= "" then SpawnEntityWorld(spawnedEntity, { x = self.worldPosition.x + spawnOffX, y = self.worldPosition.y + spawnOffY }, spawnArgs) end
	end
	if self.lifetime % 35 == 0 and self.lifetime % 600 > 540 then
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
	if self.lifetime > hangtime then
		targetX = -1000
		if self.position.x < AdjustXToWideScreen(-200) then self.Deactivate() end
	end
    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)
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
	return self.lifetime > 70
end

function HasCollision()
	return true
end

function ShouldKillPlayerOnTouch()
	return self.lifetime > 70
end
