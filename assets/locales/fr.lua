return {
	locale  = "fr",
	quotes  = { "\"", "\"" },
	base    = "assets/audio/fr",
	strings = {
		-- Main Menu
		["new-game"]      = { text = "Nouvelle Partie" },
		["new-game-plus"] = { text = "Nouvelle Partie +" },
		["continue-game"] = { text = "Continuer" },
		["controls"]      = { text = "Contrôles" },
		["options"]       = { text = "Options" },
		["exit-game"]     = { text = "Quitter" },

		-- Continue Menu
		["level-1"] = { text="Stage 1" },
		["level-2"] = { text="Stage 2" },
		["level-3"] = { text="Stage 3" },
		["level-4"] = { text="Stage 4" },
		["level-5"] = { text="Stage 5" },
		["level-6"] = { text="Stage 6" },
		["level-7"] = { text="Stage 7" },

		-- Controls Menu
		["control-forward"] = { text = "Avancer" },
		["control-up"]      = { text = "Monter" },
		["control-down"]    = { text = "Descendre" },
		["control-camera"]  = { text = "Tourner la Caméra" },
		["control-brake"]   = { text = "Frein" },
		["control-turbo"]   = { text = "Turbo" },
		["control-pause"]   = { text = "Mettre en Pause" },

		-- Options Menu
		["volume-up"]     = { text = "Volume +" },
		["volume-down"]   = { text = "Volume -" },
		["reset-options"] = { text = "Réinitialiser les Options" },

		-- Gameplay UI
		["strikes"]    = { text = "Marques" },
		["durability"] = { text = "Durabilité du Paquet" },
		["time"]       = { text = "Temps" },

		-- Results Screen
		["level-time"] = { text="Temps du Stage" },
		["final-time"] = { text="Temps Final" },

		-- Other
		["return"] = { text="Retourner" },

		-- Papi
		["bad-end-1"] = {
			text     = "Non... Je suis finie...",
			duration = 4
		},
		["broke-1"] = {
			text     = "Oh non, Je l'ai brisé...",
			duration = 2.5
		},
		["close-1"] = {
			text     = "Je me rapproche!",
			duration = 2.5
		},
		["close-2"] = {
			text     = "Presque rendue!",
			duration = 2
		},
		["complete-1"] = {
			text     = "Fiou! Je les ai tous délivrés à temps!",
			duration = 4
		},
		["complete-2"] = {
			text     = "Je vais être un citoyen en peu de temps!",
			duration = 2.5
		},
		["delivered-1"] = {
			text     = "Yé, Je l'ai déliveré!",
			duration = 3.5
		},
		["late-1"] = {
			text     = "Je veux pas être sacrifiée!",
			duration = 2.5
		},
		["thank-you"] = {
			text     = "Merci à vous d'avoir joué notre jeu!",
			duration = 5
		},

		-- Chief
		["chief-intro-1"] = {
			text     = "Bon, tu connais la routine! Livre les colis pendant encore une semaine et je vais graver ta tablette de citoyenneté.",
			duration = 7
		},
		["chief-intro-2"] = {
			text     = "Mais si tu échoue, tu seras le sacrifice de la prochaine moisson!",
			duration = 4
		},
		["chief-intro-3"] = {
			text     = "T'attends quoi? Vole petit oiseau!",
			duration = 3
		},
		["chief-incomplete-1"] = {
			text     = "Sors d'ici, t'as encore des colis à livrer!",
			duration = 3
		},
		["chief-complete-1"] = {
			text     = "Bonne job tête de moineau, tu t'en ai sortie.",
			duration = 2.5
		},
		["chief-complete-2"] = {
			text     = "Bon travail tête en plume, personne n'as porté plainte.",
			duration = 2.5
		},
		["chief-complete-strike-1"] = {
			text     = "J'ai reçu quelques plaintes pendant que tu étais sortie, as-tu quelquechose à me dire au sujet de ton goût?",
			duration = 3.5
		},
		["chief-complete-strike-2"] = {
			text     = "J'ai des chances de devoir garder ma fille si t'apprends pas à battre tes ailes plus vite.",
			duration = 4
		},
		["chief-complete-fail-1"] = {
			text     = "On avait un accord, tu l'as brisé.",
			duration = 3
		},
		["chief-complete-fail-2"] = {
			text     = "Je voulais pas devoir faire ça...",
			duration = 2.5
		},
		["chief-bad-end-1"] = {
			text     = "Puissent les Dieux accepter ce monstre au lieu de ma sixième fille...",
			duration = 4
		},
		["chief-good-end-1"] = {
			text     = "Et bien voilà, ta tablette officielle de citoyenneté. Bienvenue à la tribu de Dana!",
			duration = 5.5
		},

		-- Citizen
		["civ-happy-1"] = {
			text     = "Merci, c'est exactement ce que je voulais, et à temps! Cinq Sols!",
			duration = 5
		},
		["civ-happy-2"] = {
			text     = "Merci fille-oiseau, Je peux toujours compter sur toi! Continue comme ça et je vais pas te manger! Cinq Sols!",
			duration = 7
		},
		["civ-happy-3"] = {
			text     = "T'es buzzard, mais au moins tu as fais ton travail. Quatre Sols.",
			duration = 4.5
		},
		["civ-happy-4"] = {
			text     = "T'as l'air appétissante... Euh, m'enfin, merci! Quatre Sols!",
			duration = 5.5
		},
		["civ-happy-5"] = {
			text     = "T'es pas l'un des nôtres! Retourne dans la forêt! Trois Sols!",
			duration = 4.5
		},
		["civ-happy-6"] = {
			text     = "Donne-moi juste mon colis et vas-t'en espèce de monstre! Trois Sols!",
			duration = 5.5
		},
		["civ-late-1"] = {
			text     = "Ça me passe au-dessus de la tête comment ils ont pensés qu'une tête de moineau comme toi pourrais ne pas se tromper! Deux Sols.",
			duration = 4.5
		},
		["civ-late-2"] = {
			text     = "Pourquoi que je m'enbête à payer pour battement express! Un Sol!",
			duration = 4
		},
		["civ-late-3"] = {
			text     = "Si tu est encore en retard, Je vais faire un oreiller avec tes plumes! Un Sol!",
			duration = 5.5
		},
		["civ-broke-1"] = {
			text     = "Tu l'as brisé! J'espère que ton chef te sacrifira! Aucun Sol!",
			duration = 6
		},
		["civ-broke-2"] = {
			text     = "Espèce de Tête de moineau, c'est brisé! La prochaine fois que ça arrive je vais briser tes os! Aucun Sol!",
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
