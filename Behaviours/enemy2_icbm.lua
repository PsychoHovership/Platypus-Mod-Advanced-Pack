local mx = 0
local my
local speed
local direction = -90
local angle
local sprite
local trailTimer = 3
local dx1 = 0
local dy1 = 0
local dx2 = 0
local dy2 = 0
local vx1 = 0
local vy1 = 0
local vx2 = 0
local vy2 = 0
local player1
local player2
local length1
local length2
local distance1
local distance2

function OnInitialise()
    angle = (direction % 360 + 101.25) % 360
    sprite = math.floor((angle / (360.0 / self.animator.totalFrames) + self.animator.totalFrames/2) % self.animator.totalFrames)
    self.animator.GoTo(sprite)

    speed = NewDiffDictFloat(3.0, 4.0, 5.0, 6.0, 7.0).Get()
    my = speed
end

function OnTick()
    local r = 65
    local ox = 0
    local oy = 0
    if sprite == 0 then         ox =  0;        oy = -r
    elseif sprite == 1 then     ox =  r*0.38;   oy = -r*0.92
    elseif sprite == 2 then     ox =  r*0.71;   oy = -r*0.71
    elseif sprite == 3 then     ox =  r*0.92;   oy = -r*0.38
    elseif sprite == 4 then     ox =  r;        oy =  0
    elseif sprite == 5 then     ox =  r*0.92;   oy =  r*0.38
    elseif sprite == 6 then     ox =  r*0.71;   oy =  r*0.71
    elseif sprite == 7 then     ox =  r*0.38;   oy =  r*0.92
    elseif sprite == 8 then     ox =  0;        oy =  r
    elseif sprite == 9 then     ox = -r*0.38;   oy =  r*0.92
    elseif sprite == 10 then    ox = -r*0.71;   oy =  r*0.71
    elseif sprite == 11 then    ox = -r*0.92;   oy =  r*0.38
    elseif sprite == 12 then    ox = -r;        oy =  0
    elseif sprite == 13 then    ox = -r*0.92;   oy = -r*0.38
    elseif sprite == 14 then    ox = -r*0.71;   oy = -r*0.71
    elseif sprite == 15 then    ox = -r*0.38;   oy = -r*0.92
    end

    if trailTimer > 0 then trailTimer = trailTimer - 1
    else
        trailTimer = 3
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 0)
        SpawnEntityWorld("icbmTrail", { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy}, smokeArgs)
    end
    if self.position.x < -300 and mx < 0 then self.Deactivate() end
    if self.position.x >  900 and mx > 0 then self.Deactivate() end
    if self.position.y > 1000 and my > 0 then self.Deactivate() end
    if self.worldPosition.y < -450 then
        SpawnEntityWorld("explosionHuge", { x = self.worldPosition.x, y = self.worldPosition.y + 150 })
        self.SpawnShipShards(60, -15, 15, -60, 30, 0, 0, 0, 0, 0, 0)
        self.Deactivate()
    end

    player1 = GetPlayer(0)
    if player1.isActive then
        dx1 = player1.worldPosition.x - (self.worldPosition.x + (math.cos(math.rad(direction)) * 240))
        dy1 = player1.worldPosition.y - (self.worldPosition.y + (math.sin(math.rad(direction)) * 240))
        vx1 = player1.worldPosition.x - self.worldPosition.x
        vy1 = player1.worldPosition.y - self.worldPosition.y
        distance1 = math.sqrt(dx1 * dx1 + dy1 * dy1)
        length1 = math.sqrt(vx1 * vx1 + vy1 * vy1)
        dx1 = dx1 / distance1
        dy1 = dy1 / distance1
        if distance1 < 200 then player1.TriggerWarning() end
    else length1 = 1000
    end
    player2 = GetPlayer(1)
    if player2.isActive then
        dx2 = player2.worldPosition.x - (self.worldPosition.x + (math.cos(math.rad(direction)) * 240))
        dy2 = player2.worldPosition.y - (self.worldPosition.y + (math.sin(math.rad(direction)) * 240))
        vx2 = player2.worldPosition.x - self.worldPosition.x
        vy2 = player2.worldPosition.y - self.worldPosition.y
        distance2 = math.sqrt(dx2 * dx2 + dy2 * dy2)
        length2 = math.sqrt(vx2 * vx2 + vy2 * vy2)
        dx2 = dx2 / distance2
        dy2 = dy2 / distance2
        if distance2 < 200 then player2.TriggerWarning() end
    else length2 = 1000
    end
    if player1.isActive or player2.isActive then
        if length1 > length2 then
            local sourcePos = self.worldPosition
            local targetPos = player2.worldPosition
            local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
            direction = MoveTowardsAngle(direction, targetAngle, 4)
        else
            local sourcePos = self.worldPosition
            local targetPos = player1.worldPosition
            local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
            direction = MoveTowardsAngle(direction, targetAngle, 4)
        end
    end

    if direction < -135 then direction = -135 elseif direction > -45 then direction = -45 end
    angle = (direction % 360 + 101.25) % 360
    sprite = math.floor((angle / (360.0 / self.animator.totalFrames) + self.animator.totalFrames/2) % self.animator.totalFrames)
    self.animator.GoTo(sprite)
    
    mx = math.cos(math.rad(direction)) * speed
    my = math.sin(math.rad(direction)) * speed
    self.movement = { x = mx, y = my, z = 0 }
end

function OnKill()
    self.SpawnShipShards(60, -15, 15, -60, 30, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
