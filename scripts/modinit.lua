local util = include("modules/util")
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simunit = include( "sim/simunit" )
local abilitydefs = include( "sim/abilitydefs" ) --use this instead of the direct ability files, as mods may override some
local simfactory = include( "sim/simfactory" )
local astar_handlers = include( "sim/astar_handlers" )
local inventory = include( "sim/inventory" )
--local cutil = include("client/client_util")
local ThisModLoaded = false

local function earlyInit( modApi )
	modApi.requirements = {"Sim Constructor", "Contingency Plan", "Programs Extended", "Permadeath", "Function Library"} --PE because it force-overrides some functions we edit
end

local function init( modApi )
    local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	KLEIResourceMgr.MountPackage( dataPath .. "/gui.kwad", "data" )
	-- KLEIResourceMgr.MountPackage( dataPath .. "/sound.kwad", "data" )
	KLEIResourceMgr.MountPackage( dataPath .. "/anims.kwad", "data" ) 
	
	--If you don't want Red, disable the entire mod.
	-- modApi:addGenerationOption("transistor_red",  STRINGS.TRANSISTOR.OPTIONS.RED , STRINGS.TRANSISTOR.OPTIONS.RED_TIP, {noUpdate = true} )
	-- modApi:addGenerationOption("transistor_detention",  STRINGS.TRANSISTOR.OPTIONS.REDENTION , STRINGS.TRANSISTOR.OPTIONS.REDENTION_TIP, {noUpdate = true} )
	--Red has no wireframe anyways, so this option is redundant.
	-- modApi:addGenerationOption("transistor_wireframe",  STRINGS.TRANSISTOR.OPTIONS.WIREFRAME, STRINGS.TRANSISTOR.OPTIONS.WIREFRAME_TIP, {noUpdate = true} )
	modApi:addGenerationOption("transistor_on_ko",  STRINGS.TRANSISTOR.OPTIONS.ON_KO , STRINGS.TRANSISTOR.OPTIONS.ON_KO_TIP, {enabled = false, noUpdate = true} )
	modApi:addGenerationOption("permadeath_poolrand",  STRINGS.TRANSISTOR.OPTIONS.PERMADEATH_POOLRAND , STRINGS.TRANSISTOR.OPTIONS.PERMADEATH_POOLRAND_TIP, {enabled = false, noUpdate = true} )
	
	-- adding datalogs
	local logs = include( scriptPath .. "/logs" )
	for i,log in ipairs(logs) do      
		modApi:addLog(log)
	end
	
	
	-- local useItem_old = inventory.useItem
	-- inventory.useItem = function( sim, unit, item, ... )
		-- if not ThisModLoaded then return useItem_old( sim, unit, item, ...) end
		-- if unit and unit:isPC() and item:getTraits().cooldown then
			-- local i = 0
			-- for _, ability in ipairs( sim:getNPC():getAbilities() ) do 
				-- if ability:getID() == "transistordaemonsharp" then
					-- i = i + 1
				-- end
			-- end
			-- if i > 0 then
				-- -- local x1, y1 = unit:getLocation()
				-- -- sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt = STRINGS.ITEMS.AUGMENTS.TORQUE_INJECTORS, x = x1, y = y1,color={r=255/255,g=255/255,b=51/255,a=1}} )	
				
			-- end
		-- end
		-- useItem_old( sim, unit, item, ...)
	-- end
	
	--Prism 1
	-- local aihandler_handleNode_old = astar_handlers.aihandler._handleNode
	-- astar_handlers.aihandler._handleNode = function(self, to_cell, from_node, goal_cell)
		-- local n = aihandler_handleNode_old(self, to_cell, from_node, goal_cell)
		-- if not ThisModLoaded or not to_cell then
			-- return n
		-- end
		-- if self._unit:getSim():getNPC():hasMainframeAbility("transistordaemonprism") then
			-- for i,unit in ipairs(to_cell.units) do
				-- if unit ~= self._unit and self._unit:isNPC() and unit:hasTrait("hologram") then
				-- -- if unit ~= self._unit and unit:hasTrait("hologram") then
					-- n.mCost = n.mCost + 63
					-- n.score = n.score + 63
					-- break
				-- end
			-- end
		-- end
		-- return n
	-- end
	--end of Prism 1
	--Shalem
	local calculateShotSuccess_old = simquery.calculateShotSuccess
	simquery.calculateShotSuccess = function( sim, sourceUnit, targetUnit, equipped, ...)
		if not ThisModLoaded or not equipped then
			return calculateShotSuccess_old( sim, sourceUnit, targetUnit, equipped, ...)
		end
		local i = 0
		if sourceUnit and sourceUnit:isPC() then
			for _, ability in ipairs( sim:getNPC():getAbilities() ) do 
				if ability:getID() == "transistordaemonshalem" then
					i = i + 1
				end
			end
		end
		if equipped:getTraits().baseDamage then
			equipped:getTraits().baseDamage = equipped:getTraits().baseDamage + 3 * i
		end
		local hadAP = equipped:getTraits().armorPiercing ~= nil
		equipped:getTraits().armorPiercing = (equipped:getTraits().armorPiercing or 0) + 3 * i
		local result = calculateShotSuccess_old( sim, sourceUnit, targetUnit, equipped, ...)
		if equipped:getTraits().baseDamage then
			equipped:getTraits().baseDamage = equipped:getTraits().baseDamage - 3 * i
		end
		if hadAP then
			equipped:getTraits().armorPiercing = equipped:getTraits().armorPiercing - 3 * i
		else
			equipped:getTraits().armorPiercing = nil
		end
		return result
	end
	local shootSingle_execute_old = abilitydefs._abilities.shootSingle.executeAbility
	abilitydefs._abilities.shootSingle.executeAbility = function( self, sim, ownerUnit, ... )
		if not ThisModLoaded or not ownerUnit or not ownerUnit:isPC() then
			return shootSingle_execute_old( self, sim, ownerUnit, ... )
		end
		local i = 0
		for _, ability in ipairs( sim:getNPC():getAbilities() ) do 
			if ability:getID() == "transistordaemonshalem" then
				i = i + 1
			end
		end
		if i < 1 then
			return shootSingle_execute_old( self, sim, ownerUnit, ... )
		end
		ownerUnit:getTraits().cooldown = ownerUnit:getTraits().cooldown or 0
		-- local hadCD = ownerUnit:getTraits().cooldownMax ~= nil
		ownerUnit:getTraits().cooldownMax = (ownerUnit:getTraits().cooldownMax or 0) + 4 * i
		shootSingle_execute_old( self, sim, ownerUnit, ... )
		--Technically speaking, we should set the cooldown to nil when it reaches 0,
		--but a cooldownMax of 0 works just as well, ignoring the tooltip. -M
		--Can't set to nil because that'd crash due to poor logic in the basegame
		-- if hadCD then
			ownerUnit:getTraits().cooldownMax = ownerUnit:getTraits().cooldownMax - 4 * i
		-- else
			-- ownerUnit:getTraits().cooldownMax = nil
		-- end
	end
	--end of Shalem
	--Apologies if hacking into simfactory makes you die inside. -M
	local createUnit_old = simfactory.createUnit
	simfactory.createUnit = function(unitData, ...)
		local unit = createUnit_old(unitData, ...)
		if not ThisModLoaded then return unit end
		if unitData.type == "simtrap" then
			--Xu
			-- log:write("SIMTRAP CREATED")
			local performTrap_old = unit.performTrap
			unit.performTrap = function( self, sim, cell, unit )
				if unit and not unit:isPC() then
					local i = 0
					for _, ability in ipairs( sim:getNPC():getAbilities() ) do 
						if ability:getID() == "transistordaemonxu" then
							i = i + 1
						end
					end
					-- log:write("TRIGGER TRAP ".. tostring(i))
					if i > 0 then
						-- sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt = STRINGS.,x=cell.x,y=cell.y,color={r=255/255,g=255/255,b=51/255,a=1}} )
						-- sim:getPC():addCPUs( 4 * i, sim, cell.x, cell.y )
						for j, sourceUnit in pairs(sim:getPC():getUnits()) do
							if sourceUnit:isValid() then
								for k, item in pairs(sourceUnit:getChildren()) do
									if item:isValid() then
										if item:getTraits().energyWeapon then
											item:getTraits().energyWeapon = "idle"
										end
										if item:getTraits().ammo then
											item:getTraits().ammo = item:getTraits().ammo + 1
										end
										if item:getTraits().charges then
											item:getTraits().charges = item:getTraits().charges + 1
										end
									end
								end
							end
						end
					end
				end
				return performTrap_old( self, sim, cell, unit )
			end
			--end of Xu
		-- elseif unitData.type == "simunit" then
			--Prism 2
			-- local onWarp_old = unit.onWarp
			-- unit.onWarp = function( self, sim, oldcell, cell )
				-- if unit:isNPC() and sim:getNPC():hasMainframeAbility("transistordaemonprism")
				-- and cell then
					-- for i,checkUnit in pairs( cell.units ) do
						-- if checkUnit:getTraits().hologram and self:getTraits().hasSight and self:getBrain() then
							-- self:getBrain():getSenses():addInterest( cell.x, cell.y, simdefs.SENSE_SIGHT, simdefs.REASON_FOUNDOBJECT, checkUnit)
						-- end
					-- end
				-- else --Skipping over the entire old function might cause mod incompatibilities -M
					-- return onWarp_old( self, sim, oldcell, cell )
				-- end
			-- end
			--end of Prism 2
		elseif unitData.type == "laser_emitter" then
			-- Mist 1
			-- explicitly grant controlled guards passage
			local canControl_old = unit.canControl
			unit.canControl = function( self, unit, ... )
				return ThisModLoaded and simquery.isAgent(unit) and unit:getTraits().psiTakenGuard or canControl_old(self, unit, ...)
			end
			--end of Mist 1
		end
		return unit
	end
	--Draco
	--cannot set display string... local variable only
	table.insert(modApi.mod_manager.credit_sources, "transistordaemondraco")
	--end of Draco
	--Red
	local getArmor_old = simunit.getArmor
	simunit.getArmor = function( self )
		local armor = getArmor_old( self )
		if self and not self:isPC() and ThisModLoaded
		and self._sim and self._sim:getNPC():hasMainframeAbility("transistordaemonred") then
			armor = math.floor(armor * .5)
		end
		return armor
	end
	-- local getMPMax_old = simunit.getMPMax
	-- simunit.getMPMax = function( self )
		-- local mpMax = getMPMax_old( self )
		-- if self and not self:isPC() and ThisModLoaded
		-- and self._sim and self._sim:getNPC():hasMainframeAbility("transistordaemonred") then
			-- mpMax = math.floor(mpMax * .5)
		-- end
		-- return mpMax
	-- end
	--end of Red
			
	--Ghuff
	local observePath_executeAbility_old = abilitydefs._abilities.observePath.executeAbility
	abilitydefs._abilities.observePath.executeAbility = function( self, sim, unit, userUnit, target, ... )
		local targetUnit = sim:getUnit( target )
		if ThisModLoaded and sim:getNPC():hasMainframeAbility("transistordaemonghuff") then
			targetUnit:setTagged()
			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_wisp_activate" )
			sim:dispatchEvent( simdefs.EV_UNIT_TAGGED, {unit = targetUnit} )
		end
		return observePath_executeAbility_old( self, sim, unit, userUnit, target, ... )	
	end

	--Mist 2
	--disable overwatch ability for hijacked guards
	local overwatch_canUseAbility_old = abilitydefs._abilities.overwatch.canUseAbility
	abilitydefs._abilities.overwatch.canUseAbility = function( self, sim, unit, ... )
		if ThisModLoaded and sim:getNPC():hasMainframeAbility( "transistordaemonmist" ) then
			if unit and unit:getTraits().psiTakenGuard then
				return false, STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.CANNOT_OVERWATCH
			end
		end
		return overwatch_canUseAbility_old( self, sim, unit, ... )
	end
	
	--hijacked guards still try to use this function, which causes an assertion error because it's not 'meant' to be used by PC units
	local simquery_canSoftPath_old = simquery.canSoftPath
	simquery.canSoftPath = function( sim, unit, startcell, endcell, ... )
		if not ThisModLoaded then
			return simquery_canSoftPath_old( sim, unit, startcell, endcell, ... )
		else
			if unit:getTraits().psiTakenGuard then
				-- if this bugs you, original canSoftPath does it this way too!
			else
				return simquery_canSoftPath_old( sim, unit, startcell, endcell, ... )
			end
		end
	end
	
	-- local simquery_isEnemyTarget_old = simquery.isEnemyTarget
	-- simquery.isEnemyTarget = function( player, unit, ... )
		-- if ThisModLoaded and unit and unit:getTraits().psiTakenGuard then
			-- return false -- Nothing is aggressive to taken-over guards (same applies to takenDrone)
		-- end
		-- return simquery_isEnemyTarget_old( player, unit, ... )
	-- end
	
		
	-- for Mist's KIA algorithm --setAlerted doesn't allow you to set a false value so we'll have to do this instead
	local simunit_setAlerted_old = simunit.setAlerted
	simunit.setAlerted = function( self, alerted, ... )
		if self and self:getTraits().psiCalmedGuard and ThisModLoaded and self._sim and self._sim:getNPC():hasMainframeAbility("transistordaemonmistkia") then
			self:getTraits().alerted = nil
		else
			return simunit_setAlerted_old( self, alerted, ... )
		end
	end
	
	local STRINGS = include("strings")
	util.tmerge( STRINGS.LOADING_TIPS, STRINGS.TRANSISTOR.LOADING_TIPS  ) --add new loading screen tooltips
