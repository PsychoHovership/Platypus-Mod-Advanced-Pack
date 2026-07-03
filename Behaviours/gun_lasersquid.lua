local shotOffX
local shotOffY
local lightningAudio = nil

function OnInitialise()
	shotOffX = self.customBehaviourData.GetFieldFloat("shotOffX", 0)
	shotOffY = self.customBehaviourData.GetFieldFloat("shotOffY", 0)
	self.sortingGroup.SetSortingOrder(2)
end

function OnTick()
	if self.lifetime <= 300 then return end
	local firewait  = self.lifetime % 250
	local spriteIndex = self.animator.totalFrames - 1
	if firewait < 136 then spriteIndex = math.floor(Lerp(0, self.animator.totalFrames - 1, (firewait - 120) / (136 - 120))) end
	if firewait < 120 then spriteIndex = 0 end
	if firewait < 38 then spriteIndex = math.floor(Lerp(0, self.animator.totalFrames - 1, (firewait - 38) / (0 - 38))) end
	self.animator.GoTo(spriteIndex)

	if firewait == 154 and lightningAudio == nil then
		lightningAudio = PlaySoundRaw("s_enemy_kazap")
		lightningAudio.loop = true
	end
	if spriteIndex == self.animator.totalFrames - 1 and firewait > 145 then
		local frame = math.random(2, 9)
		if firewait > 100 then
			if firewait < 165 then frame = 1 end
			if firewait < 155 then frame = 0 end
		end
		local zapArgs = NewJSONObject()
		zapArgs.AddFieldInt("frame", frame)
		zapArgs.AddFieldInt("angle", 180)
		SpawnEntityWorld("enemyZap", { x = self.worldPosition.x + shotOffX + self.movement.x, y = self.worldPosition.y + shotOffY + self.movement.y }, zapArgs)
	else
		if lightningAudio ~= nil then
			lightningAudio.Stop()
			lightningAudio = nil
		end
	end
end

function OnDeinitialise()
	if lightningAudio ~= nil then lightningAudio.Stop() end
end

function OnDestroy()
	if lightningAudio ~= nil then lightningAudio.Stop() end
end
