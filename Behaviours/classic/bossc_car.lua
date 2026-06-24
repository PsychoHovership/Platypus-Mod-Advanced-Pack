local cartype = 0
local wheelFrame = 0
local wheelLeftY = 0
local wheelRightY = 0
local nextCarriage
local nextCarriageID = 0
local spawnedNextCarriage = false
local nextCarriageDestroyed = false
local linkFrame = 0
local barrelY = 0
local carsprite = 0
local mx = 0
local bonus = 0
local firewait = 0
local barreloff = 0

local topOffsetX = 0
local topOffsetY = 0
local frontCarTopOffsetX = 0
local frontCarTopOffsetY = 0
local frontCarBackOffsetX = 0
local frontCarBackOffsetY = 0
local frontTurretOffsetX = 0
local frontTurretOffsetY = 0
local missileLauncherOffsetX = 0
local missileLauncherOffsetY = 0
local fireSFX = "s_laser"

local suspensionLeftAnimator
local suspensionRightAnimator
local wheelLeftAnimator
local wheelRightAnimator
local cartopAnimator
local trayAnimator
local bigGunAnimator
local missileAnimator
local linkAnimator
local bigBarrelAnimator

local wheelLeftCollider = nil
local wheelRightCollider = nil
local cartopCollider = nil
local trayCollider = nil
local bigGunCollider = nil
local missileCollider = nil
local bigBarrelCollider = nil

local tray_im = "Sprites/Boss 1/tray"
local empty_im = "Sprites/Boss 1/empty top"
local tray_front_im = "Sprites/Boss 1/front car back"
local suspension_im = "Sprites/Boss 1/suspension"
local miss_im = "Sprites/Boss 1/missile hatch"
local wheel_im = "Sprites/Boss 1/wheel"
local big_gun_im = "Sprites/Boss 1/big gun"
local bigBarrel_im = "Sprites/Boss 1/big barrel"
local link_im = "Sprites/Boss 1/link"

function OnInitialise()
    -- Reset all variables for now to avoid state corruption
    wheelFrame = 0
    wheelLeftY = 0
    wheelRightY = 0
    nextCarriage = nil
    nextCarriageID = -1
    spawnedNextCarriage = false
    nextCarriageDestroyed = false
    linkFrame = 0
    barrelY = 0
    barreloff = 0

    topOffsetX = self.customBehaviourData.GetFieldFloat("topOffsetX", 0)
    topOffsetY = self.customBehaviourData.GetFieldFloat("topOffsetY", 0)
    frontCarTopOffsetX = self.customBehaviourData.GetFieldFloat("frontCarTopOffsetX", 0)
    frontCarTopOffsetY = self.customBehaviourData.GetFieldFloat("frontCarTopOffsetY", 0)
    frontCarBackOffsetX = self.customBehaviourData.GetFieldFloat("frontCarBackOffsetX", 0)
    frontCarBackOffsetY = self.customBehaviourData.GetFieldFloat("frontCarBackOffsetY", 0)
    frontTurretOffsetX = self.customBehaviourData.GetFieldFloat("frontTurretOffsetX", 0)
    frontTurretOffsetY = self.customBehaviourData.GetFieldFloat("frontTurretOffsetY", 0)
    missileLauncherOffsetX = self.customBehaviourData.GetFieldFloat("missileLauncherOffsetX", 0)
    missileLauncherOffsetY = self.customBehaviourData.GetFieldFloat("missileLauncherOffsetY", 0)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser")

    cartype = self.customBehaviourData.GetFieldInt("cartype", 0)

    -- The game uses a hard typed fields for most globals
    -- But we can read and write our own custom global data like so if we want to communicate between scripts
    -- Globals.custom.SetFieldInt("my_global_counter", Globals.custom.GetFieldInt("my_global_counter", 0) + 1)

    bonus = Globals.trainbonus[Globals.trainCounter + 1]
    self.sortingGroup.SetSortingOrder(self.data.sortOrder + Globals.trainCounter)

    -- Predamage the boss
    if (not IsOriginalVersion()) and cartype ~= 4 then self.hitPoints = (self.hitPoints/2) + 150 end
    if Globals.difficulty >= GameDifficulty.Hard then self.hitPoints = self.hitPoints + 100 end

    Globals.trainCounter = Globals.trainCounter + 1
    if Globals.trainCounter == #Globals.trainEntities then
        Globals.trainCounter = 0
    end

    firewait = 500
    carsprite = 1
    mx = 0.6
    if cartype == 0 then carsprite = 0 end
    if cartype == 4 then carsprite = 2 end
    if cartype == 2 then
        if IsOriginalVersion() then
            CreateTurret("legacyTurret", -42, 25, self, math.floor(Globals.firewait * 1.67))
            CreateTurret("legacyTurret", 36, 25, self, Globals.firewait)
        else
            CreateTurret("turretCarSingle", -42, 35, self, math.floor(Globals.firewait * 1.67))
            CreateTurret("turretCarSingleSlower", 36, 35, self, Globals.firewait)
        end
    end

    if cartype == 4 then
        if IsOriginalVersion() then
            CreateTurret("legacyTurret", frontTurretOffsetX, -frontTurretOffsetY, self, math.floor(Globals.firewait / 1.5))
        else
            if Globals.difficulty >= GameDifficulty.Hard then
                CreateTurret("carTurret", frontTurretOffsetX, -frontTurretOffsetY, self, math.floor(Globals.firewait / 1.5))
            else
                CreateTurret("turretNastySingleSlower", frontTurretOffsetX, -frontTurretOffsetY, self, math.floor(Globals.firewait / 1.5))
            end
            CreateTurret("turretNastySingle", frontTurretOffsetX + 60, -frontTurretOffsetY, self, Globals.firewait)
        end
    end

    if cartype == 0 and Globals.difficulty >= GameDifficulty.Hard then
        if not IsOriginalVersion() then
            CreateTurret("turretCarDoubleLaser", 0, 80, self, math.floor(Globals.firewait / 1.2))
        end
    end

    SetupVisuals()
    SetupColliders()

    -- Main body does not have sprites or collisions, so we disable the default ones
    self.animator.enabled = false
    self.collider2D.enabled = false
