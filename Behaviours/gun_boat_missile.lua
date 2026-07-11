local firePattern
local fireSFX
local timer = 0
local firstLaunch = 36
local sprite
local launcher
local launchSprite = 0
local launchPos = -32
local originOffX
local originOffY

function OnInitialise()
    sprite = self.data.spriteName
    launcher = self.SpawnAttachedSpriteAnimator(sprite, -1, false)
    launcher.position = { x = 0, y = -32 }
    self.animator.Initialise("empty")

    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    originOffX = self.customBehaviourData.GetFieldInt("bulletOriginOffX", 0)
    originOffY = self.customBehaviourData.GetFieldInt("bulletOriginOffY", 0)
end

function OnTick()
    if launchSprite == 0 then
        if timer > 0 then timer = timer - 1 end
        if launchPos > -32 and timer == 0 then launchPos = launchPos - 1 end
    end

    if CanFire() == true then
        firePattern.Tick()
        if firstLaunch > 0 then firstLaunch = firstLaunch - 1 end
        if firePattern.GetTicksTillFire() <= 35 or firstLaunch <= 36 and firstLaunch > 0 then
            launchSprite = 1
            if launchPos <= 0 then launchPos = launchPos + 1 end
        end

        if firePattern.CanFire() and firstLaunch == 0 then
            firePattern.MarkFired()
            launchSprite = 0
            timer = 27

            local missileArgs = NewJSONObject()
            missileArgs.AddFieldInt("homingDelay", 30)
            missileArgs.AddFieldInt("currentAngle", -30)
            missileArgs.AddFieldInt("var5", math.random(0, 360))
            SpawnEntityWorld("homingMissile", { x = self.worldPosition.x + originOffX, y = self.worldPosition.y + originOffY}, missileArgs)
            if fireSFX ~= "" then PlaySound(fireSFX) end
        end
    else
        if firePattern.GetTicksTillFire() > 35 then firePattern.Tick() else firstLaunch = 36 end
        if launchPos > -32 then launchPos = launchPos - 1 end
    end

    launcher.GoTo(launchSprite)
    launcher.position = { x = 0, y = launchPos }
end

function CanFire()
    return self.parent.CanFire()
end
