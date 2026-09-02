local mx
local my
local hangtime
local deathFallbackTick = 0
local topMissileOffX
local topMissileOffY
local bottomMissileOffX
local bottomMissileOffY
local missileSFX
local targetX
local targetY
local hatchSquidSprite
local hatchSquidAnimator
local hatchTurretSprite
local hatchTurretAnimator
local hatchOffX
local hatchOffY
local spawnedEntity
local spawnOffX
local spawnOffY
local spawnedTurret
local turretOffX
local turretOffY
local hugeBulletTimer = 0
local fireSFX
local hatchState
local hatchCounter = 0
local turretEntityID = -1
local hatchSequence = {}
local currentHatchIndex = 1
local turretData
local octoSpawn = false
local fruitSets = {}

HatchState = {
    None = 0,
    Squid = 1,
    Turret = 2
}

function OnInitialise()
    if self.customBehaviourData.HasField("fruitSets") then
        local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end

    mx = self.commandArgs.GetFieldFloat("mx", 0)
    my = self.commandArgs.GetFieldFloat("my", 0)
    targetX = self.commandArgs.GetFieldFloat("targetX", 550)
    targetY = -self.commandArgs.GetFieldFloat("targetY", 300)
	hangtime = self.customBehaviourData.GetFieldInt("hangtime", self.data.speedKillTimer * 2)

    topMissileOffX = self.customBehaviourData.GetFieldFloat("topMissileOffX", -110)
    topMissileOffY = self.customBehaviourData.GetFieldFloat("topMissileOffY", 106)
    bottomMissileOffX = self.customBehaviourData.GetFieldFloat("bottomMissileOffX", -130)
    bottomMissileOffY = self.customBehaviourData.GetFieldFloat("bottomMissileOffY", -96)
    missileSFX = self.customBehaviourData.GetFieldString("missileSFX", "")

    turretData = NewTurretDataFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")

    hatchOffX = self.customBehaviourData.GetFieldFloat("hatchOffX", -28)
    hatchOffY = self.customBehaviourData.GetFieldFloat("hatchOffY", 68)
    hatchSquidSprite = self.customBehaviourData.GetFieldString("hatchSquidSprite", "Sprites/Boss 4/squid mother hatch")
    hatchSquidAnimator = self.SpawnAttachedSpriteAnimator(hatchSquidSprite, self.customBehaviourData.GetFieldInt("hatchSortOffset", -1))
    hatchSquidAnimator.position = { x = (GetSpriteDimensions(hatchSquidAnimator.currentSheet, 0).x / 2) + hatchOffX, y = (GetSpriteDimensions(hatchSquidAnimator.currentSheet, 0).y / 2) + hatchOffY}
    hatchTurretSprite = self.customBehaviourData.GetFieldString("hatchTurretSprite", "Sprites/Boss 4/squid mother hatch turret")
    hatchTurretAnimator = self.SpawnAttachedSpriteAnimator(hatchTurretSprite, self.customBehaviourData.GetFieldInt("hatchSortOffset", -1))
    hatchTurretAnimator.position = { x = (GetSpriteDimensions(hatchTurretAnimator.currentSheet, 0).x / 2) + hatchOffX, y = (GetSpriteDimensions(hatchTurretAnimator.currentSheet, 0).y / 2) + hatchOffY}
    hatchState = HatchState.None
    hatchSequence = {
        HatchState.Squid,
        HatchState.Squid,
        HatchState.Squid,
        HatchState.Turret
    }

	spawnedEntity = self.customBehaviourData.GetFieldString("spawnedEntity", "squid")
    spawnOffX = self.customBehaviourData.GetFieldFloat("spawnOffX", 25)
    spawnOffY = self.customBehaviourData.GetFieldFloat("spawnOffY", 25)
	spawnedTurret = self.customBehaviourData.GetFieldString("spawnedTurret", "squidMotherTurret")
    turretOffX = self.customBehaviourData.GetFieldFloat("turretOffX", 33.2)
    turretOffY = self.customBehaviourData.GetFieldFloat("turretOffY", -3.8)
end

