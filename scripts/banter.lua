
return function(modApi)
	local DECKER = 1
	local SHALEM = 2
	local XU = 3
	local BANKS = 4
	local NIKA = 6
	local MARIA = 5
	local SHARP = 7
	local PRISM = 8
	local MONSTER = 100
	local CENTRAL = 108
	local OLIVIA = 1000
	local DEREK = 1001
	local RUSH = 1002
	local DRACO = 1003
	local PEDLER = "mod_01_pedler"
	local MIST = "mod_02_mist"
	local GHUFF = "mod_03_ghuff"
	local NUMI = "mod_04_n_umi"
	local DOSAN = "dosan_01"
	local CONWAY = "gunpoint_conway"
	local RED = "transistor_red"
	local SOMBRA = "SOMBRA_001"
	local WIDOWMAKER = "WIDOWMAKER_001"
	
	
	-- modApi:addBanter( {
			-- id = 421, --IDs are useless, but add some anyways for good measure
			-- agents = {RED, DECKER},
			-- dialogue = {
				-- {DECKER, "Argh! That was a strong daemon. My spine..." },
				-- {RED, "Hm-Hmmm~" },
			-- },
		-- } )
		
		
	modApi:addBanter( {
			id = "decker_red1",
			agents = {RED, DECKER},
			dialogue = {
				{DECKER, "\"Red.\" Because that's *so* original." },
				{RED, "Hmmmmm." },
				{DECKER, "Yeah, that's what I thought."},
			},
		} )

	modApi:addBanter( {
			id = "decker_red2",
			agents = {RED, DECKER},
			dialogue = {
				{DECKER, "I deal enough with daemons without turning into one. You keep that thing away from me, you got that?" },
				{RED, " ... " },
			},
		} )	

	modApi:addBanter( {
			id = "decker_banks_red",
			agents = {RED, DECKER, BANKS},
			dialogue = {
				{DECKER, "Great. Now there's two nutjobs on the team."},
				{BANKS, "I'm sure she's as sane as I am sometimes."},
				{DECKER, "That's kind of the part that's got me worried."},
				{RED, " ... "},
			},
		} )		
		
	modApi:addBanter( {
			id = "red_sharp1",
			agents = {RED, SHARP},
			dialogue = {
				{SHARP, "Is it true? That you were part of some cyber mind meld project gone wrong?"},
				{RED, "..."},
				{SHARP, "I suppose it's only right that they tested it on the likes of you. Weak and organic. If it were me in that experiment-"},
				{RED, "< It would have processed you first. >"},
			},
		} )	


	modApi:addBanter( {
			id = "red_mist1",
			agents = {RED, MIST},
			dialogue = {
				{MIST, "...Huh."},
				{RED, "Hmmm?"},
				{MIST, "Weird, it's almost like it's not just you in your head... No, can't be..."},
				{RED, " ... "},
			},
		} )	
		
	modApi:addBanter( {
			id = "red_mist2",
			agents = {RED, MIST},
			dialogue = {
				{MIST, "I guess Central's kind of collecting failed experiments these days."},
				{RED, "Hmm."},
				{MIST, "You and me. I meant the two of us."},
				{RED, " ... "},
				{MIST, "Was it something I said?"},
			},
		} )			

		
	modApi:addBanter( {
			id = "red_mist3",
			agents = {RED, MIST},
			dialogue = {
				{RED, "Hmmm~ Hm-Hmmm~ Hmmm..."},
				{MIST, "I can almost hear what the song is supposed to sound like, if I focus. It's beautiful."},
				{RED, " ... "},
				{MIST, "I'm sorry. I didn't mean to make you stop."},
			},
		} )		
		
		
	modApi:addBanter( {
			id = "red_draco1",
			agents = {RED, DRACO},
			dialogue = {
				{DRACO, "We are alike, you and I. We both grow stronger from carnage."},
				{RED, " ... " },
				{DRACO, "You wear your silence like a veil, but allow me to say that I am a staunch admirer."},
			},
		} )	

	modApi:addBanter( {
			id = "red_prism",
			agents = {RED, PRISM},
			dialogue = {
				{PRISM, "So you used to be a singer, huh?"},
				{RED, "Mmmm." },
				{PRISM, "Can't say I've heard of you."},
			},
		} )	

	modApi:addBanter( {
			id = "red_banks",
			agents = {RED, BANKS},
			dialogue = {
				{BANKS, "I saw something, last time I was... in that thing. A city. It was like a dream..."},
				{RED, "< Oh... >"},
				{BANKS, "I think I'd like to see it again. Just need to get myself knocked out, right?"},
				{RED, "< Don't. >"},
			},
		} )			
		
		
	modApi:addBanter( {
			id = "red_red",
			agents = {RED, MARIA},
			dialogue = {
				{MARIA, "I've never liked the idea of cyberconsciousness. There are some things technology shouldn't meddle with."},
				{RED, " ... "},
				{MARIA, "If I lose consciousness, will I even have a choice? Or will it simply... suck me up?"},
				{RED, "< I don't know. >"},
			},
		} )		

	modApi:addBanter( {
			id = "red_xu1",
			agents = {RED, XU},
			dialogue = {
				{XU, "I will admit, I am both intrigued and uneasy."},
				{RED, "Hm?"},
				{XU, "I prefer to work with things I understand, yet your augment eludes every attempt to study it."},
				{RED, "< Good. >"},
			},
		} )			

	modApi:addBanter( {
			id = "red_xu2",
			agents = {RED, XU},
			dialogue = {
				{XU, "My concerns aside, the idea of interacting with the mainframe on a more direct level is exciting. Maybe we could experiment sometime?"},
				{RED, "< No. >"},
				{XU, "Are you certain? Some practice couldn't hurt, could it?"},
				{RED, "< Yes. It could. >"},
			},
		} )	
		
	modApi:addBanter( {
			id = "red_nika",
			agents = {RED, NIKA},
			dialogue = {
				{NIKA, " ... "},
				{RED, " ... "},
				{NIKA, "I would like to make this clear. If I see you deliberately put others in harm's way to bolster yourself, I will treat you as an enemy. You understand me?"},
				{RED, "Hmm."},
				{NIKA, "Good."},
			},
		} )			

	modApi:addBanter( {
			id = "red_shalem",
			agents = {RED, SHALEM},
			dialogue = {
				{SHALEM, "A singer? I used to date a singer or two, back in my heyday."},
				{RED, " ........ "},
				{SHALEM, "They're usually a bit more chatty."},
			},
		} )
		
	modApi:addBanter( {
			id = "red_maria2",
			agents = {RED, MARIA},
			dialogue = {
				{MARIA, "I can't make sense of it. That last mission we had, something blindsided me. Did you do that?"},
				{RED, " ... "},
				{MARIA, "You couldn't have, could you? You weren't anywhere near me. Nobody has that kind of power."},
				{RED, "Hmmmm~"},
			},
		} )	
		
end
