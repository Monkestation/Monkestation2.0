
/datum/robot_model/medical
	name = "Medical"
	hud_icon_state = "medical"
	default_skin = /datum/robot_skin/medical/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer/cyborg,
		/obj/item/device/antibody_scanner,
		/obj/item/reagent_containers/borghypo/medical,
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/borg/cyborg_omnitool/medical,
		/obj/item/borg/cyborg_omnitool/medical,
		/obj/item/blood_filter,
		/obj/item/extinguisher/mini,
		/obj/item/emergency_bed/silicon,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze,
		/obj/item/stack/medical/bone_gel,
		/obj/item/borg/apparatus/organ_storage,
		/obj/item/borg/lollipop,
		/obj/item/holosign_creator/medical/treatment_zone
	)
	emagged_modules = list(
		/obj/item/reagent_containers/borghypo/medical/hacked
	)
	radio_channels = list(RADIO_CHANNEL_MEDICAL)
	traits = list(TRAIT_PUSHIMMUNE)