function Fire()
    for _, bulletParams in ipairs(turretData.CalculateBulletParams(self.worldPosition, 180)) do
        SpawnEntityWorld(bulletParams.bulletEntity, bulletParams.spawnPosition, bulletParams.args)
    end
    if fireSFX ~= "" then PlaySound(fireSFX) end
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }
    mx = mx + RandRangeF(-0.05, 0.05)
    my = my + RandRangeF(-0.05, 0.05)

    if self.hitPoints > 0 then
        if self.position.x > (targetX + 30) and mx > -4 then mx = mx - 0.05 end
        if self.position.x < (targetX - 30) and mx < 4 then mx = mx + 0.05 end
        if self.position.y > (targetY + 50) and my > -4 then my = my - 0.05 end
        if self.position.y < (targetY - 50) and my < 4 then my = my + 0.05 end
    else
        if self.position.x > 570 and mx > -2 then mx = mx - 0.05 end
        if self.position.x < 530 and mx < 2 then mx = mx + 0.05 end
        if self.position.y > -290 and my > -2 then my = my - 0.05 end
        if self.position.y < -310 and my < 2 then my = my + 0.05 end
    end

    local oldFrame = self.animator.currentFrame
    local currentFrame = self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames - 1)
    self.HandleDamageEffects(currentFrame, oldFrame)

    if self.lifetime > hangtime then
        targetX = -1000
        if self.position.x < -400 then self.Deactivate() end
    end
    if currentFrame == self.animator.totalFrames - 2 and (hugeBulletTimer >= 150 or mx >= 0) then
        hugeBulletTimer = hugeBulletTimer + 1
        if hugeBulletTimer > 150 then
            if hugeBulletTimer == 151 and mx > 0 then Fire() end
            currentFrame = self.animator.totalFrames - 1
            if hugeBulletTimer > 165 then hugeBulletTimer = 0 end
        end
    end
    if oldFrame ~= currentFrame then CreateExplosionSquare(self.worldPosition.x - 30, self.worldPosition.y + 80, 240, 246) end
    if self.hitPoints < -500 then self.Kill() end

    if self.lifetime > 400 and self.hitPoints > 0 then
        local hatchFrame = 0
        hatchCounter = hatchCounter + 1
        if hatchState == HatchState.None then
            hatchSquidAnimator.GoTo(0)
            hatchSquidAnimator.enabled = true
            hatchTurretAnimator.enabled = false
            if hatchCounter >= 100 then
                if self.lifetime < 700 then
                    hatchState = HatchState.Squid
                    hatchCounter = 0
                else
                    hatchState = hatchSequence[currentHatchIndex]
                    currentHatchIndex = (currentHatchIndex % #hatchSequence) + 1
                    hatchCounter = 0
                end
            end
        elseif hatchState == HatchState.Squid then
            hatchSquidAnimator.enabled = true
            hatchTurretAnimator.enabled = false
            hatchFrame = 0
            local hatchSquidCounter = hatchCounter % 60
            if hatchSquidCounter < 40 then hatchFrame = 5 end
            if hatchSquidCounter < 35 then hatchFrame = 4 end
            if hatchSquidCounter < 30 then hatchFrame = 3 end
            if hatchSquidCounter < 10 then hatchFrame = 2 end
            if hatchSquidCounter < 5 then hatchFrame = 1 end
            hatchSquidAnimator.GoTo(hatchFrame)
            if hatchSquidCounter == 10 then
                local spawnArgs = NewJSONObject()
                spawnArgs.AddFieldFloat("focus_x", math.random(350, 620))
                spawnArgs.AddFieldFloat("focus_y", math.random(30, 570))
                SpawnEntityWorld(spawnedEntity, { x = self.worldPosition.x + spawnOffX, y = self.worldPosition.y + spawnOffY }, spawnArgs)
            end
            if hatchCounter >= 60 then
                hatchSquidAnimator.GoTo(0)
                hatchState = HatchState.None
                hatchCounter = 0
            end
        elseif hatchState == HatchState.Turret then
            hatchSquidAnimator.enabled = false
            hatchTurretAnimator.enabled = true
            hatchFrame = 0
            local hatchTurretCounter = hatchCounter % 300
            if hatchTurretCounter < 295 then hatchFrame = 1 end
            if hatchTurretCounter < 290 then hatchFrame = 2 end
            if hatchTurretCounter < 285 then hatchFrame = 3 end
            if hatchTurretCounter < 280 then hatchFrame = 4 end
            if hatchTurretCounter < 275 then hatchFrame = 5 end
            if hatchTurretCounter < 270 then hatchFrame = 6 end
            if hatchTurretCounter < 265 then hatchFrame = 7 end
            if hatchTurretCounter < 35 then hatchFrame = 6 end
            if hatchTurretCounter < 30 then hatchFrame = 5 end
            if hatchTurretCounter < 25 then hatchFrame = 4 end
            if hatchTurretCounter < 20 then hatchFrame = 3 end
            if hatchTurretCounter < 15 then hatchFrame = 2 end
            if hatchTurretCounter < 10 then hatchFrame = 1 end
            if hatchTurretCounter < 5 then hatchFrame = 0 end
            hatchTurretAnimator.GoTo(hatchFrame)
            if hatchTurretCounter == 40 then turretEntityID = CreateTurret(spawnedTurret, turretOffX, turretOffY, self, 0)
            end
            if hatchCounter == 265 then
                local success = GetEntity(turretEntityID)
                if success ~= nil then
                    success.Deactivate()
                    turretEntityID = -1
                end
            end
            if hatchCounter >= 300 then
                hatchTurretAnimator.GoTo(0)
                hatchState = HatchState.None
                hatchCounter = 0
            end
        end
    end

    if self.hitPoints > 0 and self.lifetime % 500 == 0 then
        local missileArgs1 = NewJSONObject()
        local missileArgs2 = NewJSONObject()
        missileArgs1.AddFieldInt("homingDelay", 30)
        missileArgs1.AddFieldInt("currentAngle", -150)
        missileArgs1.AddFieldInt("var5", math.random(0, 360))
        missileArgs2.AddFieldInt("homingDelay", 30)
        missileArgs2.AddFieldInt("currentAngle", 150)
        missileArgs2.AddFieldInt("var5", math.random(0, 360))
		SpawnEntityWorld("homingMissile", { x = self.worldPosition.x + topMissileOffX, y = self.worldPosition.y + topMissileOffY }, missileArgs1)
		SpawnEntityWorld("homingMissile", { x = self.worldPosition.x + bottomMissileOffX, y = self.worldPosition.y + bottomMissileOffY }, missileArgs2)
		if missileSFX ~= "" then PlaySound(missileSFX) end
    end

    if self.hitPoints <= 0 then
        if not octoSpawn then
            local octoArgs = NewJSONObject()
            octoArgs.AddFieldInt("parent_id", self.entityID)
            SpawnEntityWorld("octopusPreview", self.worldPosition, octoArgs)
            octoSpawn = true
        end
        if self.data.endKillTimerOnDeath then self.EndKillTimer() end
        currentFrame = self.animator.totalFrames - 2
        self.hitPoints = self.hitPoints - 1
        if self.lifetime % 10 == 0 and (-math.random(0, 500)) > self.hitPoints then
            for _ = 1, 2 do
                SpawnEntityWorld("explosionMedium", { x = self.worldPosition.x - 200 + math.random(0, 400), y = self.worldPosition.y - 40 - math.random(0, 80) })
            end
        end
        if self.hitPoints <= -500 and self.position.x > 500 and deathFallbackTick < 300 then
            deathFallbackTick = deathFallbackTick + 1
            self.hitPoints = -499
        end
    end
    self.animator.GoTo(currentFrame)
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x - 50, self.worldPosition.y - 100, fruitSets[i]) end
    end
    SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y - 50 })
    SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y - 50 })
    SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y + 50 })
    SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y + 50 })
    self.SpawnShipShards(100, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
    self.SpawnShipDebris(30, -24, 16, -44, 10, 0, 40, 2, 6, 2, 6)
end

function CanFire()
    return self.hitPoints > 0
end

function HasCollision()
    return self.hitPoints > 0
end

function IsKilledManually()
    return true
end

function OnHitByBullet()
	self.hitPoints = math.max(self.hitPoints, 0)
end

function OnHitByPlayer()
	self.hitPoints = math.max(self.hitPoints, 0)
end

function ShouldKillPlayerOnTouch()
    return true
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
