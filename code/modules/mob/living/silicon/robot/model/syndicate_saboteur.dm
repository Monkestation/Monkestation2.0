GENERATE_ROBOT_MODEL(syndicate_saboteur)

/datum/robot_model/syndicate_saboteur
	name = "Syndicate Saboteur"
	hud_icon_state = "malf"
	default_skin = /datum/robot_skin/syndicate_saboteur/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/borg/cyborg_omnitool/engineering/syndie,
		/obj/item/borg/cyborg_omnitool/engineering/syndie,
		/obj/item/storage/part_replacer/cyborg,
		/obj/item/borg/apparatus/circuit,
		/obj/item/analyzer,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/borg/apparatus/sheet_manipulator,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/dest_tagger/borg,
		/obj/item/stack/cable_coil,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/borg_chameleon,
		/obj/item/card/emag,
		/obj/item/borg/charger
	)
	traits = list(TRAIT_PUSHIMMUNE, TRAIT_NEGATES_GRAVITY, TRAIT_KNOW_ENGI_WIRES, TRAIT_KNOW_ROBO_WIRES, TRAIT_CAN_CLIMB_DISPOSALS)


/*
/datum/robot_model/syndicate_saboteur/rebuild_modules()
	..()
	var/mob/living/silicon/robot/cyborg = loc
	cyborg.faction -= FACTION_SILICON //ai turrets

/datum/robot_model/syndicate_saboteur/remove_module(obj/item/removed_module)
	..()
	var/mob/living/silicon/robot/cyborg = loc
	cyborg.faction |= FACTION_SILICON //ai is your bff now!
*/
