return {
	OPTIONS = {
		RED = "RED",
		RED_TIP = "Adds Red to possible agents.",
		REDENTION = "RED IN DETENTION",
		REDENTION_TIP = "Chance to rescue Red from detention center.",
		WIREFRAME = "NO WIREFRAME",
		WIREFRAME_TIP = "Removes the grayed silhouette of Red when hidden in cover. This makes it harder to notice her, but grants prettier screenshots.",
		ON_KO = "SPAWN FUNCTIONS WHEN KO",
		ON_KO_TIP = "Enable this to spawn agent functions when those agents get Knocked Out. Additionally, Reds \"Hurt\" ability will only KO the target.\n\nPlease keep in mind that this makes the Transistor significantly more powerful than we originally intended.",
		PERMADEATH_POOLRAND = "PERMADEATH RANDOMISATION",
		PERMADEATH_POOLRAND_TIP = "If the Permadeath mod is enabled and persistent Transistor functions have been acquired, enabling this option randomises how many of them spawn each mission. (Capped at 4 functions either way)",
	},

	RED = {
		NAME = "Red",
		FILE = "FILE #03-250334A-84681275",
		YEARS_OF_SERVICE = "0",
		AGE = "Null",
		HOMETOWN = "\"Cloudbank\"",
		RESCUED = "...",
		BIO_SPOKEN = "",
		FULLNAME = 'Red',
		BIO = "Red's true identity and her past remain a mystery, as she claims to hail from a city that's not on any physical map. Whispers in the SecNet link her to a hushed-up Plastech experiment with cyberconsciousness that failed on a massive scale. The only known survivor of this incident, Red is suspected to have played a more active role in its disintegration than she lets on.",
		TOOLTIP = "Singer",

		BANTER = {
			START = {
				--We don't want to clutter the start banters with throwaway lines.
				--This is incredibly stupid, but the game just assumes we have a banter.
				--Can we at least play humming sounds somehow?
				"Hmm-Hm-Hmmm~", --Vanishing point
				"Hmmm~, Hmm-Hm~, Hmm-Hm~", --Interlace 
				"Hm-Hmm-Hmmm-Hm~", --Forecast
				"Hm-Hmm~, Hm-Hmm-Hm-m-Hmmm-Hmmm~", --Water Wall
			},
			FINAL_WORDS =
			{
				"...",	
			},
			--crossbanter is now in a separate file
		},
	},	
	
	AUGMENT_TRANSISTOR = "Transistor",
	AUGMENT_TRANSISTOR_TIP = "Unique algorithms activate while agents are dying. Can put agents into critical condition remotely.",
	AUGMENT_TRANSISTOR_TIP_KO = "Unique algorithms activate while agents are KO or dying. Can KO agents remotely.",
	AUGMENT_TRANSISTOR_FLAVOR = "Neural trace data can be used to generate powerful functions based on the subjects' identities. These functions fall apart once the subjects regain higher consciousness.",
	
	ABILITY_REMOTECRITICAL = "Hurt",
	ABILITY_REMOTECRITICAL_TIP = "Hurt {1}",
	ABILITY_REMOTECRITICAL_DESC = "Inflict a critical, not quite lethal wound.",
	ABILITY_REMOTECRITICAL_DESC_KO = "Apply overwhelming pain, causing a temporary Knock-Out.",
	
	CONFIRM_REMOTECRITICAL = "Are you sure you want to hurt this agent?",
	CONFIRM_REMOTECRITICAL_LASTAGENT = "This is your last active agent. Are you sure you want to hurt them?",
	
	BADCELL = "Bad Cell",
	TOOLTIP_BADCELL_EXPLO = "VOLATILE",
	TOOLTIP_BADCELL_EXPLO_DESC = "This unit will explode on the enemy turn, rendering all guards on the same tile KO for that turn.",
	TOOLTIP_BADCELL_INVIS = "IMPERCEPTIBLE",
	TOOLTIP_BADCELL_INVIS_DESC = "This unit cannot be seen or heard.",
	TOOLTIP_BADCELL_LOS = "SHORT VISION",
	TOOLTIP_BADCELL_LOS_DESC = "Vision range is 2 tiles. Does not detect sound.",
	
	CORRUPTEDCELL = "Corrupted Cell",
	TOOLTIP_CORRUPTEDCELL_LOS_DESC = "Vision range is 1 tile. Does not detect sound.",	
	
	LOADING_TIPS = {
		"TRANSISTOR: You can view the available agent algorithms in the Transistor's tooltip during a mission.",
		"TRANSISTOR: Red's Transistor augment will make agents spawn as cyberconscious algorithms when they are down. Use this to turn the tide.",
		"TRANSISTOR: With the Permadeath mod enabled, any agent that permanently dies with Red around will stay with you as an algorithm for the rest of the campaign.",
		"TRANSISTOR: Red's algorithm, Crash(), will slow and weaken enemies as long as it's active.",
		"TRANSISTOR: With the Permadeath mod enabled, you can have up to four ghost algorithms active at a time.",
		"TRANSISTOR: An agent with no unique function of their own will spawn Checksum(), a powerful weapon for KOing guards.",
		"TRANSISTOR: Each agent's Transistor algorithm matches their skills and personality. This may not always be a good thing.",
		"TRANSISTOR: Transpose() allows you to psijack an enemy guard, mind-controlling them for as long as Mist is down.",
		"TRANSISTOR: Red's Hurt ability can activate the algorithms at a tactically convenient time. She can even use it on herself!",
		"TRANSISTOR: 'Agent down' doesn't mean you've failed. Agent algorithms are there to help you claw your way back to victory!",
		"TRANSISTOR: Attention(), Chase() and Abscond() are all handy for that boost of extra AP in a pinch.",
		"TRANSISTOR: With the Agent Reserve mod, you can keep expanding your team past the 4 agent limit and experiment with their algorithms.",
		"TRANSISTOR: Coup() and Grace() can be used together for a flexible, lethal game-changer when Olivia and Derek are down.",
		"TRANSISTOR: You can use Red's Hurt ability on the Prisoner or the Courier to spawn Checksum().",
		},
	
	AGENTDAEMONS = {
		GENERIC = {
			NAME = "Checksum()",
			DESC = "Agent body spawns a bad cell every turn, which can move and causes a tiny explosion.",
			SHORT_DESC = "Body spawns Bad Cells",
			ACTIVE_DESC = "ERROR! PRODUCING BAD CELLS",
			UNITNAME = "Any other agent",
		},
		GENERICKIA = {		-- only used if Permadeath on
			NAME = "Checksum()",
			DESC = "Spawns a corrupted cell in a random location every other turn, which can move and causes a tiny explosion.",
			SHORT_DESC = "Spawns Corrupted Cells",
			ACTIVE_DESC = "ERROR! PRODUCING BAD CELLS",
			UNITNAME = "Any other agent",
		},		
		DECKER = {
			NAME = "Chase()",
			DESC = "Increases all agents' AP by 1 for each guard alerted.",
			SHORT_DESC = "+1 AP per alerted guard",
			ACTIVE_DESC = "AGENTS' AP INCREASED BY ALERTED GUARDS",
		},
		MARIA = {
			NAME = "Triangulate()",
			DESC = "Reveals all drones as red \"ghosts\".",
			SHORT_DESC = "Reveals enemy drones",
			ACTIVE_DESC = "DRONES REVEALED",
		},
		SHALEM = {
			NAME = "Aim()",
			DESC = "Increases gun KO damage and Armor Piercing by 3, increases cooldown by 4. All guns must cool down.",
			SHORT_DESC = "Stronger, slower guns",
			ACTIVE_DESC = "STRONGER, SLOWER GUNS",
		},
		BANKS = {
			NAME = "Besiege()",
			DESC = "Any daemon reduces firewalls on half of active devices by 2, not breaking any.",
			SHORT_DESC = "Daemons lower several firewalls",
			ACTIVE_DESC = "DAEMONS LOWER FIREWALLS",
		},
		XU = {
			NAME = "Mischief()",
			-- DESC = "Shock Traps triggered by enemies add a charge to all agency items, including nuclear weapons.",
			-- -- (this refreshes the flurry gun (="nuclear weapon") too)
			-- SHORT_DESC = "Shock Traps charge items",
			-- ACTIVE_DESC = "SHOCK TRAPS CHARGE ITEMS",
			DESC = "Random enemy is marked and emits noisy EMP next turn (range=3).",
			-- (this refreshes the flurry gun (="nuclear weapon") too)
			SHORT_DESC = "Random marked enemy emits EMP each turn",
			ACTIVE_DESC = "ENEMIES EMIT EMP PULSES",	
			MARKED_UNIT_DESC = "This unit will emit a noisy EMP (range=3) next agent turn.",
		},
		NIKA = {
			NAME = "Punch()",
			DESC = "Melee combat against alerted targets generates 4 PWR and the weapon instantly cools down.",
			SHORT_DESC = "Fast melee when alerted",
			ACTIVE_DESC = "FASTER MELEE",
		},
		SHARP = {
			NAME = "Exceed()",
			DESC = "Melee attacks pierce 1 Armor per augment and drain 4 PWR per empty augment slot.",
			SHORT_DESC = "Stronger melee with PWR cost",
			ACTIVE_DESC = "MELEE BOOSTS FOR HAVING AUGMENTS",
		},
		PRISM = {
			NAME = "Integrity()",
			-- DESC = "Hologram-Projectors make no noise and hinder guard patrols.",
			-- SHORT_DESC = "Holo-Projectors block guards",
			-- ACTIVE_DESC = "BETTER HOLO-PROJECTORS",
			DESC = "Agents spawn a temporary Hologram Projection once a turn when overwatched.",
			SHORT_DESC = "Emergency Holo-Projections",
			ACTIVE_DESC = "EMERGENCY HOLO-PROJECTIONS",
			HOLOGRENADE_TIP = "Fake cover item generated by Transistor. Dissipates after player turn."
		},
		CENTRAL = {
			NAME = "Parry()",
			DESC = "Increases Daemon reversal chance by 33%. Reversal generates 10 PWR.",
			SHORT_DESC = "More daemon reversal and PWR",
			ACTIVE_DESC = "POWER FOR DAEMON REVERSAL",
		},
		MONSTER = {
			NAME = "Yield()",
			DESC = "Agents next to consoles further reduce all program cooldown by 1 next turn. Has a 66% chance of daemon.",
			-- DESC = "Starting the turn next to a console reduces all program cooldown by 1 and has a 66% chance of daemon.",
			SHORT_DESC = "Faster programs near consoles",
			ACTIVE_DESC = "CONSOLES REDUCE PROGRAM COOLDOWN",
		},
		DRACO = {
			NAME = "Read()",
			DESC = "Killing a human guard, or pinning him at turn start, reveals a large area. Bonus credits if everything already revealed.",
			SHORT_DESC = "Killing/pinning reveals an area",
			ACTIVE_DESC = "INTEL FROM DYING GUARDS",
		},
		RUSH = {
			NAME = "Attention()",
			DESC = "Getting targeted restores AP and Attack once per turn.",
			SHORT_DESC = "Restore AP under overwatch",
			ACTIVE_DESC = "RESTORE AP WHEN TARGETED",
		},
		OLIVIA = {
			NAME = "Coup()",
			DESC = "Melee KO damage on already KO guards kills them and bypasses basic heart monitors. Grants another attack.",
			-- DESC = "Killing KO guards disables heart monitors and grants another attack.",
			SHORT_DESC = "Disruptors kill pinned guards",
			ACTIVE_DESC = "DISRUPTORS KILL PINNED GUARDS",
		},
		DEREK = {
			NAME = "Grace()",
			-- DESC = "Agents behind cover get +2 AP next turn.",
			-- SHORT_DESC = "+2 AP per turn if hidden",
			-- ACTIVE_DESC = "AGENTS' AP INCREASED BY COVER",
			DESC = "Player-controlled unit can instantly swap position with another once per turn. Uses attack.",
			SHORT_DESC = "Units gain swap-teleportation ability",
			ACTIVE_DESC = "UNITS CAN SWAP-TELEPORT",	
			ABILITY_GRACE_DESC = "Teleport-swap with this unit",
			ABILITY_GRACE_TIP ="Swap places with {1}",
			ABILITY_GRACE_TIP2 ="Swap places with unit",
			CONFIRM_GRACE = "Are you sure you want to swap these units?",
			ALREADY_USED = "Already used this turn",
		},
		RED = {
			NAME = "Crash()",
			DESC = "Guard armor is halved, rounded down. Guards lose 4 AP.",
			SHORT_DESC = "Guard armor halved, guards lose 4 AP",
			ACTIVE_DESC = "GUARD ARMOR HALVED, -4 AP",
		},
		NUMI = {
			NAME = "Tuning()",
			DESC = "Hacked drones gain 5 AP. Control hacked drones for 3 extra turns.",
			SHORT_DESC = "Faster drones, longer control",
			ACTIVE_DESC = "FASTER DRONES, LONGER CONTROL",
		},
		MIST = { 
			NAME = "Transpose()",
			DESC = "Psi-hijack the next human guard to stand on Mist's body.",
			SHORT_DESC = "Mind control a guard",
			ACTIVE_DESC = "MIND CONTROL  A GUARD", --double space after "control" because else it looks awkward in-game -M
			PSI_CONTROL = "PSI CONTROL",
			PSI_CONTROL_TIP = "Hostile actions taken by this unit will cause a drastic alarm increase and break control over the unit.",
			LOST_CONTROL = "CONTROL LOST",
			CANNOT_OVERWATCH = "PSI-CONTROLLED UNITS CANNNOT OVERWATCH",
			NEUTRALIZED_TIP = "Your agents are down, but Transpose() is active! If a human guard pins Mist, you will gain control over him and can salvage this mission. If success seems unlikely, you can use Abort Mission from the menu.",	
		},
		
		-- MIST_KIA = { -- unused
			-- NAME = "Transpose()",
			-- DESC = "Psi-hijack the next human guard to overwatch an agent",
			-- SHORT_DESC = "Mind control a guard",
			-- ACTIVE_DESC = "MIND CONTROL A GUARD",
			-- PSI_CONTROL = "PSI CONTROL",
			-- PSI_CONTROL_TIP = "This enemy unit is under psi control. Hostile actions taken by this unit will cause a drastic alarm increase.",
			-- CANNOT_OVERWATCH = "PSI-CONTROLLED UNITS CANNNOT OVERWATCH",			
		-- },		
		MIST_KIA = {
			NAME = "Transpose()",
			DESC = "KO'd guards are not alerted when they wake up",
			SHORT_DESC = "Awakening guards are not alerted",
			ACTIVE_DESC = "KO'D GUARDS ARE CALMED",			
		},		
		GHUFF = { 
			NAME = "Sleuth()",
			DESC = "Observing guards permanently tags them.",
			SHORT_DESC = "Tag guards by observing",
			ACTIVE_DESC = "TAG GUARDS BY OBSERVING",
		},	
		PEDLER = { 
			NAME = "Brawl()",
			DESC = "+1 melee KO damage per enemy armour, minimum 1. KO'd agents get right back up.",
			SHORT_DESC = "Extra KO damage, KO resistance",
			ACTIVE_DESC = "EXTRA KO DAMAGE, KO RESIST",
		},		
		CONWAY = {
			NAME = "Bashdoor()", --in reference to that exploit
			--Can hold one guard at gunpoint?
			DESC = "By kicking down doors, guards generate 4 PWR and KO themselves for 4 turns.",
			SHORT_DESC = "Doorkicking guards self-KO",
			ACTIVE_DESC = "DOORKICKING HURTS GUARDS",
		},
		
		CARMEN = { -- from Carmen Sandiego mod
			NAME = "Abscond()",
			DESC = "Once per agent per turn, agents on tiles with interest points gain 4 AP.",
			SHORT_DESC = "Bonus AP on interest point",
			ACTIVE_DESC = "GUARD INTEREST POINTS GIVE AP",
		},	
		
		GOOSE = { -- from Goose Protocol mod
			NAME = "Gaggle()",
			DESC = "All agents gain Goose's Honk ability.",
			SHORT_DESC = "Agents can Honk",
			ACTIVE_DESC = "AGENTS CAN HONK",
		},	
		AGENT_47 = { -- from Agent 47 mod
			NAME = "Anopsia()",
			DESC = "Guards will not see bodies. Includes corpses, drones, and incapacitated agents.",
			SUBTITLE = "BODIES ARE NOT NOTICED",
			DESC2 = "Guards that investigate a tile with a body on it will still notice that body!",
			SUBTITLE2 = "WARNING",
			SHORT_DESC = "Guards don't notice bodies",
			ACTIVE_DESC = "GUARDS DON'T NOTICE BODIES",
		},			
	},
	
	LOGS =
	{
	log_transistor1_filename = "STACK TRACEBACK",
	log_transistor1_title = "Trace Data Decryption - \"Crash()\"",
	log_transistor1 = [[SUBJECT
	Age
	<c:62B3B3>27</>

	Gender
	<c:62B3B3>Female</>

	Selections
	<c:62B3B3>Music, Linguistics</>

	Reasons Cited
	<c:62B3B3>Declined</>

	Trace Status
	<c:62B3B3>Intact</>

	FILE
	
	<c:61CD98>Background</>
	<c:62B3B3>Ranked in the top percentile of Cloudbank's contemporary performing artists for five years, Red demonstrated early interest in music despite studying at Traverson Hall. Traverson groomed many of the city's most ambitious civic planners, though Red spent the majority of her time developing the academy's nascent arts program, and was the first on record to select two nontraditional disciplines. Records indicate she was reluctant to explain, citing personal reasons. She remained reticent even after gaining the spotlight, and when asked about her past and influences, would often say her work spoke for itself. She did admit, however, that she never wrote her music with intent to stir controversy. </>
	
	<c:61CD98>Career</>
	<c:62B3B3>To appreciate the impact of Red's music, consider first the current state of Cloudbank's social climate and how it evolved over the past two decades. When an altercation finally erupted in the crowd during one of her performances, it was the first such incident in four years. It escalated to the point where administrators were summoned to the scene. As one of the suspects was banned from the premises, he accused Red of being an instigator and provocateur. Red later stated it was in this moment that she fully understood the potent effect her music had on people. She decided to take certain precautions from that point, receding from the spotlight to compose new material in relative privacy. Rumors swirled. Then, once she finally re-emerged, trouble followed. </>
	
	<c:61CD98>Disappearance</>
	<c:62B3B3>The Camerata found her one night once the crowds dispersed after one of her performances. They had reason to believe that she would be alone, rehearsing said new material. But she was not alone, and the presence of another individual disrupted aspects of the Camerata's plan for the night. Red survived the incident, becoming separated from the Camerata due to these unforeseen events on their part. Although her trace data remains intact, partial transfer did occur, including transfer of ownership status of something the Camerata believed theirs.</>
	
	Decryption complete.]],
	
	
	log_transistor2_filename = "CORRUPTED DATA",
	log_transistor2_title = "Checksum Error Log",
	log_transistor2 = [[Designa__on: Badcell

	ROLE
	<c:EDA922>To Be Recycl__</>

	_EATURES
	<c:EDA922>+ Pellet Blaster
	+ B_rst ___ckwave</>

	VULNERAB__IT_ES
	<c:EDA922>- Una_mored Fr_me
	- Cannot Dete__ Cover</>

	PR_FERENCES
	<c:EDA922>Cool Dark Places,
	Early T_rm__ation.</>

	<c:D76120>!-- the cells, they spoil! they spoil like, wel___like anything that spoils except instead of spoiling they they become someth___ else, something they don't seem to want to be. this is no conversion but a total metamor___sis, it cannot be r___rsed as far as i ca_ t_ll. once the cell has shif_ed to this form, then all that remains is for it to expel its st_red potent__l, like a l_st br__th. back into the ether i suppose. some form of self defense? royce --!</>
	
	End of file.]],},
}
