return {
	locale  = "it",
	quotes  = { "\"", "\"" },
	base    = "assets/audio/it",
	strings = {
		-- Main Menu
		["new-game"]      = { text = "Nuova Partita" },
		["new-game-plus"] = { text = "Nuova Partita +" },
		["continue-game"] = { text = "Continua" },
		["controls"]      = { text = "Controlli" },
		["options"]       = { text = "Opzioni" },
		["exit-game"]     = { text = "Esci" },

		-- Continue Menu
		["level-1"] = { text="Livello 1" },
		["level-2"] = { text="Livello 2" },
		["level-3"] = { text="Livello 3" },
		["level-4"] = { text="Livello 4" },
		["level-5"] = { text="Livello 5" },
		["level-6"] = { text="Livello 6" },
		["level-7"] = { text="Livello 7" },

		-- Controls Menu
		["control-forward"] = { text = "Avanti" },
		["control-up"]      = { text = "Sali" },
		["control-down"]    = { text = "Scendi" },
		["control-camera"]  = { text = "Muovi visuale" },
		["control-brake"]   = { text = "Freno" },
		["control-turbo"]   = { text = "Turbo" },
		["control-pause"]   = { text = "Pausa" },

		-- Options Menu
		["volume-up"]     = { text = "Volume +" },
		["volume-down"]   = { text = "Volume -" },
		["reset-options"] = { text = "Ripristina opzioni" },

		-- Gameplay UI
		["strikes"]    = { text = "Fallimenti" },
		["durability"] = { text = "Resistenza del pacco" },
		["time"]       = { text = "Tempo" },

		-- Results Screen
		["level-time"] = { text="Tempo (livello)" },
		["final-time"] = { text="Tempo (totale)" },

		-- Other
		["return"] = { text="Indietro" },

		-- Papi
		["bad-end-1"] = {
			text     = "No... È finita...",
			duration = 4
		},
		["broke-1"] = {
			text     = "Oh no, l'ho rotto...",
			duration = 2.5
		},
		["close-1"] = {
			text     = "Manca poco!",
			duration = 2.5
		},
		["close-2"] = {
			text     = "Ci sono quasi!",
			duration = 2
		},
		["complete-1"] = {
			text     = "Phew! Li ho consegnati tutti in tempo!",
			duration = 4
		},
		["complete-2"] = {
			text     = "Sarò una cittadina in men che non si dica!",
			duration = 2.5
		},
		["delivered-1"] = {
			text     = "Sì, l'ho consegnato!",
			duration = 3.5
		},
		["late-1"] = {
			text     = "Non voglio essere sacrificata!",
			duration = 2.5
		},
		["thank-you"] = {
			text     = "Grazie per aver giocato!",
			duration = 5
		},

		-- Chief
		["chief-intro-1"] = {
			text     = "Ok, sai come funziona! Consegna questi pacchi per una settimana e sarai parte della città.",
			duration = 7
		},
		["chief-intro-2"] = {
			text     = "Ma se fallirai, sarai il prossimo sacrificio per il raccolto!",
			duration = 4
		},
		["chief-intro-3"] = {
			text     = "Beh, che aspetti? Vola, uccellaccio!",
			duration = 3
		},
		["chief-incomplete-1"] = {
			text     = "Devi consegnare altri pacchi, fuori di qui!",
			duration = 3
		},
		["chief-complete-1"] = {
			text     = "Bel lavoro, uccellino, ce l'hai fatta.",
			duration = 2.5
		},
		["chief-complete-2"] = {
			text     = "Bel lavoro pulcino, nessuno si è lamentato.",
			duration = 2.5
		},
		["chief-complete-strike-1"] = {
			text     = "Ho ricevuto lamentele mentre consegnavi i pacchi... Mi chiedevo, che sapore hai?",
			duration = 3.5
		},
		["chief-complete-strike-2"] = {
			text     = "Potrei tenere mia figlia se non impari a sbattere quelle ali più in fretta.",
			duration = 4
		},
		["chief-complete-fail-1"] = {
			text     = "Avevamo un accordo e hai fallito.",
			duration = 3
		},
		["chief-complete-fail-2"] = {
			text     = "Non volevo arrivare a questo...",
			duration = 2.5
		},
		["chief-bad-end-1"] = {
			text     = "Che gli dei accettino questo mostro al posto della mia sesta figlia...",
			duration = 4
		},
		["chief-good-end-1"] = {
			text     = "Ecco a te, la tua ufficiale tavoletta di cittadinanza. Benvenuta nella tribù!",
			duration = 5.5
		},

		-- Citizen
		["civ-happy-1"] = {
			text     = "Grazie, proprio quello che volevo, giusto in tempo! 5 Sol!",
			duration = 5
		},
		["civ-happy-2"] = {
			text     = "Grazie uccellino, sei affidabilissima! Continua così e non ti mangerò! 5 Sol!",
			duration = 7
		},
		["civ-happy-3"] = {
			text     = "Sei una strana, ma almeno fai il tuo lavoro. 4 Sol.",
			duration = 4.5
		},
		["civ-happy-4"] = {
			text     = "Sembri saporita... uh, voglio dire, grazie! 4 Sol!",
			duration = 5.5
		},
		["civ-happy-5"] = {
			text     = "Non sei una di noi! Tornatene nella foresta! 3 Sol!",
			duration = 4.5
		},
		["civ-happy-6"] = {
			text     = "Dammi il mio pacco e vai via da qui, mostro! 3 Sol!",
			duration = 5.5
		},
		["civ-late-1"] = {
			text     = "Credevano che un uccellaccio come te ce l'avrebbe fatta? 2 Sol.",
			duration = 4.5
		},
		["civ-late-2"] = {
			text     = "Ma perché pago per il volo rapido! 1 Sol!",
			duration = 4
		},
		["civ-late-3"] = {
			text     = "Se arrivi di nuovo in ritardo, farò un cuscino con le tue piume! 1 Sol!",
			duration = 5.5
		},
		["civ-broke-1"] = {
			text     = "L'hai rotto! Spero che il capo ti sacrifichi! 0 Sol!",
			duration = 6
		},
		["civ-broke-2"] = {
			text     = "Brutto uccellaccio, è rotto! La prossima volta ti rompo le ossa! 0 Sol!",
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