return {
	locale  = "en",
	quotes  = { "\"", "\"" },
	base    = "assets/audio/en",
	strings = {
		-- Main Menu
		["new-game"]      = { text = "New Game" },
		["new-game-plus"] = { text = "New Game +" },
		["continue-game"] = { text = "Continue Game" },
		["controls"]      = { text = "Controls" },
		["options"]       = { text = "Options" },
		["exit-game"]     = { text = "Exit Game" },

		-- Continue Menu
		["level-1"] = { text="Level 1" },
		["level-2"] = { text="Level 2" },
		["level-3"] = { text="Level 3" },
		["level-4"] = { text="Level 4" },
		["level-5"] = { text="Level 5" },
		["level-6"] = { text="Level 6" },
		["level-7"] = { text="Level 7" },

		-- Controls Menu
		["control-forward"] = { text = "Move Forward" },
		["control-up"]      = { text = "Move Up" },
		["control-down"]    = { text = "Move Down" },
		["control-camera"]  = { text = "Move Camera" },
		["control-brake"]   = { text = "Brake" },
		["control-turbo"]   = { text = "Turbo" },
		["control-pause"]   = { text = "Pause Menu" },

		-- Options Menu
		["volume-up"]     = { text = "Volume +" },
		["volume-down"]   = { text = "Volume -" },
		["reset-options"] = { text = "Reset Options" },

		-- Gameplay UI
		["strikes"]    = { text = "Strikes" },
		["durability"] = { text = "Package Durability" },
		["time"]       = { text = "Time" },

		-- Results Screen
		["level-time"] = { text="Level Time" },
		["final-time"] = { text="Final Time" },

		-- Other
		["return"] = { text="Return" },

		-- Papi
		["bad-end-1"] = {
			audio    = "bad-end-1.wav",
			text     = "No... I'm done for...",
			duration = 4
		},
		["broke-1"] = {
			audio    = "broke-1.wav",
			text     = "Oh no, I broke it...",
			duration = 2.5
		},
		["close-1"] = {
			audio    = "close-1.wav",
			text     = "I'm getting close!",
			duration = 2.5
		},
		["close-2"] = {
			audio    = "close-2.wav",
			text     = "Almost there!",
			duration = 2
		},
		["complete-1"] = {
			audio    = "complete-1.wav",
			text     = "Phew! I delivered them all on time!",
			duration = 4
		},
		["complete-2"] = {
			audio    = "complete-2.wav",
			text     = "I'll be a citizen in no time!",
			duration = 2.5
		},
		["delivered-1"] = {
			audio    = "delivered-1.wav",
			text     = "Yay, I delivered it!",
			duration = 3.5
		},
		["late-1"] = {
			audio    = "late-1.wav",
			text     = "I don't want to be sacrificed!",
			duration = 2.5
		},
		["thank-you"] = {
			audio    = "thank-you.wav",
			text     = "Thank you for playing our game!",
			duration = 5
		},

		-- Chief
		["chief-intro-1"] = {
			audio    = "chief-intro-1.wav",
			text     = "Alright, you know the drill! Deliver packages for one more week and I'll carve out your citizenship tablet work.",
			duration = 7
		},
		["chief-intro-2"] = {
			audio    = "chief-intro-2.wav",
			text     = "But if you fail, you'll be the next harvest sacrifice!",
			duration = 4
		},
		["chief-intro-3"] = {
			audio    = "chief-intro-3.wav",
			text     = "Well what are you waiting for? Get flapping bird girl!",
			duration = 3
		},
		["chief-incomplete-1"] = {
			audio    = "chief-incomplete-1.wav",
			text     = "You still have packages left, get outta here!",
			duration = 3
		},
		["chief-complete-1"] = {
			audio    = "chief-complete-1.wav",
			text     = "Good job bird brain, you managed.",
			duration = 2.5
		},
		["chief-complete-2"] = {
			audio    = "chief-complete-2.wav",
			text     = "Good work feather face, no one complained.",
			duration = 2.5
		},
		["chief-complete-strike-1"] = {
			audio    = "chief-complete-strike-1.wav",
			text     = "I got some complaints while you were out, care to tell me what you taste like?",
			duration = 3.5
		},
		["chief-complete-strike-2"] = {
			audio    = "chief-complete-strike-2.wav",
			text     = "I might have to keep a daughter if you don't learn to flap those wings faster.",
			duration = 4
		},
		["chief-complete-fail-1"] = {
			audio    = "chief-complete-fail-1.wav",
			text     = "We made a deal, and you blew it.",
			duration = 3
		},
		["chief-complete-fail-2"] = {
			audio    = "chief-complete-fail-2.wav",
			text     = "I didn't want to have to do this...",
			duration = 2.5
		},
		["chief-bad-end-1"] = {
			audio    = "chief-bad-end-1.wav",
			text     = "May the gods accept this monster instead of my sixth daughter...",
			duration = 4
		},
		["chief-good-end-1"] = {
			audio    = "chief-good-end-1.wav",
			text     = "And here you are, your official citizenship tablet. Welcome to the tribe!",
			duration = 5.5
		},

		-- Citizen
		["civ-happy-1"] = {
			audio    = "civ-happy-1.wav",
			text     = "Thank you, this is just what I wanted, and on time! 5 Sols!",
			duration = 5
		},
		["civ-happy-2"] = {
			audio    = "civ-happy-2.wav",
			text     = "Thanks bird girl, I can always count on you! Keep this up and I won't eat you! 5 Sols!",
			duration = 7
		},
		["civ-happy-3"] = {
			audio    = "civ-happy-3.wav",
			text     = "You're a weird one, but at least you did your job. 4 Sols.",
			duration = 4.5
		},
		["civ-happy-4"] = {
			audio    = "civ-happy-4.wav",
			text     = "You look tasty... I mean, uh, thanks! 4 Sols!",
			duration = 5.5
		},
		["civ-happy-5"] = {
			audio    = "civ-happy-5.wav",
			text     = "You're not one of us! Go back to the forest! 3 Sols!",
			duration = 4.5
		},
		["civ-happy-6"] = {
			audio    = "civ-happy-6.wav",
			text     = "Just give me my package and get out of here, monster! 3 Sols!",
			duration = 5.5
		},
		["civ-late-1"] = {
			audio    = "civ-late-1.wav",
			text     = "Why did they ever think a bird bag like you could get this right? 2 Sols.",
			duration = 4.5
		},
		["civ-late-2"] = {
			audio    = "civ-late-2.wav",
			text     = "Why do I even bother paying for express flapping! 1 Sol!",
			duration = 4
		},
		["civ-late-3"] = {
			audio    = "civ-late-3.wav",
			text     = "If you're late again, I'll make a pillow out of your feathers! 1 Sol!",
			duration = 5.5
		},
		["civ-broke-1"] = {
			audio    = "civ-broke-1.wav",
			text     = "You broke it! I hope your chief sacrifices you! 0 Sols!",
			duration = 6
		},
		["civ-broke-2"] = {
			audio    = "civ-broke-2.wav",
			text     = "You bird brain, it's broken! Next time I'll break your bones! 0 Sols!",
			duration = 6.5
		},

		-- No text!
		["bonk-1"] = {
			audio    = "bonk-1.wav",
			text     = "",
			duration = 2
		},
		["bonk-2"] = {
			audio    = "bonk-2.wav",
			text     = "",
			duration = 2
		},
		["bonk-3"] = {
			audio    = "bonk-3.wav",
			text     = "",
			duration = 2
		},
		["bonk-4"] = {
			audio    = "bonk-4.wav",
			text     = "",
			duration = 2
		},
		["incomplete-1"] = {
			audio    = "incomplete-1.wav",
			text     = "",
			duration = 1.5
		},
		["incomplete-2"] = {
			audio    = "incomplete-2.wav",
			text     = "",
			duration = 1.5
		},
		["random-1"] = {
			audio    = "random-1.wav",
			text     = "",
			duration = 1
		},
		["random-2"] = {
			audio    = "random-2.wav",
			text     = "",
			duration = 1
		},
		["random-3"] = {
			audio    = "random-3.wav",
			text     = "",
			duration = 1
		},
		["random-4"] = {
			audio    = "random-4.wav",
			text     = "",
			duration = 1
		},
	}
}
