local mx
local my

local bullets
local speed

function OnInitialise()
    if self.commandArgs.HasField("mx") then mx = self.commandArgs.GetFieldFloat("mx") else mx = 0 end
    if self.commandArgs.HasField("my") then my = self.commandArgs.GetFieldFloat("my") else my = 0 end

    if Globals.difficulty == -1 then bullets = 6; speed = 5
    elseif Globals.difficulty == 0 then bullets = 12; speed = 6
    elseif Globals.difficulty == 1 then bullets = 18; speed = 8
    elseif Globals.difficulty == 2 then bullets = 24; speed = 10
    elseif Globals.difficulty == 3 then bullets = 32; speed = 15
    end
end

function OnTick()
    my = my - 0.1
    self.movement = { x = mx, y = my, z = 0 }

    if self.position.x < -200 then self.Deactivate() end
    if self.position.x > 800 then self.Deactivate() end
    if Globals.createSplashes == true then
        if self.position.y < -600 then
            self.CreateFancySplashes()
            self.Deactivate()
        end
    else
        if self.position.y < -700 then self.Deactivate() end
    end
end

function OnKill()
    PlaySound("s_laser")
    for i = 0, bullets - 1 do
        local angle = (i / bullets) * (2 * math.pi)

        local mxb = math.cos(angle) * speed
        local myb = math.sin(angle) * speed

        local args = NewJSONObject()
        args.AddFieldFloat("mx", mxb)
        args.AddFieldFloat("my", myb)
        SpawnEntityWorld("enemyshot_shrapnel", self.worldPosition, args)
    end
end

function HasCollision()
    return true
end
function ShouldKillPlayerOnTouch()
    return true
end
