local mx
local my
local yAcceleration = 1
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY
local fruitSets = {}

function OnInitialise()
    if self.customBehaviourData.HasField("fruitSets") then
        local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end

	mx = self.commandArgs.GetFieldFloat("mx", 5)
	my = self.commandArgs.GetFieldFloat("my", 0)
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldFloat("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldFloat("smokeTrailPosY", 0)
end

function OnTick()
	self.movement = { x = mx, y = my / 16.0, z = 0 }

	-- Decelerate early in lifetime
	if self.lifetime < 350 then
		mx = mx - 0.0145
		mx = math.max(mx, -0.2)
	end

	-- Accelerate away late in lifetime
	if self.lifetime > 1200 then mx = mx + 0.008 end

	-- Vertical oscillation
	my = my + yAcceleration
	if my > 40 then yAcceleration = -2 end
	if my < -40 then yAcceleration = 2 end

	-- Smoke ring every 26 frames when not retreating fast
	if smokeTrailEntity ~= "" and self.lifetime % 26 == 0 and mx > -0.5 then
		local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 2)
        smokeArgs.AddFieldInt("layer", 1)
        smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
        SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
	end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

	-- Deactivate when out of horizontal bounds
	if self.position.x > 950 or self.position.x < -300 then self.Deactivate() end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    self.SpawnShipShards(30, -14, 7, -22, 4, 0, 40, 2, 5, 2, 5)
    self.SpawnShipDebris(4, -24, 15, -44, 9, 0, 40, 2, 5, 2, 5)
end

function CanFire()
	return self.lifetime >= 160
end

function HasCollision()
	return true
end

function ShouldKillPlayerOnTouch()
	return self.lifetime > 140
end