end

local function lateInit( modApi )
	--Central
	--late init because PE edits this
	local aiplayer = include( "sim/aiplayer" )
	local addMainframeAbility_old = aiplayer.addMainframeAbility
	aiplayer.addMainframeAbility = function(self, sim, abilityID, hostUnit, reversalOdds, ...)
		-- log:write("DAEMON REVERSAL ODDS WERE... " .. (reversalOdds or "nil"))
		reversalOdds = (reversalOdds or 10)
		if reversalOdds > 0 then
			for _, ability in ipairs( sim:getNPC():getAbilities() ) do 
				if ability.daemonReversalAddTransistor then --use unique variable so we don't add other mods' stuff twice
					-- log:write("Found a Central ".. ability.daemonReversalAddTransistor)
					reversalOdds = (reversalOdds or 10) + ability.daemonReversalAddTransistor
				end
			end
			-- log:write("DAEMON REVERSAL ODDS ARE... " .. (reversalOdds or "nil"))
		end
		return addMainframeAbility_old(self, sim, abilityID, hostUnit, reversalOdds, ...)
	end
	--end of Central
	--Olivia
	--late init because Dr Pedler edits this
	local melee_executeAbility_old = abilitydefs._abilities.melee.executeAbility
	abilitydefs._abilities.melee.executeAbility = function( self, sim, ownerUnit, userUnit, target, ... )
		local targetUnit = sim:getUnit(target)
		if ThisModLoaded
		and ownerUnit and ownerUnit:isPC()
		and targetUnit and targetUnit:isKO() then
			for _, ability in ipairs( sim:getNPC():getAbilities() ) do 
				if ability:getID() == "transistordaemonolivia" then
					if targetUnit:getTraits().heartMonitor and not targetUnit:getTraits().improved_heart_monitor then
						targetUnit:getTraits().heartMonitor = "disabled"
					end
					local result = melee_executeAbility_old( self, sim, ownerUnit, userUnit, target, ... )
					ownerUnit:getTraits().ap = ownerUnit:getTraits().ap + 1 --can't ResetAP() because Nika's augment is coded horribly -M
					if targetUnit and targetUnit:isValid() and not targetUnit:isDead() then
						targetUnit:onDamage(1)
					end
					return result
				end
			end
		end
		return melee_executeAbility_old( self, sim, ownerUnit, userUnit, target, ... )
	end
	--end of Olivia
	
	--Sharp & Pedler
	local calculateDamageAndArmorForMelee_old = simquery.calculateDamageAndArmorForMelee
	simquery.calculateDamageAndArmorForMelee = function( sim, sourceUnit, targetUnit )
		local dmg, armorPiercing, armor = calculateDamageAndArmorForMelee_old( sim, sourceUnit, targetUnit )
		if not ThisModLoaded or not sourceUnit then
			return dmg, armorPiercing, armor
		end
		local i = 0 -- for Sharp
		local z = 0 -- for Pedler
		local unitOwner = sourceUnit:getUnitOwner()
		if unitOwner and unitOwner:isPC() then
			for _, ability in ipairs( sim:getNPC():getAbilities() ) do 
				if ability:getID() == "transistordaemonsharp" then
					i = i + 1
				elseif ability:getID() == "transistordaemonpedler" then
					z = z + 1
				end
			end

			i = i * unitOwner:getAugmentCount()
			if ( armor > 1 ) then 
				z = z * armor
			end
			--log:write(i)
			--log:write(z)
		end
		
		--log:write("MELEE FOR ".. (targetUnit and targetUnit:getUnitData().name or "UNKNOWN") .." is ".. i .."/".. armor)
		return (dmg + z), armorPiercing + i, armor
	end
	--end of Sharp * Pedler

	--Mist --this needs to be in lateinit
	-- hack to prevent guards from shooting a psi-controlled guard who just shot someone else, which bugs out the game as the dead unit tries to stop shooting
	local calculateShotSuccess_old = simquery.calculateShotSuccess
	simquery.calculateShotSuccess = function(sim, sourceUnit, targetUnit, equipped, ... )
		local shot = calculateShotSuccess_old( sim, sourceUnit, targetUnit, equipped, ... )
		if ThisModLoaded and sim:getNPC():hasMainframeAbility("transistordaemonmist") then
			if targetUnit:getTraits().psiBulletproof then
				shot.armorBlocked = true
			end
		end
		
		return shot
	end		
	
	-- PERMADEATH
	--late init because Escorts Fixed relies on an Upvalue
	local mission_scoring = include( "mission_scoring" )
	local oldDoFinishMission = mission_scoring.DoFinishMission
	
	mission_scoring.DoFinishMission = function( sim, campaign )
		local flow_result = oldDoFinishMission( sim, campaign )
		local agency = sim:getParams().agency
		
		if sim.transistordeath then  -- if agent killed in mission
		
			if agency.transistorkia == nil then
				agency.transistorkia = {}
			end
			--log:write("LOG transistor kia:")
			--log:write(util.stringize(sim.transistordeath,2))
			for k,v in pairs(sim.transistordeath) do
				table.insert(agency.transistorkia, v)
			end
			sim.transistordeath = nil -- prevent this code from possibly running twice
			
		end
		return flow_result
	end
	-- /PERMADEATH
