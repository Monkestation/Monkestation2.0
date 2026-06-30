GENERATE_ROBOT_MODEL(science)

/datum/robot_model/science
	name = "Science"
	hud_icon_state = "science"
	default_skin = /datum/robot_skin/science/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/borg/cyborg_omnitool/engineering,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/stack/cable_coil,
		/obj/item/storage/part_replacer/cyborg,
		/obj/item/experi_scanner,
		/obj/item/nanite_scanner, // Nanite remote not included because it is an upgrade.
		/obj/item/borg/apparatus/sheet_manipulator, // This is needed for material scans.
		/obj/item/borg/apparatus/circuit/science,
		/obj/item/analyzer,
		/obj/item/assembly/signaler, // Ordiance is an upgrade.
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper,
		/obj/item/borg/apparatus/organ_storage/limb, // They need to be able to hold limbs to hit artifacts with it.
		/obj/item/borg/artifact_sticker_holder,
		/obj/item/pen/fountain
	)
	emagged_modules = list(
		/obj/item/borg/handheld_jaunter
	)
	radio_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)
