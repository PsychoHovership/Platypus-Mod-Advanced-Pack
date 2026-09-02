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
local hatchSprite
local hatchAnimator
local hatchOffX
local hatchOffY
local spawnedEntity
local spawnOffX
local spawnOffY
local fruitSets = {}

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

    hatchOffX = self.customBehaviourData.GetFieldFloat("hatchOffX", -28)
    hatchOffY = self.customBehaviourData.GetFieldFloat("hatchOffY", 68)
    hatchSprite = self.customBehaviourData.GetFieldString("hatchSprite", "Sprites/Boss 4/squid mother hatch")
    hatchAnimator = self.SpawnAttachedSpriteAnimator(hatchSprite, self.customBehaviourData.GetFieldInt("hatchSortOffset", 1))
    hatchAnimator.position = { x = hatchOffX, y = hatchOffY }

	spawnedEntity = self.customBehaviourData.GetFieldString("spawnedEntity", "squid")
    spawnOffX = self.customBehaviourData.GetFieldFloat("spawnOffX", 25)
    spawnOffY = self.customBehaviourData.GetFieldFloat("spawnOffY", 25)
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }
    mx = mx + RandRangeF(-0.05, 0.05)
    my = my + RandRangeF(-0.05, 0.05)
    if self.position.x > (targetX + 30) and mx > -4 then mx = mx - 0.05 end
    if self.position.x < (targetX - 30) and mx < 4 then mx = mx + 0.05 end
    if self.position.y > (targetY + 50) and my > -4 then my = my - 0.05 end
    if self.position.y < (targetY - 50) and my < 4 then my = my + 0.05 end

    local oldFrame = self.animator.currentFrame
    local currentFrame = self.GetDamageFrame(self.hitPoints)
    self.HandleDamageEffects(currentFrame, oldFrame)

    if self.lifetime > hangtime then
        targetX = -1000
        if self.position.x < -400 then self.Deactivate() end
    end
    if oldFrame ~= currentFrame then CreateExplosionSquare(self.worldPosition.x - 30, self.worldPosition.y + 80, 240, 246) end
    if self.hitPoints < -500 then self.Kill() end

    if self.hitPoints > 0 then
        if self.lifetime % 500 == 0 then
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
        local hatchFrame = 0
        if self.lifetime % 660 > 480 then
            if self.lifetime % 60 < 40 then hatchFrame = 5 end
            if self.lifetime % 60 < 35 then hatchFrame = 4 end
            if self.lifetime % 60 < 30 then hatchFrame = 3 end
            if self.lifetime % 60 < 10 then hatchFrame = 2 end
            if self.lifetime % 60 < 5 then hatchFrame = 1 end
            hatchAnimator.GoTo(hatchFrame)
            if self.lifetime % 60 < 10 == 10 then
                local spawnArgs = NewJSONObject()
                spawnArgs.AddFieldFloat("focus_x", math.random(350, 620))
                spawnArgs.AddFieldFloat("focus_y", math.random(30, 570))
                SpawnEntityWorld(spawnedEntity, { x = self.worldPosition.x + spawnOffX, y = self.worldPosition.y + spawnOffY }, spawnArgs)
            end
        end
    end

    if self.hitPoints <= 0 then
        if self.data.endKillTimerOnDeath then self.EndKillTimer() end
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
    self.SpawnShipShards(160, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
    self.SpawnShipDebris(40, -24, 16, -44, 10, 0, 40, 2, 6, 2, 6)
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
