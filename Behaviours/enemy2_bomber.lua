local mx = 0.3
local timer = 0
local trailTimer = 0

local planeSprite = 0

local mineSprite
local minePeekX = -5
local minePeekY = -5

local firePattern
local fireSFX

local firstLaunch = 20

function OnInitialise()
    mineSprite = self.SpawnAttachedSpriteAnimator("Effects/Bullets/bullet bomb", -100, false)
    mineSprite.position = { x = -5, y = -5 }
    mineSprite.Initialise("empty")

    if self.commandArgs.HasField("fireSFX") then fireSFX = self.commandArgs.GetFieldString("fireSFX") else fireSFX = "s_enemyfire_bomber" end
    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    self.animator.AnimateTo(planeSprite)

    mineSprite.position = { x = minePeekX, y = minePeekY }

    if ShouldKillPlayerOnTouch() == true then
        if timer >= 0 then
            timer = timer - 1
        end

        if timer <= 0 and planeSprite < 3 then
            timer = 10
            planeSprite = planeSprite + 1
        elseif timer <= 0 and planeSprite >= 3 then
            planeSprite = planeSprite + 1
            mineSprite.Initialise("Effects/Bullets/bullet bomb", 0)
        end
    end

    self.movement = { x = mx, y = 0, z = 0 }
    mx = mx + 0.001

    local smokePos = { x = self.worldPosition.x - 70, y = self.worldPosition.y + 13 }

    trailTimer = trailTimer - 1
    if trailTimer <= 0 then
        trailTimer = 16

        local smokeArgs = NewJSONObject()
        local smokeTrail = 1

        smokeArgs.AddFieldFloat("mx", smokeTrail)
        SpawnEntityWorld("smokeRing3", smokePos, smokeArgs)
    end

    if CanFire() == true then
        firePattern.Tick()
        if firstLaunch > 0 then
            firstLaunch = firstLaunch - 1
        end

        if firePattern.GetTicksTillFire() == 15 or firstLaunch == 15 then
            PlaySound(fireSFX)
        end

        if firePattern.GetTicksTillFire() <= 20 or firstLaunch <= 20 and firstLaunch > 0 then
            minePeekX = minePeekX - 1
            minePeekY = minePeekY - 3
        end

        if firePattern.CanFire() and firstLaunch <= 0 then
            firePattern.MarkFired()
            minePeekX = -5
            minePeekY = -5
            mineSprite.position = { x = -5, y = -5 }

            local minePos = { x = self.worldPosition.x - 25, y = self.worldPosition.y - 65 }

            local mineArgs = NewJSONObject()
            mineArgs.AddFieldFloat("my", -3)

            SpawnEntityWorld("enemyshot_bomb", minePos, mineArgs)
        end
    end
            
    if self.position.x > 840 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return self.position.x >= 20
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= -20
end
