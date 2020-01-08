local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local speechdefs = include("sim/speechdefs")
local abilityutil = include( "sim/abilities/abilityutil" )
local inventory = include( "sim/inventory" )


local peek_tooltip = class( abilityutil.hotkey_tooltip )

function peek_tooltip:init( hud, unit, ... )
	abilityutil.hotkey_tooltip.init( self, ... )
	self._game = hud._game
	self._unit = unit
	self._cost = 0
	if unit:getTraits().gooseRibbon then
	    		self._cost = 1
			else
				self._cost = 1
			end
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
		baseMPCost = 1,
		range = 7,
		hotkey = "abilityOverwatch",
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
		
		--profile_icon = "gui/items/icon-action_peek.png",

	    getProfileIcon = function( self, sim, abilityOwner, abilityUser, hasTarget )
	    		return "gui/skill_honk.png"
	    end,
		
		getMPCost = function( self, sim, goose )
			if goose:getTraits().gooseRibbon then
	    		return self.baseMPCost -- + 1
			else
				return self.baseMPCost
			end
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

		profile_icon = "gui/skill_honk.png",
		HUDpriority = 3,
		alwaysShow = true,
		usesMP = true,
		trigger = false,

		getName = function( self, sim, unit )
			return self.name
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

		usesAction = false,
		
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
			
			
		--	sim:emitSpeech( unit, speechdefs.EVENT_PEEK )
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
			

			-- process reactions BEFORE turning guards around for extra utility

			
	--[==[		for i,spookUnit in pairs(spookedUnits) do
				
				if spookUnit:isAiming() then 
				--	spookUnit:setAiming(false)
				--	sim:dispatchEvent( simdefs.EV_UNIT_OVERWATCH, { unit = spookUnit, cancel=true })
					local gun = simquery.getEquippedGun( spookUnit )
					local bystanders = {}
					local pratt = false
					for i,bystander in pairs(spookUnit:getSeenUnits()) do
						local shot =  simquery.calculateShotSuccess( sim, spookUnit, bystander, gun )
						if shot and bystander:getUnitOwner() == spookUnit:getUnitOwner() and not bystander:isKO() and not sim:getCell(pratt:getLocation()) == sim:getCell(spookUnit:getLocation())  then
							table.insert (bystanders, bystander)
						end
					end
					if #bystanders > 0 then
						pratt = bystanders[sim:nextRand(1, (#bystanders))]
						if pratt then
							spookUnit:hasAbility("shootOverwatch"):getDef():executeAbility( sim, gun, spookUnit, pratt )
						end
					end
				end
				spookUnit:turnToFace(x0, y0)
			--	if spookUnit:getTraits().vip and spookUnit:getTraits().canKO then
			--		targetUnit:setKO( sim, 1 )
			--	end
			end
		]==]	
		--	unit:getTraits().sightable = true
			
			for i,turnUnit in pairs(turnUnits) do
				if sim:canUnitSeeUnit( unit, turnUnit ) then
					turnUnit:turnToFace(x0, y0)
				end
			end
	--		for i,spookUnit in pairs(spookedUnits) do
	--			spookUnit:getTraits().hasSight = true
	--		end
			
			---- bonus KO in 1 tile range
			
			sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = userUnit:getID(), facing = newFacing } )	
			
			
		end,
		
		
		------walking and forgetting stuff is included here for ease
		
		
		onSpawnAbility = function( self, sim, unit )
			self.abilityOwner = unit
			local goose = self.abilityOwner
			local gooseAug = array.findIf( unit:getChildren(), function( u ) return u:getTraits().gooseAug ~= nil end )
			if gooseAug then
				gooseAug:getUnitData().profile_icon = gooseAug:getTraits().profile_A
				gooseAug:getUnitData().profile_icon_100 = gooseAug:getTraits().profile_sml_A
			end
			sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
			sim:addTrigger( simdefs.TRG_UNIT_APPEARED, self )
			sim:addTrigger( simdefs.TRG_UNIT_DISAPPEARED, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_ALARM_STATE_CHANGE, self )
			
			------- if steal do steal
			------- 1/5 chance of happening
			local goosedoesitems = sim:getParams().difficultyOptions.goosedoesitems
			local contraband = false
			
			if goosedoesitems then
				unit:getTraits().steal = sim:nextRand(1, 15)
			end
			
	--[==[		if contraband then
				log:write("checking items for goose")
				local mainframeItems = {}
				for i,unit in pairs(sim:getAllUnits())do
					if unit:getTraits().mainframe_item then
						table.insert(mainframeItems,unit)
					end
				end
				local items = {}
					for i, agent in pairs( mainframeItems ) do	
						if goose:getName() ~= agent:getName() then
							for j,item in ipairs(agent:getChildren())do
								if not item:getTraits().augment and item:hasAbility( "carryable" ) ~= nil then
									table.insert (items, item)
								end
							end
						end
					end
				local item = items[sim:nextRand(1, #items)]	
				inventory.giveItem( item._parent, goose, item )
			end
		]==]
		end,
			
		onDespawnAbility = function( self, sim, unit )
			sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
			sim:removeTrigger( simdefs.TRG_UNIT_APPEARED, self )
			sim:removeTrigger( simdefs.TRG_UNIT_DISAPPEARED, self )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_ALARM_STATE_CHANGE, self )
			self.abilityOwner = nil
		end,

		onTrigger = function( self, sim, evType, evData )
			local goose = self.abilityOwner
			local difficulty = sim:getParams().difficultyOptions.gooseAlarm
			
			if goose then
				
				if evType == simdefs.TRG_UNIT_WARP and evData.unit == goose and evData.unit:getPlayerOwner() and evData.to_cell and evData.from_cell then
					if  ( simquery.checkIfCellNextToCover(sim, evData.to_cell) ) and ( simquery.checkIfCellNextToCover(sim, evData.from_cell) 
					or ( goose:getTraits().movePath and #goose:getTraits().movePath == 0 ) ) then   -- evData.unit:getTraits().sneaking or simquery.checkIfCellNextToCover(sim, evData.to_cell) 
						evData.unit:getTraits().walk = nil
						--log:write("run")
					else
						evData.unit:getTraits().walk = true
						--log:write("walk")
					end
					if goose:getTraits().movePath and #goose:getTraits().movePath > 0 and not goose:getTraits().sneaking then
					--	evData.unit:getTraits().walk = nil
						if goose:getTraits().gooseRibbon then
							goose:changeKanim(  "kanim_goose_wings_R" )
						else
							goose:changeKanim(  "kanim_goose_wings" )
						end
					else
						goose:changeKanim(  nil )
					end
				end
				
				if evType == simdefs.TRG_UNIT_APPEARED and not evData.unit == goose and evData.seerID then
					local guard = sim:getUnit( evData.seerID )
					if guard then guard:getTraits().seenHuman = true end
				end
				if goose and evType == simdefs.TRG_UNIT_DISAPPEARED and evData.unit == goose and evData.seerID then
					local guard = sim:getUnit( evData.seerID )
					if guard and not guard:getTraits().seenHuman and not guard:getTraits().vip and guard:getTraits().unGoosed and sim:getTrackerStage() < difficulty then
						guard:getTraits().alerted = false
					end
					
				end
		
			
				if goose and not goose:getTraits().firstHonk and evType == simdefs.TRG_START_TURN then
					local guards = sim:getNPC():getUnits()

						for i,guard in ipairs(guards) do
							if guard:getBrain() then
								guard:getTraits().unGoosed = true
							end
						end
					goose:getTraits().firstHonk = true
					
					local items = {}
					--log:write("checking items for goose")
					------- find all non intsalled held by others and add to table
					for i, agent in pairs( goose:getPlayerOwner():getUnits() ) do	
						--log:write( agent:getName() )
						if goose:getName() ~= agent:getName() then
							--log:write("items of " .. agent:getName())
							for j,item in ipairs(agent:getChildren())do
								if not item:getTraits().augment then
									table.insert (items, item)
									--log:write("item - " .. item:getName())
								end
							end
						end
					end
					
					local invSpace = 8 - goose:getInventoryCount()
					
					if goose:getTraits().steal and goose:getTraits().steal == 1 and #items > 0 and invSpace > 0 then
						local item = items[sim:nextRand(1, #items)]	
						inventory.giveItem( item._parent, goose, item )
						--log:write("give goose " .. item:getName())
					end
					
					------- give one random items
				end
				
				if difficulty and evType == simdefs.TRG_ALARM_STATE_CHANGE then
					local alarmState = sim:getTrackerStage()
					if alarmState == difficulty then
						local sound = "goose/goosesfx/" .. difficulty .. "_bells_mono"
						if sound then 
							local x0, y0 = goose:getLocation()
				--			sim:emitSound( { path = sound, range = 0 }, x0, y0, nil )
							local gooseAug = array.findIf( goose:getChildren(), function( u ) return u:getTraits().gooseAug ~= nil end )
							if gooseAug then
								gooseAug:getUnitData().profile_icon = gooseAug:getTraits().profile_B
								gooseAug:getUnitData().profile_icon_100 = gooseAug:getTraits().profile_sml_B
							end
							sim:emitSound( { path = sound, range = 0 }, x0, y0, nil )
							sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.GOOSE.ABILITIES.GUARD_POPUP, unit = goose, color=cdefs.COLOR_CORP_WARNING })
							sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.GOOSE.ABILITIES.GUARD_WARNING, color=cdefs.COLOR_CORP_WARNING, sound =  "goose/goosesfx/wings", icon=nil } )
							sim:dispatchEvent( simdefs.EV_CAM_PAN, { x0, y0 } )	
							sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 30 )
						end
					end
				end
			end
			
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
		end
	}
return honk
