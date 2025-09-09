/obj/item/choice_beacon/commando_support
	name = "support beacon"
	icon_state = "gangtool-red"
	desc = "A single use beacon to deliver a team support asset."
	company_source = "Gorlex Securities"
	company_message = span_bold("Supply Pod incoming, please stand back.")

/obj/item/choice_beacon/commando_support/generate_display_names()
	var/static/list/selectable_assets = list(
		"Elite Monkey Strike Team (Distraction/Sabotage)" = /obj/item/antag_spawner/loadout/monkey_crash,
		"Ricky's Mauler (Defensive)" = /obj/item/antag_spawner/loadout/monkey_man/ricky,
		"Syndicate Medical Cyborg (Support)" = /obj/item/antag_spawner/nuke_ops/borg_tele/medical,
		"Missile Targeter (Offensive)" = /obj/item/missile_targeter,
	)
	return selectable_assets

/obj/item/choice_beacon/commando_support/spawn_option(obj/choice_path, mob/living/user)
	podspawn(list(
		"target" = get_turf(src),
		"style" = STYLE_SYNDICATE,
		"spawn" = choice_path,
	))

