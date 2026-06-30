GENERATE_ROBOT_MODEL(miner)

/datum/robot_model/miner
	name = "Miner"
	hud_icon_state = "miner"
	default_skin = /datum/robot_skin/miner/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/t_scanner/adv_mining_scanner/cyborg,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/shovel,
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon,
		/obj/item/borg/apparatus/organ_storage/monster
	)
	emagged_modules = list(
		/obj/item/borg/stun
	)
	radio_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)
	traits = list(TRAIT_NEGATES_GRAVITY)
	/// The weakref to the energy shield toggle action we own.
	var/datum/weakref/energy_shield_ref

/datum/robot_model/miner/Destroy()
	QDEL_NULL(energy_shield_ref)
	return ..()

/*
/obj/item/robot_model/miner/be_transformed_to(obj/item/robot_model/old_model, forced = FALSE)
	. = ..()
	if(!.)
		return
	var/datum/action/cooldown/borg_sight_vision/sight_vision_meson = new(loc)
	sight_vision_meson.Grant(loc)
	sight_vision_ref = WEAKREF(sight_vision_meson)
	var/datum/action/cooldown/cyborg_miner_shield/energy_shield_action = new(loc)
	energy_shield_action.Grant(loc)
	energy_shield_ref = WEAKREF(energy_shield_action)
*/
