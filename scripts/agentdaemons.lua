local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include( "client_defs" )
local mainframe = include( "sim/mainframe" )
local modifiers = include( "sim/modifiers" )
local mission_util = include( "sim/missions/mission_util" )
local serverdefs = include("modules/serverdefs")
local mainframe_common = include("sim/abilities/mainframe_common")
local unitghost = include( "sim/unitghost" )
local simfactory = include( "sim/simfactory" )
local unitdefs = include( "sim/unitdefs" )
-- local rand = include( "modules/rand" )


-- local function getTransistorOwner(sim)
	-- for i, unit in pairs(sim:getPC():getUnits()) do
		-- if unit:ownsAbility("ability_transistor") then
			-- return unit
		-- end
	-- end
-- end

--copies from simplayer.lua
local function getCellGhost( player, cellx, celly )
	assert( player._ghost_cells, util.stringize( player, 1 ))
	return player._ghost_cells[ simquery.toCellID( cellx, celly ) ]
end
local function addCellGhost( self, sim, cell )
	local ghost_units, ghost_cells = self._ghost_units, self._ghost_cells
	if ghost_cells[ cell.id ] ~= nil then
		return 		-- Never update ghost info if it's already ghosted.
	end

	self._nextGhostID = (self._nextGhostID or 0) + 1
	local cellghost = {}
	cellghost.id = cell.id
	cellghost.x = cell.x
	cellghost.y = cell.y
	cellghost.impass = cell.impass
	cellghost.exits = {}
	cellghost.units = {}	
	cellghost.exitID = cell.exitID
	-- keep track of relative ages of ghosts, given that nextID() is monotonically increasing.
	cellghost.ghostID = self._nextGhostID

	for dir,exit in pairs(cell.exits) do
		-- Only ghost doors.  Other stuff doesn't change, so reference the raw exit.  Reduces table junk.
		if exit.door then
			cellghost.exits[ dir ] = util.tmerge( {}, exit )
		else
			cellghost.exits[ dir ] = exit
		end
	end

	ghost_cells[ cell.id ] = cellghost
	return cellghost
end
local function addUnitGhost( ghost_units, ghost_cell, unit )
	local ghost_unit = ghost_units[ unit:getID() ]
	if ghost_unit ~= nil then
		return false -- Never update ghost info if it's already ghosted.
	end
	if unit:getTraits().noghost then
		return false
	end

	ghost_unit = unitghost.createUnitGhost( unit )

	table.insert( ghost_cell.units, ghost_unit )
	ghost_units[ unit:getID() ] = ghost_unit

	return true
end
local function removeUnitGhost( player, cellghost, sim, unitID )
	local ghost_units = player._ghost_units
	local ghost = ghost_units[ unitID ]

	if ghost then
		if cellghost == nil then
			cellghost = getCellGhost( player, ghost:getLocation() )
		end

		assert( array.find( cellghost.units, ghost ))  -- If a unit ghost it exists, it must exist in a ghosted cell.

		array.removeElement( cellghost.units, ghost )
		local unit = player._sim:getUnit(unitID)
		ghost_units[ unitID ] = nil

	-- Handle the unghosting (whether or not a ghost actually existed).
	-- A unit is unghosted because (1) it was seen (2) its ghost was seen, in either case,
	-- its viz state must be updated.  Unghosting a unit is NOT equivalent to that unit becoming seen,
	-- but note that a unit becoming seen DOES always result in unghosting.

		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = ghost } )	
	end
end
-- for INTERNATIONALE
local function generateGhost( sim, unit )
	local player = sim:getPC()
	local cell = sim:getCell( unit:getLocation() )
	local cellghost = getCellGhost( player, cell.x, cell.y )
	if cellghost then
		removeUnitGhost( player, nil, sim, unit:getID() )
		addUnitGhost( player._ghost_units, cellghost, unit )
	elseif not sim:canPlayerSee( player, cell.x, cell.y ) then
		cellghost = addCellGhost( player, sim, cell )
		addUnitGhost( player._ghost_units, cellghost, unit )
	end
end
-- for DRACO
local function isKnownCell( sim, cellx, celly)
	return getCellGhost(sim:getPC(), cellx, celly)
	or sim:canPlayerSee( sim:getPC(), cellx, celly )
end

