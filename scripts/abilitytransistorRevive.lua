local array = include( "modules/array" )
local util = include( "modules/util" )
local mathutil = include( "modules/mathutil" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local serverdefs = include( "modules/serverdefs" )

local abilitytransistorRevive =
{
	--ability to kill fellow agents (for the algorithm stuff, go farther down)
	
	-- name = STRINGS.TRANSISTOR.AUGMENT_TRANSISTOR,
	name = STRINGS.TRANSISTOR.ABILITY_REMOTEHEAL, 
	getName = function( self, sim, unit )
		return self.name
	end,

	createToolTip = function( self, sim, abilityOwner, abilityUser, targetID )
		local target = sim:getUnit(targetID)
		local name = target and target:getName()
		local desc = STRINGS.TRANSISTOR.ABILITY_REMOTEHEAL_DESC
		if name then
			return abilityutil.formatToolTip(util.sformat(STRINGS.TRANSISTOR.ABILITY_REMOTEHEAL_TIP, name), desc)
		else
			return abilityutil.formatToolTip(STRINGS.TRANSISTOR.ABILITY_REMOTEHEAL, desc)
		end
	end,
	
	profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_heart_monitor_small.png",

	alwaysShow = true,
	canUseWhileDragging = true,
	usesAction = true, --colour

	isTarget = function( self, userUnit, targetUnit )
		
		if targetUnit and targetUnit:isValid()
		and not targetUnit:isGhost() and targetUnit:isPC()
		and not targetUnit:getTraits().isDrone 
		and not targetUnit:getTraits().isGuard --psiTakenGuard
		and targetUnit:isDead() and targetUnit:getTraits().transistorKO then 
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
		if unit:getAP() < 1 then
			return false, STRINGS.UI.REASON.ATTACK_USED
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
		return STRINGS.TRANSISTOR.CONFIRM_REMOTEHEAL
	end,

	executeAbility = function( self, sim, unit, userUnit, target )
		local targetUnit = sim:getUnit(target)	
		targetUnit:getTraits().transistorKO = nil
		assert( targetUnit:getWounds() >= targetUnit:getTraits().woundsMax ) -- Cause they're dead, should have more wounds than max
		targetUnit:getTraits().dead = nil
		targetUnit:addWounds( targetUnit:getTraits().woundsMax - targetUnit:getWounds() - 1 )
		local x1, y1 = targetUnit:getLocation()
		sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.REVIVED,x=x1,y=y1,color={r=1,g=1,b=1,a=1}} )
		sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = targetUnit } )

		targetUnit:setKO( sim, nil )
		targetUnit:getTraits().mp = math.max( 0, targetUnit:getMPMax() - (targetUnit:getTraits().overloadCount or 0) )		
	end,
}

return abilitytransistorRevive
