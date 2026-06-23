local mx = -3
local my = 0
local dx = 0
local dy = 0
local target = nil
local length
local speed = 6
local timer
local fireTimer = 100
local targetTimer
local leaveTimer = 1200
local knockback = 0
local finSprite
local finCollider = nil
local t = 1

function OnInitialise()
    timer = math.random(0, 30)
    targetTimer = math.random(50, 200)

    finSprite = self.SpawnAttachedSpriteAnimator("Sprites/Enemies/squid bottom", -1)
    finSprite.position = { x = 20, y = 3 }

    if finSprite ~= nil then finCollider = finSprite.AddCollider(); finCollider.SetLogicLayerEnemy() end
end

function OnTick()
    finSprite.AnimateToNextFrame(true)

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if timer > 0 then timer = timer - 1 else t = t + 0.05 end
    
    if target == nil then target = GetRandomActivePlayer() elseif target ~= nil and not target.isActive then target = nil end
    if target ~= nil then
        dx = target.worldPosition.x - self.worldPosition.x
        dy = target.worldPosition.y - self.worldPosition.y
        length = math.sqrt(dx * dx + dy * dy)
        dx = dx / length
        dy = dy / length
        my = dy
    end

    if leaveTimer > 0 then
        leaveTimer = leaveTimer - 1
        if dx > 0 or length < 200 then
            if self.position.x < 700 then mx = mx + 0.2 else mx = mx - 0.2 end
        else mx = mx - 0.2 end
    else mx = mx - 0.2 end
    if mx < -3 then mx = -3 elseif mx > 5 then mx = 5 end
    if knockback > 0 then knockback = knockback - 0.1 else knockback = 0 end

    self.movement = { x = mx + knockback, y = (my + (math.sin(t) * 0.3 )) * speed, z = 0 }

    if fireTimer > 0 then fireTimer = fireTimer - 1 end
    if CanFire() then
        if targetTimer > 0 then targetTimer = targetTimer - 1 else targetTimer = math.random(50, 200); target = nil end
    end

    if self.position.x < -150 then self.Deactivate() end
end

function OnHitByBullet()
    if self.position.x <= 700 then
        knockback = 4
    end
end

function OnKill()
    self.SpawnShipDebris( 5, -6, 0, -5, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipShards( 15, -6, 0, -5, 5, 0, 0, 0, 0, 0, 0)
end

function CanFire()
    return fireTimer == 0
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
