local mx
local my
local frame = 8
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY

function OnInitialise()
    mx = self.commandArgs.GetFieldFloat("mx", -8)
    my = -self.commandArgs.GetFieldFloat("my", 0) * 1.2
	self.animator.GoTo(frame)
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldInt("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldInt("smokeTrailPosY", 0)
end

function OnTick()
    self.movement = { x = mx * 1.3, y = -my, z = 0 }
	if self.position.y > -300 and my > -8 then my = my + 0.07 end
	if self.position.y < -300 and my < 8 then my = my - 0.07 end

    if smokeTrailEntity ~= "" and self.lifetime % 3 == 0 then
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 0)
        smokeArgs.AddFieldInt("layer", 1)
        smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() + ((frame > 8) and 1 or -1))
        SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
    end

    if self.lifetime > 70 and self.lifetime < 150 and mx < 8 then
        mx = mx + 0.2
        frame = 4 - math.floor(mx / 2)
    end
    if self.lifetime > 160 and mx > -8 then
        mx = mx - 0.2
        frame = 12 + math.floor(mx / 2)
    end
    if frame >= 15 then frame = 15 end
    if self.position.x < -200 then self.Deactivate() end
    self.animator.GoTo(frame)
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
