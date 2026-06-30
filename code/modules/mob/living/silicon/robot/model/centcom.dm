GENERATE_ROBOT_MODEL(centcom)

/datum/robot_model/centcom
	name = "CentCom"
	default_skin = /datum/robot_skin/centcom/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/clipboard/cyborg,
		/obj/item/pen,
		/obj/item/pen/fountain,
		/obj/item/stamp/centcom,
		/obj/item/stamp/granted,
		/obj/item/stamp/denied,
		/obj/item/stamp/void,
		/obj/item/knife/kitchen/silicon,
		/obj/item/borg/apparatus/cooking,
		/obj/item/reagent_containers/cup/beaker/large,
		/obj/item/reagent_containers/condiment/enzyme,
		/obj/item/soap/deluxe/centcom/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/hand_labeler/borg,
		/obj/item/rsf/deluxe/cyborg,
		/obj/item/instrument/piano_synth,
		/obj/item/lighter,
		/obj/item/storage/bag/tray,
		/obj/item/reagent_containers/borghypo/borgshaker/centcom,
		/obj/item/borg/apparatus/beaker/service,
	)
	radio_channels = list(RADIO_CHANNEL_CENTCOM)


// TRAIT_CAN_CLIMB_DISPOSALS for syndicate sabo
