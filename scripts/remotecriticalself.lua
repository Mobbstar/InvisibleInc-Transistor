local array = include( "modules/array" )
local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local abilityutil = include( "sim/abilities/abilityutil" )

local abilitytransistor =
{
	--ability to kill yourself (refer to abilitytransistor.lua for the original code, this is a copy for moving the ability button to the actions tray)
	--I know it's not good practise, but far easier than hacking the client to add this functionality -M
	
	name = STRINGS.TRANSISTOR.ABILITY_REMOTECRITICAL, 
	getName = function( self, sim, unit )
		return self.name
	end,

	createToolTip = function( self, sim, abilityOwner, abilityUser )
		local name = abilityUser and abilityUser:getName()
		local desc = simdefs.transistor_on_ko and STRINGS.TRANSISTOR.ABILITY_REMOTECRITICAL_DESC_KO or STRINGS.TRANSISTOR.ABILITY_REMOTECRITICAL_DESC
		if name then
			return abilityutil.formatToolTip(util.sformat(STRINGS.TRANSISTOR.ABILITY_REMOTECRITICAL_TIP, name), desc)
		else
			return abilityutil.formatToolTip(STRINGS.TRANSISTOR.ABILITY_REMOTECRITICAL, desc)
		end
	end,
	
	-- profile_icon = "gui/items/icon-action_peek.png",
	-- profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_shocktrap_small.png",
	profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_heart_monitor_small.png",

	alwaysShow = true,
	canUseWhileDragging = true,
	-- HUDpriority = 2,
	-- proxy = true, --on doors
	usesAction = true, --colour
	-- usesMP = true, --colour
	
	canUseAbility = function( self, sim, unit, userUnit )
		if userUnit:getAP() < 1 then
			return false, STRINGS.UI.REASON.ATTACK_USED
		end

		return true 
	end, 

	confirmAbility = function( self, sim, ownerUnit, userUnit )
		for i, unit in pairs( userUnit:getPlayerOwner():getUnits() ) do
			if unit:hasAbility( "escape" ) and not unit:isKO() and unit ~= userUnit then
				return string.format(STRINGS.TRANSISTOR.CONFIRM_REMOTECRITICAL, userUnit:getName())
			end
		end
		return string.format(STRINGS.TRANSISTOR.CONFIRM_REMOTECRITICAL_LASTAGENT, userUnit:getName())
	end,

	executeAbility = function( self, sim, unit, userUnit )
		
		--if easy mode is enabled, just KO them and skip all the permadeath stuff
		if simdefs.transistor_on_ko then
			userUnit:setKO( sim, 3 )
			userUnit:useAP(sim)
			return
		end
		
		local agent_id = userUnit._unitData.agentID	
		local agents = include( "sim/unitdefs/agentdefs" )
		local mortalitychanged = nil
		
		-- this block is here for the purposes of the Permadeath mod. If permadeath is on, the agent will briefly become critical-able for the Transistor attack, then reset afterwards (so they'll still be killable by guards as usual) - Hek
		
		-- for k,v in pairs(agents) do
			-- if v.agentID and (v.agentID == agent_id) and (v.traits.canBeCritical == false) then
				-- userUnit:getTraits().canBeCritical = true
				-- mortalitychanged = true
				-- -- log:write("LOG: changed traits")
			-- end
		-- end
		-- this stuff is pointless with the current Permadeath build - Hek
	
		userUnit:getTraits().transistorKO = true
		if userUnit:getTraits().canBeCritical == false then 
			userUnit:getTraits().canBeCritical = true 
			mortalitychanged = true 
		end
		userUnit:onDamage((userUnit:getTraits().woundsMax or 1) - (userUnit:getTraits().wounds or 0))
		userUnit:useAP(sim)
		
		--resetting of canBeCritical - Hek
		if mortalitychanged then
			userUnit:getTraits().canBeCritical = false
			mortalitychanged = nil
		end
	end,
	
}

return abilitytransistor