end

function SetupVisuals()
    linkAnimator = self.SpawnAttachedSpriteAnimator(link_im, -7)

    if cartype ~= 4 then
        trayAnimator = self.SpawnAttachedSpriteAnimator(tray_im, -6)
        trayAnimator.position = {x=0, y=-40}
    else
        trayAnimator = self.SpawnAttachedSpriteAnimator(tray_front_im, -6)
        trayAnimator.position = {x=frontCarBackOffsetX, y=frontCarBackOffsetY}
    end

    suspensionLeftAnimator = self.SpawnAttachedSpriteAnimator(suspension_im, -5)
    suspensionLeftAnimator.position = {x=-50, y=-55}

    suspensionRightAnimator = self.SpawnAttachedSpriteAnimator(suspension_im, -5)
    suspensionRightAnimator.position = {x=50, y=-55}

    if cartype == 1 then
        local vertOffset = 15
        if IsOriginalVersion() then
            vertOffset=0
        end

        bigBarrelAnimator = self.SpawnAttachedSpriteAnimator(bigBarrel_im, -4)
        bigGunAnimator = self.SpawnAttachedSpriteAnimator(big_gun_im, -2)
        bigGunAnimator.position = {x=-3, y=71 + vertOffset}
    end

    if cartype ~= 3 then
        cartopAnimator = self.SpawnAttachedSpriteAnimator(GetCartopIm(carsprite), -2)

        if cartype ~= 4 then
            cartopAnimator.position = {x=topOffsetX, y=topOffsetY - 5 + GetSpriteDimensions(GetCartopIm(carsprite), 0).y / 2.0}
        else
            cartopAnimator.position = {x=frontCarTopOffsetX, y=frontCarTopOffsetY}
        end
    elseif not IsOriginalVersion() then
        cartopAnimator = self.SpawnAttachedSpriteAnimator(empty_im, 1)
        cartopAnimator.position = {x=0, y=-3}
    end

    if cartype == 4 then
        missileAnimator = self.SpawnAttachedSpriteAnimator(miss_im, -2)
        missileAnimator.position = {x=missileLauncherOffsetX, y=missileLauncherOffsetY}
    end

    wheelLeftAnimator = self.SpawnAttachedSpriteAnimator(wheel_im, -1)
    wheelRightAnimator = self.SpawnAttachedSpriteAnimator(wheel_im, -1)
end

