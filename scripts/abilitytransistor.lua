local array = include( "modules/array" )
local util = include( "modules/util" )
local mathutil = include( "modules/mathutil" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local serverdefs = include( "modules/serverdefs" )

--Note: (ARCHIVE) agents get specific IDs if SAA is installed
local _agentdaemons = {
	[1] = "decker", --DECKER
	[230] = "decker", --DECKER (ARCHIVE)
	[2] = "shalem", --SHALEM
	[232] = "shalem", --SHALEM (ARCHIVE)
	[3] = "xu", --XU
	[234] = "xu", --XU (ARCHIVE)
	[4] = "banks", --BANKS
	[233] = "banks", --BANKS (ARCHIVE)
	[5] = "maria", --MARIA
	[231] = "maria", --MARIA (ARCHIVE)
	[6] = "nika", --NIKA
	[235] = "nika", --NIKA (ARCHIVE)
	[7] = "sharp", --SHARP
	[236] = "sharp", --SHARP (ARCHIVE)
	[8] = "prism", --PRISM
	[237] = "prism", --PRISM (ARCHIVE)
	[99] = "monster", --MONSTER (STORY)
	[100] = "monster", --MONSTER
	[107] = "central", --CENTRAL (STORY)
	[108] = "central", --CENTRAL
	[1000] = "olivia", --OLIVIA
	[1001] = "derek", --DEREK
	[1002] = "rush", --RUSH
	[1003] = "draco", --DRACO
	transistor_red = "red", --RED
	carmen_sandiego_o  = "carmen", --CARMEN
	mod_01_pedler = "pedler", --PEDLER
	mod_02_mist = "mist", --MIST
	mod_03_ghuff = "ghuff", --GHUFF
	mod_04_n_umi = "numi", --N-UMI
} 

local function removeAlgorithm(self, sim, unit)
	abilityID = _agentdaemons[unit:getUnitData().agentID or 0] or "generic"
	--disable the daemon again (fails if none of this type are left)
	sim:getNPC():removeAbility( sim, "transistordaemon".. abilityID )
	self.downedagents[unit] = nil
end

local abilitytransistor =
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

	isTarget = function( self, userUnit, targetUnit )
		
		if targetUnit and targetUnit:isValid()
		and not targetUnit:isGhost() and targetUnit:isPC()
		and targetUnit:getTraits().canBeCritical ~= nil --Can't check for true because of Permadeath
		and not targetUnit:getTraits().isDrone 
		and not targetUnit:getTraits().isGuard --psiTakenGuard
		and not targetUnit:isDead() then 
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
		-- for i, unit in pairs( userUnit:getPlayerOwner():getUnits() ) do
			-- if unit:hasAbility( "escape" ) and not unit:isKO() and unit ~= userUnit then
				return STRINGS.TRANSISTOR.CONFIRM_REMOTECRITICAL
			-- end
		-- end
		-- Red has a separate ability for doing this to herself, so in this ability, there will always be an agent (Red) still standing.
		-- return STRINGS.TRANSISTOR.CONFIRM_REMOTECRITICAL_LASTAGENT
	end,

	executeAbility = function( self, sim, unit, userUnit, target )
		local targetUnit = sim:getUnit(target)
		
		--if easy mode is enabled, just KO them and skip all the permadeath stuff
		if simdefs.transistor_on_ko then
			targetUnit:setKO( sim, 3 )
			unit:useAP(sim)
			return
		end
		
		local agent_id = targetUnit._unitData.agentID	
		local agents = include( "sim/unitdefs/agentdefs" )
		local mortalitychanged = nil
		
		
		-- this block is here for the purposes of the Permadeath mod. If permadeath is on, the agent will briefly become critical-able for the Transistor attack, then reset afterwards (so they'll still be killable by guards as usual) - Hek
		
		-- for k,v in pairs(agents) do
			-- if v.agentID and (v.agentID == agent_id) and (v.traits.canBeCritical == false) then
				-- targetUnit:getTraits().canBeCritical = true
				-- mortalitychanged = true
				-- -- log:write("LOG: changed traits")
			-- end
		-- end
		-- this stuff is pointless with the current Permadeath build - Hek
		
		targetUnit:getTraits().transistorKO = true
		if targetUnit:getTraits().canBeCritical == false then 
			targetUnit:getTraits().canBeCritical = true 
			mortalitychanged = true 
		end
		sim:getUnit(target):onDamage(1)
		unit:useAP(sim)
		
		--resetting of canBeCritical - Hek
		if mortalitychanged then
			targetUnit:getTraits().canBeCritical = false
			mortalitychanged = nil
		end
		
	end,
	
	
	
	-- algorithm stuff
	
	onSpawnAbility = function( self, sim, unit )
		self.abilityOwner = unit
		sim:addTrigger( simdefs.TRG_UNIT_KO, self )
		
		if sim:getPC() and sim:getPC():getUnits() then
			self:recalcPossibleDaemons( sim )
		else
			sim:addTrigger( simdefs.TRG_START_TURN, self )
		end
		
		sim:addTrigger( simdefs.TRG_UNIT_RESCUED, self )
		sim:addTrigger( simdefs.TRG_UNIT_ESCAPED, self )
		sim:addTrigger( simdefs.TRG_UNIT_KILLED, self ) -- PERMADEATH. not needed unless we decide to add a custom event for her... -Hek
	end,
	
	onDespawnAbility = function( self, sim, unit )
		sim:removeTrigger( simdefs.TRG_UNIT_KO, self )
		sim:removeTrigger( simdefs.TRG_START_TURN, self )
		sim:removeTrigger( simdefs.TRG_UNIT_RESCUED, self )
		sim:removeTrigger( simdefs.TRG_UNIT_ESCAPED, self )
		-- sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self ) -- PERMADEATH
		self.abilityOwner = nil
		self._possibleDaemons = nil
		--if red leaves, remove all Transistor effects
		for unit, _ in pairs(self.downedagents) do
			removeAlgorithm(self, sim, unit)
		end
	end,
	
	onTrigger = function( self, sim, evType, evData )
		
		if evType == simdefs.TRG_START_TURN then
			if sim:getPC() and sim:getPC():getUnits() then
				self:recalcPossibleDaemons( sim )
				if not self.secondturn then
					self.secondturn = true --hack to kinda fix final mission tooltip, as Story Agents spawn after init
				else
					sim:removeTrigger( simdefs.TRG_START_TURN, self )
				end
			end

			-- PERMADEATH --
			if evData:isPC() and sim:getTurnCount() <= 0 then
			-- log:write("LOG: permadeath turn count started")
				local agency = sim:getParams().agency
				--log:write("LOG: agency transistorkia")
				--log:write(util.stringize(agency.transistorkia,2))
				if agency.transistorkia then
					local KIApool = agency.transistorkia

					if #KIApool > 0 then
						-- local ghostfunction = KIApool[sim:nextRand(1, #KIApool) ]
						-- log:write(util.stringize(ghostfunction,2))
						
						-- get our random set of KIA agent daemons, but not more than four
						local poolsizemax
						if #KIApool > 4 then poolsizemax = 4 else poolsizemax = #KIApool end -- either 4 or all available, whichever is lesser, minimum 1 though due to if condition at start of block
						local poolsize = sim:nextRand(1,poolsizemax) -- spawn varying number each mission
						if simdefs.transistor_permadeath_poolrand then --We run the nextRand anyways for backwards compatibilitiy (random is no longer default)
							poolsize = poolsizemax
						end
						local spawnedpool = {} -- what we'll actually spawn
						local tempdaemons = util.tcopy(KIApool)
						local spawnedlimiter = false -- ensures max 1 daemon per spawned batch
						while #spawnedpool < poolsize do
							
								local i = sim:nextRand(1, #tempdaemons)
								if #KIApool > 2 and sim:nextRand() < .25 and not spawnedlimiter then
									-- 25% chance to spawn Endless daemon instead of agent algorithm if you've been naughty
									local limiter = serverdefs.ENDLESS_DAEMONS[ sim:nextRand(1, #serverdefs.ENDLESS_DAEMONS) ]
									table.insert(spawnedpool, limiter)
									spawnedlimiter = true
								else
									table.insert(spawnedpool, tempdaemons[i])
									table.remove(tempdaemons, i)
								end	
							
						end

						for k, ghostfunction in pairs(spawnedpool) do
							sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=nil } ) -- this does nothing because it's overriden by start of mission HUD..
							
							sim:getNPC():addMainframeAbility(sim, ghostfunction, sim:getNPC(), 0)
						end						
		
					end
				end
			end
			-- /PERMADEATH
			
		elseif evType == simdefs.TRG_UNIT_RESCUED
		or evType == simdefs.TRG_UNIT_ESCAPED then
			self:recalcPossibleDaemons( sim )
			
			if evType == simdefs.TRG_UNIT_ESCAPED and evData
			and self.downedagent and self.downedagents[evData] then
				removeAlgorithm(self, sim, evData)
			end
			
		elseif evType == simdefs.TRG_UNIT_KO then
			--apparently this includes agent "deaths" á là "critical condition"
			--the agent gets KO'd and flagged "critical", but not properly replaced with a corpse
			self.downedagents = self.downedagents or {} --this might be a bit redundant
			if evData.unit and evData.unit:isPC() then
				--check for agent daemon
				-- log:write("JUST KILLED..."..evData.unit:getUnitData().agentID)
				if self.downedagents[evData.unit] then
					if evData.ticks == nil and not evData.unit:isDead() then --waking up...
						removeAlgorithm(self, sim, evData.unit)
						if evData.unit:getTraits().transistorKO then evData.unit:getTraits().transistorKO = nil end
					end
				elseif not self.downedagents[evData.unit]
				and (simdefs.transistor_on_ko or evData.unit:isDead()) then --don't care about the ticks, dead is dead
					
					-- special FX - Hek
					evData.unit._sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/EMP_explo" )
					local x0, y0 = evData.unit:getLocation()
					sim:dispatchEvent( simdefs.EV_SCANRING_VIS, { x= x0,y= y0, range=3 } )
					--install daemon
					local abilityID = _agentdaemons[evData.unit:getUnitData().agentID or 0] or "generic"
					sim:getNPC():addMainframeAbility(sim, "transistordaemon".. abilityID, evData.unit, 0 )
					self.downedagents[evData.unit] = true
					
				end
			end
			
		--PERMADEATH--
		elseif evType == simdefs.TRG_UNIT_KILLED then
			log:write("LOG transistor death")
			-- log:write(util.stringize(evData.unit,3))
			if evData.unit and evData.unit:getUnitData().agentID and evData.unit:getTraits().corpseTemplate then							
				if not sim.transistordeath then 
					sim.transistordeath = {}
				end
					
				local abilityID = _agentdaemons[evData.unit:getUnitData().agentID or 0]
					if abilityID == "generic" then
						abilityID = "generickia"
					elseif abilityID == "mist" then
						abilityID = "mistkia"
					end
				local agentdaemon = ("transistordaemon".. abilityID)	
				table.insert(sim.transistordeath, agentdaemon)
				-- log:write(util.stringize(agentdaemon,2))
				log:write(util.stringize(sim.transistordeath,2))
				-- special FX
				evData.corpse._sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/transferData" )				
				local x0, y0 = evData.corpse:getLocation()
				sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, {x = x0, y = y0, units = nil, range = 7 } )
				
				-- if agentdaemon == "transistordaemonred" then --to make death as severe as the user apparently desires: if this is reached in the first place, do not install algorithms just yet. -M
				if evData.unit == self.abilityOwner then --the only exception is Red, because her death means there won't be algorithms in any mission afterwards.
					self:onDespawnAbility(self, sim, self.abilityOwner)
					sim:getNPC():addMainframeAbility(sim, agentdaemon, nil, 0 )
				else
					-- despawns active algorithm if the agent bled out
					self.downedagents = self.downedagents or {} --this might be a bit redundant
					removeAlgorithm(self, sim, evData.unit)
				end
			end
		end
		-- /PERMADEATH --xoxo, Hek	
		
	end,
	
	--this is a hack for client
	_possibleDaemons = {},
	recalcPossibleDaemons = function(self, sim)
		self._possibleDaemons = {}
		for i, unit in pairs(sim:getPC():getUnits()) do
			local abilityID = _agentdaemons[unit:getUnitData().agentID or 0]
			if abilityID and not self._possibleDaemons[abilityID] then
				self._possibleDaemons[abilityID] = unit
			end
		end
	end,
	getPossibleDaemons = function(self)
		return self._possibleDaemons or {}
	end,
}

return abilitytransistor
