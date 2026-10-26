local frame
local scriptTimer
local scriptPointer
local scriptTargetFrame
local fireSFX
local shipScript = {}

local mx
local my



function OnInitialise()

    local field = self.commandArgs.GetFieldInt("scriptIndex", 0)

    self.shipScript = Globals.fishFighterScripts.Get(field, {1, 0, -1})
    self.frame = ShipScriptFrame(0) - math.floor(self.Animator.TotalFrames / 16);
    self.scriptTimer = 0;
    self.scriptPointer = 0;
    self.scriptTargetFrame = 0;
    self.customBehaviourData.GetFieldString("fireSFX", "s_laser");

end


-- local
function ShipScript(index)

    if #shipScript < index then
        return -1
    end

    return shipScript[index]

end


-- local
function ShipScriptFrame(index)

    local value = ShipScript(index)
    return math.floor(value / 16 * self.animator.totalFrames)

end



function OnTick()

    local currentScriptFrame = self.shipScriptFrame(self.scriptPointer)


    local totalFrames = self.animator.totalFrames
    local num = ((self.frame + math.floor(totalFrames / 2)) % totalFrames ) * (22.5 * (16 / totalFrames))

    local rad = num * ( math.pi / 180 )
    local cosRad = math.cos(rad)
    local sinRad = math.sin(rad)

    mx = cosRad * 5
    my = (0 - sinRad) * 5

    self.movement = { x = mx, y = my, z = 0 }


    if self.scriptTimer > 0 then
        self.scriptTimer = self.scriptTimer - 1
    else

        if (self.shipScript(self.scriptPointer) == 100) and (Globals.fishFire) then

            self.scriptTimer = self.shipScript(self.scriptPointer + 1)
            self.scriptPointer = self.scriptPointer + 2

            local x = self.worldPosition.x + cosRad * 42
            local y = self.worldPosition.y - sinRad * 42
            local mx = cosRad * 8
            local my = (0 - sinRad) * 8

            SpawnEntityWorld(entity, { x, y, mx, my })
            PlaySound(fireSFX)
            
        end


        if      (self.scriptTargetFrame == self.frame) then
            
                if ( self.shipScript(self.scriptPointer) == -1 ) then
                    self.Deactivate()
                    return
                end

                if ( self.shipScriptFrame(self.scriptPointer) < totalFrames + 1 and currentScriptFrame > 0 ) then -- revise currentScriptFrame
                    self.scriptTargetFrame = currentScriptFrame - math.floor(totalFrames / 16)
                    self.scriptTimer = self.shipSCript(self.scriptPointer + 1)
                
                end

                self.scriptPointer = self.scriptPointer + 2

        elseif (self.scriptTargetFrame < self.frame) and (self.scriptTargetFrame > self.frame - math.floor(totalFrames / 2) + 1) or
               (self.scriptTargetFrame > self.frame) and (self.scriptTargetFrame > self.frame + math.floor(totalFrames / 2))     then

                self.frame = self.frame - 1
                self.scriptTimer = math.floor(3 * (16 / totalFrames))

                if self.frame < 0 then
                    self.frame = totalFrames - 1
                end

        elseif (self.scriptTargetFrame > self.frame) and (self.scriptTargetFrame < self.frame + math.floor(totalFrames / 2) + 1) or
               (self.scriptTargetFrame < self.frame) and (self.scriptTargetFrame < self.frame - math.floor(totalFrames / 2))     then

                self.frame = self.frame + 1
                self.scriptTimer = math.floor(3 * (16 / totalFrames))

                if self.frame > totalFrames - 1 then
                    self.frame = 0
                end 

        end

    end

    self.animator.GoTo(self.frame)

end



function OnKill()

    for i = 0, 10 do
        self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
        -- ShardBehaviour.ShipShard(base.WorldPosition.x, base.WorldPosition.y, GameUtils.Random(-6, 0), GameUtils.Random(-15, 5), i);
    end
end


function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
