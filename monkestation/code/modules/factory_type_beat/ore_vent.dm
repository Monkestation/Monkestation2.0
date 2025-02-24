/obj/structure/ore_vent
	name = "ore vent"
	desc = "An ore vent, brimming with underground ore. Scan with an advanced mining scanner to start extracting ore from it."
	icon = 'monkestation/code/modules/factory_type_beat/icons/terrain.dmi'
	icon_state = "ore_vent"
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //This thing will take a beating.
	anchored = TRUE
	density = TRUE

	/// Has this vent been tapped to produce boulders? Cannot be untapped.
	var/tapped = FALSE
	/// Has this vent been scanned by a mining scanner? Cannot be scanned again. Adds ores to the vent's description.
	var/discovered = FALSE

	/// What string do we use to warn the player about the excavation event?
	var/excavation_warning = "Are you ready to excavate this ore vent?"
	///What items can be used to scan a vent?
	var/static/list/scanning_equipment = list(
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/mining_scanner,
	)

	/// We use a cooldown to prevent the wave defense from being started multiple times.
	COOLDOWN_DECLARE(wave_cooldown)

/obj/structure/ore_vent/Initialize(mapload)
	return ..()

/obj/structure/ore_vent/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(.)
		return TRUE
	if(!is_type_in_list(attacking_item, scanning_equipment))
		return TRUE
	if(tapped)
		balloon_alert_to_viewers("vent tapped!")
		return TRUE
	scan_and_confirm(user)
	return TRUE

/**
 * Called when the ore vent is tapped by a scanning device.
 * Gives a readout of the ores available in the vent that gets added to the description,
 * then asks the user if they want to start wave defense if it's already been discovered.
 * @params user The user who tapped the vent.
 * @params scan_only If TRUE, the vent will only scan, and not prompt to start wave defense. Used by the mech mineral scanner.
 */
/obj/structure/ore_vent/proc/scan_and_confirm(mob/living/user, scan_only = FALSE)
	if(tapped)
		balloon_alert_to_viewers("vent already tapped!")
		return
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		balloon_alert_to_viewers("protect the node drone!")
		return
	if(!discovered)
		if(DOING_INTERACTION_WITH_TARGET(user, src))
			balloon_alert(user, "already scanning!")
			return
		balloon_alert(user, "scanning...")
		playsound(src, 'sound/items/timer.ogg', 30, TRUE)
		if(!do_after(user, 4 SECONDS) && !discovered) // Prevent multiple scan rewards
			return
		discovered = TRUE
		balloon_alert(user, "vent scanned!")
		//generate_description(user)
		var/obj/item/card/id/user_id_card = user.get_idcard(TRUE)
		if(isnull(user_id_card))
			return
		user_id_card.registered_account.mining_points += (MINER_POINT_MULTIPLIER)
		user_id_card.registered_account.bank_card_talk("You've been awarded [MINER_POINT_MULTIPLIER] mining points for discovery of an ore vent.")
		return

	if(scan_only) //Placed here to allow rewards
		return
	if(tgui_alert(user, excavation_warning, "Begin defending ore vent?", list("Yes", "No")) != "Yes")
		return
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		return
	//start_wave_defense()

/obj/structure/ore_vent/random

/obj/structure/ore_vent/random/icebox //The one that shows up on the top level of icebox

/obj/structure/ore_vent/random/icebox/lower

/obj/structure/ore_vent/boss

/obj/structure/ore_vent/boss/icebox
