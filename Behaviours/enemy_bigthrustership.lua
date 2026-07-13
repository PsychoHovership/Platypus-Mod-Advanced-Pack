local mx = 0
local my = 0
local yAcceleration = 1
local topWingSprite
local topWingOffX
local topWingOffY
local topWingHitPoints
local topWingMaxHitPoints
local topWingAnimator
local topWingCollider
local bottomWingSprite
local bottomWingOffX
local bottomWingOffY
local bottomWingHitPoints
local bottomWingMaxHitPoints
local bottomWingAnimator
local bottomWingCollider
local engineSprite
local engineOffX
local engineOffY
local engineHitPoints
local engineMaxHitPoints
local engineAnimator
local engineCollider
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

    topWingSprite = self.customBehaviourData.GetFieldString("topWingSprite", "")
    topWingOffX = self.customBehaviourData.GetFieldFloat("topWingOffX", 0)
    topWingOffY = self.customBehaviourData.GetFieldFloat("topWingOffY", 0)
    topWingHitPoints = self.customBehaviourData.GetFieldFloat("topWingHitPoints", 400)
    topWingMaxHitPoints = topWingHitPoints
    if topWingSprite ~= "" then
        topWingAnimator = self.SpawnAttachedSpriteAnimator(topWingSprite, -1)
        topWingAnimator.position = { x = topWingOffX, y = topWingOffY }
        topWingCollider = topWingAnimator.AddCollider()
    end

    bottomWingSprite = self.customBehaviourData.GetFieldString("bottomWingSprite", "")
    bottomWingOffX = self.customBehaviourData.GetFieldFloat("bottomWingOffX", 0)
    bottomWingOffY = self.customBehaviourData.GetFieldFloat("bottomWingOffY", 0)
    bottomWingHitPoints = self.customBehaviourData.GetFieldFloat("bottomWingHitPoints", 400)
    bottomWingMaxHitPoints = bottomWingHitPoints
    if bottomWingSprite ~= "" then
        bottomWingAnimator = self.SpawnAttachedSpriteAnimator(bottomWingSprite, -1)
        bottomWingAnimator.position = { x = bottomWingOffX, y = bottomWingOffY }
        bottomWingCollider = bottomWingAnimator.AddCollider()
    end

    engineSprite = self.customBehaviourData.GetFieldString("engineSprite", "")
    engineOffX = self.customBehaviourData.GetFieldFloat("engineOffX", 0)
    engineOffY = self.customBehaviourData.GetFieldFloat("engineOffY", 0)
    engineHitPoints = self.customBehaviourData.GetFieldFloat("engineHitPoints", 600)
    engineMaxHitPoints = engineHitPoints
    if engineSprite ~= "" then
        engineAnimator = self.SpawnAttachedSpriteAnimator(engineSprite, -1)
        engineAnimator.position = { x = engineOffX, y = engineOffY }
        engineCollider = engineAnimator.AddCollider()
    end

    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldInt("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldInt("smokeTrailPosY", 0)
end

function OnTick()
    if self.position.x > 950 or self.position.x < -300 or self.position.y > 650 then self.Deactivate() end
    self.movement = { x = mx, y = my / 16, z = 0 }

    if topWingAnimator ~= "" and topWingCollider ~= nil and topWingHitPoints > 0 then
        self.CheckCollision(topWingCollider, nil, function(x)
            topWingHitPoints = topWingHitPoints - x.BulletConsume(self)
        end)
        topWingAnimator.GoTo(self.GetDamageFrame(topWingMaxHitPoints, topWingHitPoints, topWingAnimator.totalFrames))
        if topWingHitPoints <= 0 then
            SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + topWingOffX - 20, y = self.worldPosition.y + topWingOffY + 30 })
            self.SpawnShipShards(40, -14, 7, -22, 4, topWingOffX - 20, topWingOffY + 30, 2, 5, 2, 5)
        end
    end

    if bottomWingAnimator ~= "" and bottomWingCollider ~= nil and bottomWingHitPoints > 0 then
        self.CheckCollision(bottomWingCollider, nil, function(x)
            bottomWingHitPoints = bottomWingHitPoints - x.BulletConsume(self)
        end)
        bottomWingAnimator.GoTo(self.GetDamageFrame(bottomWingMaxHitPoints, bottomWingHitPoints, bottomWingAnimator.totalFrames))
        if bottomWingHitPoints <= 0 then
            SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + bottomWingOffX - 20, y = self.worldPosition.y + bottomWingOffY - 30 })
            self.SpawnShipShards(40, -14, 7, -22, 4, bottomWingOffX - 20, bottomWingOffY - 30, 2, 5, 2, 5)
        end
    end

    if engineAnimator ~= "" and engineCollider ~= nil and engineHitPoints > 0 then
        self.CheckCollision(engineCollider, nil, function(x)
            engineHitPoints = engineHitPoints - x.BulletConsume(self)
        end)
        engineAnimator.GoTo(self.GetDamageFrame(engineMaxHitPoints, engineHitPoints, engineAnimator.totalFrames - 1))
        if engineHitPoints <= 0 then
            SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + engineOffX - 30, y = self.worldPosition.y + engineOffY })
            engineAnimator.GoTo(engineAnimator.totalFrames - 1)
            self.SpawnShipShards(40, -14, 7, -22, 4, engineOffX - 30, engineOffY, 2, 5, 2, 5)
        end
    end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.lifetime < 400 and mx > 0 then mx = mx - 0.015 end

    if smokeTrailEntity ~= "" and Globals.levelLifetime % 40 == 0 and engineHitPoints > 0 then
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 2)
        smokeArgs.AddFieldInt("layer", 1)
        smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
        SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
    end

    if engineHitPoints <= 0 and self.lifetime > 2000 and mx > -2 then mx = mx - 0.01 end
    if self.lifetime > 2500 and engineHitPoints > 0 then mx = mx + 0.01 end
    my = my + yAcceleration

    if topWingHitPoints <= 0 and bottomWingHitPoints <= 0 then
        yAcceleration = yAcceleration - 0.01
        yAcceleration = math.max(-0.5, math.min(0.5, yAcceleration))
    end

    if my > 40 then
        if topWingHitPoints > 0 then yAcceleration = -2 else yAcceleration = -0.2 end
    end
    if my < -40 then
        if bottomWingHitPoints > 0 then yAcceleration = 2 else yAcceleration = 0.2 end
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.lifetime > 140
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x - 50, self.worldPosition.y - 100, fruitSets[i]) end
    end
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y - 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y - 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 50, y = self.worldPosition.y + 50 })
	SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 50, y = self.worldPosition.y + 50 })
	self.SpawnShipShards(160, -14, 7, -22, 4, 0, 40, 2, 5, 2, 5)
    self.SpawnShipDebris(40, -24, 15, -44, 9, 0, 40, 2, 5, 2, 5)
end

function CanFire()
    if self.position.x > 50 then return self.position.y < 650 end
    return false
end
