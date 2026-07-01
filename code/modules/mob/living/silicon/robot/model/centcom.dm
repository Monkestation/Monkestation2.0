/datum/robot_model/centcom
	name = "CentCom"
	default_skin = /datum/robot_skin/centcom/default
	available_skins = list(
		/datum/robot_skin/centcom/default,
		/datum/robot_skin/centcom/kerfus
	)
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
		/obj/item/borg/apparatus/beaker/service
	)
	radio_channels = list(RADIO_CHANNEL_CENTCOM)

/datum/robot_model/centcom/on_model_removed()
	qdel(cyborg_owner.GetComponent(/datum/component/personal_crafting/borg))
	for(var/atom/movable/screen/craft/button in cyborg_owner.hud_used.static_inventory)
		qdel(button)
	qdel(cyborg_owner.radio.keyslot)
	cyborg_owner.radio.recalculateChannels()
	cyborg_owner.emagged = FALSE
	cyborg_owner.centcom = FALSE

/datum/robot_model/centcom/on_model_given()
	cyborg_owner.AddComponent(/datum/component/personal_crafting/borg)
	var/datum/component/personal_crafting/borg/crafting = cyborg_owner.GetComponent(/datum/component/personal_crafting/borg)
	crafting.forced_mode = TRUE
	crafting.mode = TRUE
	if(cyborg_owner.client)
		crafting.create_mob_button(cyborg_owner, cyborg_owner.client)
	qdel(cyborg_owner.radio.keyslot)
	cyborg_owner.radio.keyslot = new /obj/item/encryptionkey/headset_cent()
	cyborg_owner.radio.recalculateChannels()
	// Remove all laws.
	if(!cyborg_owner.shell)
		cyborg_owner.set_connected_ai(null)
		cyborg_owner.clear_inherent_laws()
		cyborg_owner.clear_zeroth_law()
		cyborg_owner.clear_supplied_laws()
		cyborg_owner.clear_ion_laws()
		cyborg_owner.clear_hacked_laws()
	cyborg_owner.emagged = TRUE
	cyborg_owner.centcom = TRUE
