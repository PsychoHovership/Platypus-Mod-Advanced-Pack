local mx = 0
local decoy
local missileType
local missileCount
local offset = 0
local direction
local spawnXmin
local spawnXmax
local spawnYmin
local spawnYmax
local launchTime
local launchTimeMin
local launchTimeMax

function OnInitialise()
    self.ChangeLayers(5)
    mx = -Globals.ScrollingSpeed(5) * Globals.backgroundSpeedMultiplier
    decoy = self.commandArgs.GetFieldBool("decoy", false)
    missileType = self.commandArgs.GetFieldInt("type", 0)
    if decoy == false then
        missileCount = self.commandArgs.GetFieldInt("missiles", 1)
        direction = self.commandArgs.GetFieldInt("direction", -30)
        if self.commandArgs.HasField("spawnRange") then
            local s = self.commandArgs.GetFieldIntArray("spawnRange")
            spawnXmin = s[1] or 0
            spawnXmax = s[2] or 0
            spawnYmin = s[3] or 0
            spawnYmax = s[4] or 0
        else
            spawnXmin = -600
            spawnXmax = -300
            spawnYmin = -300
            spawnYmax =  100
        end
        if self.commandArgs.HasField("timeRange") then
            local t = self.commandArgs.GetFieldIntArray("timeRange")
            launchTimeMin = t[1] or 0
            launchTimeMax = t[2] or 0
        else
            launchTimeMin = 200
            launchTimeMax = 200
        end
        launchTime = math.random( launchTimeMin, launchTimeMax )

        for i = 0, missileCount - 1 do
            local missileArgs = NewJSONObject()
            missileArgs.AddFieldIntArray("spawnRange", { spawnXmin, spawnXmax, -spawnYmin, -spawnYmax })
            missileArgs.AddFieldInt("launchTime", launchTime)
            missileArgs.AddFieldInt("direction", direction)
            if missileType <= 0 or missileType >= 3 then
                SpawnEntityWorld("icbmBackground", { x = self.worldPosition.x + offset, y = self.worldPosition.y + 111}, missileArgs)
            elseif missileType == 1 then
                SpawnEntityWorld("icmmBackground", { x = self.worldPosition.x + offset, y = self.worldPosition.y + 101}, missileArgs)
            elseif missileType == 2 then
                SpawnEntityWorld("icnmBackground", { x = self.worldPosition.x + offset, y = self.worldPosition.y + 107}, missileArgs)
            end
            launchTime = math.random( launchTimeMin, launchTimeMax )

            local launcherArgs = NewJSONObject()
            launcherArgs.AddFieldBool("decoy", true)
            SpawnEntityWorld("icbmLauncher", { x = self.worldPosition.x + offset, y = self.worldPosition.y}, launcherArgs)
            offset = offset + 70
        end
    end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }
    if self.position.x < -200 then self.Deactivate() end
end

function HasCollision()
    return false
end