return
{
	--DECKER
	-- +1 AP per alerted guard
		-- recalc on turn start
		-- listen for the alerted trigger to add mid-turn
	transistordaemondecker = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.DECKER ) )
	{
		icon = "gui/icons/daemon_icons/fu_chase.png",
		title = STRINGS.AGENTS.DECKARD.NAME,
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			-- self.duration = 1 --same as self.turns apparently
			-- self.turns = 1 --turns to executeTimedAbility
			-- self.perpetual = true --every turn, executeTimedAbility
			-- self.transistorOwner = getTransistorOwner( sim )
			self.trackedagents = {}
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )

			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_UNIT_ALERTED, self )
			self.totalbonus = 0
			self:recalcBonusMP( sim )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )	
			sim:removeTrigger( simdefs.TRG_UNIT_ALERTED, self )
			
			for unit, _ in pairs(self.trackedagents) do
				unit:addMP( - self.totalbonus )
				unit:addMPMax( - self.totalbonus )
			end
		end,
		
		recalcBonusMP = function( self, sim )
			local calcBonus = 0
			sim:forEachUnit(function(unit)
				if unit:isAlerted() and unit:isNPC() and not unit:isKO() then
					calcBonus = calcBonus + 1
				end
			end)
			
			for unit, _ in pairs(self.trackedagents) do
				if not (unit and unit:isValid()) then
					self.trackedagents[unit] = nil
				elseif not unit:isPC() then
					unit:addMP( - self.totalbonus )
					unit:addMPMax( - self.totalbonus )
					self.trackedagents[unit] = nil
				end
			end
			for i, unit in pairs(sim:getPC():getUnits()) do
				if unit:isValid() and unit:getTraits().mp then --the KO agent has no "mp" trait
					local diff = calcBonus - self.totalbonus
					if not self.trackedagents[unit] then
						self.trackedagents[unit] = true
						diff = calcBonus
					end
					if diff then
						if diff > 0 then
							--fancy "gain AP" fx
							local x1, y1 = unit:getLocation()
							sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = unit } )
							sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
								unit = unit,
								txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.DECKER.NAME),
								x = x1, y = y1,
								color = {r = 255/255, g = 255/255, b = 51/255, a = 1 },
							} )
						end
						
						--apply the diff
						unit:addMP( diff )
						unit:addMPMax( diff )
					end
				end
			end
			self.totalbonus = calcBonus
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if ( evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() )
				or evType == simdefs.TRG_UNIT_ALERTED then
				self:recalcBonusMP( sim )
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
		
		executeTimedAbility = function( self, sim )
			-- sim:getNPC():removeAbility(sim, self )
		end,
	},
	--CENTRAL
	-- +33% Daemon Reversal Chance
	-- +10 PWR whenever a Daemon Reversal happens
	transistordaemoncentral = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.CENTRAL ) )
	{
		icon = "gui/icons/daemon_icons/fu_parry.png",
		title = STRINGS.AGENTS.CENTRAL.NAME,
		noDaemonReversal = true,
		daemonReversalAddTransistor = 33, -- for the code, see modinit.lua / init()
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_DAEMON_REVERSE, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_DAEMON_REVERSE, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_DAEMON_REVERSE then
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_gainCPU" )
				sim:getPC():addCPUs( 10, sim )
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--SHALEM
	-- +2 Armor Piercing on PC guns
	-- +2 KO on PC guns
	-- +4 CD on PC guns
	transistordaemonshalem = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.SHALEM ) )
	{
		icon = "gui/icons/daemon_icons/fu_aim.png",
		title = STRINGS.AGENTS.SHALEM.NAME,
		noDaemonReversal = true,
		
		--everything handled in modinit.lua / init()
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
		end,
	},
	--INTERNATIONALE
	-- reveal all drones as ghosts
	-- update whenever the drone moves
	-- need to restore on every player turn
	transistordaemonmaria = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.MARIA ) )
	{
		icon = "gui/icons/daemon_icons/fu_triangulate.png",
		title = STRINGS.AGENTS.INTERNATIONALE.NAME,
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:forEachUnit(function(u)
				if u:hasTrait("isDrone") then
					generateGhost( sim, u )
				end
			end)
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN then
				sim:forEachUnit(function(u)
					if u:hasTrait("isDrone") then
						generateGhost( sim, u )
					end
				end)
			elseif evType == simdefs.TRG_UNIT_WARP then
				if evData.unit and evData.unit:hasTrait("isDrone") and not (evData.unit:getUnitData().kanim == "kanim_badcell") then
					generateGhost( sim, evData.unit )
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--XU
	-- gain PWR when Shock Trap triggers
	transistordaemonxu = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.XU ) )
	{
		icon = "gui/icons/daemon_icons/fu_mischief.png",
		title = STRINGS.AGENTS.XU.NAME,
		noDaemonReversal = true,
		
		--everything handled in modinit.lua / init()
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
		end,
	},
	--NIKA
	-- gain PWR when melee
	-- instantly cool down weapon
	-- more melee Armor Piercing
	transistordaemonnika = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.NIKA ) )
	{
		icon = "gui/icons/daemon_icons/fu_punch.png",
		title = STRINGS.AGENTS.NIKA.NAME,
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_UNIT_HIT, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_HIT, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_UNIT_HIT then
				if evData.targetUnit and evData.targetUnit:isAlerted()
				and evData.sourceUnit and evData.sourceUnit:isPC()
				and evData.melee then
					local x, y = evData.sourceUnit:getLocation()
					sim:getPC():addCPUs( 4, sim, x, y )
					local weapon = simquery.getEquippedMelee( evData.sourceUnit )
					if weapon and weapon:isValid() then
						if weapon:getTraits().cooldown then
							weapon:getTraits().cooldown = 0
						end
					end
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--PRISM
	-- getting overwatched spawns a hologrenade that deletes after player turn
	transistordaemonprism = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.PRISM ) )
	{
		icon = "gui/icons/daemon_icons/fu_integrity.png",
		title = STRINGS.AGENTS.PRISM.NAME,
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_UNIT_NEWTARGET, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_NEWTARGET, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_UNIT_NEWTARGET then
				if evData.unit and not evData.unit:isPC() and not evData.unit:hasTrait("pacifist")
				and evData.target and evData.target:isPC()
				and (not evData.target:getTraits().transistorprismturn or evData.target:getTraits().transistorprismturn < sim:getTurnCount() ) then
					evData.target:getTraits().transistorprismturn = sim:getTurnCount()
					local x1, y1 = evData.target:getLocation()
					-- spawn cover unit here
					local grenadeUnit = simfactory.createUnit( unitdefs.lookupTemplate( "item_hologrenade_transistor" ), sim )
					sim:spawnUnit( grenadeUnit )
					sim:warpUnit( grenadeUnit, sim:getCell(x1, y1) )
					grenadeUnit:setPlayerOwner(evData.target:getPlayerOwner())
					grenadeUnit:activate()
					-- removal on enemy turn conveniently handled by simgrenade
					
					sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
						unit = evData.target,
						txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.PRISM.NAME),
						x = x1, y = y1,
						color = {r = 255/255, g = 255/255, b = 51/255, a = 1 },
					} )
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--DRACO
	-- killing a guard reveals a random unseen area of the level
	-- if there are no sufficiently unseen areas, give credits
	transistordaemondraco = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.DRACO ) )
	{
		icon = "gui/icons/daemon_icons/fu_read.png",
		title = STRINGS.DLC1 and STRINGS.DLC1.AGENTS.DRACO.NAME or "Draco", --use the official name if available
		noDaemonReversal = true,
		-- creditsBonus = 400, --reduced by 50 each time, total of 1800 for 8 scans
		creditsBonus = 240, --reduced by 30 each time, total of 1080 for 8 scans
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		tryBonus = function( self, sim, targetUnit )
			if targetUnit and not targetUnit:isPC()
			and not targetUnit:hasTrait("drone")
			and not targetUnit:hasTrait("transistordaemondraco") then
				targetUnit:getTraits().transistordaemondraco = true
				-- find valid area to reveal
				local range = 5
				local cellx
				local celly
				local allcells = {}
				for y, xcords in ipairs(sim._board) do
					for x, cell in ipairs(xcords) do
						if not isKnownCell( sim, x, y ) then --this is a bit wrong, as the centre of a valid area could already be known, but this greatly improves performance
							table.insert(allcells, simquery.toCellID( x, y ))
						end
					end
				end
				while (not cellx or not celly) and #allcells > 0 do
					local cellIdx = sim:nextRand(1, #allcells)
					if allcells[cellIdx] then
						local x, y = simquery.fromCellID( allcells[cellIdx] )
						table.remove(allcells, cellIdx)
						
						-- log:write("CHECKING FOR REVEAL... "..x.."/"..y)
						local numcells = 0
						for i, x2, y2 in util.xypairs( simquery.rasterCircle( sim, x, y, range ) ) do
							local cell = sim:getCell( x2, y2 )
							if cell and not isKnownCell( sim, x2, y2 )
							and (not cell.procgenRoom or cell.procgenRoom.zone ~= "elevator_guard") then -- exclude uninteresting cells
								numcells = numcells + 1
								-- log:write("NUMCELLS... ("..x.."/"..y..") ".. numcells)
								if numcells > 8 then
									--We found our coords, break
									cellx = x
									celly = y
									break
								end
							end
						end
						
					end
				end
				
				if cellx and celly then
					-- reveal the area
					local revealedcells = simquery.rasterCircle( sim, cellx, celly, range )
					for i, x, y in util.xypairs( revealedcells ) do
						local cell = sim:getCell( x, y )
						-- log:write("REVEAL CELL ("..x.."/"..y..") ".. tostring(cell~=nil))
						if cell then
							sim:getPC():glimpseCell( sim, cell )
							sim:dispatchEvent( simdefs.EV_CAM_PAN, { cellx, celly } )
							for _, unit in ipairs(cell.units) do
								if not unit:hasTrait("isGuard") then
									sim:getPC():glimpseUnit( sim, unit:getID() )
								end
							end
						end
					end 
					sim:dispatchEvent( simdefs.EV_LOS_REFRESH, { player = sim:getPC(), cells = revealedcells } )
					-- sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety_DLC001/Actions/scandrone_scan" )
					sim:dispatchEvent( simdefs.EV_SCANRING_VIS, {x = cellx, y = celly, range = range } ) -- the actual vfx is hidden in grenaderig
					sim:dispatchEvent( simdefs.EV_CAM_PAN, { cellx, celly } ) --look I really like cam pan events
					sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, { --look I really like floaty texts -M
						txt = STRINGS.TRANSISTOR.AGENTDAEMONS.DRACO.NAME,
						alwaysShow = true,
						skipQue = true,
						sound = "SpySociety_DLC001/Actions/scandrone_scan",
						x = cellx, y = celly,
						color = {r = 255/255, g = 255/255, b = 255/255, a = 1 },
					} )
				elseif self.creditsBonus > 0 then
					-- There's no area to be revealed, grant credits instead
					-- log:write("YOU GET MONEY")
					local x1, y1 = targetUnit:getLocation()
					sim._resultTable.credits_gained.transistordaemondraco = (sim._resultTable.credits_gained.transistordaemondraco or 0) + self.creditsBonus
					sim:getPC():addCredits( self.creditsBonus, sim, x1, y1 )
					self.creditsBonus = self.creditsBonus - 30
				end
			end
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				sim:forEachUnit(function(targetUnit)
					local pinned, pinner = simquery.isUnitPinned( sim, targetUnit )
					-- log:write("TRY PIN BONUS for ".. (targetUnit and targetUnit:getUnitData().name or "UNKNOWN") ..", ".. pinned .." by ".. (pinner or "nobody"))
					if targetUnit:isValid() and pinned and pinner and pinner:isPC() then
						self:tryBonus( sim, targetUnit )
						sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_DAEMON_REVEAL.path ) -- Hek
					end
				end)
			elseif evType == simdefs.TRG_UNIT_KILLED then
				if evData.unit and not evData.unit:getUnitData().agentID then -- copypasting because lazy... check that it's not an agent, with Permadeath on
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_DAEMON_REVEAL.path ) -- Hek
				end				
				self:tryBonus( sim, evData.unit )
				
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--BANKS
	-- daemon lowers firewalls
	transistordaemonbanks = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.BANKS ) )
	{
		icon = "gui/icons/daemon_icons/fu_besiege.png",
		title = STRINGS.AGENTS.BANKS.NAME,
		noDaemonReversal = true,
		hasInstalled = false, --little hack so it doesn't trigger itself
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_DAEMON_INSTALL, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_DAEMON_INSTALL, self )
			self.hasInstalled = false
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_DAEMON_INSTALL then
				if not self.hasInstalled then self.hasInstalled = true else -- skip the first one (it's this daemon itself)
					-- local b_lower = true
					local targets = {}
					sim:forEachUnit(function(unit)
						if unit:getTraits().mainframe_ice and unit:getTraits().mainframe_ice > 1
						and not (unit:getTraits().isDrone and unit:isKO())
						and (unit:getTraits().mainframe_status ~= "off"
							or (unit:getTraits().mainframe_camera and unit:getTraits().mainframe_booting)
						) then
							table.insert(targets, unit)
							--pairs() always uses the same order, regardless of how often you use it. We need to use nextRand instead.
							-- if b_lower then
								-- -- mainframe.canBreakIce(sim, unit, 1) --reveals unit
								-- sim:dispatchEvent( simdefs.EV_UNIT_UPDATE_ICE, { unit = unit, ice = unit:getTraits().mainframe_ice, delta = -1 } )
								-- unit:getTraits().mainframe_ice = math.max(unit:getTraits().mainframe_ice - 2, 1)
								-- sim:triggerEvent( simdefs.TRG_ICE_BROKEN, { unit = unit } )
								-- sim:dispatchEvent( simdefs.EV_UNIT_MAINFRAME_UPDATE, {units={unit:getID()}} )
							-- end
							-- b_lower = not b_lower -- only lower every second one
						end
					end)
					for numleft = math.ceil(#targets * .5), 1, -1 do
						local i = sim:nextRand(1, #targets)
						sim:dispatchEvent( simdefs.EV_UNIT_UPDATE_ICE, { unit = targets[i], ice = targets[i]:getTraits().mainframe_ice, delta = -2 } )
						targets[i]:getTraits().mainframe_ice = math.max(targets[i]:getTraits().mainframe_ice - 2, 1)
						sim:triggerEvent( simdefs.TRG_ICE_BROKEN, { unit = targets[i] } )
						sim:dispatchEvent( simdefs.EV_UNIT_MAINFRAME_UPDATE, {units={targets[i]:getID()}} )
						table.remove(targets, i)
					end
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--RUSH
	-- getting overwatched refreshes MP and Attack
	transistordaemonrush = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.RUSH ) )
	{
		icon = "gui/icons/daemon_icons/fu_attention.png",
		title = STRINGS.DLC1 and STRINGS.DLC1.AGENTS.RUSH.NAME or "Rush",
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_UNIT_NEWTARGET, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_NEWTARGET, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_UNIT_NEWTARGET then
				--turrets?
				if evData.unit and not evData.unit:isPC() and not evData.unit:hasTrait("pacifist")
				and evData.target and evData.target:isPC() and not evData.target:hasTrait("takenDrone")
				and (not evData.target:getTraits().transistorrushturn or evData.target:getTraits().transistorrushturn < sim:getTurnCount() ) then
					evData.target:getTraits().transistorrushturn = sim:getTurnCount()
					evData.target:getTraits().mp = math.max( evData.target:getTraits().mp, evData.target:getMPMax() )
					evData.target:getTraits().ap = math.max( evData.target:getTraits().ap, 1 )
					if evData.target:getTraits().floatTxtQue then
						table.insert(evData.target:getTraits().floatTxtQue,{txt={
							txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.RUSH.NAME),
							color = {r = 255/255, g = 255/255, b = 51/255, a = 1 },
						}})
					else
						local x1, y1 = evData.target:getLocation()
						sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
							unit = evData.target,
							txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.RUSH.NAME),
							x = x1, y = y1,
							color = {r = 255/255, g = 255/255, b = 51/255, a = 1 },
						} )
					end
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--MONST3R
	-- fires when starting the turn next to a console (per agent/console pair)
	-- reduces all program cooldowns by 1
	-- 66% chance of daemon when fired
	transistordaemonmonster = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.MONSTER ) )
	{
		icon = "gui/icons/daemon_icons/fu_yield.png",
		title = STRINGS.AGENTS.MONST3R.NAME,
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				for i, sourceUnit in pairs(sim:getPC():getUnits()) do
					if sourceUnit:isValid() and not sourceUnit:isDown() then
						--scan nearby cells for consoles
						local x1, y1 = sourceUnit:getLocation()
						local sourceCell = sim:getCell( x1, y1 )
						local cells = {
							sim:getCell( x1 + 1, y1 ),
							sim:getCell( x1, y1 + 1 ),
							sim:getCell( x1 - 1, y1 ),
							sim:getCell( x1, y1 - 1 ),
						}
						for _, cell in ipairs(cells) do
							if simquery.isConnected( sim, sourceCell, cell ) then
								for _, unit in ipairs(cell.units) do
									if unit:hasTrait("mainframe_console") and unit:getTraits().mainframe_status ~= "off" then
										-- log:write("PROGRAM BONUS PROVIDED BY ".. (sourceUnit:getUnitData().name or "somebody"))
										--provide bonus
										for _, program in pairs(sim:getPC():getAbilities()) do
											if program.cooldown and program.cooldown > 0 then
												program.cooldown = program.cooldown - 1
											end
										end
										--install daemon
										if sim:nextRand() < .66 then
											programList = sim:handleOverrideAbility(serverdefs.OMNI_PROGRAM_LIST)
											if sim and sim:getParams().difficultyOptions.daemonQuantity == "LESS" then
												programList = sim:handleOverrideAbility(serverdefs.OMNI_PROGRAM_LIST_EASY)
											end
											sim:getNPC():addMainframeAbility( sim, programList[sim:nextRand(1, #programList)])
										end
									end
								end
							end
						end
					end
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--SHARP
	transistordaemonsharp = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.SHARP ) )
	{
		icon = "gui/icons/daemon_icons/fu_exceed.png",
		title = STRINGS.AGENTS.SHARP.NAME,
		noDaemonReversal = true,
		
		--Armor Piercing handled in modinit.lua / init()
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_UNIT_HIT, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_HIT, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_UNIT_HIT then
				if evData.sourceUnit and evData.sourceUnit:isPC() and evData.melee then
					local x, y = evData.sourceUnit:getLocation()
					local i = evData.sourceUnit:getAugmentCount()
					-- if i > 0 then
						-- if evData.sourceUnit:getPlayerOwner() ~= sim:getCurrentPlayer() then
							-- if not evData.sourceUnit:getTraits().floatTxtQue then
								-- evData.sourceUnit:getTraits().floatTxtQue = {}
							-- end
							-- table.insert(evData.sourceUnit:getTraits().floatTxtQue,{
								-- txt=util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.SHARP.NAME, i),
								-- color={r=1,g=1,b=41/255,a=1}})
						-- else
							-- sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = evData.sourceUnit } )
							-- sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {
								-- txt=util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.SHARP.NAME, i),
								-- x=x,y=y,
								-- color={r=1,g=1,b=41/255,a=1}} ) 
						-- end
						-- evData.sourceUnit:addMP( i * 2 )
					-- end
					i = (evData.sourceUnit:getTraits().augmentMaxSize or i) - i
					if i > 0 then
						sim:getPC():addCPUs( -i * 4, sim, x, y )
					end
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--DEREK
	-- +2 AP on turn start if behind cover
	transistordaemonderek = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.DEREK ) )
	{
		icon = "gui/icons/daemon_icons/fu_grace.png",
		title = STRINGS.DLC1 and STRINGS.DLC1.AGENTS.DEREK.NAME or "Derek",
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				for i, sourceUnit in pairs(sim:getPC():getUnits()) do
					if sourceUnit:isValid() and not sourceUnit:isDown() and sourceUnit:canHide()
					and simquery.checkIfCellNextToCover(sim, sim:getCell(sourceUnit:getLocation()) ) then
						sourceUnit:addMP( 2 )
					end
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	--OLIVIA
	-- melee on KO guard refreshes attack, kills and bypasses heart monitor
	transistordaemonolivia = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.OLIVIA ) )
	{
		icon = "gui/icons/daemon_icons/fu_coup.png",
		title = STRINGS.DLC1 and STRINGS.DLC1.AGENTS.OLIVIA.NAME or "Olivia",
		noDaemonReversal = true,
		
		--everything handled in modinit.lua / init()
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
		end,
	},
	--RED
	-- halves all guard armor
	-- reduces all guard mp
	transistordaemonred = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.RED ) )
	{
		icon = "gui/icons/daemon_icons/fu_crash.png",
		title = STRINGS.TRANSISTOR.RED.NAME,
		noDaemonReversal = true,
		
		--armor handled in modinit.lua / init()
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			
			self.mpAffected = {}
			sim:forEachUnit(function(unit)
				if unit and unit:isValid() and not unit:isPC() and unit:getTraits().mp and unit:getTraits().mpMax then
					unit:getTraits().mp = unit:getTraits().mp - 4
					unit:getTraits().mpMax = unit:getTraits().mpMax - 4
					self.mpAffected[unit] = true
				end
			end)
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
			sim:forEachUnit(function(unit)
				if unit and unit:isValid() and self.mpAffected[unit] and unit:getTraits().mp and unit:getTraits().mpMax then
					unit:getTraits().mp = unit:getTraits().mp + 4
					unit:getTraits().mpMax = unit:getTraits().mpMax + 4
				end
			end)
			self.mpAffected = nil
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_UNIT_WARP then
				if evData.unit and evData.unit:isValid()
				and not self.mpAffected[evData.unit] and not evData.unit:isPC()
				and evData.unit:getTraits().mp and evData.unit:getTraits().mpMax then
					evData.unit:getTraits().mp = evData.unit:getTraits().mp - 4
					evData.unit:getTraits().mpMax = evData.unit:getTraits().mpMax - 4
					self.mpAffected[evData.unit] = true
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	
	-- Mod agents, generic algorithms
	
	--CARMEN
	-- Generating interest points on agent location gives AP per agent per turn
	transistordaemoncarmen = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.CARMEN ) )
	{
		icon = "gui/icons/daemon_icons/fu_abscond.png",--needs icon
		title = STRINGS.CARMEN and STRINGS.CARMEN.AGENTS.CARMEN.NAME or "Carmen",
		noDaemonReversal = true,
		APbonus = 4,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_NEW_INTEREST, self )
			sim:addTrigger( simdefs.TRG_UNIT_NEWINTEREST, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_NEW_INTEREST, self )
			sim:removeTrigger( simdefs.TRG_UNIT_NEWINTEREST, self )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if (evType == simdefs.TRG_NEW_INTEREST) or (evType == simdefs.TRG_UNIT_NEWINTEREST) then
				-- log:write("LOG new interest")
				-- log:write(util.stringize(evData,2))				
				local targets = {} --table in case more than one target on cell (KO'd agents)
				
				if evData.target then 
					table.insert(targets, evData.target )
				elseif evData.interest and evData.interest.x and evData.interest.y then
					local cell = sim:getCell( evData.interest.x, evData.interest.y )
						for i, cellUnit in ipairs(cell.units) do
							if cellUnit:isValid() and ( cellUnit:getPlayerOwner() == sim:getPC() ) and cellUnit:getTraits().mp and not cellUnit:getTraits().isDrone then
								table.insert(targets, cellUnit)
							end
						end
				end
				
				if #targets > 0 then
					for i, target in pairs(targets) do				
						if sim:getCurrentPlayer() == sim:getPC() then
							if (not target:getTraits().transistorcarmenturn or target:getTraits().transistorcarmenturn < sim:getTurnCount() ) then
								target:getTraits().transistorcarmenturn = sim:getTurnCount()
								target:getTraits().mp = target:getTraits().mp + self.APbonus
								local x1, y1 = target:getLocation()
								sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
								unit = target,
								txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.CARMEN.NAME),
								x = x1, y = y1,
								color = {r = 255/255, g = 255/255, b = 51/255, a = 1 }
						} )
							end
						else --if interest points spawns on enemy turn
							target:getTraits().transistorcarmenbonus = true
						end
					end
				end	
				
			elseif evType == simdefs.TRG_START_TURN then
				-- log:write("LOG abscond start turn")
				for i, unit in pairs( sim:getPC():getUnits() ) do
					if unit:isValid() and unit:getTraits().transistorcarmenbonus then
						unit:getTraits().mp = unit:getTraits().mp + self.APbonus
						unit:getTraits().transistorcarmenbonus = nil
						unit:getTraits().transistorcarmenturn = sim:getTurnCount()
						local x1, y1 = unit:getLocation()
						sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
						unit = unit,
						txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.CARMEN.NAME),
						x = x1, y = y1,
						color = {r = 255/255, g = 255/255, b = 51/255, a = 1 }} )
					end
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	
	--Ghuff from Agent Mod Combo
	-- Observing guards tags them
	transistordaemonghuff= util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.GHUFF ) )
	{
		icon = "gui/icons/daemon_icons/fu_sleuth.png", --update
		title = STRINGS.AMRE and STRINGS.AMRE.AGENTS.GHUFF.NAME or "Ghuff",
		noDaemonReversal = true,
		
		--everything handled in modinit.lua / init()
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
		end,
	},
	
	--N-Umi from Agent Mod Combo
	-- More AP for hacked drones, control drones for longer
	transistordaemonnumi= util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.NUMI ) )
	{
		icon = "gui/icons/daemon_icons/fu_tuning.png", --update
		title = STRINGS.AMRE and STRINGS.AMRE.AGENTS.NU.NAME or "N-Umi",
		noDaemonReversal = true,
		MPbonus = 5,
		LeashBonus = 3,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_ICE_BROKEN, self )
			sim:getPC():getTraits().controlTicks = (sim:getPC():getTraits().controlTicks or 0) + self.LeashBonus
			
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_ICE_BROKEN, self )
			if sim:isVersion("0.17.5") then	
            	sim:getPC():getTraits().controlTicks = (sim:getPC():getTraits().controlTicks or 0) - self.LeashBonus --this doesn't affect already hacked drones but that's ok
        	end
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if (evType == simdefs.TRG_START_TURN) and (sim:getCurrentPlayer() == sim:getPC()) then
				sim:forEachUnit(function(u)
					if u:hasTrait("isDrone") and (u:getPlayerOwner() == sim:getPC() ) and u:hasTrait("mp") then
						u:addMP(self.MPbonus)
					end
				end)
			elseif evType == simdefs.TRG_ICE_BROKEN then --for drones hacked on same turn as daemon proccs -- currently doesn't work, more digging
				if evData.unit and evData.unit:getTraits().isDrone and evData.unit:getTraits().takenDrone and evData.unit:getTraits().mp then
					evData.unit:addMP(self.MPbonus)
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end
	},

