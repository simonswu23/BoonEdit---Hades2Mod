---@meta _
---@diagnostic disable: lowercase-global


once('MetallicDroplet', function()
	modutil.mod.Path.Wrap('EndTimedBuff', function(base, traitData)
		local active = config.KeepsakeChanges.MetallicDroplet.Enabled
			and mod.tuning.MetallicDroplet.ResidualFraction > 0
			and traitData and traitData.SetupFunction and traitData.SetupFunction.Args
		local totalSpeedChange = active and traitData.SetupFunction.Args.Multiplier

		base(traitData)

		if not totalSpeedChange or totalSpeedChange == 1 then return end

		local residual = 1 + (totalSpeedChange - 1) * mod.tuning.MetallicDroplet.ResidualFraction
		game.MapState.KeepsakeSpeedPropertyChanges = nil
		local savedTime = traitData.CurrentTime
		traitData.CurrentTime = 1
		game.TimedBuffSetup(game.CurrentRun.Hero, { Multiplier = residual })
		traitData.CurrentTime = savedTime
	end)
end)
