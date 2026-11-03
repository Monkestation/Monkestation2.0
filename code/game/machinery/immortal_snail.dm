/// One offer, one victim. The machine never accepts deposits or pays out twice.
/obj/machinery/computer/slot_machine/immortal_snail
	desc = "A slot machine with a single, unblinking eye on its screen. Something about it feels terribly wrong."
	icon = 'icons/obj/immortal_snail_slot_machine.dmi'
	icon_state = "cursed_slots"
	icon_screen = "slots_screen"
	circuit = null
	var/offer = 100000
	var/claimed = FALSE

/obj/machinery/computer/slot_machine/immortal_snail/update_icon_state()
	. = ..()
	icon_state = "cursed_slots"

/obj/machinery/computer/slot_machine/immortal_snail/ui_interact(mob/living/user, datum/tgui/ui)
	. = ..()
	if(claimed || !ishuman(user) || user.stat != CONSCIOUS)
		return
	var/answer = tgui_alert(user, "Take [offer] credits? An immortal snail will pursue you until you die, even if you drop the money. Touching it is fatal. If it catches you with at least [offer] credits in cash and your bank account, you will die and be husked. Otherwise, your body and organs will be destroyed. After your death, it reclaims every cursed credit: anyone carrying them will die unless they drop them first. Spending cursed credits or sending them somewhere unrecoverable marks the spender for death.", "An offer you can refuse", list("Leave", "Accept"))
	if(answer != "Accept" || QDELETED(src) || claimed || QDELETED(user) || user.stat != CONSCIOUS || !user.can_interact_with(src))
		return
	claimed = TRUE
	var/mob/living/basic/immortal_snail/snail = new(get_turf(src))
	snail.bind_target(user, offer)
	var/obj/item/holochip/prize = new(drop_location(), offer)
	GLOB.snail_debt = new(get_turf(src))
	GLOB.snail_debt.mark(prize, offer)
	user.put_in_hands(prize)
	log_game("[key_name(user)] accepted [offer] credits from the immortal snail slot machine at [AREACOORD(src)].")
	to_chat(user, span_userdanger("The deal is sealed. It knows where you are."))

/obj/machinery/computer/slot_machine/immortal_snail/attackby(obj/item/inserted, mob/living/user, params)
	balloon_alert(user, "no deposits accepted")
	return TRUE

/obj/machinery/computer/slot_machine/immortal_snail/multitool_act(mob/living/user, obj/item/tool)
	return NONE

/// A pursuer, not a combat AI: attacks never distract it from its contract.
/mob/living/basic/immortal_snail
	name = "immortal snail"
	desc = "A small snail leaving a glistening trail of slime. Do not touch it."
	icon = 'icons/mob/simple/immortal_snail.dmi'
	icon_state = "snail"
	icon_living = "snail"
	density = FALSE
	movement_type = FLYING
	maxHealth = INFINITY
	health = INFINITY
	status_flags = NONE
	mob_size = MOB_SIZE_SMALL
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	ai_controller = null
	gold_core_spawnable = NO_SPAWN
	var/datum/weakref/target_ref
	var/datum/weakref/target_mind_ref
	/// Keep the original account; borrowing someone else's ID does not satisfy the contract.
	var/datum/weakref/account_ref
	var/contract_value = 0
	var/next_step = 0
	var/pursuing = FALSE
	var/list/route = list()
	var/turf/route_destination
	var/original_dead = FALSE
	var/curse_fulfilled = FALSE

/mob/living/basic/immortal_snail/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_GODMODE, TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_NO_SLIP_ALL, TRAIT_SPACEWALK), INNATE_TRAIT)
	AddElement(/datum/element/snailcrawl)
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, connections)
	RegisterSignal(src, COMSIG_PREQDELETED, PROC_REF(prevent_premature_deletion))
	START_PROCESSING(SSprocessing, src)

/mob/living/basic/immortal_snail/proc/prevent_premature_deletion(datum/source, force)
	SIGNAL_HANDLER
	return contract_value && !curse_fulfilled && !force

/mob/living/basic/immortal_snail/Destroy(force)
	if(contract_value && !curse_fulfilled && !force)
		return QDEL_HINT_LETMELIVE
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(GLOB.snail_debt)
	target_ref = null
	target_mind_ref = null
	account_ref = null
	return ..()

/mob/living/basic/immortal_snail/death(gibbed)
	return FALSE

/mob/living/basic/immortal_snail/gib(no_brain, no_organs, no_bodyparts, safe_gib = TRUE)
	return

/mob/living/basic/immortal_snail/dust(just_ash, drop_items, force)
	return

/mob/living/basic/immortal_snail/ex_act(severity, target, origin)
	return

/mob/living/basic/immortal_snail/proc/bind_target(mob/living/target, amount)
	target_ref = WEAKREF(target)
	if(target.mind)
		target_mind_ref = WEAKREF(target.mind)
	var/datum/bank_account/account = target.get_bank_account()
	if(account)
		account_ref = WEAKREF(account)
	contract_value = amount
	// Give the victim time to leave the machine before the first step.
	next_step = world.time + 10 SECONDS

