local timer = 1349
local startAngle = 90
local bullets = 7
local speed = 4.4
local barrel
local my = 0

function OnInitialise()
    barrel = self.SpawnAttachedSpriteAnimator("Sprites/Boss 1/big barrel", -100, false)
    barrel.position = { x = 0.5, y = 0 }
end

function OnTick()
    barrel.position = { x = 0.5, y = my }
    if my <= 0 then
        my = my + 1
    end
    
    timer = timer - 1
    if timer < 0 then
        timer = 149
        PlaySound("s_laser")
        my = -28
        barrel.position = { x = 0.5, y = -28 }

        for i = 0, bullets - 1 do
            local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
            local angleDeg = startAngle - 120 / 2 + t * 120
            local angleRad = math.rad(angleDeg)
            local mxb = math.cos(angleRad) * speed - 0.535
            local myb = math.sin(angleRad) * speed + 3.1

            local args = NewJSONObject()
            args.AddFieldFloat("mx", mxb * 0.93)
            args.AddFieldFloat("my", myb)

            SpawnEntityWorld("enemyshot_car_cannon_red", self.worldPosition, args)
        end
    end
end
