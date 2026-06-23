local firePattern
local timer = 0
local firstLaunch = 36
local sprite
local launcher
local launchSprite = 0
local launchPos = -30

function OnInitialise()
    sprite = self.data.spriteName
    launcher = self.SpawnAttachedSpriteAnimator(sprite, -100, false)
    launcher.position = { x = 0, y = -30 }
    self.animator.Initialise("empty")

    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    launcher.AnimateTo(launchSprite)
    launcher.position = { x = 0, y = launchPos }

    if launchSprite == 0 then
        if timer > 0 then
            timer = timer - 1
        end

        if launchPos >= -30 and timer <= 0 then
            launchPos = launchPos - 1
        end
    end

    if CanFire() == true then
        firePattern.Tick()
        if firstLaunch > 0 then
            firstLaunch = firstLaunch - 1
        end

        if firePattern.GetTicksTillFire() <= 36 or firstLaunch <= 36 and firstLaunch > 0 then
            launchSprite = 1
            if launchPos <= 0 then
                launchPos = launchPos + 1
            end
        end

        if firePattern.CanFire() and firstLaunch <= 0 then
            firePattern.MarkFired()
            launchSprite = 0
            timer = 27
            PlaySound("s_woosh")
        
            local missilePos = { x = self.worldPosition.x, y = self.worldPosition.y + 13}

            local missileArgs = NewJSONObject()
            missileArgs.AddFieldInt("homingDelay", 30)
            missileArgs.AddFieldInt("currentAngle", -30)

            SpawnEntityWorld("homingMissile", missilePos, missileArgs)
        end
    elseif CanFire() == false then
        if firePattern.GetTicksTillFire() >= 36 then
            firePattern.Tick()
        elseif firePattern.GetTicksTillFire() < 36 then
            firstLaunch = 36
        end

        if launchPos >= -30 then
            launchPos = launchPos - 1
        end
    end
end

function CanFire()
    return self.parent.CanFire()
end