function SetupColliders()
    if wheelLeftAnimator ~= nil then
        wheelLeftCollider = wheelLeftAnimator.AddCollider()
        wheelLeftCollider.SetLogicLayerEnemy()
    end
    if wheelRightAnimator ~= nil then
        wheelRightCollider = wheelRightAnimator.AddCollider()
        wheelRightCollider.SetLogicLayerEnemy()
    end
    if cartopAnimator ~= nil then
        cartopCollider = cartopAnimator.AddCollider()
        cartopCollider.SetLogicLayerEnemy()
    end
    if trayAnimator ~= nil then
        trayCollider = trayAnimator.AddCollider()
        trayCollider.SetLogicLayerEnemy()
    end
    if bigGunAnimator ~= nil then
        bigGunCollider = bigGunAnimator.AddCollider()
        bigGunCollider.SetLogicLayerEnemy()
    end
    if missileAnimator ~= nil then
        missileCollider = missileAnimator.AddCollider()
        missileCollider.SetLogicLayerEnemy()
    end
    if bigBarrelAnimator ~= nil then
        bigBarrelCollider = bigBarrelAnimator.AddCollider()
        bigBarrelCollider.SetLogicLayerEnemy()
    end
end

function OnTick()
    -- Check all collisions
    if wheelLeftCollider ~= nil then self.CheckCollision(wheelLeftCollider) end
    if wheelRightCollider ~= nil then self.CheckCollision(wheelRightCollider) end
    if cartopCollider ~= nil then self.CheckCollision(cartopCollider) end
    if trayCollider ~= nil then self.CheckCollision(trayCollider) end
    if bigGunCollider ~= nil then self.CheckCollision(bigGunCollider) end
    if missileCollider ~= nil then self.CheckCollision(missileCollider) end
    if bigBarrelCollider ~= nil then self.CheckCollision(bigBarrelCollider) end

    -- Half Height Cart with cannon
    if cartype == 1 then
        if barreloff > 0 then barreloff = barreloff - 1; end
        if firewait > 0 then firewait = firewait - 1 end
        if firewait == 0 then
            firewait = 150
            barreloff = 20

            local vertOffset = 15
            if IsOriginalVersion() then
                vertOffset = 0
            end

            for llp = 60, 120, 15 do
                CreateBullet("enemyshot_car_cannon", self.worldPosition.x - 5, self.worldPosition.y + 125 + vertOffset, math.cos(math.rad(llp)) * 4 - 0.5, math.sin(math.rad(llp)) * 9)
                PlaySound(fireSFX)
            end
        end
    end

    -- Front Cart
    if cartype == 4 then
        if (firewait > 0) then firewait = firewait - 1 end
        local hatchFrame = 3
        if firewait < 20 or firewait > 90 then hatchFrame = 4 end
        if firewait > 24 and firewait < 86 or firewait > 124 then hatchFrame = 2 end
        if firewait > 27 and firewait < 83 or firewait > 127 then hatchFrame = 1 end
        if firewait > 30 and firewait < 80 or firewait > 130 then hatchFrame = 0 end

        -- Extra missile for harder difficulties
        if (Globals.difficulty >= GameDifficulty.Hard and firewait == 20 and (not IsOriginalVersion())) then
            CreateHomingMissile(self.worldPosition.x + 60, self.worldPosition.y + 76, 40 + math.floor(mx * 5))
        end

        if firewait == 0 then
            firewait = 120
            CreateHomingMissile(self.worldPosition.x + 60, self.worldPosition.y + 76, 40 + math.floor(mx * 5))
        end

        missileAnimator.GoTo(hatchFrame)
    end

    if nextCarriage == nil and spawnedNextCarriage then
        nextCarriage = GetEntity(nextCarriageID);
    end

    if self.position.x <= AdjustXToWideScreen(540) and (not spawnedNextCarriage) and cartype ~= 4 then
        if IsOriginalVersion() then
            SpawnNextCart(760)
        else
            SpawnNextCart(800)
        end
    end

    wheelFrame = wheelFrame + math.max(1, Round((2.7 - mx) / 3.0))
    wheelFrame = wheelFrame % 17
    wheelLeftAnimator.GoTo(wheelFrame / 5)
    wheelRightAnimator.GoTo(wheelFrame / 5)

    wheelLeftY = Clamp(-GetHillOffset(self.worldPosition.x - 50), -20, 19)
    wheelRightY = Clamp(-GetHillOffset(self.worldPosition.x + 50), -20, 19)

    local suspensionLeftFrame = 0
    if -472 + wheelLeftY > self.position.y then suspensionLeftFrame = 1 end
    if -484 + wheelLeftY > self.position.y then suspensionLeftFrame = 2 end
    if -496 + wheelLeftY > self.position.y then suspensionLeftFrame = 3 end
    suspensionLeftAnimator.GoTo(suspensionLeftFrame);

    local suspensionRightFrame = 0;
    if -472 + wheelRightY > self.position.y then suspensionRightFrame = 1 end
    if -484 + wheelRightY > self.position.y then suspensionRightFrame = 2 end
    if -496 + wheelRightY > self.position.y then suspensionRightFrame = 3 end
    suspensionRightAnimator.GoTo(suspensionRightFrame);

    linkFrame = 1000
    if cartype == 4 and self.position.x < 300 then mx = mx - 0.01 end
    if cartype == 4 and self.position.x > 300 and mx < 2.7 then mx = mx + 0.01 end

    if nextCarriage ~= nil and not nextCarriageDestroyed then
        mx = -nextCarriage.movement.x;
        linkFrame = 0;
        barrelY = (self.position.y + nextCarriage.position.y) / 2;
        if self.position.y > nextCarriage.position.y + 2 then linkFrame = 6 end
        if self.position.y > nextCarriage.position.y + 5 then linkFrame = 5 end
        if self.position.y > nextCarriage.position.y + 8 then linkFrame = 4 end
        if self.position.y < nextCarriage.position.y - 2 then linkFrame = 1 end
        if self.position.y < nextCarriage.position.y - 5 then linkFrame = 2 end
        if self.position.y < nextCarriage.position.y - 8 then linkFrame = 3 end

        -- Reclayed's link only has one frame
        if not IsOriginalVersion() then
            linkFrame = 0;
        end

        nextCarriageDestroyed = nextCarriage.hitPoints <= 0 or nextCarriage.position.x < -150;
    else
        if self.position.x < 540 and mx < 2.7 and cartype ~= 4 then mx = mx + 0.02 end
    end

    if cartopAnimator ~= nil then
        local lastFrame = cartopAnimator.currentFrame
        cartopAnimator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, cartopAnimator.totalFrames))
        self.HandleDamageEffects(cartopAnimator.currentFrame, lastFrame)
    end

    local targetY = -480 - (wheelLeftY + wheelRightY) / 4;
    -- self.movement.x = -mx
    -- self.movement.y = targetY - self.position.y
    self.movement = {x=-mx, y=targetY - self.position.y, z=0}
    if (self.position.x < AdjustXToWideScreen(-150) and cartype ~= 4) or self.hitPoints <= 0 then
        if self.position.x >= AdjustXToWideScreen(540) and (not spawnedNextCarriage) and cartype ~= 4 then
            if IsOriginalVersion() then
                SpawnNextCart(self.worldPosition.x + 220);
            else
                SpawnNextCart(self.worldPosition.x + 260);
            end
        end

        -- Kill or deactivate, depending on how we got here
        if (self.hitPoints <= 0) then
            self.Kill();
        else
            self.Deactivate();
        end
    end
