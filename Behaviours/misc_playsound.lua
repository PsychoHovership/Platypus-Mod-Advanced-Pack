local sound

function OnInitialise()
    if self.commandArgs.HasField("sound") then sound = self.commandArgs.GetFieldString("sound") else sound = "s_fruit" end
    PlaySound(sound)
    self.Kill()
end
