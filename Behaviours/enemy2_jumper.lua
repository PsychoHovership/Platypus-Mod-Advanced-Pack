local mx
local mx1
local mx2
local my
local my1
local my2
local myMax
local acceleration
local timer
local spriteTimer = 0
local trailTimer = 0
local sprite = 7
local jumped = false
local iFrames = 40

function OnInitialise()
    if self.commandArgs.HasField("speedX") then
        local x = self.commandArgs.GetFieldFloatArray("speedX")
        mx1 = x[1] or 0
        mx2 = x[2] or 0
    else
        mx1 = -1
        my2 = 1
    end
    if self.commandArgs.HasField("speedY") then
        local y = self.commandArgs.GetFieldFloatArray("speedY")
        my1 = y[1] or 0
        my2 = y[2] or 0
    else
        my1 = 9
        my2 = 10
    end
    if self.commandArgs.HasField("upwardTime") then timer = self.commandArgs.GetFieldInt("upwardTime") else timer = 0 end
    if self.commandArgs.HasField("downwardMax") then myMax = self.commandArgs.GetFieldFloat("downwardMax") else myMax = -6 end
    if self.commandArgs.HasField("acceleration") then acceleration = self.commandArgs.GetFieldFloat("acceleration") else acceleration = 2 end

    mx = math.random(mx1, mx2)
    my = math.random(my1, my2)
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }
    self.animator.GoTo(sprite)

    if timer > 0 then
        timer = timer - 1
    else
        if my > myMax then my = my - ( 0.05 * acceleration ) end
    end
    if my <= 2 then
        if spriteTimer > 0 then spriteTimer = spriteTimer - 1 end
        if spriteTimer <= 0 and sprite > 0 then
            spriteTimer = spriteTimer + ( 12 / acceleration )
            sprite = sprite - 1
        end
    end

    if trailTimer > 0 then
        trailTimer = trailTimer - 1
    else
        if my >= 3 then
            trailTimer = 3
            SpawnEntityWorld("rocketTrail", { x = self.worldPosition.x - 1, y = self.worldPosition.y - 10 }, NewJSONObject())
        end
    end
    if iFrames > 0 and jumped == true then iFrames = iFrames - 1 end
    if self.position.y >= -650 and jumped == false then
        if Globals.createSplashes == true then self.CreateFancySplashes() end
        jumped = true
    end
    if Globals.createSplashes == true then
        if self.position.y < -580 and my < 0 then
            self.CreateFancySplashes()
            self.Deactivate()
        end
    else
        if self.position.y < -700 and my < 0 then self.Deactivate() end
    end
    if self.position.y > 1000 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(24, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return iFrames <= 0
end
