local speed1
local speed2
local speed3
local speed4
local speed5
local speedT
local entity
local spawnDistance
local firePattern
local fireSFX
local cycle1
local cycle2
local cycle3
local cycle4
local cycle5
local baseCycle
local currentCycle
local firstShot
local spriteIndex = 1
local spriteTimer = 0
local spriteThreshold = 1
local switchTimer = 120
local isSwitching = true
local gunAngle = 90
local flip = 1

function OnInitialise()
    self.animator.GoTo(spriteIndex)

    if self.customBehaviourData.HasField("bulletSpeed") then
        local d = self.customBehaviourData.GetFieldFloatArray("bulletSpeed")
        speed1 = d[1]
        speed2 = d[2]
        speed3 = d[3]
        speed4 = d[4]
        speed5 = d[5]
    else
        speed1 = 0
        speed2 = 0
        speed3 = 0
        speed4 = 0
        speed5 = 0
    end
    speedT = NewDiffDictFloat(speed1, speed2, speed3, speed4, speed5).Get()
    entity = self.customBehaviourData.GetFieldString("bulletEntity", "")
    spawnDistance = self.customBehaviourData.GetFieldFloat("bulletSpawnDistance", 0)

    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser2")
    firstShot = math.max(self.customBehaviourData.GetFieldInt("firstShotDelay", 100), 100)
    if self.customBehaviourData.HasField("shotsTillSwitch") then
        local c = self.customBehaviourData.GetFieldIntArray("shotsTillSwitch")
        cycle1 = c[1]
        cycle2 = c[2]
        cycle3 = c[3]
        cycle4 = c[4]
        cycle5 = c[5]
    else
        cycle1 = 1
        cycle2 = 1
        cycle3 = 1
        cycle4 = 1
        cycle5 = 1
    end
    baseCycle = NewDiffDictInt(cycle1, cycle2, cycle3, cycle4, cycle5).Get()
    currentCycle = baseCycle
end

function OnTick()
    firePattern.Tick()
    if CanFire() == true then
        if firstShot > 0 then firstShot = firstShot - 1 end
        if firePattern.CanFire() and firstShot == 0 and isSwitching == false then
            firePattern.MarkFired()
            if flip == 1 then spriteIndex = 0 elseif flip == -1 then spriteIndex = 6 end
            spriteTimer = 10
            if currentCycle > 0 then currentCycle = currentCycle - 1 end
            PlaySound(fireSFX)
            for i = 1, 5 do
                local shotAngle = (i / 5) * (2 * math.pi) + math.rad(gunAngle)
                local args = NewJSONObject()
                args.AddFieldFloat("mx", math.cos(shotAngle) * speedT * Globals.enemyShotSpeedMultiplier)
                args.AddFieldFloat("my", math.sin(shotAngle) * speedT * Globals.enemyShotSpeedMultiplier)
                SpawnEntityWorld(entity, { x = self.worldPosition.x + math.cos(shotAngle) * spawnDistance, y = self.worldPosition.y + math.sin(shotAngle) * spawnDistance }, args)
            end
        end
    end

    if currentCycle == 0 then
        currentCycle = baseCycle
        switchTimer = 50
        isSwitching = true
    end

    if flip == 1 then gunAngle = 90 elseif flip == -1 then gunAngle = 126 end
    if isSwitching == true then
        if switchTimer > 0 then switchTimer = switchTimer - 1 end
        if switchTimer <= 25 then
            if flip == 1 then spriteThreshold = 5 elseif flip == -1 then spriteThreshold = 1 end
        end
        if switchTimer == 0 then
            flip = -flip
            if firstShot <= 10 then firstShot = 10 end
            isSwitching = false
        end
    end

    if spriteTimer > 0 then spriteTimer = spriteTimer - 1 else
        if spriteIndex ~= spriteThreshold then
            spriteTimer = 5
            if flip == 1 then spriteIndex = spriteIndex + 1 elseif flip == -1 then spriteIndex = spriteIndex - 1 end
        end
    end
    self.animator.GoTo(spriteIndex)
end

function CanFire()
    return self.parent.CanFire()
end