/mob/living/basic/immortal_snail/proc/original_target()
	var/datum/mind/target_mind = target_mind_ref?.resolve()
	if(isliving(target_mind?.current))
		return target_mind.current
	return target_ref?.resolve()

/mob/living/basic/immortal_snail/process(seconds_per_tick)
	if(pursuing || world.time < next_step)
		return
	GLOB.snail_debt?.refresh_carriers()
	var/mob/living/target = original_target()
	if(!target || target.stat == DEAD)
		original_dead = TRUE
	if(original_dead)
		var/datum/claim = GLOB.snail_debt?.next_claim()
		if(!claim)
			curse_fulfilled = TRUE
			qdel(src)
			return PROCESS_KILL
		var/atom/money_location = GLOB.snail_debt.location_of(claim)
		if(get_turf(money_location) == get_turf(src))
			var/mob/living/carrier = GLOB.snail_debt.carrier_of(claim)
			if(carrier)
				contact(carrier)
			GLOB.snail_debt.collect(claim)
			return
		next_step = world.time + 3 SECONDS
		pursuing = TRUE
		INVOKE_ASYNC(src, PROC_REF(pursue), money_location)
		return
	next_step = world.time + 3 SECONDS
	pursuing = TRUE
	INVOKE_ASYNC(src, PROC_REF(pursue), target)

/mob/living/basic/immortal_snail/proc/pursue(atom/target)
	var/turf/destination = get_turf(target)
	if(!destination)
		pursuing = FALSE
		return
	if(z != destination.z)
		// Reappear well away from the victim, including on space turfs.
		var/list/arrivals = list()
		for(var/turf/possible in orange(15, destination))
			if(!possible.density && get_dist(possible, destination) >= 10)
				arrivals += possible
		if(length(arrivals))
			forceMove(pick(arrivals))
			route.Cut()
		pursuing = FALSE
		return
	if(get_turf(src) == destination)
		if(isliving(target))
			contact(target)
		pursuing = FALSE
		return
	if(!length(route) || route_destination != destination)
		// JPS's scan loops still compare against the limit when zero is supplied.
		route = get_path_to(src, destination, max_distance = world.maxx * world.maxy, simulated_only = FALSE)
		route_destination = destination
	if(QDELETED(src))
		return
	if(QDELETED(target) || get_turf(target) != destination)
		route.Cut()
		pursuing = FALSE
		return
	// Prefer a real route around obstacles. If sealed in, chew toward the target
	// one tile at a time until the pathfinder can find a route again.
	var/fallback_direction = get_dir(src, destination)
	if(ISDIAGONALDIR(fallback_direction))
		fallback_direction &= EAST|WEST
	var/turf/next = length(route) ? route[1] : get_step(src, fallback_direction)
	if(istype(next, /turf/closed/wall))
		var/step_direction = get_dir(src, next)
		var/turf/closed/wall/wall = next
		wall.dismantle_wall(devastated = TRUE)
		next = get_step(src, step_direction)
	else if(isclosedturf(next))
		// Even reinforced mineral or indestructible map turfs cannot imprison it.
		next = next.ChangeTurf(/turf/open/floor/plating)
	if(next)
		for(var/obj/obstacle in next)
			if(!obstacle.density)
				continue
			obstacle.take_damage(1000, BRUTE, MELEE, sound_effect = TRUE)
			if(!QDELETED(obstacle) && obstacle.density)
				qdel(obstacle)
		if(!next.density)
			step_towards(src, next)
		if(get_turf(src) == next && length(route))
			route.Cut(1, 2)
		else
			route.Cut()
	pursuing = FALSE

/mob/living/basic/immortal_snail/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	for(var/mob/living/victim in loc)
		if(victim != src)
			contact(victim)

/mob/living/basic/immortal_snail/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(isliving(entered) && entered != src)
		INVOKE_ASYNC(src, PROC_REF(contact), entered)

/mob/living/basic/immortal_snail/attack_hand(mob/living/carbon/human/user, list/modifiers)
	contact(user)
	return TRUE

/mob/living/basic/immortal_snail/attack_paw(mob/living/user, list/modifiers)
	contact(user)
	return TRUE

/mob/living/basic/immortal_snail/proc/available_credits(mob/living/victim)
	var/datum/bank_account/account = account_ref?.resolve()
	var/total = account ? account.account_balance : 0
	for(var/obj/item/item in victim.get_all_contents())
		if(istype(item, /obj/item/holochip) || istype(item, /obj/item/stack/spacecash) || istype(item, /obj/item/coin))
			total += item.get_item_credit_value()
	return total

/mob/living/basic/immortal_snail/proc/contact(mob/living/victim)
	if(QDELETED(victim) || victim == src || victim.stat == DEAD)
		return
	log_combat(src, victim, "killed by contact")
	var/is_target = victim == original_target()
	if(is_target && available_credits(victim) < contract_value)
		ADD_TRAIT(victim, TRAIT_NO_SPECIAL_REVIVAL, REF(src))
		victim.gib(no_brain = TRUE, no_organs = TRUE, no_bodyparts = TRUE)
	else
		victim.death()
		if(is_target && iscarbon(victim))
			var/mob/living/carbon/carbon_victim = victim
			carbon_victim.become_husk(REF(src))
	if(is_target)
		original_dead = TRUE
