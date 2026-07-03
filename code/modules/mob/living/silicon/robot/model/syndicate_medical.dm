/datum/robot_model/syndicate/medical
	name = "Syndicate Medical"
	hud_icon_state = "malf"
	default_skin = /datum/robot_skin/syndicate_medical/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate/cyborg,
		/obj/item/healthanalyzer/cyborg,
		/obj/item/borg/cyborg_omnitool/medical/upgraded,
		/obj/item/borg/cyborg_omnitool/medical/upgraded,
		/obj/item/melee/energy/sword/cyborg/saw,
		/obj/item/blood_filter,
		/obj/item/emergency_bed/silicon,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/stack/medical/gauze,
		/obj/item/gun/medbeam,
		/obj/item/borg/apparatus/organ_storage
	)
	traits = list(TRAIT_PUSHIMMUNE)
