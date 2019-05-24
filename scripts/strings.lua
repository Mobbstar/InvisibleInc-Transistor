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
		PERMADEATH_POOLRAND_TIP = "If the Permadeath mod is enabled, enabling this option randomises which persistent Transistor functions spawn from the available pool.",
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
			DESC = "Shock Traps triggered by enemies add a charge to all agency items, including nuclear weapons.",
			-- (this refreshes the flurry gun (="nuclear weapon") too)
			SHORT_DESC = "Shock Traps charge items",
			ACTIVE_DESC = "SHOCK TRAPS CHARGE ITEMS",
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
			DESC = "Agents behind cover get +2 AP next turn.",
			SHORT_DESC = "+2 AP per turn if hidden",
			ACTIVE_DESC = "AGENTS' AP INCREASED BY COVER",
		},
		RED = {
			NAME = "Crash()",
			-- DESC = "Every guards' armor and movement range are reduced to half, rounding up.",
			-- SHORT_DESC = "Halves all guard Armor and AP",
			-- ACTIVE_DESC = "GUARD ARMOR AND AP HALVED",
			DESC = "Guard armor is halved, rounded down. Guards lose 4 AP.",
			SHORT_DESC = "Guard armor halved, guards lose 4 AP",
			ACTIVE_DESC = "GUARD ARMOR HALVED, -4 AP",
		},
		NUMI = { --TODO
			NAME = "Invalid()",
			--rebooting devices can be hacked?
			DESC = "Hacked drones gain 5 AP and 5 Armor Piercing.",
			SHORT_DESC = "",
			ACTIVE_DESC = "",
		},
		MIST = { --TODO
			NAME = "Invalid()",
			DESC = "Guard vision range is drastically reduced.",
			SHORT_DESC = "Shorter guard vision",
			ACTIVE_DESC = "SHORTER GUARD VISION",
		},
		CONWAY = { --TODO
			NAME = "Bashdoor()", --in reference to that exploit
			--Can hold one guard at gunpoint?
			DESC = "By kicking down doors, guards generate 4 PWR and KO themselves for 4 turns.",
			SHORT_DESC = "",
			ACTIVE_DESC = "",
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
