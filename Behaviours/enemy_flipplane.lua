local mx = 5
local flipFrame = 21
local oldDamageFrame = 0
local newDamageFrame = 0
local totalDamageFrames
local totalFlipFrames
local turretEntity1
local turretPosX1
local turretPosY1
local turretEntity2
local turretPosX2
local turretPosY2
local fruitSets = {}

function OnInitialise()
    if self.customBehaviourData.HasField("fruitSets") then
        local f = self.customBehaviourData.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end

    totalDamageFrames = self.customBehaviourData.GetFieldInt("damageFrames", 5)
    totalFlipFrames = self.animator.totalFrames - totalDamageFrames
    turretEntity1 = self.customBehaviourData.GetFieldString("topTurretEntity", "")
    turretPosX1 = self.customBehaviourData.GetFieldInt("topTurretX", 0)
    turretPosY1 = self.customBehaviourData.GetFieldInt("topTurretY", 0)
    turretEntity2 = self.customBehaviourData.GetFieldString("bottomTurretEntity", "")
    turretPosX2 = self.customBehaviourData.GetFieldInt("bottomTurretX", 0)
    turretPosY2 = self.customBehaviourData.GetFieldInt("bottomTurretY", 0)
end

function OnTick()
    self.movement = { x = mx * 1.3, y = 0, z = 0 }
    if self.lifetime > 80 then
        if mx > -1 then mx = mx - 0.05 else mx = -1 end
    end

    if self.lifetime == 146 then
        if turretEntity1 ~= "" then CreateTurret(turretEntity1, turretPosX1, turretPosY1, self, Globals.firewait) end
        if turretEntity2 ~= "" then CreateTurret(turretEntity2, turretPosX2, turretPosY2, self, Globals.firewait) end
    end

    if self.lifetime > 40 then
        oldDamageFrame = newDamageFrame
        newDamageFrame = self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, totalDamageFrames)
        self.HandleDamageEffects(newDamageFrame, oldDamageFrame)
    end
    flipFrame = Lerp(0, totalFlipFrames - 1, (self.lifetime - 130) / (145 - 130))
    if self.lifetime < 146 then self.animator.GoTo(flipFrame) else self.animator.GoTo(newDamageFrame + totalFlipFrames) end

    if self.position.x < AdjustXToWideScreen(-150) and mx < 0 then self.Deactivate() end
end

function OnHitByBullet()
    if self.position.x <= 770 and mx < 1 then mx = 0.65 end
end

function OnKill()
    if fruitSets ~= nil then
        for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
    end
    self.SpawnShipShards(80, -14, 8, -22, 5, 0, -40, 2, 6, 2, 6)
    self.SpawnShipDebris(8, -14, 8, -22, 5, 0, -40, 2, 6, 2, 6)
end

function CanFire()
    return self.lifetime >= 146 and self.position.x > 60
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.lifetime > 70
end
