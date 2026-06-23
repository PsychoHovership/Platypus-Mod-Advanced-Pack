local mx

local wake

function OnInitialise()
    if self.commandArgs.HasField("speedX") then mx = self.commandArgs.GetFieldFloat("speedX") else mx = 0.3 end
    
    wake = self.SpawnAttachedSpriteAnimator("Effects/Water/boat wake", 1)
    wake.position = { x = -20, y = -20 }
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }

    if self.position.x < -200 then self.Deactivate() end
    if self.position.x > 860 then self.Deactivate() end

    local damageframe = self.GetDamageFrame(self.hitPoints)
    self.animator.AnimateTo(damageframe)
    
    wake.AnimateToNextFrame(true)
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return self.position.x >= 56.2 and mx > 0 or self.position.x <= 683.8 and mx < 0
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x > 10 or mx <= 0
end