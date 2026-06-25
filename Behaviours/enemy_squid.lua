local mx = -3
local my = 0
local dx = 0
local dy = 0
local length
local speed = 6
local timer
local fireTimer = 100
local leaveTimer = 1200
local finSprite
local finCollider = nil
local t = 1

local posY = 0

local focusx = 0
local focusy = 0

function OnInitialise()

    focusx = self.commandArgs.GetFieldInt("focus_x")
    focusy = self.commandArgs.GetFieldInt("focus_y")

    timer = math.random(0, 30)

    finSprite = self.SpawnAttachedSpriteAnimator("Sprites/Enemies/squid bottom", -1)
    finSprite.position = { x = 1.5, y = -37.5 }

    if finSprite ~= nil then finCollider = finSprite.AddCollider(); finCollider.SetLogicLayerEnemy() end

end

function OnTick()

    -- ANIMATION

    finSprite.AnimateToNextFrame(true)

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if timer > 0 then timer = timer - 1 else t = t + 0.05 end
    


    local posY = self.position.y

    -- MOVEMENT

        dx = focusx --
        dy = focusy --
        length = math.sqrt(dx * dx + dy * dy)
        --dx = dx / length
        --dy = dy / length
        --my = dy


    if leaveTimer > 0 then
        leaveTimer = leaveTimer - 1

        --if dx > 0 or length < 200 then
        if self.position.x > focusx then mx = mx - 0.2 else mx = mx + 0.2 end
        if self.position.y > focusy then --my = my - 0.2 else my = my + 0.2 end
        self.position.y = posY - 0.2 else
        self.position.y = posY + 0.2 end
        --else mx = mx - 0.2 end

      


    else mx = mx - 0.2 end



    if mx < -3 then mx = -3 elseif mx > 5 then mx = 5 end
    --if my < -3 then my = -3 elseif my > 5 then my = 5 end

    

    self.movement = { x = mx, y = my, z = 0 }

    if fireTimer > 0 then fireTimer = fireTimer - 1 end

    if self.position.x < -150 then self.Deactivate() end

end

function OnHitByBullet()
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
