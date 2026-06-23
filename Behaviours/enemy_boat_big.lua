local mx

local wake

function OnInitialise()
    if self.commandArgs.HasField("speedX") then mx = self.commandArgs.GetFieldFloat("speedX") else mx = 0.3 end
    
    wake = self.SpawnAttachedSpriteAnimator("Effects/Water/boat wake 2", 1)
    wake.position = { x = -70, y = -48 }
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }

    if self.position.x < -300 then self.Deactivate() end
    if self.position.x > 950 then self.Deactivate() end

    local damageframe = self.GetDamageFrame(self.hitPoints)
    self.animator.AnimateTo(damageframe)
    
    wake.AnimateToNextFrame(true)
end

function OnKill()
    self.SpawnShipShards(32, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(32, -12, 8, -20, 0, 0, 0, 0, 10, 0, 5)

    local pos1 = { x = self.worldPosition.x - 20, y = self.worldPosition.y }
    local pos2 = { x = self.worldPosition.x + 80, y = self.worldPosition.y }

    SpawnEntityWorld("explosionBig", pos1, NewJSONObject())
    SpawnEntityWorld("explosionBig", pos2, NewJSONObject())
end

function CanFire()
    return self.position.x >= 154.5 and mx > 0 or self.position.x <= 770.5 and mx < 0
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x > -50 or mx <= 0
end