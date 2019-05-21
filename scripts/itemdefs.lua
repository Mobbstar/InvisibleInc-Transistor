local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local commondefs = include( "sim/unitdefs/commondefs" )
-- local simdefs = include( "sim/simdefs" )

local _item_ontooltip = commondefs.item_template.onTooltip

local tool_templates =
{
	augment_transistor = util.extend(commondefs.augment_template)
	{
		name = STRINGS.TRANSISTOR.AUGMENT_TRANSISTOR,
		desc = STRINGS.TRANSISTOR.AUGMENT_TRANSISTOR_TIP,
		flavor = STRINGS.TRANSISTOR.AUGMENT_TRANSISTOR_FLAVOR,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS ){
			installed = true,
			addAbilities = "ability_transistor",
		},
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_generic_torso_small.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_generic_torso.png",
		onTooltip = function( tooltip, unit, userUnit )
			commondefs.item_template.onTooltip(tooltip, unit, userUnit)
			local footer = tooltip._children[#tooltip._children]
			tooltip._children[#tooltip._children] = nil
			--add descriptions of all the currently possible daemons
			local owner = userUnit or unit
			if owner and owner.isValid and owner:isValid() then
				local ability_transistor = owner:ownsAbility("ability_transistor")
				if ability_transistor then
					for abilityID, otherUnit in pairs(ability_transistor:getPossibleDaemons()) do
						-- log:write("displaying Transistor ability for "..abilityID)
						tooltip:addAbility(
							otherUnit:getName(),
							STRINGS.TRANSISTOR.AGENTDAEMONS[string.upper(abilityID)].DESC,
							--TODO maybe use agent icon instead of arrow_small?
							"gui/icons/arrow_small.png"
						)
					end
					tooltip:addAbility(
						STRINGS.TRANSISTOR.AGENTDAEMONS.GENERIC.UNITNAME,
						STRINGS.TRANSISTOR.AGENTDAEMONS.GENERIC.DESC,
						"gui/icons/arrow_small.png"
					)
				end
	        end
			table.insert(tooltip._children, footer)
		end,
	},
	item_hologrenade_transistor = util.extend( commondefs.item_template )
	{
		type = "simgrenade",
		rig = "grenaderig",
		name = STRINGS.TRANSISTOR.AGENTDAEMONS.PRISM.NAME .." ".. STRINGS.ITEMS.GRENADE_HOLO,
		desc = STRINGS.TRANSISTOR.AGENTDAEMONS.PRISM.HOLOGRENADE_TIP,
		flavor = STRINGS.ITEMS.GRENADE_HOLO_FLAVOR,
		--icon = "itemrigs/FloorProp_Bandages.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_holo_grenade_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_holo_grenade.png",	
		kanim = "kanim_hologrenade",
		sounds = {activate="SpySociety/Actions/holocover_activate", deactivate="SpySociety/Actions/holocover_deactivate", activeSpot="SpySociety/Actions/holocover_run_LP", bounce="SpySociety/Grenades/bounce"},
		traits = { cover=false, holoProjector=true, agent_filter=true, deploy_cover=true, explodes=1 },	
		locator = true,
	},
}

return tool_templates