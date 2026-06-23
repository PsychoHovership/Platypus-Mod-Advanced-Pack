local mx
local my
local topy
local boty
local speedT
local speedX
local arcDeg
local arcRad

local purple
local t
local t2
local bullets
local speedB
local form
local setForm1
local setForm2
local setForm3
local formTimer1
local formTimer2
local formTimer3
local formStage
local loop
local loopTimer1
local loopTimer2
local loopTimer3
function OnInitialise()
    mx = self.commandArgs.GetFieldFloat("speedX", -4)
    my = self.commandArgs.GetFieldFloat("speedY", 0)
    if self.commandArgs.HasField("formation") then
        local f = self.commandArgs.GetFieldFloatArray("formation")
        formTimer1 = f[1] or 0
        setForm1   = f[2] or 0
        formTimer2 = f[3] or 0
        setForm2   = f[4] or 0
        formTimer3 = f[5] or 0
        setForm3   = f[6] or 0
        else
        formTimer1 = 0
        setForm1   = 0
        formTimer2 = 0
        setForm2   = 0
        formTimer3 = 0
        setForm3   = 0
    end
    loopTimer1 = formTimer1
    loopTimer2 = formTimer2
    loopTimer3 = formTimer3
    loop = self.commandArgs.GetFieldBool("loop", false)
    purple = self.commandArgs.GetFieldBool("isPurple", false)

    speedT = math.sqrt(mx * mx + my * my)
    speedX = mx
    arcDeg = math.deg(math.atan2(my, mx))
    t = 0
    t2 = 0

    local setEase1 = false
    local setEase2 = false

    if purple == true then
        bullets = NewDiffDictInt(6, 12, 18, 24, 32).Get()
        speedB = NewDiffDictFloat(5, 8, 10, 15, 20).Get()
    end

    --if Globals.difficulty == 3 then
    --    local args = NewJSONObject()
    --    args.AddFieldFloat("speedX", mx)
    --    args.AddFieldFloat("speedY", my)
    --    args.AddFieldFloatArray("formation", { formTimer1, setForm1, formTimer2, setForm2, formTimer3, setForm3 })
    --    SpawnEntityWorld("enemyshot_poker", self.worldPosition, args)
    --end
end

