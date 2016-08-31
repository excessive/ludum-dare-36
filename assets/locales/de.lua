return {
	locale  = "de",
	quotes  = { "\"", "\"" },
	base    = "assets/audio/de",
	strings = {
		-- Main Menu
		["new-game"]      = { text = "Neues Spiel" },
		["new-game-plus"] = { text = "Neues Spiel +" },
		["continue-game"] = { text = "Spiel fortführen" },
		["controls"]      = { text = "Steuerung" },
		["options"]       = { text = "Optionen" },
		["exit-game"]     = { text = "Spiel verlassen" },

		-- Continue Menu
		["level-1"] = { text="Level 1" },
		["level-2"] = { text="Level 2" },
		["level-3"] = { text="Level 3" },
		["level-4"] = { text="Level 4" },
		["level-5"] = { text="Level 5" },
		["level-6"] = { text="Level 6" },
		["level-7"] = { text="Level 7" },

		-- Controls Menu
		["control-forward"] = { text = "Vorwärts" },
		["control-up"]      = { text = "Rauf" },
		["control-down"]    = { text = "Runter" },
		["control-camera"]  = { text = "Kamera bewegen" },
		["control-brake"]   = { text = "Bremsen" },
		["control-turbo"]   = { text = "Turbo" },
		["control-pause"]   = { text = "Pausen-Menü" },

		-- Options Menu
		["volume-up"]     = { text = "Lautstärke +" },
		["volume-down"]   = { text = "Lautstärke -" },
		["reset-options"] = { text = "Optionen zurücksetzen" },

		-- Gameplay UI
		["strikes"]    = { text = "Fehlschläge" },
		["durability"] = { text = "Paket Haltbarkeit" },
		["time"]       = { text = "Zeit" },

		-- Results Screen
		["level-time"] = { text="Level Zeit" },
		["final-time"] = { text="Finale Zeit" },

		-- Other
		["return"] = { text="Zurück" },

		-- Papi
		["bad-end-1"] = {
			text     = "Nein... das war's wohl...",
			duration = 4
		},
		["broke-1"] = {
			text     = "Oh nein, ich hab's kaputt gemacht...",
			duration = 2.5
		},
		["close-1"] = {
			text     = "Ich bin nah dran!",
			duration = 2.5
		},
		["close-2"] = {
			text     = "Fast da!",
			duration = 2
		},
		["complete-1"] = {
			text     = "Hui! Ich habe alles rechtzeitig ausgeliefert!",
			duration = 4
		},
		["complete-2"] = {
			text     = "Ich werde ratz-fatz ein Bürger!",
			duration = 2.5
		},
		["delivered-1"] = {
			text     = "Juhuu, ich hab's ausgeliefert!",
			duration = 3.5
		},
		["late-1"] = {
			text     = "Ich will nicht geopfert werden!",
			duration = 2.5
		},
		["thank-you"] = {
			text     = "Danke, dass du unser Spiel gespielt hast!",
			duration = 5
		},

		-- Chief
		["chief-intro-1"] = {
			text     = "Okay, du weißt, was zu tun ist. Liefer für noch eine Woche Pakete aus und ich schnitze dir deine Bürgertafel.",
			duration = 7
		},
		["chief-intro-2"] = {
			text     = "Aber wenn du fehlschlägst, bist du das nächste Opfer!",
			duration = 4
		},
		["chief-intro-3"] = {
			text     = "Na, worauf wartest du noch? Flatter los, Vogelmädel!",
			duration = 3
		},
		["chief-incomplete-1"] = {
			text     = "Du hast noch Pakete übrig, zisch ab!",
			duration = 3
		},
		["chief-complete-1"] = {
			text     = "Gute Arbeit Spatzenhirn, du hast es hingekriegt.",
			duration = 2.5
		},
		["chief-complete-2"] = {
			text     = "Gute Arbeit Federgesicht, niemand hat sich beschwert.",
			duration = 2.5
		},
		["chief-complete-strike-1"] = {
			text     = "Ich habe ein paar Beschwerden bekommen während du weg warst. Willst du mir verraten wie du schmeckst?",
			duration = 3.5
		},
		["chief-complete-strike-2"] = {
			text     = "Ich müsste glatt eine Tochter behalten, wenn du nicht lernst die Flügel schneller zu schlagen.",
			duration = 4
		},
		["chief-complete-fail-1"] = {
			text     = "Wir hatten eine Verabmachung und du hast sie platzen lassen.",
			duration = 3
		},
		["chief-complete-fail-2"] = {
			text     = "Ich wollte es nicht soweit kommen lassen...",
			duration = 2.5
		},
		["chief-bad-end-1"] = {
			text     = "Mögen die Götter dieses Monster statt meiner sechsten Tochter annehmen...",
			duration = 4
		},
		["chief-good-end-1"] = {
			text     = "Und hier hast du's, deine offizielle Bürgertafel. Willkommen im Stamm!",
			duration = 5.5
		},

		-- Citizen
		["civ-happy-1"] = {
			text     = "Danke sehr, das ist genau was ich wollte und pünktlich dazu! 5 Sols!",
			duration = 5
		},
		["civ-happy-2"] = {
			text     = "Danke Vogelmädel, auf dich kann ich mich immer verlassen! Behalte das bei und ich werden dich nicht fressen müssen! 5 Sols!",
			duration = 7
		},
		["civ-happy-3"] = {
			text     = "Du bist seltsam, aber zumindest hast du deine Arbeit erledigt. 4 Sols.",
			duration = 4.5
		},
		["civ-happy-4"] = {
			text     = "Du siehst lecker aus... Äh, ich meine, danke! 4 Sols!",
			duration = 5.5
		},
		["civ-happy-5"] = {
			text     = "Du bist keine von uns! Geh zurück in den Wald! 3 Sols!",
			duration = 4.5
		},
		["civ-happy-6"] = {
			text     = "Gib mir einfach mein Paket und hau ab, Monster! 3 Sols!",
			duration = 5.5
		},
		["civ-late-1"] = {
			text     = "Warum haben die jemals gedacht ein Vöglein wie du könnte das hinkriegen? 2 Sols.",
			duration = 4.5
		},
		["civ-late-2"] = {
			text     = "Warum bezahle ich überhaupt für Express-Flügelschlag! 1 Sol!",
			duration = 4
		},
		["civ-late-3"] = {
			text     = "Wenn du nochmal zu spät kommst mache ich ein Kissen aus deinen Federn! 1 Sol!",
			duration = 5.5
		},
		["civ-broke-1"] = {
			text     = "Du hast es kaputt gemacht! Ich hoffe dein Häuptling opfert dich! 0 Sols!",
			duration = 6
		},
		["civ-broke-2"] = {
			text     = "Es ist kaputt, du Spatzenhirn! Nächstes mal mache ich deine Knochen kaputt! 0 Sols!",
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