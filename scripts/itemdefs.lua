local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local unitdefs = include("sim/unitdefs")
local commondefs = include( "sim/unitdefs/commondefs" )

local tryGetAgentIdsFromState
do -- TODO extract this to a separate file
	local unitdefs = include("sim/unitdefs")
	local serverdefs = include("modules/serverdefs")

	local function findAgentTemplateName(idx) -- inverse of findAgentIdx @ state-team-preview:54
		return serverdefs.SELECTABLE_AGENTS[idx]
	end

	tryGetAgentDefsFromState = function()
		local states = statemgr.getStates()
		local agentDefs = {}
		for i = #states, 1, -1 do --the most recent state is at the top of the "stack" (which is not guaranteed to pop like a stack, but for our purposes it's a duck)
			if states[i]._selectedAgents then -- state-team-preview
				for j = 1, #states[i]._selectedAgents do
					local templateName = findAgentTemplateName(states[i]._selectedAgents[j])
					local agentDef = unitdefs.lookupTemplate(templateName)
					if agentDef then
						table.insert(agentDefs, agentDef)
					end
				end
				return agentDefs
			elseif states[i]._agency and states[i]._agency.unitDefs then -- state-upgrade-screen, or a goose pretending to be it
				for j = 1, #states[i]._agency.unitDefs do
					local templateName = states[i]._agency.unitDefs[j].template
					local agentDef = unitdefs.lookupTemplate(templateName)
					if agentDef then
						table.insert(agentDefs, agentDef)
					end
				end
				return agentDefs
			end
		end
	end
end

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
			local agentDefs = {}
			local owner = userUnit or unit
			if owner and owner.isValid and owner:isValid() then
				local ability_transistor = owner:ownsAbility("ability_transistor")
				if ability_transistor then
					agentDefs = ability_transistor.currentAgentDefs
				end
			else
				--TODO in state-team-preview, the entire onTooltip only runs once, but we want it to re-run whenever selected loadout changes
				local agentDefs = tryGetAgentDefsFromState()
	        end
			local showGeneric = false
			for i = 1, #agentDefs do
				local transistorDef = unitdefs:getTransistorForAgentId(agentDefs[i].agentID)
				if transistorDef then
					tooltip:addAbility(
						agentDefs[i].name,
						transistorDef.description,
						"gui/icons/arrow_small.png" --TODO maybe use agent icon instead of arrow_small?
					)
				else
					showGeneric = true
				end
			end
			if showGeneric then
				tooltip:addAbility(
					STRINGS.TRANSISTOR.AGENTDAEMONS.GENERIC.UNITNAME,
					STRINGS.TRANSISTOR.AGENTDAEMONS.GENERIC.DESC,
					"gui/icons/arrow_small.png"
				)
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