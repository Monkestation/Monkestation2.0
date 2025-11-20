//Right now it's a structure that works off of magic, as it'd require an internal power source for what its supposed to do
/obj/structure/liquid_pump
	name = "portable liquid pump"
	desc = "An industrial grade pump, capable of either siphoning or spewing liquids. Needs to be anchored first to work. Has a limited capacity internal storage."
	icon = 'monkestation/icons/obj/structures/liquid_pump.dmi'
	icon_state = "liquid_pump"
	base_icon_state = "liquid_pump"
	density = TRUE
	max_integrity = 500
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// How many reagents at maximum can it hold
	var/max_volume = 10000
	/// Whether spewing reagents out, instead of siphoning them
	var/spewing_mode = FALSE
	/// Whether its turned on and processing
	var/turned_on = FALSE
	/// How fast does the pump work, in percentages relative to the volume we're working with
	var/pump_speed_percentage = 0.4
	/// How fast does the pump work, in flat values. Flat values on top of percentages to help processing
	var/pump_speed_flat = 20

/obj/structure/liquid_pump/Initialize()
	. = ..()
	create_reagents(max_volume)

/obj/structure/liquid_pump/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(reagents)
	return ..()

/obj/structure/liquid_pump/wrench_act(mob/living/user, obj/item/wrench)
	. = ..()
	default_unfasten_wrench(user, wrench, 0.5 SECONDS)
	if(!anchored && turned_on)
		toggle_working()
	return ITEM_INTERACT_SUCCESS

/obj/structure/liquid_pump/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, span_warning("[src] needs to be anchored first!"))
		balloon_alert(user, "anchor it first!")
		return
	balloon_alert(user, "turned [turned_on ? "off" : "on"]")
	to_chat(user, span_notice("You turn [src] [turned_on ? "off" : "on"]."))
	toggle_working()

/obj/structure/liquid_pump/click_alt(mob/living/user)
	to_chat(user, span_notice("You flick [src]'s spewing mode [spewing_mode ? "off" : "on"]."))
	spewing_mode = !spewing_mode
	update_appearance(UPDATE_ICON_STATE)
	return CLICK_ACTION_SUCCESS

/obj/structure/liquid_pump/examine(mob/user)
	. = ..()
	. += span_notice("Its anchor bolts are [anchored ? "down and secured" : "up"].")
	. += span_notice("Its currently [turned_on ? "ON" : "OFF"].")
	. += span_notice("Its mode currently is set to [spewing_mode ? "SPEWING" : "SIPHONING"]. (Alt-click to switch)")
	. += span_notice("The pressure gauge shows [round(reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)]/[round(reagents.maximum_volume, CHEMICAL_VOLUME_ROUNDING)].")

/obj/structure/liquid_pump/process()
	if(!isturf(loc))
		return
	if(spewing_mode)
		spew()
	else
		suck()

/obj/structure/liquid_pump/proc/suck()
	if(!turned_on)
		return PROCESS_KILL
	var/free_space = round(reagents.maximum_volume - reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
	if(!free_space)
		return
	var/list/turfs_to_suck = list()
	for(var/turf/open/turf in range(1, loc))
		if(turf.liquids?.liquid_group?.total_reagent_volume)
			turfs_to_suck += turf
	var/turfs_amt = length(turfs_to_suck)
	if(!turfs_amt) // don't bother
		return
	var/delta_time = DELTA_WORLD_TIME(SSobj)
	var/pump_speed_percentage = src.pump_speed_percentage * delta_time
	var/pump_speed_flat = src.pump_speed_flat * delta_time
	for(var/turf/open/turf_to_suck as anything in turfs_to_suck)
		var/datum/liquid_group/turf_liquid_group = turf_to_suck.liquids?.liquid_group
		if(!turf_liquid_group?.total_reagent_volume)
			turfs_amt-- // turf must have lost liquid from us sucking up a different turf
			if(!turfs_amt) // no more turfs to succ, just stop
				return
			continue
		var/target_siphon_amt = min((turf_liquid_group.total_reagent_volume * (pump_speed_percentage / turfs_amt)) + (pump_speed_flat / turfs_amt), free_space)
		turf_liquid_group.trans_to_seperate_group(reagents, round(target_siphon_amt, CHEMICAL_VOLUME_ROUNDING))
		free_space = round(reagents.maximum_volume - reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
		if(!free_space)
			return

/obj/structure/liquid_pump/proc/spew()
	if(!reagents.total_volume)
		return
	var/turf/turf = loc
	var/datum/reagents/tempr = new(10000)
	var/target_amt = ((reagents.total_volume * pump_speed_percentage) + pump_speed_flat) * DELTA_WORLD_TIME(SSobj)
	reagents.trans_to(tempr, round(target_amt, CHEMICAL_VOLUME_ROUNDING), no_react = TRUE)
	turf.add_liquid_from_reagents(tempr)
	qdel(tempr)

/obj/structure/liquid_pump/update_icon_state()
	if(turned_on)
		if(spewing_mode)
			icon_state = "[base_icon_state]_spewing"
		else
			icon_state = "[base_icon_state]_siphoning"
	else
		icon_state = base_icon_state
	return ..()

/obj/structure/liquid_pump/proc/toggle_working()
	if(turned_on)
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)
	turned_on = !turned_on
	update_appearance(UPDATE_ICON_STATE)
