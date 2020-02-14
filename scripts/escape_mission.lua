local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local unitdefs = include( "sim/unitdefs" )
local simfactory = include( "sim/simfactory" )
local itemdefs = include( "sim/unitdefs/itemdefs" )
local propdefs = include( "sim/unitdefs/propdefs" )
local serverdefs = include( "modules/serverdefs" )
local SCRIPTS = include('client/story_scripts')
---------------------------------------------------------------------------------------------
--BLAH
local function Transpose_tip(script, sim)
	local _, agent = script:waitFor( mission_util.AGENT_DOWN )
	-- log:write("LOG Transpose tip")
	if sim:getNPC():hasMainframeAbility( "transistordaemonmist" ) then
		-- log:write("LOG transpose block")
		local healthy_agents = false
		for _, unit in pairs( sim:getPC():getUnits() ) do
			if unit:hasAbility( "escape" ) and not unit:isNeutralized() then --copied from the player isNeutralized function
				healthy_agents = true
				-- log:write("LOG healthy agents")
			end
		end
		if healthy_agents == false then
			-- log:write("LOG showing dialog")
			local txt = STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.NEUTRALIZED_TIP
			local title = "HINT"
			-- script:queue( 3*cdefs.SECONDS )
			sim:dispatchEvent( simdefs.EV_SHOW_DIALOG, { dialog = "messageDialog", dialogParams = { title, txt }})	
		end	
	end
	script:addHook(Transpose_tip)
end

--Interface Functions

function init( scriptMgr, sim )
	scriptMgr:addHook( "Transpose_tip", Transpose_tip )
end

return
{
	init = init,
}