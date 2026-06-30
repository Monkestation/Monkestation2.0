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

/obj/item/robot_model/saboteur/operative
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/borg/cyborg_omnitool/engineering/syndie,
		/obj/item/borg/cyborg_omnitool/engineering/syndie,
		/obj/item/analyzer,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/borg/apparatus/sheet_manipulator,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/holosign_creator/atmos,
		/obj/item/dest_tagger/borg,
		/obj/item/stack/cable_coil,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/pinpointer/operative_cyborg,
		/obj/item/borg_chameleon,
		/obj/item/card/emag,
		/obj/item/borg/stun
	)

/obj/item/pinpointer/operative_cyborg
	name = "cyborg syndicate pinpointer"
	desc = "An integrated tracking device, jury-rigged to search for living assault operatives."
	flags_1 = NONE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/pinpointer/operative_cyborg/cyborg_unequip(mob/user)
	if(!active)
		return
	toggle_on()

/obj/item/pinpointer/operative_cyborg/scan_for_target()
	target = null
	var/list/possible_targets = list()
	var/turf/here = get_turf(src)
	for(var/V in get_antag_minds(/datum/antagonist/assault_operative))
		var/datum/mind/M = V
		if(ishuman(M.current) && M.current.stat != DEAD)
			possible_targets |= M.current
	var/mob/living/closest_operative = get_closest_atom(/mob/living/carbon/human, possible_targets, here)
	if(closest_operative)
		target = closest_operative
	..()