end

function OnKill()
    if cartype == 4 and self.data.endKillTimerOnDeath then
        self.EndKillTimer();
    end

    CreateExplosion(self.worldPosition.x - 50, self.worldPosition.y + 20, "explosionBig");
    CreateExplosion(self.worldPosition.x + 50, self.worldPosition.y + 20, "explosionBig");

    self.SpawnShipShards(80, -14, 8, -22, 5, 0, 40, 2, 6, 2, 6)
    self.SpawnShipDebris(40, -14, 8, -32, 5, 0, 40, 2, 6, 2, 6)

    CreateBouncyWheelBehaviour(self.worldPosition.x - 50, self.worldPosition.y - wheelLeftY, RandRangeF(-6.0, -2.0), RandRangeF(-15.0, -8.0));
    CreateBouncyWheelBehaviour(self.worldPosition.x + 50, self.worldPosition.y - wheelRightY, RandRangeF(2.0, 6.0), RandRangeF(-15.0, -8.0));

    if bonus ~= 0 then
        MakeBonuses(self.worldPosition.x, self.worldPosition.y, bonus);
    end
end

function SpawnNextCart(xPosition)
    local entity = Globals.trainEntities[Globals.trainCounter + 1];
    if entity == "bossc_car_front" then
        xPosition = xPosition + 20;
    end

    nextCarriageID = SpawnEntityLocal(entity, {x=AdjustXToWideScreen(xPosition), y=-480}, nil);
    spawnedNextCarriage = true;
