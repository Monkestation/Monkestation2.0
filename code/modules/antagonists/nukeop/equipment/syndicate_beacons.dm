/obj/item/choice_beacon/commando_support
	name = "support beacon"
	icon_state = "gangtool-red"
	desc = "A single use beacon to deliver a team support asset."
	company_source = "Gorlex Securities"
	company_message = span_bold("Supply Pod incoming, please stand back.")

/obj/item/choice_beacon/commando_support/generate_display_names()
	var/static/list/selectable_assets = list(
		"Elite Monkey Strike Team" = /obj/item/antag_spawner/loadout/monkey_crash,
		"Ricky's Mauler" = /obj/item/antag_spawner/loadout/monkey_man/ricky,
		"Syndicate Cyborg Support Pack (Saboteur & Medical)" = /obj/item/storage/box/syndie_kit/cyborg_pack,
	)
	return selectable_assets

/obj/item/choice_beacon/commando_support/spawn_option(obj/choice_path, mob/living/user)
	podspawn(list(
		"target" = get_turf(src),
		"style" = STYLE_SYNDICATE,
		"spawn" = choice_path,
	))

/obj/item/storage/box/syndie_kit/cyborg_pack/PopulateContents()
	new /obj/item/antag_spawner/nuke_ops/borg_tele/medical(src)
	new /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur(src)
