---@meta _
---@diagnostic disable: lowercase-global

-- Loaded once after all other mods. Nothing needs it: boons that depend on another mod are imported
-- from `reload_late.lua` and do their load-time work inside `once`.
