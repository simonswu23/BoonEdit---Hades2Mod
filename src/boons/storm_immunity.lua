---@meta _
---@diagnostic disable: lowercase-global


-- Demeter's storms detonate on their Fuse but a foe is immune for far longer, so most of every
-- storm's ticks are thrown away and two overlapping storms do the work of one. Dropping the
-- window to a hair lets each detonation land.
function storm_immunity_projectiles()
	return mod.tuning.StormImmunity.Projectiles
end


function storm_immunity_suspended()
	return config.BoonChanges.StormImmunity.Enabled
end
