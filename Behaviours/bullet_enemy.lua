local mx = 0
local my = 0
local velocity

local shottype = 0

ShotType = {
    Normal = 1,
    Laser = 2,
    CarCannon = 3,
    Shrapnel = 4,
}

function OnInitialise()
    self.SetLogicLayerEnemyShot()

    self.defaultOnHitByBulletBehaviour = false -- Default behaviour consumes bullets that hit us, so we skip it and cook our own, as we want bullets to fly through us
    self.defaultOnHitByPlayerBehaviour = false -- Lowers our health, we don't really use it, so we just skip it

    -- Unlike similar behaviours, this one is already converted into world space and world speed
    -- As it is defined and created in runtime
    mx = self.commandArgs.GetFieldFloat("mx", 1.0)
    my = self.commandArgs.GetFieldFloat("my", 1.0)
    velocity = {x=mx, y=my, z=0}

    shottype = self.customBehaviourData.GetFieldInt("shottype", 0)

    if shottype == 5 then -- start slow for accellerator bullet
        velocity.x = velocity.x * 0.3
        velocity.y = velocity.y * 0.3
    end

    if shottype == ShotType.Normal then
        self.animator.GoTo(RandRange(0, self.animator.totalFrames));
        self.animator.LoopAnimation();
    end

    if shottype == ShotType.Laser then
        -- angle of laser, left is 0 clockwise to 360
        local angle = math.deg(math.atan2(-my, mx)) + 180;

        -- Animation is half a rotation, so we "double" the frames and modulo it back down
        local frame = math.floor(angle / (360.0 / (self.animator.totalFrames * 2))) % self.animator.totalFrames;
        self.animator.GoTo(frame);
    end
end

function OnTick()
    if shottype == 5 and self.lifetime < 40 then -- accellerator
        velocity.x = velocity.x * 1.045
        velocity.y = velocity.y * 1.045
    end

    if shottype == ShotType.CarCannon then
        velocity.y = velocity.y - 0.1

        if Globals.createSplashes and self.position.y < -580 then
            CreateLittleSplash(self.worldPosition.x);
            self.Deactivate();
            return;
        end
    end

    self.movement = velocity;

    if self.position.x < -300 or self.position.x > 1300 or self.position.y < -900 or self.position.y > 200 or self.lifetime > 1000 then
        self.Deactivate();
    end
end

function OnHitByBullet(bulletEntity)
    -- Make bullets disappear if they hit a player shot "Sonic Pulse"
    -- Note that we don't actually consume the bulletEntity here
    if shottype == 3 then
        return
    end

    if bulletEntity.data.behaviourName == "PlayerShotSonicPulseBehaviour" then -- The game appends "Behaviour" to behaviour names used in entities.json
        CreateFlash(self.worldPosition.x, self.worldPosition.y, self.movement.x, 0);
        self.Deactivate();
    end
end

function HasCollision()
    return true
end

function OnHitByPlayer(player)
    self.Kill()
end

function ShouldKillPlayerOnTouch()
    return true
end


-- The game uses these functions like this to actually spawn this behaviour instead of manually spawning it
function SpawnSimpleBullet(x, y) -- "fire_enemy_bullet" in original code
    local startPos = {x=x, y=y}
    local targetPos = {x=0, y=0}

    if GetActivePlayerCount() > 0 then
        local player = GetRandomActivePlayer()
        if player ~= nil then
            targetPos = player.position
        end
    end

    -- normalize direction
    local diff = {x=targetPos.x - startPos.x, y=targetPos.y - startPos.y}
    local length = math.sqrt(math.pow(diff.x, 2) + math.pow(diff.y, 2))
    local dir = {x=diff.x / length, y=diff.y / length}

    local bulletSpeed = NewDiffDictFloat(3.0, 3.0, 4.0, 5.0, 6.0).Get();

    local args = NewJSONObject()
    args.AddFieldFloat("mx", dir.x * bulletSpeed * Globals.enemyShotSpeedMultiplier);
    args.AddFieldFloat("my", dir.y * bulletSpeed * Globals.enemyShotSpeedMultiplier);

    SpawnEntityWorld(GetEntityNameFromType(ShotType.Normal), {x=x, y=y}, args);
end

function SpawnBullet(x, y, _mx, _my, shotType) -- "fire_enemy_bullet_2" in original code
    local args = NewJSONObject()
    args.AddFieldFloat("mx", _mx);
    args.AddFieldFloat("my", _my);

    SpawnEntityWorld(GetEntityNameFromType(shotType), {x=x, y=y}, args)
end

function GetEntityNameFromType(shotType)
    if shotType == ShotType.Normal then return "enemyshot_normal" end
    if shotType == ShotType.Laser then return "enemyshot_laser" end
    if shotType == ShotType.CarCannon then return "enemyshot_car_cannon" end
    if shotType == ShotType.Shrapnel then return "enemyshot_shrapnel" end
    return "enemyshot_normal"
end


-- Helper functions to create other entities
function CreateFlash(x, y, _mx, frame)
    local args = NewJSONObject()
    args.AddFieldFloat("mx", _mx);
    args.AddFieldInt("frame", frame);

    SpawnEntityWorld("flash", {x=x, y=y}, args)
end

function CreateLittleSplash(x)
    for i = 0, 4 do
        CreateDrip(x, -586)
    end
    PlaySound("s_little_splash")

    SpawnEntityLocal("littleSplash", {x=x, y=-580}, nil)
end

function CreateDrip(x, y)
    local args = NewJSONObject()
    args.AddFieldFloat("mx", RandRangeF(-4.0, 2.0))
    args.AddFieldFloat("my", RandRangeF(-12.0, -5.0))
    args.AddFieldInt("frame", 0)

    SpawnEntityLocal("drip", {x=x, y=y}, args)
end
