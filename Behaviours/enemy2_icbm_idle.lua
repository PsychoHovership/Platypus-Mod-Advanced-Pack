local mx
local my = 0
local direction
local trailTimer = 3
local launchTime
local spawnXmin
local spawnXmax
local spawnYmin
local spawnYmax
local spawnY
local spawnX
local isLaunched = false

function OnInitialise()
    self.ChangeLayers(5)
    mx = -Globals.ScrollingSpeed(5) * Globals.backgroundSpeedMultiplier

    direction = self.commandArgs.GetFieldInt("direction")
    launchTime = self.commandArgs.GetFieldInt("launchTime") + 60
    if self.commandArgs.HasField("spawnRange") then
        local s = self.commandArgs.GetFieldIntArray("spawnRange")
        spawnXmin = s[1] or 0
        spawnXmax = s[2] or 0
        spawnYmin = s[3] or 0
        spawnYmax = s[4] or 0
    else
        spawnXmin = -200
        spawnXmax = -200
        spawnYmin = -250
        spawnYmax =  200
    end
    spawnY = math.random( spawnYmin, spawnYmax )
    spawnX = math.random( spawnXmin, spawnXmax )
end

function OnTick()
    if self.worldPosition.x < 700 then
        if launchTime > 0 then launchTime = launchTime - 1
        else
            if my < 3 then my = my + 0.1 else my = my + 0.01 end
            if isLaunched == false then
                PlaySound("s_icbm_launch")
                isLaunched = true
            end
            if trailTimer > 0 then trailTimer = trailTimer - 1
            else
                trailTimer = 3
                local smokeArgs = NewJSONObject()
                smokeArgs.AddFieldFloat("mx", -mx)
                SpawnEntityWorld("icbmTrail2", { x = self.worldPosition.x, y = self.worldPosition.y - 40 }, smokeArgs)
            end
        end
        if launchTime == 50 then PlaySound("s_icbm_siren") end
    end

    if self.worldPosition.y > 200 then
        local missileArgs = NewJSONObject()
        missileArgs.AddFieldInt("direction", direction)
        SpawnEntityWorld("enemy2_icbm", { x = spawnX, y = spawnY }, missileArgs)
        self.Deactivate()
    end
    self.movement = { x = mx, y = my, z = 0 }
end

function HasCollision()
    return false
end
