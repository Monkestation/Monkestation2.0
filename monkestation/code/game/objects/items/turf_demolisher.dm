//simply an item that breaks turfs down
/obj/item/turf_demolisher
	name = "\improper Exprimental Demolisher"
	desc = "An exprimental able to quickly deconstruct any surface."
	icon = 'icons/obj/mining.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	icon_state = "jackhammer"
	inhand_icon_state = "jackhammer"
	///The balloon_alert() to send when we cannot demolish a turf
	var/unbreakable_alert = "Unable to demolish that."
	///List of turf types we are allowed to break, if unset then we can break any turfs that dont have the INDESTRUCTIBLE resistance flag
	var/list/allowed_types = list(/turf/closed/wall)
	///List of turf types we are NOT allowed to break
	var/list/blacklisted_types
	///How long is the do_after() to break a turf
	var/break_time = 8 SECONDS
	///Do we devastate broken walls, because of quality 7 year old code this always makes iron no matter the wall type
	var/devastate = TRUE
	///How long is our recharge time between uses
	var/recharge_time = 0
	///How long after our first turf broken do our resonances detonate
	var/resonance_delay = 5 SECONDS
	///How many tiles out from out demolished turf do we spawn resonances, set to 0 for no resonances
	var/resonance_range = 0
	COOLDOWN_DECLARE(recharge)

/obj/item/turf_demolisher/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isturf(target) || (user.istate & ISTATE_HARM))
		return

	if(!check_breakble(target, user))
		return

	if(try_demolish(target, user))
		return

/obj/item/turf_demolisher/proc/check_breakble(turf/attacked_turf, mob/living/user, silent = FALSE, ignore_cooldown = FALSE)
	if(recharge_time && !ignore_cooldown && !COOLDOWN_FINISHED(src, recharge))
		if(!silent)
			balloon_alert(user, "\The [src] is still recharging.")
		return FALSE

	if((allowed_types && !is_type_in_list(attacked_turf, allowed_types)) || is_type_in_list(attacked_turf, blacklisted_types) || (attacked_turf.resistance_flags & INDESTRUCTIBLE))
		if(unbreakable_alert && !silent)
			balloon_alert(user, unbreakable_alert)
		return FALSE
	return TRUE

/obj/item/turf_demolisher/proc/try_demolish(turf/attacked_turf, mob/living/user)
	if(!do_after(user, break_time, attacked_turf))
		return FALSE

	playsound(src, 'sound/weapons/sonic_jackhammer.ogg', 80, channel = CHANNEL_SOUND_EFFECTS, mixer_channel = CHANNEL_SOUND_EFFECTS)
	if(iswallturf(attacked_turf))
		var/turf/closed/wall/wall_turf = attacked_turf
		wall_turf.dismantle_wall(devastate)
	else
		attacked_turf.ScrapeAway()

	if(recharge_time)
		COOLDOWN_START(src, recharge, recharge_time)
	if(!resonance_range)
		return TRUE

	var/tiles_out = 0
	var/list/checked_turfs = list(attacked_turf)
	var/list/resonate_from = list(attacked_turf)
	while(tiles_out < resonance_range)
		tiles_out++
		for(var/turf/resonated_from in resonate_from)
			resonate_from -= resonated_from
			var/list/step_turfs = list(get_step(resonated_from, NORTH), get_step(resonated_from, SOUTH), get_step(resonated_from, EAST), get_step(resonated_from, WEST))
			for(var/turf/checked_turf in step_turfs)
				if(!(checked_turf in checked_turfs) && check_breakble(checked_turf, silent = TRUE, ignore_cooldown = TRUE))
					if(tiles_out < resonance_range)
						resonate_from += checked_turf
					new /obj/effect/temp_visual/turf_demolisher_resonance(checked_turf, resonance_delay, checked_turf)
				checked_turfs += checked_turf
	return TRUE

/obj/effect/temp_visual/turf_demolisher_resonance
	name = "resonance field"
	desc = "A resonating field that will destroy any nearby surface."
	icon_state = "shield2"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	duration = 5 SECONDS
	///The turf that we are on
	var/turf/holder_turf

/obj/effect/temp_visual/turf_demolisher_resonance/Initialize(mapload, _duration = 5 SECONDS, holder)
	duration = _duration
	holder_turf = holder || get_turf(src)
	. = ..()
	if(!holder_turf)
		return INITIALIZE_HINT_QDEL

	transform = matrix()*0.75
	animate(src, transform = matrix()*1.5, time = duration)
	RegisterSignal(holder_turf, COMSIG_ATOM_DESTRUCTION, PROC_REF(on_holder_destruction))

/obj/effect/temp_visual/turf_demolisher_resonance/Destroy()
	if(holder_turf)
		UnregisterSignal(holder_turf, COMSIG_ATOM_DESTRUCTION)
		collapse()
		holder_turf = null
	return ..()

/obj/effect/temp_visual/turf_demolisher_resonance/proc/on_holder_destruction()
	SIGNAL_HANDLER
	UnregisterSignal(holder_turf, COMSIG_ATOM_DESTRUCTION)
	holder_turf = null
	qdel(src)

/obj/effect/temp_visual/turf_demolisher_resonance/proc/collapse()
	new /obj/effect/temp_visual/resonance_crush(holder_turf)
	playsound(holder_turf, 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	if(iswallturf(holder_turf))
		var/turf/closed/wall/wall_turf = holder_turf
		wall_turf.dismantle_wall()
	else
		holder_turf.ScrapeAway()

/obj/item/turf_demolisher/reebe
	desc = "An exprimental able to quickly deconstruct any surface. This one seems to be calibrated to only work on reebe."
	break_time = 5 SECONDS
	recharge_time = 5 SECONDS
	resonance_delay = 5 SECONDS
	resonance_range = 2

/obj/item/turf_demolisher/reebe/check_breakble(turf/attacked_turf, mob/living/user, silent, ignore_cooldown)
	. = ..()
	if(!.)
		return

	var/turf/our_turf = get_turf(src)
	if(!on_reebe(our_turf))
		balloon_alert(user, "\The [src] is specially calibrated to be used on reebe and will not work here!")
		return FALSE

	if(GLOB.clock_ark && get_dist(our_turf, get_turf(GLOB.clock_ark)) <= ARK_TURF_DESTRUCTION_BLOCK_RANGE)
		balloon_alert(user, "A near by energy source is interfering \the [src]!")
		return FALSE
