local function onAgentTooltip( tooltip, unit )
	if unit:getTraits().psiTakenGuard then
		tooltip:addAbility( STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.PSI_CONTROL, STRINGS.TRANSISTOR.AGENTDAEMONS.MIST.PSI_CONTROL_TIP, "gui/icons/thought_icons/status_channeling.png" ) 
	end

end

return 
{
	onAgentTooltip = onAgentTooltip,
}