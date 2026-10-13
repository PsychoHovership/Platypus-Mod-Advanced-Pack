local mx = 0.8
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY
local acceleration
local starType

function OnInitialise()
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldFloat("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldFloat("smokeTrailPosY", 0)
	acceleration = self.commandArgs.GetFieldFloat("acceleration", 0.01)
	starType = self.commandArgs.GetFieldString("starType", "")
end

function OnTick()
	if self.position.x > AdjustXToWideScreen(680) then self.Deactivate() end
	if self.position.x > AdjustXToWideScreen(160) then
		mx = mx + acceleration
		if self.lifetime % 4 == 0 then
            local smokeArgs = NewJSONObject()
            smokeArgs.AddFieldFloat("mx", 0)
            smokeArgs.AddFieldInt("layer", 1)
            smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
            SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
        end
	else mx = 0.8 end
	self.movement = { x = mx, y = 0, z = 0 }
end

function OnKill()
    self.SpawnShipDebris(2, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
	local starArgs = NewJSONObject()
	starArgs.AddFieldString("starType", starType)
	starArgs.AddFieldInt("state", 0)
	starArgs.AddFieldInt("invulTime", 20)
	SpawnEntityWorld("bonusStar", self.worldPosition, starArgs)
end

function HasCollision()
	return true
end

function ShouldKillPlayerOnTouch()
	return self.position.x > 0
end
