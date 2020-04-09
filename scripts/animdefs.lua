local cdefs = include( "client_defs" )
local util = include( "client_util" )
local commondefs = include( "sim/unitdefs/commondefs" )
local commonanims = include("common_anims")
local Layer = commondefs.Layer
local BoundType = commondefs.BoundType
local DRONE_ANIMS = commondefs.DRONE_ANIMS
local FLOAT_DRONE_ANIMS = commondefs.FLOAT_DRONE_ANIMS
-------------------------------------------------------------------
-- Data for anim definitions.

local animdefs =
{

	kanim_crash =
	{
		wireframe =
		{
			"data/anims/characters/agents/agent_male_empty.abld",
		},
		build = 
		{ 
			
			"data/anims/characters/anims_female/shared_female_hits_01.abld",
			"data/anims/characters/anims_female/shared_female_attacks_a_01.abld",
			"data/anims/characters/agents/agent_crash.abld",
		},
		grp_build = 
		{
			"data/anims/characters/agents/grp_agent_crash.abld",
		},
		grp_anims = commonanims.female.grp_anims,

		anims = commonanims.female.default_anims_unarmed,
		anims_1h = commonanims.female.default_anims_1h,
		anims_2h = commonanims.female.default_anims_2h,

		animMap = commondefs.AGENT_ANIMS,

		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.25,
		layer = commondefs.Layer.Unit,
		boundType = commondefs.BoundType.Character,
		boundTypeOverrides = {
			{anim="idle_ko" ,boundType= commondefs.BoundType.CharacterFloor},
			{anim="dead" ,boundType= commondefs.BoundType.CharacterFloor},
		},
		peekBranchSet = 1,
	},

	kanim_badcell =
	{
		build = 
		{ 
			"data/anims/characters/agents/badcell_body.abld",	 
		},
		anims =
		{		
			"data/anims/characters/corp_SK/sankaku_droid_camera.adef",
		},
		anims_1h =
		{
			"data/anims/characters/corp_SK/sankaku_droid_camera.adef",
		},
		anims_2h =
		{	
			"data/anims/characters/corp_SK/sankaku_droid_camera.adef",
		},


		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.15,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {			
			{anim="idle_closed" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},		
		animMap = FLOAT_DRONE_ANIMS,
		filterSymbols = {{symbol="scan",filter="default"},{symbol="camera_ol_line",filter="default"}},

	},
	
	kanim_mischief_fx =
	{
		build = { "data/anims/fx/mischief_fx.abld" },
		anims = { "data/anims/fx/null_drone_fx.adef" },
		--symbol = "APMeter",
		anim = "default",
		scale = 0.3,
		layer = Layer.Unit,
		boundType = BoundType.Character, -- this doesn't really apply to HUD stuff...
	},	
	
}

return animdefs
