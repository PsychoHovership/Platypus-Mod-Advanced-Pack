
local var3
local spawnedNextSegment
local targetX
local targetY
local currentFrame = 0
local fireDelayCounter = 120
local planeSegmentWidth
local topArmAnimator
local bottomArmAnimator
local topThrusterEntityID = -1
local topThruster
local previousSegment
local field

function CalculateMovement(targetX, targetY, pos)
	if Globals.custom.GetFieldBool("moveplane") == true then targetX = targetX - 1 end
	local num
	local num2
	if IsOriginalVersion() then
		num = targetX + math.cos(Round(Globals.custom.GetFieldInt("bigPlaneLifetime") * 1.4) % 360) * 100
		num2 = targetY + math.cos(Globals.custom.GetFieldInt("bigPlaneLifetime") / 2 % 360) * 200
	else
		num = targetX - 30 + math.cos(Round(Globals.custom.GetFieldInt("bigPlaneLifetime") * 0.9) % 360) * 100
		num2 = targetY + math.cos(Globals.custom.GetFieldInt("bigPlaneLifetime") / 3 % 360) * 220
	return { x = num - pos.x, y = num2 - pos.y, z = 0 } end
end

function OnInitialise()
	planeSegmentWidth = IsOriginalVersion() and 173 or 164
	spawnedNextSegment = false
	Globals.custom.SetFieldInt("planeCounter", Globals.custom.GetFieldInt("planeCounter", 0) + 1)
	targetX = self.commandArgs.GetFieldFloat("targetX")
	targetY = self.commandArgs.GetFieldFloat("targetY")
	field = self.commandArgs.GetFieldInt("previousSegmentID", -1)
	if field ~= -1 then previousSegment = GetEntity(field) end
	if Globals.custom.GetFieldInt("planeCounter") == 1 then
		var3 = 1
		if IsOriginalVersion() then
            SpawnEntityChild("bigPlaneEngine", self, { x = -138, y = 66 })
			SpawnEntityChild("bigPlaneEngine", self, { x = -138, y = -66 })
			SpawnEntityChild("bigPlaneTopFin", self, { x = -26, y = 206 })
			SpawnEntityChild("bigPlaneBottomFin", self, { x = -26, y = -205 })
			CreateTurret("legacyTurret", 0, -10, self, Globals.firewait)
			CreateTurret("legacyTurret", 0, 90, self, Globals.firewait / 2)
			CreateTurret("legacyTurret", 0, -105, self, Globals.firewait / 3)
		else
            local engineArgs = NewJSONObject()
            engineArgs.AddFieldBool("workaroundtomakethetoppartuseadifferentspritethanthebottomwhyyoureadingthis?", false)
			SpawnEntityChild("bigPlaneEngine", self, { x = -160, y = 80 })
			SpawnEntityChild("bigPlaneEngine", self, { x = -160, y = -80 }, engineArgs)
			SpawnEntityChild("bigPlaneTopFin", self, { x = -14, y = 230 })
			SpawnEntityChild("bigPlaneBottomFin", self, { x = -14, y = -230 })
			CreateTurret("turretSingle", 0, 90, self, Globals.firewait)
			CreateTurret("turretSingleSlower", 0, -10, self, Globals.firewait / 2)
			CreateTurret("turretSingle", 0, -105, self, Globals.firewait / 3)
        end
    elseif Globals.custom.GetFieldInt("planeCounter") == 2 then var3 = 2
    elseif Globals.custom.GetFieldInt("planeCounter") == 3 then
        var3 = 3
        if IsOriginalVersion() then
			CreateTurret("legacyTurret", 0, 90, self, Globals.firewait)
			CreateTurret("legacyTurret", 0, -105, self, Globals.firewait / 1.5)
		else
			CreateTurret("turretTriple", 0, 55, self, Globals.firewait)
			CreateTurret("turretTriple", 0, -70, self, Globals.firewait / 1.5)
        end
	end
	if Globals.custom.GetFieldInt("planeCounter") == 5 then
		var3 = 3
		if IsOriginalVersion() then
			CreateTurret("legacyTurret", 0, -10, self, Globals.firewait)
			CreateTurret("legacyTurret", 0, 90, self, Globals.firewait / 2)
			CreateTurret("legacyTurret", 0, -105, self, Globals.firewait / 3)
		else
			CreateTurret("turretTriple", 0, 90, self, Globals.firewait)
			CreateTurret("turretTripleSlower", 0, -10, self, Globals.firewait / 2)
			CreateTurret("turretTriple", 0, -105, self, Globals.firewait / 3)
        end
    end
	if Globals.custom.GetFieldInt("planeCounter") == 4 then
		var3 = 4
		if IsOriginalVersion() then
			SpawnEntityChild("bigPlaneThruster", self, { x = 124 - planeSegmentWidth, y = 250 })
			SpawnEntityChild("bigPlaneThruster", self, { x = 124 - planeSegmentWidth, y = -250 })
			topArmAnimator = self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/arm 1", -1)
			topArmAnimator.position = { x = -40, y = 184}
			bottomArmAnimator = self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/arm 2", -1)
			bottomArmAnimator.position = { x = -40, y = -188}
		else
			topThrusterEntityID = SpawnEntityChild("bigPlaneThruster", self, { x = 84 - planeSegmentWidth, y = 320 })
			SpawnEntityChild("bigPlaneThruster", self, { x = 84 - planeSegmentWidth, y = -320 })
			topArmAnimator = self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/arm 1", -1)
			topArmAnimator.position = { x = -40, y = 232 }
			bottomArmAnimator = self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/arm 2", -1)
			bottomArmAnimator.position = { x = -40, y = -232 }
        end
	end
	_ = Globals.custom.GetFieldInt("planeCounter")
	_ = 6
	if Globals.custom.GetFieldInt("planeCounter") ~= 1 then
		local spriteAnimator = self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/frayed body", self.data.sortOrder - 2, true)
		if IsOriginalVersion() then spriteAnimator.position = { x = -126, y = -5 } else spriteAnimator.position = { x = -140, y = 1 } end
    end
	if var3 == 2 then
		self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/homer1", 1).position = { x = 0, y = 45 }
		self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/homer2", 1).position = { x = 0, y = -60 }
    elseif var3 == 4 then
		local spriteAnimator1 = self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/homer1", 1)
		local spriteAnimator2 = self.SpawnAttachedSpriteAnimator("Sprites/Boss 2/homer2", 1)
		if IsOriginalVersion() then
			spriteAnimator1.position = { x = 0, y = 45 }
			spriteAnimator2.position = { x = 0, y = -60 }
		else
			spriteAnimator1.position = { x = 0, y = 70 }
			spriteAnimator2.position = { x = 0, y = -90 }
			CreateTurret("turretMeanSingle", 0, -10, self, Globals.firewait)
        end
	end
