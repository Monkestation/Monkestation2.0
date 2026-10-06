/obj/item/robot_model/ninja/saboteur
	name = "Ninja Saboteur"
	hud_icon_state = "ninja"
	default_skin = /datum/robot_skin/ninja_saboteur/default
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
		/obj/item/borg_chameleon,
		/obj/item/card/emag,
		/obj/item/borg/charger,
	)
	traits = list(TRAIT_PUSHIMMUNE, TRAIT_NEGATES_GRAVITY, TRAIT_KNOW_ENGI_WIRES, TRAIT_KNOW_ROBO_WIRES, TRAIT_CAN_CLIMB_DISPOSALS)

/obj/item/robot_model/ninja/saboteur/Initialize(mapload)
	. = ..()
	if(!cyborg_owner)
		return
	var/datum/action/cooldown/borg_sight_vision/thermal/sight_vision_thermal = new(cyborg_owner)
	sight_vision_thermal.Grant(cyborg_owner)
	sight_vision_ref = WEAKREF(sight_vision_thermal)
