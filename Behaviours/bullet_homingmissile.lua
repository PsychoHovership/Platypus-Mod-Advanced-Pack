local currentAngle
local targetAngle
local homingDelay
local frame
local targangle
local speed
local tickTurnDegrees
local var5

function OnInitialise()
    if self.customBehaviourData.HasField("speed") then
        local s = self.customBehaviourData.GetFieldFloatArray("speed")
        speed = NewDiffDictFloat(s[1], s[2], s[3], s[4], s[5]).Get()
    else speed = NewDiffDictFloat(3.1, 3.5, 4.2, 4.2, 4.2).Get() end
    if self.customBehaviourData.HasField("tickTurnDegrees") then
        local t = self.customBehaviourData.GetFieldIntArray("tickTurnDegrees")
        tickTurnDegrees = NewDiffDictInt(t[1], t[2], t[3], t[4], t[5]).Get()
    else tickTurnDegrees = NewDiffDictInt(3, 4, 4, 4, 4).Get() end
	currentAngle = self.commandArgs.GetFieldInt("currentAngle", 0)
	homingDelay = self.commandArgs.GetFieldInt("homingDelay", 0)
	var5 = self.commandArgs.GetFieldInt("var5", 0)
	targetAngle = currentAngle
end

function OnTick()
	self.movement = { x = 0, y = 0, z = 0 }
	if self.lifetime % 3 == 0 then
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 0)
        smokeArgs.AddFieldInt("layer", 1)
        smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
        SpawnEntityWorld("rocketTrail", { x = self.worldPosition.x - math.cos(math.rad(currentAngle)) * 20, y = self.worldPosition.y + math.sin(math.rad(currentAngle)) * 20 }, smokeArgs)
    end
	local targetPlayer = GetRandomActivePlayer()
	if targetPlayer ~= nil then
		local targetY = self.worldPosition.y - targetPlayer.worldPosition.y + 20
		local targetX = targetPlayer.worldPosition.x + 26 - self.worldPosition.x
		if targetX ~= 0 then
			targangle = math.floor(math.deg(math.atan2(targetY, targetX)))
			if targetPlayer.worldPosition.x + 26 < self.worldPosition.x then targangle = targangle + 180
			elseif not (targetPlayer.worldPosition.y + 20 < self.worldPosition.y) then targangle = targangle + 360 end
			targetAngle = targangle
		end
	end
	local i = ((Globals.levelLifetime - var5) * 6) % 360
	while i < 0 do i = i + 360 end
	targangle = targetAngle + math.floor(math.cos(i) * 40) - 20
	local j = currentAngle - targangle
	while j > 180 do j = j - 360 end
	while j < -180 do j = j + 360 end
	if homingDelay == 0 then
	    if j < -2 then currentAngle = currentAngle + tickTurnDegrees elseif j > 2 then currentAngle = currentAngle - tickTurnDegrees end
	else homingDelay = homingDelay - 1 end
	frame = math.floor(currentAngle / (360 / self.animator.totalFrames))
	frame = math.floor(frame + self.animator.totalFrames * 1.5) % self.animator.totalFrames
	frame = Clamp(frame, 0, self.animator.totalFrames - 1)
	self.animator.GoTo(frame)
	if currentAngle >= 360 then currentAngle = currentAngle - 360 end
	if currentAngle < 0 then currentAngle = currentAngle + 360 end
	self.movement = { x = math.cos(math.rad(currentAngle)) * speed, y = -math.sin(math.rad(currentAngle)) * speed, z = 0 }
	if self.position.x < -250 or self.position.x > 1000 or self.position.y > 250 or self.position.y < -900 then self.Deactivate() end
	if self.lifetime > 400 then homingDelay = 1000 end
	if self.lifetime > 800 then self.Kill() end
	if Globals.createSplashes and self.position.y <= -580 then
		self.CreateFancySplashes()
		self.Deactivate()
    end
end

function OnHitByBullet()
	self.Kill()
end

function OnHitByPlayer()
	self.Kill()
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
	return true
end

function ShouldKillPlayerOnTouch()
	return true
end
