local angle = 0

local firstShotDelay = 0
local fireFlashTimer = 0

local turretData
local firePattern

local target = nil

local normalSprite
local fireSprite
local fireSFX

local shadowSprite
local shadowOffsetX
local shadowOffsetY
local shadowAnimator

function OnInitialise()
    angle = 0;
    firstShotDelay = self.commandArgs.GetFieldFloat("firstShotDelay", 0)

    -- Record sprites for later
    normalSprite = self.data.spriteName
    fireSprite = self.customBehaviourData.GetFieldString("fireSprite", self.data.spriteName)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser2")

    shadowSprite = self.customBehaviourData.GetFieldString("shadowSprite", "")
    shadowOffsetX = self.customBehaviourData.GetFieldFloat("shadowOffsetX", 0.0)
    shadowOffsetY = self.customBehaviourData.GetFieldFloat("shadowOffsetY", 0.0)

    turretData = NewTurretDataFromEntityData(self.data)
    firePattern = NewFirePatternFromEntityData(self.data)

    self.sortingGroup.SetSortingOrder(2)

    if shadowSprite ~= "" then
        shadowAnimator = self.SpawnAttachedSpriteAnimator(shadowSprite, -1)
        if shadowAnimator ~= nil then
            shadowAnimator.position = {x=shadowOffsetX, y=shadowOffsetY}
        end
    else
        shadowAnimator = nil
    end
end

function Fire()
    for _, bulletParams in ipairs(turretData.CalculateBulletParams(self.worldPosition, angle)) do
        SpawnEntityWorld(bulletParams.bulletEntity, bulletParams.spawnPosition, bulletParams.args)
    end
    PlaySound(fireSFX)
end

function OnTick()
    firstShotDelay = firstShotDelay - 1
    firePattern.Tick()

    -- "Unfire" our sprite
    if fireFlashTimer > 0 then
        fireFlashTimer = fireFlashTimer - 1
        if fireFlashTimer == 0 then
            self.animator.Initialise(normalSprite)
            self.animator.ApplyLayerMaterial(self.layer)
        end
    end

    -- Target a random player
    if target == nil then
        target = GetRandomActivePlayer();
    end

    -- Don't fire at dead targets
    if target ~= nil and not target.isActive then
        target = nil;
    end

    -- Update target angle and fire if close enough
    if target ~= nil then
        local sourcePos = self.worldPosition;
        local targetPos = target.position;
        local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x));

        -- Move towards the target angle
        angle = MoveTowardsAngle(angle, targetAngle, 2);

        local distance = math.abs(DeltaAngle(angle, targetAngle));
        if distance < 2 then
            if firePattern.CanFire() and CanFire() then
                firePattern.MarkFired()
                target = nil

                fireFlashTimer = 4
                self.animator.Initialise(fireSprite)
                self.animator.ApplyLayerMaterial(self.layer)

                Fire()
            end
        end
    end

    local positiveAngle = (angle % 360 + 360) % 360;
    local animatorFrame = math.floor((positiveAngle / (360.0 / self.animator.totalFrames) + self.animator.totalFrames/2) % self.animator.totalFrames);
    self.animator.GoTo(animatorFrame);

    -- Shadow animation only has one frame.. we make another exception to the no rotation rule here
    if shadowAnimator ~= nil then
        shadowAnimator.rotation = angle - 180
    end
end

function CanFire()
    return firstShotDelay <= 0 and self.parent.CanFire()
end

function HasCollision()
    return false
end