end

function OnRender()
    linkAnimator.GoTo(linkFrame)
    linkAnimator.enabled = linkFrame ~= 1000
    if IsOriginalVersion() then
        linkAnimator.position = {x=110, y=-480 - barrelY - 10}
    else
        linkAnimator.position = {x=130, y=-480 - barrelY - 35}
    end

    if cartype == 1 then
        local vertOffset = 15
        if IsOriginalVersion() then
            vertOffset=0
        end

        bigBarrelAnimator.position = {x=-3, y=103 + vertOffset - barreloff}
    end

    wheelLeftAnimator.position = {x=-50, y=-self.position.y - 560 + wheelLeftY}
    wheelRightAnimator.position = {x=50, y=-self.position.y - 560 + wheelRightY}
end

function OnHitByBullet(bulletEntity)
    local damage = bulletEntity.BulletConsume(self);

    if not IsOriginalVersion() and cartype ~= 4 then
        damage = damage * Lerp(0.2, 1.0, self.lifetime / 1000)
    end

    self.hitPoints = self.hitPoints - damage;
    PlaySound("s_dink");
end

function CanFire()
    return self.position.x < 750 and self.position.x > 40 and self.lifetime > 300
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end

-- This function is called by the game and makes it bypass a lot of automatic kill logic, see OnKill here for how we handle certain effects like items spawning anyway
function IsKilledManually()
    return true
end

function GetCartopIm(index)
    -- Could be smarter, but no point. No simple switch statements in lua
    if index == 0 then return "Sprites/Boss 1/transport top"
    elseif index == 1 then return "Sprites/Boss 1/war top"
    elseif index == 2 then return "Sprites/Boss 1/front car"
    else return "Sprites/Boss 1/transport top" end
end

-- This function is originally part of BouncyWheelBehaviour as a global, but we can't access it here, so we just redefine it for simplicity
function GetHillOffset(xx)
    local tmp =
        math.cos(math.rad(math.floor((Globals.levelLifetime * 2.7 + xx) / 1.5 % 360))) * 15 +
        math.cos(math.rad(math.floor((Globals.levelLifetime * 2.7 + xx) * 1.6 % 360))) * 8 +
        math.cos(math.rad(math.floor((Globals.levelLifetime * 2.7 + xx) * 1.2 % 360))) * 5 +
        math.cos(math.rad(math.floor((Globals.levelLifetime * 2.7 + xx) * 5.0 % 360))) * 2
    return Round(tmp);
end

---Helper function for creating a child turret entity
function CreateBouncyWheelBehaviour(_x, _y, _mx, _my)
    local args = NewJSONObject()
    args.AddFieldFloat("mx", _mx)
    args.AddFieldFloat("my", _my)

    return SpawnEntityWorld("bouncyWheel", {x=_x, y=_y}, args)
end

function CreateExplosion(x, y, entity)
    Globals.isPassiveResistance = false -- Unexpected side effect

    -- Don't fire "explosionHuge" on classic (technical debt)
    if IsOriginalVersion() and type == "explosionHuge" then
        type = "explosionBig"
    end

    -- "Huge" is the only off centered explosion
    -- We hack the position up to keep perceived positions unchanged when switching between explosions (technical debt)
    if type == "explosionHuge" then
        y = y + 150;
    end

    SpawnEntityWorld(entity, { x=x, y=y }, nil);
end

function CreateHomingMissile(x, y, angle)
    local args = NewJSONObject()
    args.AddFieldInt("var5", RandRange(0, 360))
    args.AddFieldInt("currentAngle", -angle)
    args.AddFieldInt("homingDelay", 30)

    PlaySound("s_woosh")
    SpawnEntityWorld("homingMissile", {x=x, y=y}, args)
end

function CreateBullet(entity, _x, _y, _mx, _my)
    local args = NewJSONObject()
    args.AddFieldFloat("mx", _mx)
    args.AddFieldFloat("my", _my)

    SpawnEntityWorld(entity, {x=_x, y=_y}, args)
end
