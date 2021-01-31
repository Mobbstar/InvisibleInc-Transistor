local function onAgentTooltip( tooltip, unit )
	if unit:getTraits().psiTakenGuard then
		tooltip:addAbility( STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.PSI_CONTROL, STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.PSI_CONTROL_TIP, "gui/icons/thought_icons/status_channeling.png" ) 
	end

end

local function onGuardTooltip( tooltip, unit )
	if unit:getTraits().mischiefMarked then
		tooltip:addAbility( STRINGS.TRANSISTOR.AGENTDAEMONS.XU.MARKED_UNIT_NAME, STRINGS.TRANSISTOR.AGENTDAEMONS.XU.MARKED_UNIT_DESC, "gui/icons/item_icons/items_icon_small/icon-item_emp_small.png" )
	end
end

return 
{
	onAgentTooltip = onAgentTooltip,
	onGuardTooltip = onGuardTooltip,
}
