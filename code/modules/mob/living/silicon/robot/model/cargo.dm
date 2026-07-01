/datum/robot_model/cargo
	name = "cargo"
	hud_icon_state = "cargo"
	default_skin = /datum/robot_skin/cargo/default
	basic_modules = list(
		/obj/item/stamp,
		/obj/item/stamp/denied,
		/obj/item/pen/cyborg,
		/obj/item/clipboard/cyborg,
		/obj/item/stack/package_wrap/cyborg,
		/obj/item/stack/wrapping_paper/xmas/cyborg,
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/hydraulic_clamp,
		/obj/item/borg/hydraulic_clamp/mail,
		/obj/item/storage/bag/mail_token_catcher,
		/obj/item/hand_labeler/cyborg,
		/obj/item/dest_tagger,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher,
		/obj/item/universal_scanner,
		/obj/item/cargo_teleporter,
		/obj/item/boxcutter
	)
	emagged_modules = list(
		/obj/item/stamp/chameleon,
		/obj/item/borg/paperplane_crossbow,
	)
	radio_channels = list(RADIO_CHANNEL_SUPPLY)
