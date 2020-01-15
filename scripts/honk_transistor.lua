local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local inventory = include( "sim/inventory" )


local peek_tooltip = class( abilityutil.hotkey_tooltip )

function peek_tooltip:init( hud, unit, ... )
	abilityutil.hotkey_tooltip.init( self, ... )
	self._game = hud._game
	self._unit = unit
	self._cost = 1
end

function peek_tooltip:activate( screen )
	abilityutil.hotkey_tooltip.activate( self, screen )
	self._game.hud:previewAbilityAP( self._unit, self._cost )
end

function peek_tooltip:deactivate()
	abilityutil.hotkey_tooltip.deactivate( self )
	self._game.hud:previewAbilityAP( self._unit, 0 )
end


local honk =
	{
		name = STRINGS.GOOSE.ABILITIES.HONK,
		profile_icon = "gui/skill_honk.png",
		baseMPCost = 1,
		range = 7,
		-- hotkey = "abilityOverwatch",
		HUDpriority = 3,
		alwaysShow = true,
		usesMP = true,
		usesAction = false,
		trigger = false,

		getName = function( self, sim, unit )
			return self.name
		end,

	    getProfileIcon = function( self, sim, abilityOwner, abilityUser, hasTarget )
	    	return self.profile_icon
	    end,

		getMPCost = function( self, sim, goose )
			return self.baseMPCost
	    end,

		onTooltip = function( self, hud, sim, abilityOwner, abilityUser )
			local unit = abilityOwner
			local aoeRange = self.range
			if unit:getTraits().gooseRibbon then
				aoeRange = aoeRange + 1
			end
			local tip = util.sformat(STRINGS.GOOSE.ABILITIES.HONK_TIP, aoeRange )
			if unit:getTraits().gooseRibbon then
				local meleeWep = simquery.getEquippedMelee( unit )
				if unit:getAP() > 0 and meleeWep ~= nil and not (meleeWep:getTraits().cooldown and meleeWep:getTraits().cooldown > 0 )  then
					local kot = meleeWep:getTraits().damage
					if kot then kot = util.sformat(STRINGS.GOOSE.ABILITIES.MELEE_HONK_TIP_KO, meleeWep:getTraits().damage ) else kot = "" end
					local pwr = self:getTotalPWR(sim, unit, meleeWep)
					if pwr then pwr =  util.sformat(STRINGS.GOOSE.ABILITIES.MELEE_HONK_TIP_PWR, (self:getTotalPWR(sim, unit, meleeWep)) ) else pwr = "" end
					local cd = meleeWep:getTraits().cooldownMax
					if cd then cd =  util.sformat(STRINGS.GOOSE.ABILITIES.MELEE_HONK_TIP_CD, (meleeWep:getTraits().cooldownMax * 2) ) else cd = "" end

					tip = util.sformat(STRINGS.GOOSE.ABILITIES.MELEE_HONK_TIP, aoeRange, meleeWep:getName(), kot, pwr, cd)
				end
			end

			return peek_tooltip( hud, abilityUser, self, sim, abilityOwner, tip ) --STRINGS.GOOSE.ABILITIES.HONK_TIP )
		end,

		getTotalPWR = function (self, sim, goose, tazerUnit)
			local player = goose:getPlayerOwner()
			if tazerUnit:getTraits().drainsAllPWR then
				return player:getCpus()
			end
			local cost = 0
			if  tazerUnit:getTraits().pwrCost then
				cost = cost + tazerUnit:getTraits().pwrCost
			end
			local x0, y0 = goose:getLocation()
			local cells = self:getExplodeCells(sim, x0, y0, 1.5)
			for i, cell in ipairs(cells) do
				for i, cellUnit in ipairs( cell.units ) do
					if tazerUnit:getTraits().damage and simquery.isEnemyAgent( player, cellUnit) then
						local meleeDamage = math.ceil( simquery.calculateMeleeDamage(sim,  tazerUnit, cellUnit) * 0.5 )
						if meleeDamage > 0 then
							if tazerUnit:getTraits().armorPWRcost and cellUnit:getArmor() then -- sim:isVersion("0.17.12") and
								local PWRcostPoints = returnPWRcostPoints(sim, goose, cellUnit)
								if PWRcostPoints > 0 then
									cost = cost + PWRcostPoints
								end
							end
						end
					end
				end
			end

			if cost > 0 then
				return cost
			else
				return nil
			end

		end,

		getNearestTarget = function( self, unit, LOSnotNeeded, includeKO, includeDrones )

			local range = 9999
			local unitPlayer = unit:getPlayerOwner()
			local x1,y1 = unit:getLocation()
			local nearestUnit = nil
			local sim = unit:getSim()
			for i,simUnit in pairs(sim:getAllUnits()) do
				if simUnit:getPlayerOwner() and simUnit:getPlayerOwner() ~= unitPlayer and simquery.canHear( simUnit ) and not simUnit:isDead() and (not simUnit:isKO() or includeKO) and (not simUnit:getTraits().isDrone or includeDrones) then
					if LOSnotNeeded or sim:canUnitSee(simUnit, x1,y1) then

						local x2,y2 = simUnit:getLocation()
						local distance = math.floor( mathutil.dist2d( x1,y1,x2,y2 ) )
						if distance < range then
							nearestUnit = simUnit
							range = distance
						end
					end
				end
			end

			return nearestUnit, range
		end,

		getExplodeCells = function (self,sim,x0,y0,range)

			if not x0 and not y0 then
				x0, y0 = self:getLocation()
			end

			local currentCell = sim:getCell( x0, y0 )
			local cells = {currentCell}
			if range then
				local coords = simquery.rasterCircle( self._sim, x0, y0, range )

				for i=1,#coords-1,2 do
					local cell = sim:getCell(coords[i],coords[i+1])
					if cell then
					local raycastX, raycastY = sim:getLOS():raycast(x0, y0, cell.x, cell.y)
						if raycastX == cell.x and raycastY == cell.y then
							table.insert(cells, cell)
						end
					end
				end
			end
			return cells
		end,

		canUseAbility = function( self, sim, unit )

			local cost = self:getMPCost(sim,unit)
			if unit:getMP() < cost then
				return false, string.format(STRINGS.UI.REASON.REQUIRES_AP,cost)
			end

			if unit:getTraits().gooseRibbon then
				local playerPWR = unit:getPlayerOwner():getCpus()
				local meleeWep = simquery.getEquippedMelee( unit )
				if unit:getAP() > 0 and meleeWep ~= nil and not (meleeWep:getTraits().cooldown and meleeWep:getTraits().cooldown > 0 ) and not (meleeWep:getTraits().pwrCost and meleeWep:getTraits().pwrCost > playerPWR ) then
					self.usesAction = true
				else
					self.usesAction = false
				end
			end

			local x0, y0 = unit:getLocation()
			local fromCell = sim:getCell( x0, y0 )

			return true
		end,


		executeAbility = function( self, sim, unit, userUnit, exitX, exitY, exitDir )

			userUnit:setInvisible(false)
			userUnit:setDisguise(false)

			local aoeRange = self.range
			if unit:getTraits().gooseRibbon then
				aoeRange = aoeRange + 1
			end

			local x0, y0 = unit:getLocation()
			local fromCell = sim:getCell( x0, y0 )

			local targetUnit, enemyDist = self:getNearestTarget( userUnit, false, false, true )

			if targetUnit and enemyDist and userUnit:isValid() and sim:canUnitSeeUnit( userUnit, targetUnit ) and enemyDist < 7 then -- aim the goose
				local x1,y1 = targetUnit:getLocation()
				local newFacing = simquery.getDirectionFromDelta(x1-x0,y1-y0)
				--simquery.suggestAgentFacing(userUnit, newFacing)
				userUnit:turnToFace(x1, y1)
               	userUnit:resetAllAiming()
			end

			-- Any doors?
			local honkInfo = { x0 = x0, y0 = y0, cellvizCount = 0}
			if exitX and exitY and exitDir then
				local exitCell = sim:getCell(exitX, exitY)
				if exitCell then
					honkInfo.preferredExit = exitCell.exits[exitDir]
				end
			end

		--	sim:dispatchEvent( simdefs.EV_UNIT_PEEK, { unitID = unit:getID(), peekInfo = honkInfo } )


			--unit:setAiming( false )
			local oldFacing = userUnit:getFacing()
			local newFacing = (math.floor (userUnit:getFacing() * 0.5)*2) -- cardinals only or the goose gets it
			local revive = false


			-- find units to turn / scare

			local cells = {}
			cells = simquery.rasterCircle( self._sim, x0, y0, aoeRange )
			local turnUnits = {}
			local spookedUnits = {}
			--local units = {}
			for i, x, y in util.xypairs( cells ) do
				local cell = self._sim:getCell( x, y )
				if cell then
					for _, cellUnit in ipairs(cell.units) do
						local player = unit:getPlayerOwner()
						if cellUnit ~= unit and (simquery.isEnemyAgent( player, cellUnit ) and simquery.canHear( cellUnit ) ) then
							--table.insert( units, cellUnit )
							local brain = cellUnit:getBrain()
							local interest = nil
							local targTable = 1
							if brain and not sim:canUnitSeeUnit( cellUnit, unit ) and not cellUnit:getTraits().isDrone then
								interest = brain:getInterest()
								local distance = math.floor ( mathutil.dist2d( x0,y0,cell.x,cell.y ) )
								if not (interest and (interest.sourceUnit == userUnit or (interest.x == x0 and interest.y == y0))) and distance == 1 then
									--targTable = 2
								end
							end

							if targTable == 1 then
								table.insert (turnUnits, cellUnit)
							else
								table.insert (spookedUnits, cellUnit)
							end

						end
					end
				end
			end

			-- do, do honk, do honk goose

			local sound = "goose/goosesfx/honk"
			local sound2 = "goose/goosesfx/wings"
			--local sound = { path = "goose/goosesfx/honk", range = 7, innocuous = true },

			--sim:dispatchEvent( simdefs.EV_UNIT_HEAL, { unit = userUnit, target = userUnit, revive = revive, facing = newFacing, sound = sound, soundFrame = 1 } )

			-- ANIM CHANGE for human agents. If necessary to update this ability with a newer version of the one from Goose mod, find the EV_UNIT_USEDOOR and emitSound lines and replace them with the block below - Hek
			sim:dispatchEvent( simdefs.EV_UNIT_OVERWATCH_MELEE, { unit = userUnit })
			-- sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = userUnit:getID(), facing = newFacing, sound = sound2, soundFrame = 1 } ) --original animation
			sim:emitSound( { path = sound, range = aoeRange }, x0, y0, nil )
			sim:dispatchEvent( simdefs.EV_UNIT_OVERWATCH_MELEE, { unit = userUnit, cancel=true})
			--/ANIM CHANGE

			if unit:getTraits().gooseRibbon then
				local tazerUnit = simquery.getEquippedMelee( userUnit )
				local player = unit:getPlayerOwner()
				local playerPWR = player:getCpus()
				if tazerUnit and tazerUnit:getTraits().damage and not (tazerUnit:getTraits().cooldown and tazerUnit:getTraits().cooldown > 0 ) and not ( unit:getAP() and unit:getAP() < 1) and not (tazerUnit:getTraits().pwrCost and tazerUnit:getTraits().pwrCost > playerPWR )  then

					local range = 1
					local didKO = false
					local didKill = false
					local didAttack = false
					sim:dispatchEvent( simdefs.EV_KO_GROUP, true )
					local cells = self:getExplodeCells(sim, x0, y0, 1.5)
					sim:dispatchEvent( simdefs.EV_FLASH_VIZ, {x = x0, y = y0, units = nil, range = range} )
					for i, cell in ipairs(cells) do
						for i, cellUnit in ipairs( cell.units ) do
							local x2,y2 = cellUnit:getLocation()
							if tazerUnit:getTraits().damage and simquery.isEnemyAgent( player, cellUnit) then
								local meleeDamage = math.ceil( simquery.calculateMeleeDamage(sim,  tazerUnit, cellUnit) * 0.5 )
								if meleeDamage > 0 then
									if tazerUnit:getTraits().armorPWRcost and cellUnit:getArmor() then -- sim:isVersion("0.17.12") and
										local PWRcostPoints = returnPWRcostPoints(sim, userUnit, cellUnit)
										if PWRcostPoints > 0 then
											player:addCPUs( -(tazerUnit:getTraits().armorPWRcost * PWRcostPoints), sim, x2,y2)
										end
									end
									if tazerUnit:getTraits().drainsAllPWR then
										local cpus = player:getCpus()
										player:addCPUs( -cpus )
										sim:dispatchEvent( simdefs.EV_UNIT_FLY_TXT, {txt=util.sformat(STRINGS.UI.FLY_TXT.MINUS_PWR, cpus), x=x0,y=y0, color={r=163/255,g=243/255,b=248/255,a=1},} )
									end
									if tazerUnit:getTraits().lethalMelee then
										cellUnit:killUnit(sim)
										didKill = true
									else
										local koTime = math.max( 0, meleeDamage )
										cellUnit:setKO(sim, koTime)
										didKO = true
									end
									didAttack = true
									sim:triggerEvent(simdefs.TRG_UNIT_HIT, {targetUnit=cellUnit, sourceUnit=unit, x=x2, y=y2, melee=true})
								end
							end
						end
					end

					if didKO then
						if unit:getTraits().convertKOtoPWR then
							player:addCPUs(koTime, sim, x0,y0, 30 )
							sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(unit:getTraits().convertKOtoPWR, koTime), x=x0,y=y0, color=cdefs.AUGMENT_TXT_COLOR} )
						end
					elseif didAttack then
						if unit:countAugments( "augment_predictive_brawling" ) > 0 then
							local BRAWLING_BONUS = 6
							if unit:getPlayerOwner() ~= sim:getCurrentPlayer() then
								if not unit:getTraits().floatTxtQue then
									unit:getTraits().floatTxtQue = {}
								end
								table.insert(unit:getTraits().floatTxtQue,{txt=util.sformat(STRINGS.UI.FLY_TXT.PREDICTIVE_BRAWLING,BRAWLING_BONUS),color={r=1,g=1,b=41/255,a=1}})
							else
								sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = unit } )
								sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.UI.FLY_TXT.PREDICTIVE_BRAWLING,BRAWLING_BONUS),x=x0,y=y0,color={r=1,g=1,b=41/255,a=1}} )
							end
							unit:addMP( BRAWLING_BONUS )
						end
						if unit:getTraits().tempMeleeBoost then
							unit:getTraits().tempMeleeBoost = 0
						end
						if not sim:isVersion("0.17.12") and unit:getTraits().kinetic_capacitor_bonus_charged then
							unit:getTraits().kinetic_capacitor_bonus_charged = nil
						end

					end

					sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
					sim:startTrackerQueue(false)
					sim:processDaemonQueue()
					inventory.useItem( sim, userUnit, tazerUnit )
					if tazerUnit:getTraits().cooldown then
						tazerUnit:getTraits().cooldown = tazerUnit:getTraits().cooldown * 2
					end

					unit:useAP( sim )
				end
			end

			unit:useMP( self:getMPCost(sim,unit),sim )
			sim:processReactions( unit )

			for i,turnUnit in pairs(turnUnits) do
				if sim:canUnitSeeUnit( unit, turnUnit ) then
					turnUnit:turnToFace(x0, y0)
				end
			end

			sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = userUnit:getID(), facing = newFacing } )

		end,

	}
return honk