end

local function load(modApi, options, params)
	local scriptPath = modApi:getScriptPath()
	
	--Permadeath thing for spawning persistent algorithms of KIA agents. Copypaste from abilitytransistor.lua with some of the comment garbage cut down
	--note, putting this edit in init does not work for some reason, keep it in Load please
	local mission_util = include("sim/missions/mission_util")
	local old_mission_util_makeAgentConnection = mission_util.makeAgentConnection
	
		if not ThisModLoaded then
			mission_util.makeAgentConnection = function( script, sim, ... )
				old_mission_util_makeAgentConnection( script, sim, ... )
				
				local agency = sim:getParams().agency
				if agency.transistorkia and #agency.transistorkia > 0 then
					local KIApool = agency.transistorkia					
					local poolsizemax
					
					if #KIApool > 4 then
						poolsizemax = 4
					else 
						poolsizemax = #KIApool
					end
					
					local poolsize = sim:nextRand(1,poolsizemax)
					if simdefs.transistor_permadeath_poolrand then 
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
						-- sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=ghostfunction.name, icon=ghostfunction.icon, txt=ghostfunction.activedesc, title=ghostfunction.title } ) -- this does nothing because it's overriden by start of mission HUD..
						
						sim:getNPC():addMainframeAbility(sim, ghostfunction, sim:getNPC(), 0)
					end						

				end
			end
		end
	
	if options.permadeath_poolrand and options.permadeath_poolrand.enabled then
		rawset(simdefs, "transistor_permadeath_poolrand", false)
	else
		rawset(simdefs, "transistor_permadeath_poolrand", true)
	end
	
	if options.transistor_on_ko and options.transistor_on_ko.enabled then
		rawset(simdefs, "transistor_on_ko", true)
	else
		rawset(simdefs, "transistor_on_ko", false)
	end
	
	if not options.transistor_red or options.transistor_red.enabled then
		ThisModLoaded = true
		
		for k, v in pairs(include( scriptPath .. "/animdefs" )) do
			modApi:addAnimDef( k, v )
		end
		
		for k, v in pairs(include( scriptPath .. "/itemdefs" )) do
			--HAAACK
			if k == "augment_transistor" then
				if simdefs.transistor_on_ko then
					v.desc = STRINGS.TRANSISTOR.AUGMENT_TRANSISTOR_TIP_KO
				else
					v.desc = STRINGS.TRANSISTOR.AUGMENT_TRANSISTOR_TIP
				end
			end
			modApi:addItemDef( k, v )
		end
		
		modApi:addAbilityDef( "remotecriticalself", scriptPath .."/remotecriticalself" )
		modApi:addAbilityDef( "ability_transistor", scriptPath .."/abilitytransistor" )
		for k, v in pairs(include( scriptPath .. "/agentdaemons" )) do
			modApi:addDaemonAbility( k, v )
		end
		
		modApi:addAgentDef( "transistor_red", include( scriptPath .. "/red" ) , { "transistor_red" } )
		modApi:addRescueAgent( serverdefs.createAgent( "transistor_red", {"augment_transistor"} ) )
		
		modApi:addGuardDef( "transistor_badcell", include( scriptPath .. "/badcell" )[1] )
		modApi:addItemDef( "transistor_badcell_grenade", include( scriptPath .. "/badcell" )[2] )
		
		include( scriptPath .. "/banter" )( modApi )
		
		local commondefs = include( scriptPath .. "/commondefs")
		modApi:addTooltipDef( commondefs )
		
		-- PERMADEATH --
		modApi:addGuardDef( "transistor_badcell_kia", include( scriptPath .. "/badcellkia" )[1] )
		
	end
	
end

local function initStrings(modApi)
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	local MOD_STRINGS = include( scriptPath .. "/strings" )
	modApi:addStrings( dataPath, "TRANSISTOR", MOD_STRINGS)
end

-- local function lateLoad(modApi, options, params, allOptions)
-- end

local function unload()
	ThisModLoaded = false
	rawset(simdefs, "transistor_permadeath_poolrand", nil)
	rawset(simdefs, "transistor_on_ko", nil)
end

return {
    init = init,
    earlyInit = earlyInit,
    lateInit = lateInit,
    load = load,
	-- lateLoad = lateLoad,
	unload = unload,
    initStrings = initStrings,
}