end

function CheckSpawnNextSegment()
	if not spawnedNextSegment and Globals.custom.GetFieldInt("planeCounter") < 6 then
		spawnedNextSegment = true
		if Globals.custom.GetFieldInt("planeCounter") == 5 then
            local segmentArgs = NewJSONObject()
            segmentArgs.AddFieldFloat("targetX", targetX)
            segmentArgs.AddFieldFloat("targetY", targetY)
            segmentArgs.AddFieldInt("previousSegmentID", field)
            SpawnEntityWorld("bigPlaneHead", { x = targetX + planeSegmentWidth + 10, y = targetY })
        else
            local segmentArgs = NewJSONObject()
            segmentArgs.AddFieldFloat("targetX", targetX)
            segmentArgs.AddFieldFloat("targetY", targetY)
            segmentArgs.AddFieldInt("previousSegmentID", field)
            SpawnEntityWorld("bigPlane", { x = targetX + planeSegmentWidth, y = targetY }, segmentArgs)
        end
    end
end

function OnTick()
	if previousSegment ~= nil and not previousSegment.IsEntityAlive then previousSegment = nil end
    self.movement = { x = 0, y = 0, z = 0 }
	if topThrusterEntityID ~= -1 then
		if topThruster == nil then topThruster = GetEntity(topThrusterEntityID) elseif not topThruster.IsEntityAlive then
            topThrusterEntityID = -1
			topArmAnimator.Initialise("Sprites/Boss 2/arm 1 broken")
			topArmAnimator.ApplyLayerMaterial(self.layer)
        end
	end
	if Globals.custom.GetFieldBool("firstPlane") == false then
		Globals.custom.SetFieldBool("firstPlane", Globals.custom.GetFieldBool("firstPlane", true))
		Globals.custom.SetFieldInt("bigPlaneLifetime", Globals.custom.GetFieldInt("bigPlaneLifetime", 0) + 1)
		fireDelayCounter = fireDelayCounter - 1
		Globals.custom.SetFieldBool("moveplane", Globals.custom.GetFieldBool("moveplane", targetX > 540))
		CheckSpawnNextSegment()
		local num = 200
		if Globals.difficulty == GameDifficulty.Nasty then num = 150 end
		if var3 == 2 or var3 == 4 and Globals.custom.GetFieldInt("bigPlaneLifetime") % num == 0 and Globals.custom.GetFieldBool("moveplane") == false then
            local missileArgs1 = NewJSONObject()
            local missileArgs2 = NewJSONObject()
            local missileArgs3 = NewJSONObject()
            local missileArgs4 = NewJSONObject()
            missileArgs1.AddFieldInt("homingDelay", 30)
            missileArgs1.AddFieldInt("currentAngle", -115)
            missileArgs1.AddFieldInt("var5", math.random(0, 360))
            missileArgs2.AddFieldInt("homingDelay", 30)
            missileArgs2.AddFieldInt("currentAngle", 115)
            missileArgs2.AddFieldInt("var5", math.random(0, 360))
            missileArgs3.AddFieldInt("homingDelay", 30)
            missileArgs3.AddFieldInt("currentAngle", -170)
            missileArgs3.AddFieldInt("var5", math.random(0, 360))
            missileArgs4.AddFieldInt("homingDelay", 30)
            missileArgs4.AddFieldInt("currentAngle", 170)
            missileArgs4.AddFieldInt("var5", math.random(0, 360))
			SpawnEntityWorld("homingMissile", { x = self.worldPosition.x - 16, y = self.worldPosition.y + 90 }, missileArgs1)
			SpawnEntityWorld("homingMissile", { x = self.worldPosition.x - 13, y = self.worldPosition.y - 107 }, missileArgs2)
			if Globals.difficulty >= GameDifficulty.Medium then
				SpawnEntityWorld("homingMissile", { x = self.worldPosition.x - 46, y = self.worldPosition.y + 44 }, missileArgs3)
				SpawnEntityWorld("homingMissile", { x = self.worldPosition.x - 46, y = self.worldPosition.y - 61 }, missileArgs4)
            end
		end
	end
	self.movement = CalculateMovement(targetX, targetY, self.position)
	CheckSpawnNextSegment()
	local oldFrame = currentFrame
	currentFrame = self.GetDamageFrame(self.hitPoints)
	self.HandleDamageEffects(currentFrame, oldFrame)
	self.animator.GoTo(currentFrame)
	if oldFrame ~= currentFrame then CreateExplosionSquare(self.worldPosition.x, self.worldPosition.y + 100, 174, 276) end
end

function OnRender()
	Globals.custom.SetFieldBool("firstPlane", Globals.custom.GetFieldBool("firstPlane", false))
end

function OnDeinitialise()
	if previousSegment ~= nil and not previousSegment.IsEntityAlive then previousSegment.Kill() end
end

function HasCollision()
	return true
end

function ShouldKillPlayerOnTouch()
    return true
end

function OnKill()
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y + 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y + 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y - 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y - 50 })
	self.SpawnShipShards(160, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
    self.SpawnShipDebris(40, -24, 16, -44, 10, 0, 40, 2, 6, 2, 6)
	if var3 == 4 then
		SpawnEntityWorld("explosionBig", { x = self.worldPosition.x, y = self.worldPosition.y + 150 })
		SpawnEntityWorld("explosionBig", { x = self.worldPosition.x, y = self.worldPosition.y - 150 })
		Globals.custom.SetFieldBool("killThrusters", Globals.custom.GetFieldBool("killThrusters", true))
    elseif var3 == 1 then
		SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y + 150 })
		SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y + 150 })
		SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y - 150 })
		SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y - 150 })
	end
end

function CanFire()
	return fireDelayCounter <= 0
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
