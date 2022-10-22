local util = include( "modules/util" )
local commondefs = include( "sim/unitdefs/commondefs" )
local simdefs = include("sim/simdefs")

local FEMALE_SOUNDS =
{
    bio = "",
    escapeVo = "",
	speech="SpySociety/Agents/dialogue_player",  
	step = simdefs.SOUNDPATH_FOOTSTEP_FEMALE_HARDWOOD_NORMAL, 
	stealthStep = simdefs.SOUNDPATH_FOOTSTEP_FEMALE_HARDWOOD_SOFT, 
	
	wallcover = "SpySociety/Movement/foley_trench/wallcover",
	crouchcover = "SpySociety/Movement/foley_trench/crouchcover",
	fall = "SpySociety/Movement/foley_trench/fall",
	land = "SpySociety/Movement/deathfall_agent_hardwood",
	land_frame = 16,						
	getup = "SpySociety/Movement/foley_trench/getup",	
	grab = "SpySociety/Movement/foley_trench/grab_guard",
	pin = "SpySociety/Movement/foley_trench/pin_guard",
	pinned = "SpySociety/Movement/foley_trench/pinned",
	peek_fwd = "SpySociety/Movement/foley_trench/peek_forward",	
	peek_bwd = "SpySociety/Movement/foley_trench/peek_back",	
	move = "SpySociety/Movement/foley_trench/move",
	hit = "SpySociety/HitResponse/hitby_ballistic_flesh",
}

return
{
	type = "simunit",
	agentID = "transistor_red",
	name = STRINGS.TRANSISTOR.RED.NAME,
	fullname = STRINGS.TRANSISTOR.RED.FULLNAME,
	codename = STRINGS.TRANSISTOR.RED.FULLNAME,
	loadoutName = STRINGS.UI.ON_FILE,
	file = STRINGS.TRANSISTOR.RED.FILE,
	yearsOfService = STRINGS.TRANSISTOR.RED.YEARS_OF_SERVICE,
	age = STRINGS.TRANSISTOR.RED.AGE,
	homeTown =  STRINGS.TRANSISTOR.RED.HOMETOWN,
	gender = "female",
	toolTip = STRINGS.TRANSISTOR.RED.TOOLTIP,
	onWorldTooltip = commondefs.onAgentTooltip,
	profile_icon_36x36= "gui/profile_icons/transistor_red_36.png",
	profile_icon_64x64= "gui/profile_icons/transistor_red_64.png",
	splash_image = "gui/agents/transistor_red_1024.png",
	team_select_img = {
		"gui/agents/transistor_red_teamselect.png",
	},
	profile_anim = "portraits/prism_face",
    profile_build = "portraits/crash_face",
	kanim = "kanim_crash",
	hireText =  STRINGS.TRANSISTOR.RED.RESCUED,
	traits = util.extend( commondefs.DEFAULT_AGENT_TRAITS ) { mp=8, mpMax =8, },
	skills = util.extend( commondefs.DEFAULT_AGENT_SKILLS ) {}, 
	startingSkills = { anarchy=2, },
	abilities = util.tconcat( {  "sprint", "remotecriticalself",  }, commondefs.DEFAULT_AGENT_ABILITIES ),
	children = {},
	sounds = FEMALE_SOUNDS,
	speech = STRINGS.TRANSISTOR.RED.BANTER,
	blurb = STRINGS.TRANSISTOR.RED.BIO,
	upgrades = { "augment_transistor", "item_tazer",},
}
