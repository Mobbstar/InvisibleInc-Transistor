local array = include( "modules/array" )
local util = include( "modules/util" )
local mathutil = include( "modules/mathutil" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local serverdefs = include( "modules/serverdefs" )

local ability_grace =
{
	--ability to kill fellow agents (for the algorithm stuff, go farther down)
	
	-- name = STRINGS.TRANSISTOR.AUGMENT_TRANSISTOR,
	name = STRINGS.TRANSISTOR.ABILITY_REMOTECRITICAL, 
	getName = function( self, sim, unit )
		return self.name
	end,

	createToolTip = function( self, sim, abilityOwner, abilityUser, targetID )
		local target = sim:getUnit(targetID)
		local name = target and target:getName()
		local desc = STRINGS.TRANSISTOR.AGENTDAEMONS.DEREK.ABILITY_GRACE_DESC
		if name then
			return abilityutil.formatToolTip(util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.DEREK.ABILITY_GRACE_TIP, name), desc)
		else
			return abilityutil.formatToolTip(STRINGS.TRANSISTOR.AGENTDAEMONS.DEREK.ABILITY_GRACE_TIP2, desc)
		end
	end,
	
	-- profile_icon = "gui/items/icon-action_peek.png",
	-- profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_shocktrap_small.png",
	profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_short_range_teleporter_small.png",

	alwaysShow = false,
	canUseWhileDragging = true,
	-- HUDpriority = 2,
	-- proxy = true, --on doors
	usesAction = true, --colour
	-- usesMP = true, --colour

	isTarget = function( self, userUnit, targetUnit )
		
		if targetUnit and targetUnit:isValid()
		and not targetUnit:isGhost() and targetUnit:isPC() and targetUnit:getTraits().isAgent then
			return true
		end 
		
		return false
	end,

	acquireTargets = function( self, targets, game, sim, unit, userUnit )
		local units = {}
		for _, targetUnit in pairs(sim:getPC():getUnits()) do
			if self:isTarget( userUnit, targetUnit) then
				if targetUnit ~= userUnit then --that's a separate, agent-inherit ability, for the sole sake of moving it to the action tray -M
					table.insert(units, targetUnit)
				end
			end
		end
		return targets.unitTarget( game, units, self, unit, userUnit )
	end,

	canUseAbility = function( self, sim, unit, userUnit, targetID )
		if not sim:getNPC():hasMainframeAbility("transistordaemonderek") then
			return false
		end
		
		if self.alreadyUsed ~= nil and (self.alreadyUsed == sim:getTurnCount()) then
			return false, "Already used during this turn"
		end
		
		if targetID then 
			local targetUnit = sim:getUnit( targetID )
			if not self:isTarget( userUnit, targetUnit ) then
				return false, STRINGS.UI.REASON.INVALID_TARGET
			end
		end

		return true 
	end, 

	confirmAbility = function( self, sim, ownerUnit, userUnit )
	
		return STRINGS.TRANSISTOR.AGENTDAEMONS.DEREK.CONFIRM_GRACE --confirm teleport

	end,

	executeAbility = function( self, sim, unit, userUnit, target )
		local targetUnit = sim:getUnit(target)
		
		self.alreadyUsed = sim:getTurnCount()
		
		local x0, y0 = userUnit:getLocation()
		local x1, y1 = targetUnit:getLocation()
		local userUnit_cell = sim:getCell(x0, y0)
		local targetUnit_cell = sim:getCell(x1, y1)

		--hide and teleport out agent1
		sim:dispatchEvent( simdefs.EV_TELEPORT, { units = { userUnit }, warpOut = true } )
		sim:dispatchEvent( simdefs.EV_UNIT_HIDE, { unit = userUnit, hide = true } )
		sim:warpUnit(userUnit, targetUnit_cell)		
		
		--hide and teleport out agent2
		sim:dispatchEvent( simdefs.EV_TELEPORT, { units = { targetUnit }, warpOut = true } )
		sim:dispatchEvent( simdefs.EV_UNIT_HIDE, { unit = targetUnit, hide = true } )	
		sim:warpUnit(targetUnit, userUnit_cell)
		
		
		--hide and teleport in agent1
		sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = userUnit:getID(), noSightingFx=true } )
		sim:dispatchEvent( simdefs.EV_TELEPORT, { units = { userUnit }, warpOut = false } )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = userUnit } )
		
		--hide and teleport in agent2
		sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = targetUnit:getID(), noSightingFx=true } )
		sim:dispatchEvent( simdefs.EV_TELEPORT, { units = { targetUnit }, warpOut = false } )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = targetUnit } )
		
		sim:processReactions()
		
	end,
	
	onSpawnAbility = function( self, sim, unit )
		self.abilityOwner = unit
		self.alreadyUsed = nil
	end,
	
	onDespawnAbility = function( self, sim, unit )
		self.abilityOwner = nil
	end,

}

return ability_grace
