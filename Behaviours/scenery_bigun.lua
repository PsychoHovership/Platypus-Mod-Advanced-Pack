local mxMin
local mxMax
local mxTotal
local xPos
local yPos
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY

function OnInitialise()
    mxMin = self.customBehaviourData.GetFieldFloat("minSpeed", 0.25)
    mxMax = self.customBehaviourData.GetFieldFloat("maxSpeed", 0.35)
    if self.commandArgs.HasField("x") then xPos = self.commandArgs.GetFieldFloat("x") else xPos = self.customBehaviourData.GetFieldFloat("positionX", -40) end
    yPos = self.commandArgs.GetFieldFloat("y", -1)
    self.lastPosition = { x = xPos, y = -yPos }
    self.nextPosition = { x = xPos, y = -yPos }
    mxTotal = RandRangeF(mxMin, mxMax)
    self.movement = { x = mxTotal, y = 0, z = 0 }

    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldFloat("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldFloat("smokeTrailPosY", 0)
end

function OnTick()
    if smokeTrailEntity ~= "" and self.lifetime % 16 == 0 then
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 1)
        smokeArgs.AddFieldInt("layer", self.layer)
        smokeArgs.AddFieldInt("sortOrder", self.sortingGroup.GetSortingOrder() - 1)
        SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
    end

    if mxTotal > 0 and self.position.x > 1000 then self.Deactivate() end
    if mxTotal < 0 and self.position.x < -400 then self.Deactivate() end
end