--Mist from Agent Mod Combo
	-- Mist's body being pinned by guard causes her to possess that guard, seizing control until he dies or she wakes up. If guard dies, she is free to possess the next schmuck
	-- overwatch is disabled for hijacked guard because the animation bugs out, handled in modinit
	-- need to think of a permadeath version of this...
	transistordaemonmist = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.MIST ) )
	{
		icon = "gui/icons/daemon_icons/fu_transpose.png", --update
		title = STRINGS.AMRE and STRINGS.AMRE.AGENTS.MIST.NAME or "Mist",
		noDaemonReversal = true,
		trackerCount = 3,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:addTrigger( simdefs.TRG_UNIT_HIT, self )
			sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
			self.MistBody = agent
			
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:removeTrigger( simdefs.TRG_UNIT_HIT, self )
			sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
			self.MistBody = nil
			self.unPossessGuard( self, sim )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			local mist_cell = sim:getCell( self.MistBody:getLocation() )
			local x1, y1 = self.MistBody:getLocation()
			if (evType == simdefs.TRG_START_TURN) and ( sim:getCurrentPlayer() == sim:getPC() ) then

				if ( self.capturedGuard == nil ) then
				
					for i, cellUnit in ipairs(mist_cell.units) do
						if cellUnit:getTraits().isGuard and ( cellUnit:getPlayerOwner() == sim:getNPC() ) and not cellUnit:getTraits().isDrone and not cellUnit:isDown() then
							--cure the detached peripheral cone syndrome (visual bug) -M
							local periphRange_old = cellUnit:getTraits().LOSperipheralRange
							cellUnit:getTraits().LOSperipheralRange = 0
							sim:refreshUnitLOS( cellUnit )
							cellUnit:getTraits().LOSperipheralRange = periphRange_old

							--convert the guard
							cellUnit:setPlayerOwner( sim:getPC() )
							-- cellUnit:getTraits().takenDrone = true --so other guards won't shoot --no longer used!
							cellUnit:setDisguise(true)
							self.idlesOLD = cellUnit:getUnitData().idles -- needed to prevent weird anim glitches. technically this will also affect other guards but this shouldn't be noticeable, especially late in the level... smoking is bad
							cellUnit:getUnitData().idles = nil
							cellUnit:getTraits().noLoopOverwatch = nil
							cellUnit:getTraits().psiTakenGuard = true --custom tag just in case
							cellUnit:getTraits().canBeFriendlyShot = true --to enable betrayal behaviour
							cellUnit:getTraits().sneaking = true
							cellUnit:getTraits().thoughtVis = nil
							self.old_mainframeRecapture = cellUnit:getTraits().mainframeRecapture
							cellUnit:getTraits().mainframeRecapture = nil
							self.old_brain = cellUnit:getBrain() --they won't need their brain while we're in control, and keeping it messes with canSoftPath
							cellUnit._brain = nil
							
							sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = cellUnit } )
							self.capturedGuard = cellUnit
							-- self.oldLOS = cellUnit:getTraits().LOSarc
							-- self.oldLOSperiph = cellUnit:getTraits().LOSperipheralArc
							-- cellUnit:getTraits().LOSarc = math.pi * 2
							-- cellUnit:getTraits().LOSperipheralArc = nil
							if not cellUnit:getModifiers():has( "LOSarc", "psiTakenGuard" ) and cellUnit:getTraits().LOSarc then
								cellUnit:getModifiers():add( "LOSarc", "psiTakenGuard", modifiers.SET, math.pi * 2 )
							end
							if not cellUnit:getModifiers():has( "LOSperipheralArc", "psiTakenGuard" ) and cellUnit:getTraits().LOSperipheralArc then
								cellUnit:getModifiers():add( "LOSperipheralArc", "psiTakenGuard", modifiers.SET, nil )
							end
							
							-- fancy FX stuff because I'm weak
							-- sim:dispatchEvent( simdefs.EV_LOS_REFRESH, { seer = cellUnit, cells = {} } )
							sim:dispatchEvent( simdefs.EV_CAM_PAN, { self.MistBody:getLocation() } )
							sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/transferData" )
							-- sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_gainCPU" )
							-- sim:dispatchEvent( simdefs.EV_CLOAK_OUT, { unit = cellUnit  } )
							sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
								unit = cellUnit,
								txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.PSI_CONTROL),
								x = x1, y = y1,
								color = {r = 255/255, g = 255/255, b = 51/255, a = 1 },
							} )

							break
						end
					end
				else
					self.capturedGuard:getTraits().sneaking = true --is otherwise reset every turn apparently
				end
				
			elseif evType == simdefs.TRG_UNIT_KILLED then -- for if the possessed guard dies
				if self.capturedGuard then
					if evData.unit == self.capturedGuard then
						sim:dispatchEvent( simdefs.EV_CLOAK_OUT, { unit = evData.corpse  } ) --swooshy stuff
						sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_gainCPU" )
						local x1, y1 = evData.corpse:getLocation()
						sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
							unit = evData.corpse,
							txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.LOST_CONTROL),
							x = x1, y = y1,
							color = {r = 255/255, g = 255/255, b = 51/255, a = 1 },
						} )	
						self.capturedGuard = nil
					end
				end
				
			elseif evType == simdefs.TRG_UNIT_HIT then
				if self.capturedGuard and evData.sourceUnit and evData.targetUnit then
					if evData.sourceUnit == self.capturedGuard then
						if evData.targetUnit:getPlayerOwner() ~= self.capturedGuard:getPlayerOwner() then
							--targetUnit may be guard, drone, camera, turret, etc. (might be "neutral", but practically enemy player)
							self.capturedGuard:getTraits().psiBulletproof = true -- hack to keep guard from being shot before he's done shooting, causing a bug
							sim:processReactions( self.capturedGuard )
							if evData.targetUnit:getTraits().isGuard or evData.targetUnit:getTraits().isDrone then
								-- if (sim:nextRand() <= 0.5 ) then  -- a little RNG
									self.unPossessGuard( self, sim )
								-- end
								sim:trackerAdvance( self.trackerCount )
								-- should be punishing enough, as getting away with guard-on-guard murder is pretty easy
								-- try to recloak
							elseif self.capturedGuard and not sim:canPlayerSeeUnit( evData.targetUnit:getPlayerOwner() or sim:getNPC(), self.capturedGuard ) then
								log:write("Nobody saw this!!!")
								self.capturedGuard:setDisguise(true)
							end
						end
					end
				end
			elseif evType == simdefs.TRG_UNIT_WARP or evType == simdefs.TRG_END_TURN then
				if self.capturedGuard and self.capturedGuard:getTraits().psiBulletproof and ( (evData.unit and evData.unit == self.capturedGuard) or ( evType == simdefs.TRG_END_TURN ) ) then
					self.capturedGuard:getTraits().psiBulletproof = nil -- this needs to happen in on warp to get the most intuitive behaviour: guard is 'outed' after shooting another guard, but not immediately shot unless he moves, giving him the chance to get to cover
				end				
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
		
		unPossessGuard = function( self, sim )
			if self.capturedGuard and self.capturedGuard:isValid() then  --un-hijack guard!
				self.capturedGuard:setPlayerOwner( sim:getNPC() )
				self.capturedGuard:getUnitData().idles = self.idlesOLD
				self.capturedGuard:getTraits().disguise = false
				-- self.capturedGuard:setDisguise(false) --nice visual cue too
				sim:dispatchEvent( simdefs.EV_CLOAK_OUT, { unit = self.capturedGuard  } ) --swooshy stuff
				sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_gainCPU" )
				local x1, y1 = self.capturedGuard:getLocation()
				sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
					unit = self.capturedGuard,
					txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.LOST_CONTROL),
					x = x1, y = y1,
					color = {r = 255/255, g = 255/255, b = 51/255, a = 1 },
				} )	
				
				self.capturedGuard:setKO( sim, 3 )-- nap time.					
				self.capturedGuard:getTraits().psiTakenGuard = nil
				self.capturedGuard:getTraits().canBeFriendlyShot = nil
				-- self.capturedGuard:getTraits().takenDrone = nil
				-- self.capturedGuard:getTraits().LOSarc = self.oldLOS
				-- self.capturedGuard:getTraits().LOSperipheralArc = self.oldLOSperiph
				self.capturedGuard:getModifiers():remove( "psiTakenGuard" )
				self.capturedGuard:getTraits().mainframeRecapture = self.old_mainframeRecapture
				self.capturedGuard._brain = self.old_brain
				
				-- this resets aiming on guards overwatching the hijacked guard, otherwise they stay in overwatch after he's KO until next turn
				for k, u in pairs(sim:getNPC():getUnits() ) do
					if u and u:isValid() and sim:canUnitSeeUnit( u, self.capturedGuard ) and u:getBrain() and u:getBrain():getTarget() and u:getTraits().isAiming and not u:getTraits().isDrone and u:getBrain():getTarget() == self.capturedGuard then
						u:resetAllAiming()
					end
				end
			end
			self.capturedGuard = nil
		end,
	},
	
	--Mist from Agent Mod Combo
	-- Permadeath version: First guard to overwatch an agent gets mind controlled -- UNUSED
	-- transistordaemonmistkia = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.MIST_KIA ) )
	-- {
		-- icon = "gui/icons/daemon_icons/fu_transpose.png", --update
		-- title = STRINGS.AMRE and STRINGS.AMRE.AGENTS.MIST.NAME or "Mist",
		-- noDaemonReversal = true,
		-- trackerCount = 5,
		
		-- onSpawnAbility = function( self, sim, player, agent )
			-- sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			-- sim:addTrigger( simdefs.TRG_START_TURN, self )
			-- sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
			-- sim:addTrigger( simdefs.TRG_UNIT_HIT, self )
			-- sim:addTrigger( simdefs.TRG_UNIT_NEWTARGET, self )
			
		-- end,
		
		-- onDespawnAbility = function( self, sim )
			-- sim:removeTrigger( simdefs.TRG_START_TURN, self )
			-- sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
			-- sim:removeTrigger( simdefs.TRG_UNIT_HIT, self )
			-- sim:removeTrigger( simdefs.TRG_UNIT_NEWTARGET, self )
			
			-- if self.capturedGuard then  --un-hijack guard!
				-- self.capturedGuard:setPlayerOwner( sim:getNPC() )
				-- self.capturedGuard:getTraits().psiTakenGuard = nil
				-- self.capturedGuard:getTraits().canBeFriendlyShot = nil
				-- self.capturedGuard:getTraits().takenDrone = nil
				-- self.capturedGuard:getTraits().LOSarc = self.oldLOS
				-- self.capturedGuard:getTraits().LOSperipheralArc = self.oldLOSperiph
				-- self.capturedGuard:setKO( sim, 3 ) -- nap time
				-- sim:dispatchEvent( simdefs.EV_CLOAK_OUT, { unit = self.capturedGuard  } ) --swooshy special FX
			-- end
		-- end,
		
		-- onTrigger = function( self, sim, evType, evData, userUnit )
			-- if evType == simdefs.TRG_UNIT_NEWTARGET then
				-- if evData.unit and not evData.unit:isPC() and not evData.unit:hasTrait("pacifist")
				-- and evData.target and evData.target:isPC() and not evData.target:hasTrait("takenDrone") and (self.capturedGuard == nil) then
					-- self.capturedGuard = evData.unit
					-- local x1, y1 = evData.unit:getLocation()
					-- local cellUnit = evData.unit
				
					-- cellUnit:setPlayerOwner( sim:getPC() )
					-- cellUnit:getTraits().takenDrone = true --so other guards won't shoot
					-- cellUnit:getTraits().psiTakenGuard = true --custom tag just in case
					-- cellUnit:getTraits().canBeFriendlyShot = true --to enable betrayal behaviour
					-- cellUnit:getTraits().sneaking = true
					-- cellUnit:getTraits().thoughtVis = nil
					
					-- sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = cellUnit } )
					-- self.capturedGuard = cellUnit
					-- self.oldLOS = cellUnit:getTraits().LOSarc
					-- self.oldLOSperiph = cellUnit:getTraits().LOSperipheralArc
					-- cellUnit:getTraits().LOSarc = math.pi * 2
					-- cellUnit:getTraits().LOSperipheralArc = nil
					
					-- -- fancy FX stuff because I'm weak
					-- sim:dispatchEvent( simdefs.EV_CAM_PAN, { self.MistBody:getLocation() } )
					-- sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_gainCPU" )
					-- sim:dispatchEvent( simdefs.EV_CLOAK_OUT, { unit = cellUnit  } )
					-- sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
						-- unit = cellUnit,
						-- txt = util.sformat(STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.PSI_CONTROL),
						-- x = x1, y = y1,
						-- color = {r = 255/255, g = 255/255, b = 51/255, a = 1 },
					-- } )
				-- end
					
			-- elseif evType == simdefs.TRG_START_TURN then
				-- if ( sim:getCurrentPlayer() == sim:getPC() ) and (self.capturedGuard ~= nil) then
				-- self.capturedGuard:getTraits().sneaking = true --is otherwise reset every turn apparently
				-- end
				
			-- elseif evType == simdefs.TRG_UNIT_KILLED then -- for if the possessed guard dies
				-- if self.capturedGuard and evData.unit == self.capturedGuard then
					-- self.capturedGuard = nil
				-- end
				
			-- elseif evType == simdefs.TRG_UNIT_HIT then
				-- if self.capturedGuard and evData.sourceUnit and evData.targetUnit then
					-- if evData.sourceUnit == self.capturedGuard and evData.targetUnit:getTraits().isGuard or evData.targetUnit:getTraits().isDrone then
						-- sim:trackerAdvance( self.trackerCount )
						-- -- should be punishing enough, as getting away with guard-on-guard murder is pretty easy
					-- end
				-- end
				
			-- end
			-- mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		-- end
	-- },	
	
	-- MIST permadeath version
	-- KO'd guards are not alerted when they wake up
	transistordaemonmistkia = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.MIST_KIA ) )
	{
		icon = "gui/icons/daemon_icons/fu_transpose.png", --update
		title = STRINGS.AMRE and STRINGS.AMRE.AGENTS.MIST.NAME or "Mist",
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_UNIT_KO, self )
			sim:addTrigger( simdefs.TRG_NEW_INTEREST, self )
			sim:addTrigger( simdefs.TRG_UNIT_NEWINTEREST, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_KO, self )
			sim:removeTrigger( simdefs.TRG_NEW_INTEREST, self )
			sim:removeTrigger( simdefs.TRG_UNIT_NEWINTEREST, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_UNIT_KO then
				if evData.unit and not evData.unit:isPC() and evData.ticks == nil and not evData.unit:getTraits().isDrone then
					evData.unit:getTraits().psiCalmedGuard = true -- the rest handled in modinit
				end
			elseif (evType == simdefs.TRG_NEW_INTEREST) or (evType == simdefs.TRG_UNIT_NEWINTEREST) then
				if evData.unit and not evData.unit:isPC() and evData.unit:getTraits().psiCalmedGuard then
					evData.unit:getTraits().psiCalmedGuard = nil
					-- reset otherwise this unit will never be able to be alerted again :^)
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end
	},			
	
	--Pedler from Agent Mod Combo
	--Agents resist KO, +1 KO damage in melee per enemy armour (but at least 1)
	transistordaemonpedler= util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.PEDLER ) )
	{
		icon = "gui/icons/daemon_icons/fu_brawl.png",
		title = STRINGS.AMRE and STRINGS.AMRE.AGENTS.KPC.NAME or "Pedler",
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			sim:addTrigger( simdefs.TRG_UNIT_KO, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			
		end,
		-- melee KO damage handled in modinit alongside Sharp's stuff
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_KO, self )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_UNIT_KO  then
				if evData.unit and evData.unit:isPC() and not evData.unit:getTraits().isDrone and not evData.unit:isDead() and evData.ticks then
					evData.ticks = nil
					evData.unit:getTraits().koTimer = 0
					evData.unit:setKO( sim, nil )
					sim:processReactions( evData.unit )
					-- sim:dispatchEvent( simdefs.EV_UNIT_KO, {unit = evData.unit, stand = true } )
					evData.unit:getTraits().mp = evData.unit:getTraits().mp + 5
					sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = evData.unit } )
					evData.unit:getTraits().canKO = false --canKO is checked in canUseAbility of ce_melee_ko. This is required for AGP compatibility
					evData.unit:getTraits().transistor_ko_immune = true --this fix allows the Ghost Unit to try to melee-KO the agent once, but won't try again that turn, instead of getting caught in an endless, hilarious loop of hitting the agent and the agent getting back up
								
				end
			elseif evType == simdefs.TRG_START_TURN then
				for i, unit in pairs(sim:getPC():getUnits()) do
					if unit:getTraits().transistor_ko_immune then
						unit:getTraits().transistor_ko_immune = nil
						unit:getTraits().canKO = true
					end
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end
	},
	
	--Goose from Goose Protocol
	--Agents gain Honk ability, simple and lazy but effective
	transistordaemongoose= util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.GOOSE ) )
	{
		icon = "gui/icons/daemon_icons/fu_gaggle.png",
		title = STRINGS.GOOSE and STRINGS.GOOSE.AGENTS.GOOSE.NAME or "Goose",
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
			for i, unit in pairs(sim:getPC():getUnits()) do
				if unit:getUnitData().agentID and (unit:getUnitData().agentID ~= "mod_goose") then
					unit:giveAbility("honk_transistor")
				end
			end
			
		end,
		
		onDespawnAbility = function( self, sim )
			for i, unit in pairs(sim:getPC():getUnits()) do
				if unit:getUnitData().agentID and (unit:getUnitData().agentID ~= "mod_goose") then
					unit:removeAbility(sim, "honk_transistor")
				end
			end
		end,
	},	
	-- Conway from Gunpoint mod
	-- Bashdoor(): guards who kick down doors KO themselves for 4 turns and generate 4 PWR for the player
	transistordaemonconway= util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.CONWAY ) )
	{
		icon = "gui/icons/daemon_icons/fu_bashdoor.png",
		title = STRINGS.GUNPOINT and STRINGS.GUNPOINT.CONWAY.NAME or "Conway",
		noDaemonReversal = true,
		
		-- handled in modinit / init
		onSpawnAbility = function( self, sim, player, agent )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
		end,
		
	},		
	
	---
	
	--GENERIC
	-- for all mod agents who have no unique algorithm
	-- spawn a bad cell every turn
	transistordaemongeneric = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.GENERIC ) )
	{
		icon = "gui/icons/daemon_icons/checksum.png",
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			--if there is no agent, this entire daemon is screwed
			if not agent or not agent:isValid() then sim:getNPC():removeAbility( sim, self ) end
			self.agent = agent
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=agent:getName() } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and evData:isPC() and self.agent and self.agent:isValid() then
				-- spawn bad cell here
				if self.agent:getLocation() ~= nil then -- prevents bug if Permadeath is on and agent dies at start of turn
					self.badcell = simfactory.createUnit( unitdefs.lookupTemplate( "transistor_badcell" ), sim )
					sim:spawnUnit( self.badcell )
					self.badcell:setPlayerOwner(self.agent:getPlayerOwner())
					sim:warpUnit( self.badcell, sim:getCell( self.agent:getLocation() ) )
					sim:dispatchEvent( simdefs.EV_TELEPORT, { units={self.badcell}, warpOut=false } )
				end
			elseif evType == simdefs.TRG_END_TURN and evData:isPC() and self.badcell and self.badcell:isValid() then
				local grenadeUnit = simfactory.createUnit( unitdefs.lookupTemplate( "transistor_badcell_grenade" ), sim )
				sim:spawnUnit( grenadeUnit )
				grenadeUnit:setPlayerOwner(self.badcell:getPlayerOwner())
				sim:warpUnit( grenadeUnit, sim:getCell( self.badcell:getLocation() ) )
				sim:warpUnit( self.badcell )
				sim:despawnUnit( self.badcell )
				self.badcell = nil
				grenadeUnit:activate()
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},
	
	-- PERMADEATH --
	--GENERIC v.2.
	-- for all mod agents who have no unique algorithm
	-- spawn a bad cell every turn, in a random explored location on the map
	transistordaemongenerickia = util.extend( mainframe_common.createReverseDaemon( STRINGS.TRANSISTOR.AGENTDAEMONS.GENERICKIA ) )
	{
		icon = "gui/icons/daemon_icons/checksum.png",
		noDaemonReversal = true,
		-- self.counttimer = 0
		
		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=nil } ) --this doesn't work, is erased by mission_util.makeAgentConnection's HUD clearing script
			sim:addTrigger( simdefs.TRG_START_TURN, self )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
			self.counttimer = 0
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,
		onTrigger = function( self, sim, evType, evData, userUnit )
			if evType == simdefs.TRG_START_TURN and evData:isPC() then
				-- spawn bad cell here
				self.counttimer = self.counttimer + 1 -- every other turn
				if self.counttimer == 2 then
					self.counttimer = 0
					self.badcell = simfactory.createUnit( unitdefs.lookupTemplate( "transistor_badcell_kia" ), sim )
					sim:spawnUnit( self.badcell )
					self.badcell:setPlayerOwner(sim:getPC())
					-- find random viable known cell
					local allcells = {}
					sim:forEachCell(function(_cell)
						local cell = _cell
						if (cell.impass == nil or cell.impass <= 0) and not cell.isSolid then
							table.insert(allcells,cell)
						end
					end)				
					--old code: this worked but for some reason only used parts of the map/was biased towards certain sections
					-- for y, xcords in ipairs(sim._board) do
						-- for x, cell in ipairs(xcords) do
							-- -- if isKnownCell( sim, x, y ) then
								-- local cell = sim:getCell( x, y )
								
									-- if (cell.impass == nil or cell.impass <= 0) and not cell.isSolid then
								
										-- table.insert(allcells, cell)
									-- end
							-- -- end
						-- end
					-- end				
					if #allcells > 0 then
						local spawncell = allcells[sim:nextRand(1, #allcells)]
						-- log:write("LOG: allcells, spawnsite")
						-- log:write(util.stringize(allcells,2))
						-- log:write(util.stringize(spawncell,2))
						sim:warpUnit( self.badcell, spawncell)
						sim:dispatchEvent( simdefs.EV_CAM_PAN, { spawncell.x, spawncell.y } ) --sorry, the absence of this has been bugging me for months -Hek
						sim:dispatchEvent( simdefs.EV_TELEPORT, { units={self.badcell}, warpOut=false } )
					end
					end
				end
			if evType == simdefs.TRG_END_TURN and evData:isPC() and self.badcell and self.badcell:isValid() then
				local grenadeUnit = simfactory.createUnit( unitdefs.lookupTemplate( "transistor_badcell_grenade" ), sim )
				sim:spawnUnit( grenadeUnit )
				grenadeUnit:setPlayerOwner(self.badcell:getPlayerOwner())
				sim:warpUnit( grenadeUnit, sim:getCell( self.badcell:getLocation() ) )
				sim:warpUnit( self.badcell )
				sim:despawnUnit( self.badcell )
				self.badcell = nil
				grenadeUnit:activate()
			
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
		end,
	},	
	-- /PERMADEATH
	
}
