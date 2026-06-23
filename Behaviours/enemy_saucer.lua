
local my
local myMax
local yAcceleration

local allowedToShoot
local firePattern

local fireSFX

local shootMinX = 60
local shootMaxX = 620

function OnInitialise()
    my = self.commandArgs.GetFieldFloat("speedY", self.data.speed)
    myMax = self.commandArgs.GetFieldFloat("maxSpeedY", self.data.speed * 1.25)
    fireSFX = self.commandArgs.GetFieldString("fireSFX", "s_laser2")

    allowedToShoot = math.random(0, 100) < Globals.firingChanceSaucer.Get()
    firePattern = NewFirePatternFromEntityData(self.data)

    yAcceleration = myMax / 25
end

function OnTick()
    if math.abs(my) >= myMax then
        yAcceleration = -yAcceleration
    end
    my = my + yAcceleration

    self.movement = { x = -4, y = my, z = 0 }

    local spriteIndex = Round((1 + (my / myMax)) * (self.animator.totalFrames - 1) * 0.7)
    spriteIndex = Clamp(spriteIndex, 0, self.animator.totalFrames - 1)
    self.animator.AnimateTo(spriteIndex);

    if CanFire() then
        firePattern.Tick()

        if firePattern.CanFire() then
            firePattern.MarkFired()
            SpawnSimpleBullet(self.worldPosition.x, self.worldPosition.y)
            PlaySound(fireSFX)
        end
    end

    if self.position.x < -160 then
        self.Deactivate()
    end
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function CanFire()
    return allowedToShoot and self.position.x > shootMinX and self.position.x < shootMaxX
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
