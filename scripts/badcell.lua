local util = include( "modules/util" )
local commondefs = include("sim/unitdefs/commondefs")

return --util.extend( commondefs.DEFAULT_DRONE )
{
	{
		type = "simunit",
		name = STRINGS.TRANSISTOR.BADCELL,
		-- profile_anim = "portraits/sankaku_drone_face_new",
		profile_build = "portraits/badcell_portrait",
		-- profile_image = "sankaku_drone.png",
		-- kanim = "kanim_drone_SA",
		profile_anim = "portraits/sankaku_drone_camera_new",
		profile_image = "sankaku_drone_camera.png",
		kanim = "kanim_badcell",	
		rig = "dronerig",
		onWorldTooltip = function( tooltip, unit, userUnit )
			commondefs.onAgentTooltip( tooltip, unit, userUnit )
			
			tooltip:addAbility(
				STRINGS.TRANSISTOR.TOOLTIP_BADCELL_EXPLO,
				STRINGS.TRANSISTOR.TOOLTIP_BADCELL_EXPLO_DESC)
			tooltip:addAbility(
				STRINGS.TRANSISTOR.TOOLTIP_BADCELL_INVIS,
				STRINGS.TRANSISTOR.TOOLTIP_BADCELL_INVIS_DESC)
			tooltip:addAbility(
				STRINGS.TRANSISTOR.TOOLTIP_BADCELL_LOS,
				STRINGS.TRANSISTOR.TOOLTIP_BADCELL_LOS_DESC)
			
			--onFooterTooltip		
			if unit:getTraits().dlcFooter then
				tooltip:addFooter( unit:getTraits().dlcFooter[1],unit:getTraits().dlcFooter[2] )
			end
		end,
		-- sounds = commondefs.SOUNDS.DRONE_WALK,
		-- sounds = commondefs.SOUNDS.DRONE_HOVER,
		sounds = commondefs.SOUNDS.DRONE,
		-- voices = {"Drone"},
		-- speech = speechdefs.NPC,
		children = {},
		abilities = {},
		traits = --util.extend( DEFAULT_DRONE.traits )
		{
			isAgent = true,
			isDrone = true,
			isMetal = true,
			sightable = false, --this lets guards spot this unit, but cameras see it either way.
			--sightable is false so AGP UV-Vision does not see the cell
			invisible = true, --this makes the unit actually invisible, but can be disabled by advanced scanners
			--invisible is true so cameras do not see the cell
			hasSight = true,
			hasHearing = false,
			dynamicImpass = false,
			noDoorAnim = true, 

			LOSrange = 2, --8,
			LOSarc = math.pi * 2,
			seesHidden = true,

			notDraggable = true, 

			apMax = 0, 
			mpMax= 6,
			mp= 6,
			ap = 0, 
			wounds = 0,
			woundsMax = 1,
			-- meleeDamage = 3,
			dashSoundRange = 0,
			
			canBeShot = true,
			-- canBeFriendlyShot = true,
			-- canBeCritical = false,
			-- canKO = false,
			
			baseDamage = 0, 

			hits = "spark",
			
			selectpriority = 10,
			sneaking = true,

			walk=true,
			noLoopOverwatch = true,
			
			-- camera_drone = true, 
			pacifist = true,
		},
	},
	util.extend( commondefs.grenade_template )
	{
        type = "stun_grenade",
		name = STRINGS.TRANSISTOR.BADCELL,
		--icon = "itemrigs/FloorProp_Bandages.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_flash_grenade_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_flash_grenade.png",		
		kanim = "kanim_flashgrenade",		
		sounds = {explode="SpySociety/Grenades/flashbang_explo"},
		traits = { baseDamage = 1, canSleep = true, explodes = 0 },
	},
}