function OnTick()
    arcRad = math.rad(arcDeg)

    formStage = formStage or 0
    if formStage == 0 then
        formTimer1 = formTimer1 - 1
        if formTimer1 <= 0 then
            form = setForm1
            formStage = 1
        end
    elseif formStage == 1 then
        formTimer2 = formTimer2 - 1
        if formTimer2 <= 0 then
            if not setEase1 then
                t, t2 = 0, 0
                setEase1 = true
            end
            form = setForm2
            formStage = 2
        end
    elseif formStage == 2 then
        formTimer3 = formTimer3 - 1
        if formTimer3 <= 0 then
            if not setEase2 then
                t, t2 = 0, 0
                setEase2 = true
            end
            form = setForm3
            formStage = 3
            if loop then
                formStage = 0
                formTimer1 = loopTimer1
                formTimer2 = loopTimer2
                formTimer3 = loopTimer3
                setEase1 = false
                setEase2 = false
            end
        end
    end

    if form == 0 and setForm2 == 0 then form = setForm1 end
    if form == 0 and setForm3 == 0 then form = setForm2 end

    -- ACCELERATE UPWARD
    if form == 1 then
        my = my + 0.05
        
    -- ACCELERATE DOWNWARD
    elseif form == 2 then
        my = my - 0.05
        
    -- ACCELERATE RIGHTWARD
    elseif form == 3 then
        mx = mx + 0.05
        
    -- ACCELERATE LEFTWARD
    elseif form == 4 then
        mx = mx - 0.05
    
    -- ARC CLOCKWISE
    elseif form == 5 then
        arcDeg = arcDeg - 0.5 * speedT
        t = t + 1
        local angle = -math.min(t * (speedT / 120), math.pi * 2)
        mx = math.cos(arcRad) * speedT
        my = math.sin(arcRad) * speedT

    -- ARC COUNTERCLOCKWISE
        arcDeg = arcDeg + 0.5 * speedT
        t = t + 1
        local angle = math.min(t * (speedT / 120), math.pi * 2)
        mx = math.cos(arcRad) * speedT
        my = math.sin(arcRad) * speedT

    -- CIRCLE CLOCKWISE
    elseif form == 7 then
        arcDeg = math.max(arcDeg - 57.5 * (speedT / 115), -180)
        mx = math.cos(arcRad) * speedT
        my = math.sin(arcRad) * speedT

    -- CIRCLE COUNTERCLOCKWISE
    elseif form == 8 then
        arcDeg = math.min(arcDeg + 57.5 * (speedT / 115), 180)
        mx = math.cos(arcRad) * speedT
        my = math.sin(arcRad) * speedT

    -- STEP ONE UP
    elseif form == 9 then
        local angle = t * math.pi
        t = math.min(t + math.abs(speedX) / (math.pi * 90), 1)
        mx = mx
        my = math.sin(angle) * math.abs(speedX)

    -- STEP ONE DOWN
    elseif form == 10 then
        local angle = t * math.pi
        t = math.min(t + math.abs(speedX) / (math.pi * 90), 1)
        mx = mx
        my = -(math.sin(angle) * math.abs(speedX))

    -- STEP TWO UP
    elseif form == 11 then
        t = t + 0.5
        t2 = t2 + (speedX / t)
        local radX = math.cos(t2) * 0.5
        local radY = math.sin(t2) * 0.5
        local tanX = -math.sin(t2) * speedX
        local tanY =  math.cos(t2) * speedX
        mx = radX + tanX
        my = radY + tanY

    -- STEP TWO DOWN
    elseif form == 12 then
        t = t + 0.5
        t2 = t2 + (speedX / t)
        local radX = math.cos(t2) * 0.5
        local radY = math.sin(t2) * 0.5
        local tanX = -math.sin(t2) * speedX
        local tanY =  math.cos(t2) * speedX
        mx = radX + tanX
        my = -(radY + tanY)

    -- 2X SPEED
    elseif form == 13 then
        mx = speedX * 2
        speedX = mx

    -- 0.5X SPEED
    elseif form == 14 then
        mx = speedX / 2
        speedX = mx

    -- PILLAR UP
    elseif form == 15 then
        mx = mx * 0.98
        my = math.abs(speedX)

    -- PILLAR DOWN
    elseif form == 16 then
        mx = mx * 0.98
        my = -math.abs(speedX)

    -- DIAGONAL UP
    elseif form == 17 then
        mx = speedX
        my = math.abs(speedX)

    -- DIAGONAL DOWN
    elseif form == 18 then
        mx = speedX
        my = -math.abs(speedX)

    -- SINE WAVE
    elseif form == 19 then
        t = t + 0.05
        my = math.sin(t) * 3

    -- COS WAVE
    elseif form == 20 then
        t = t + 0.05
        my = -(math.sin(t)) * 3

    -- BOUNCE RIGHT SCREEN
    elseif form == 21 then
        if self.position.x > 700 then mx = -speedX end

    -- BOUNCE LEFT SCREEN
    elseif form == 22 then
        if self.position.x < -100 then mx = -speedX end

    -- SPIRAL UP
    elseif form == 23 then
        t = t + 0.05
        mx = math.sin(t) * 3 + speedX

    -- SPIRAL DOWN
    elseif form == 24 then
        t = t + 0.05
        mx = -(math.sin(t)) * 3 + speedX

    -- CHILL
    elseif form == 25 then
        mx = mx
        my = my

    -- FREEZE
    elseif form == 26 then
        mx = 0
        my = 0

    -- RANDOM
    elseif form == 27 then
        form = math.random(0, 26)
    end

    self.movement = { x = mx, y = my, z = 0 }
    self.animator.AnimateToNextFrame(true)
    if self.position.x < -200 then self.Deactivate() end
    if self.position.x > 1000 then self.Deactivate() end
    if self.position.y > 100 then self.Deactivate() end
    if self.position.y < -700 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipDebris(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipShards(4, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    if purple == true then
        for i = 0, bullets - 1 do
            local angle = (i / bullets) * (2 * math.pi)

            local mxb = math.cos(angle) * speedB
            local myb = math.sin(angle) * speedB

            local args = NewJSONObject()
            args.AddFieldFloat("mx", mxb)
            args.AddFieldFloat("my", myb)
            SpawnEntityWorld("enemyshot_normal", self.worldPosition, args)
        end
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end

