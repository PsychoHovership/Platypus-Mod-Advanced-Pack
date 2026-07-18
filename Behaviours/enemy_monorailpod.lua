local podType
local starType
local fruitSets = {}

function OnInitialise()
    if self.commandArgs.HasField("fruitSets") then
        local f = self.commandArgs.GetFieldIntArray("fruitSets")
        for i = 1, #f do fruitSets[i] = f[i] or 0 end
    else fruitSets = nil end
	local xoff = self.commandArgs.GetFieldFloat("xoff", 0)
	local yoff = self.commandArgs.GetFieldFloat("yoff", 0)
    self.lastPosition = { x = xoff, y = yoff }
    self.nextPosition = { x = xoff, y = yoff }
	podType = self.commandArgs.GetFieldInt("podtype", 0)
	starType = self.commandArgs.GetFieldString("starType", "")
	self.sortingGroup.SetSortingOrder(2)
	if podType ~= 0 then CreateTurret("turretPod"..podType.."", 0, 0, self, Globals.firewait) end
end

function OnTick()
    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)
end

function OnKill()
    self.SpawnShipShards(2, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
    self.SpawnShipDebris(2, -9, 3, -15, 5, 0, 0, 2, 4, 2, 4)
	if podType == 0 then
		if starType == "" then
            if fruitSets ~= nil then
                for i = 1, #fruitSets do MakeBonuses(self.worldPosition.x, self.worldPosition.y, fruitSets[i]) end
            end
        else
		    local starArgs = NewJSONObject()
		    starArgs.AddFieldString("starType", starType)
		    starArgs.AddFieldInt("state", self.worldPosition.x < 150 and 45 or 0)
		    starArgs.AddFieldInt("invulTime", 20)
		    SpawnEntityWorld("bonusStar", self.worldPosition, starArgs)
        end
	end
end

function HasCollision()
	return true
end

function ShouldKillPlayerOnTouch()
	return true
end

function CanFire()
	if self.worldPosition.x < AdjustXToWideScreen(600) then return self.worldPosition.x > 40 end
	return false
end
