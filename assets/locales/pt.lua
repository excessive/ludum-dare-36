return {
	locale  = "pt",
	quotes  = { "\"", "\"" },
	base    = "assets/audio/pt",
	strings = {
		-- Main Menu
		["new-game"]      = { text = "Novo Jogo" },
		["new-game-plus"] = { text = "Novo Jogo +" },
		["continue-game"] = { text = "Continuar Jgo" },
		["controls"]      = { text = "Controlos" },
		["options"]       = { text = "Opções" },
		["exit-game"]     = { text = "Sair" },

		-- Continue Menu
		["level-1"] = { text="Nível 1" },
		["level-2"] = { text="Nível 2" },
		["level-3"] = { text="Nível 3" },
		["level-4"] = { text="Nível 4" },
		["level-5"] = { text="Nível 5" },
		["level-6"] = { text="Nível 6" },
		["level-7"] = { text="Nível 7" },

		-- Controls Menu
		["control-forward"] = { text = "Avançar" },
		["control-up"]      = { text = "Voar" },
		["control-down"]    = { text = "Recuar" },
		["control-camera"]  = { text = "Mover a Camera" },
		["control-brake"]   = { text = "Travar" },
		["control-turbo"]   = { text = "Turbo" },
		["control-pause"]   = { text = "Pausar" },

		-- Options Menu
		["volume-up"]     = { text = "Volume +" },
		["volume-down"]   = { text = "Volume -" },
		["reset-options"] = { text = "Resetar as Opções" },

		-- Gameplay UI
		["strikes"]    = { text = "Strikes" },
		["durability"] = { text = "Durabilidade do Pacote" },
		["time"]       = { text = "Tempo" },

		-- Results Screen
		["level-time"] = { text="Tempo do Nível" },
		["final-time"] = { text="Tempo Final" },

		-- Other
		["return"] = { text="Voltar" },

		-- Papi
		["bad-end-1"] = {
			text     = "Um dia... um dia...",
			duration = 4
		},
		["broke-1"] = {
			text     = "Oh não, estraguei-o...",
			duration = 2.5
		},
		["close-1"] = {
			text     = "Estou a ficar perto!",
			duration = 2.5
		},
		["close-2"] = {
			text     = "Quase lá!",
			duration = 2
		},
		["complete-1"] = {
			text     = "Phew! Entreguei-as todas a tempo!",
			duration = 4
		},
		["complete-2"] = {
			text     = "A este ritmo, vou-me tornar uma cidadã num piscar de olhos!",
			duration = 2.5
		},
		["delivered-1"] = {
			text     = "Yay, entreguei-o!",
			duration = 3.5
		},
		["late-1"] = {
			text     = "Não quero ser sacrificada!",
			duration = 2.5
		},
		["thank-you"] = {
			text     = "Obrigado por jogar o nosso jogo! <3",
			duration = 5
		},

		-- Chief
		["chief-intro-1"] = {
			text     = "Ok, já sabes como é. Entrega as encomendas por mais uma semana e eu irei esculpir o teu passaporte.",
			duration = 7
		},
		["chief-intro-2"] = {
			text     = "Mas se falhares, irás ser sacrificada durante as colheiras!",
			duration = 4
		},
		["chief-intro-3"] = {
			text     = "Estás à espera de quê? Voa rapariga, voa!",
			duration = 3
		},
		["chief-incomplete-1"] = {
			text     = "Ainda te sobram encomendas, vai lá!",
			duration = 3
		},
		["chief-complete-1"] = {
			text     = "Bom trabalho cabeça na lua, conseguiste.",
			duration = 2.5
		},
		["chief-complete-2"] = {
			text     = "Bom trabalho semi-pássaro, ninguém se queixou.",
			duration = 2.5
		},
		["chief-complete-strike-1"] = {
			text     = "Recebi algumas queixas enquanto estiveste fora. Importas de dizer-me o que aconteceu? Andaste a perseguir minhocas, foi?",
			duration = 3.5
		},
		["chief-complete-strike-2"] = {
			text     = "Posso ter de ficar com uma filha se não aprenderes a dar às asas!",
			duration = 4
		},
		["chief-complete-fail-1"] = {
			text     = "Tinhamos um acordo, e tu não o cumpriste.",
			duration = 3
		},
		["chief-complete-fail-2"] = {
			text     = "Não queria ter de fazer isto...",
			duration = 2.5
		},
		["chief-bad-end-1"] = {
			text     = "Que os deuses aceitem este monstro em vez da minha sexta filha!",
			duration = 4
		},
		["chief-good-end-1"] = {
			text     = "Aqui tens, o teu passaporte oficial. Bem-vinda à tribo!",
			duration = 5.5
		},

		-- Citizen
		["civ-happy-1"] = {
			text     = "Obrigado, era mesmo isto que eu queria! 5 Sols!",
			duration = 5
		},
		["civ-happy-2"] = {
			text     = "Obrigado páss-- rapariga! Posso sempre confiar em ti! Continua assim e eu não te como! 5 Sols!",
			duration = 7
		},
		["civ-happy-3"] = {
			text     = "És esquisita, mas ao menos cumpriste a tua função. 4 Sols.",
			duration = 4.5
		},
		["civ-happy-4"] = {
			text     = "Pareces delicios-- quer dizer, obrigado! 4 Sols!",
			duration = 5.5
		},
		["civ-happy-5"] = {
			text     = "Não és um de nós! Volta para a floresta! 3 Sols!",
			duration = 4.5
		},
		["civ-happy-6"] = {
			text     = "Dá-me o raio da minha encomenda e põe-te a andar, seu monstro! 3 Sols!",
			duration = 5.5
		},
		["civ-late-1"] = {
			text     = "Como raio é que eles pensaram que um monte de penas como tu conseguia fazer isto bem? 2 Sols.",
			duration = 4.5
		},
		["civ-late-2"] = {
			text     = "Porque raio é que eu ainda pago para enviarem o correio pelo ar?! 1 Sol!",
			duration = 4
		},
		["civ-late-3"] = {
			text     = "Se te atrasas, faço-te numa almofada! 1 Sol!",
			duration = 5.5
		},
		["civ-broke-1"] = {
			text     = "Arruinaste-a! Espero que te matem durante as colheitas! 0 Sols!",
			duration = 6
		},
		["civ-broke-2"] = {
			text     = "Sua desgraça com penas, arruinaste-a! Para a próxima arranco-te as penas todas! 0 Sols!",
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