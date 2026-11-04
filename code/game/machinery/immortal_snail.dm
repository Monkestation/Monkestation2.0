/// One offer, one victim. The machine never accepts deposits or pays out twice.
/obj/machinery/computer/slot_machine/immortal_snail
	desc = "A slot machine with a single, unblinking eye on its screen. Something about it feels terribly wrong."
	icon = 'icons/obj/immortal_snail_slot_machine.dmi'
	icon_state = "cursed_slots"
	icon_screen = "slots_screen"
	circuit = null
	var/offer = 100000
	var/claimed = FALSE
	var/minimum_spawn_distance = 20
	var/maximum_spawn_distance = 35

/obj/machinery/computer/slot_machine/immortal_snail/update_icon_state()
	. = ..()
	icon_state = "cursed_slots"

/obj/machinery/computer/slot_machine/immortal_snail/open_slot_ui(mob/living/user, datum/tgui/ui)
	if(claimed || !ishuman(user) || user.stat != CONSCIOUS)
		return
	var/answer = tgui_alert(user, "The screen flickers: [offer] cursed credits. Take them, and an immortal snail will hunt you until you die. Its touch is death. Accept the curse?", "An offer you can refuse", list("Leave", "Accept"))
	if(answer != "Accept" || QDELETED(src) || claimed || QDELETED(user) || user.stat != CONSCIOUS || !user.can_interact_with(src))
		return
	claim_offer(user)

/obj/machinery/computer/slot_machine/immortal_snail/proc/claim_offer(mob/living/user)
	if(claimed || GLOB.snail_debt || QDELETED(user) || !ishuman(user) || user.stat != CONSCIOUS || !user.can_interact_with(src))
		return FALSE
	var/turf/spawn_turf = find_snail_spawn(user)
	if(!spawn_turf)
		balloon_alert(user, "the offer is unavailable")
		return FALSE
	claimed = TRUE
	GLOB.snail_debt = new(get_turf(src))
	var/mob/living/basic/immortal_snail/snail = new(spawn_turf)
	snail.bind_target(user, offer)
	var/obj/item/holochip/prize = new(drop_location(), offer)
	GLOB.snail_debt.mark(prize, offer)
	new /datum/immortal_snail_curse(snail)
	user.put_in_hands(prize)
	log_game("[key_name(user)] accepted [offer] credits from the immortal snail slot machine at [AREACOORD(src)]. Snail spawned at [AREACOORD(snail)], [get_dist(snail, user)] tiles from its target.")
	log_admin("[key_name(user)] accepted the immortal snail curse for [offer] credits at [AREACOORD(src)]. Pursuer: [AREACOORD(snail)].")
	to_chat(user, span_userdanger("The deal is sealed. Somewhere far away, something starts moving toward you."))
	new /obj/effect/temp_visual/small_smoke(get_turf(src))
	var/obj/machinery/computer/slot_machine/replacement = new(get_turf(src))
	replacement.setDir(dir)
	qdel(src)
	return TRUE

/obj/machinery/computer/slot_machine/immortal_snail/proc/find_snail_spawn(mob/living/target)
	var/turf/machine_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if(!machine_turf || !target_turf || machine_turf.z != target_turf.z)
		return null
	var/list/candidates = list()
	for(var/turf/open/floor/candidate in orange(maximum_spawn_distance, machine_turf))
		if(candidate.density || get_dist(candidate, machine_turf) < minimum_spawn_distance || get_dist(candidate, target_turf) < minimum_spawn_distance)
			continue
		if(locate(/mob/living) in candidate)
			continue
		var/blocked = FALSE
		for(var/obj/obstacle in candidate)
			if(obstacle.density)
				blocked = TRUE
				break
		if(!blocked)
			candidates += candidate
	return length(candidates) ? pick(candidates) : null

/obj/machinery/computer/slot_machine/immortal_snail/attackby(obj/item/inserted, mob/living/user, params)
	balloon_alert(user, "no deposits accepted")
	return TRUE

/obj/machinery/computer/slot_machine/immortal_snail/multitool_act(mob/living/user, obj/item/tool)
	return NONE

/// A pursuer, not a combat AI: attacks never distract it from its contract.
/datum/antagonist/immortal_snail
	name = "Immortal Snail"
	antagpanel_category = ANTAG_GROUP_HORRORS
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	show_in_roundend = FALSE
	count_against_dynamic_roll_chance = FALSE
	prevent_roundtype_conversion = FALSE
	replace_banned = FALSE
	silent = TRUE
	antag_flags = FLAG_ANTAG_CAP_IGNORE_HUMANITY

/mob/living/basic/immortal_snail
	name = "immortal snail"
	desc = "A small snail leaving a glistening trail of slime. Do not touch it."
	icon = 'icons/mob/simple/immortal_snail.dmi'
	icon_state = "snail"
	icon_living = "snail"
	density = FALSE
	movement_type = FLYING
	pass_flags = PASSDOORS
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
	/// Time spent visibly gliding across one tile, rather than waiting then hopping.
	var/move_interval = 2.2 SECONDS
	var/zero_gravity_move_interval = 1.8 SECONDS
	/// Only the three most recently vacated tiles retain cursed slime.
	var/list/slime_trail = list()
	var/pursuing = FALSE
	var/route_pending = FALSE
	var/next_route_refresh = 0
	var/list/route = list()
	/// Owned searches are cancelled on deletion, waking any waiting pursuit procs.
	var/list/pending_paths = list()
	var/turf/route_destination
	var/original_dead = FALSE
	var/original_settled = FALSE
	var/datum/weakref/corpse_ref
	var/curse_fulfilled = FALSE
	var/datum/weakref/chemical_target
	var/chemical_started = 0
	var/next_chemical_dose = 0
	var/chemical_escalated = FALSE
	var/datum/immortal_snail_pursuit/pursuit_driver
	var/datum/snail_debt/debt
	var/datum/immortal_snail_curse/curse

/mob/living/basic/immortal_snail/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/small_smoke/halfsecond(get_turf(src))
	add_traits(list(TRAIT_GODMODE, TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_NO_SLIP_ALL, TRAIT_SPACEWALK), INNATE_TRAIT)
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, connections)
	RegisterSignal(src, COMSIG_PREQDELETED, PROC_REF(prevent_premature_deletion))
	// Living mobs already use DF_ISPROCESSING for their life subsystem.
	// A separate datum owns the fast movement registration.
	pursuit_driver = new(src)
	mind_initialize()
	mind.add_antag_datum(/datum/antagonist/immortal_snail)
	if(!mapload)
		notify_ghosts(
			"An immortal snail has appeared. A cursed bargain has been struck.",
			source = src,
			action = NOTIFY_ORBIT,
			header = "Immortal Snail",
		)

/mob/living/basic/immortal_snail/proc/prevent_premature_deletion(datum/source, force)
	SIGNAL_HANDLER
	return contract_value && !curse_fulfilled && !force

/mob/living/basic/immortal_snail/Destroy(force)
	if(contract_value && !curse_fulfilled && !force)
		return QDEL_HINT_LETMELIVE
	QDEL_LIST(pending_paths)
	route.Cut()
	route_destination = null
	chemical_target = null
	route_pending = FALSE
	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		var/alert_key = "[REF(src)]_notify_action"
		var/atom/movable/screen/alert/notify_action/toast = ghost.alerts[alert_key]
		if(istype(toast))
			toast.target = null
		ghost.clear_alert(alert_key)
	if(curse_fulfilled)
		new /obj/effect/temp_visual/small_smoke/halfsecond(get_turf(src))
	if(curse)
		curse.capture_state(src)
		if(!curse_fulfilled)
			curse.report_loss(src, "body deleted; force=[force]; usr context=[key_name(usr)]")
		else
			log_admin("Immortal snail curse fulfilled at [AREACOORD(src)]; reclaimed [debt?.recovered] credits.")
			qdel(curse)
		debt = null // The independent curse keeps the ledger through body replacement.
		curse = null
	QDEL_NULL(pursuit_driver)
	QDEL_LIST(slime_trail)
	QDEL_NULL(debt)
	target_ref = null
	target_mind_ref = null
	account_ref = null
	corpse_ref = null
	return ..()

/// Independent of the body and its movement driver, so deleting either cannot end the curse.
/datum/immortal_snail_curse
	var/datum/weakref/snail_ref
	var/datum/snail_debt/debt
	var/datum/weakref/target_ref
	var/datum/weakref/target_mind_ref
	var/datum/weakref/account_ref
	var/contract_value
	var/original_dead = FALSE
	var/original_settled = FALSE
	var/datum/weakref/corpse_ref
	var/turf/last_turf
	var/recoveries = 0

/datum/immortal_snail_curse/New(mob/living/basic/immortal_snail/snail)
	. = ..()
	debt = snail.debt
	snail.curse = src
	snail_ref = WEAKREF(snail)
	capture_state(snail)
	START_PROCESSING(SSobj, src)

/datum/immortal_snail_curse/Destroy()
	STOP_PROCESSING(SSobj, src)
	var/mob/living/basic/immortal_snail/snail = snail_ref?.resolve()
	if(!QDELETED(snail))
		snail.curse = null
		snail.debt = null
		snail.curse_fulfilled = TRUE
		qdel(snail)
	snail_ref = null
	QDEL_NULL(debt)
	target_ref = null
	target_mind_ref = null
	account_ref = null
	corpse_ref = null
	last_turf = null
	return ..()

/datum/immortal_snail_curse/proc/capture_state(mob/living/basic/immortal_snail/snail)
	target_ref = snail.target_ref
	target_mind_ref = snail.target_mind_ref
	account_ref = snail.account_ref
	contract_value = snail.contract_value
	original_dead = snail.original_dead
	original_settled = snail.original_settled
	corpse_ref = snail.corpse_ref
	if(get_turf(snail))
		last_turf = get_turf(snail)

/datum/immortal_snail_curse/proc/report_loss(mob/living/basic/immortal_snail/snail, reason)
	var/message = "Immortal snail recovery: [reason]. Location: [AREACOORD(snail)]. Target: [key_name(snail.original_target())]. Health: [snail.health]; stat: [snail.stat]; last attacker: [snail.lastattacker] ([snail.lastattackerckey]). Outstanding claims: [length(debt?.claims)]."
	log_admin(message)
	log_game(message)
	message_admins(message)

/datum/immortal_snail_curse/process(seconds_per_tick)
	var/mob/living/basic/immortal_snail/snail = snail_ref?.resolve()
	if(!QDELETED(snail))
		if(snail.curse_fulfilled)
			qdel(src)
			return PROCESS_KILL
		capture_state(snail)
		if(snail.stat != DEAD && get_turf(snail))
			return
		report_loss(snail, "watchdog found a dead or missing body")
		snail.curse = null
		snail.debt = null
		qdel(snail, TRUE)
	var/turf/spawn_turf = last_turf || debt?.origin
	if(!spawn_turf)
		return // Retain the contract and retry; never interpret a missing spawn as fulfillment.
	snail = new(spawn_turf)
	snail.target_ref = target_ref
	snail.target_mind_ref = target_mind_ref
	snail.account_ref = account_ref
	snail.contract_value = contract_value
	snail.original_dead = original_dead
	snail.original_settled = original_settled
	snail.corpse_ref = corpse_ref
	snail.debt = debt
	snail.curse = src
	if(debt)
		debt.collector_ref = WEAKREF(snail)
	snail_ref = WEAKREF(snail)
	recoveries++
	var/message = "Immortal snail restored at [AREACOORD(snail)] (recovery [recoveries]). The original curse and credit claims remain active."
	log_admin(message)
	log_game(message)
	message_admins(message)

/mob/living/basic/immortal_snail/death(gibbed)
	return FALSE

/mob/living/basic/immortal_snail/gib(no_brain, no_organs, no_bodyparts, safe_gib = TRUE)
	return

/mob/living/basic/immortal_snail/dust(just_ash, drop_items, force)
	return

/mob/living/basic/immortal_snail/ex_act(severity, target, origin)
	return

/datum/immortal_snail_pursuit
	var/datum/weakref/snail_ref

/datum/immortal_snail_pursuit/New(mob/living/basic/immortal_snail/snail)
	. = ..()
	snail_ref = WEAKREF(snail)
	START_PROCESSING(SSfastprocess, src)

/datum/immortal_snail_pursuit/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	snail_ref = null
	return ..()

/datum/immortal_snail_pursuit/process(seconds_per_tick)
	var/mob/living/basic/immortal_snail/snail = snail_ref?.resolve()
	if(QDELETED(snail))
		qdel(src)
		return PROCESS_KILL
	return snail.process(seconds_per_tick)

/mob/living/basic/immortal_snail/proc/bind_target(mob/living/target, amount)
	attach_ledger()
	target_ref = WEAKREF(target)
	if(target.mind)
		target_mind_ref = WEAKREF(target.mind)
	var/datum/bank_account/account = target.get_bank_account()
	if(account)
		account_ref = WEAKREF(account)
	contract_value = amount
	// The distant spawn provides the head start; pursuit begins immediately.
	next_step = world.time

/mob/living/basic/immortal_snail/proc/attach_ledger()
	if(!debt && GLOB.snail_debt && !GLOB.snail_debt.collector_ref)
		debt = GLOB.snail_debt
		debt.collector_ref = WEAKREF(src)

/mob/living/basic/immortal_snail/proc/original_target()
	var/datum/mind/target_mind = target_mind_ref?.resolve()
	if(isliving(target_mind?.current))
		return target_mind.current
	return target_ref?.resolve()

/mob/living/basic/immortal_snail/proc/movement_interval(turf/destination)
	return has_gravity(destination) ? move_interval : zero_gravity_move_interval

/mob/living/basic/immortal_snail/process(seconds_per_tick)
	if(pursuing || !contract_value)
		return
	attach_ledger()
	var/mob/living/target = original_target()
	if(!original_dead && (!target || target.stat == DEAD))
		original_dead = TRUE
		if(target)
			corpse_ref = WEAKREF(target)
	var/atom/navigation_target = target
	var/mob/living/corpse = corpse_ref?.resolve()
	if(original_dead && !original_settled && corpse)
		navigation_target = corpse
	else if(original_dead)
		var/datum/next_claim = debt?.next_claim()
		navigation_target = debt?.location_of(next_claim)
	// Refresh paths during the current glide, not after it has finished.
	prefetch_route(navigation_target)
	if(world.time < next_step)
		return
	debt?.refresh_carriers()
	if(original_dead)
		if(!original_settled)
			if(!corpse)
				original_settled = TRUE // An already gibbed/destroyed body cannot be punished again.
			else if(get_turf(corpse) == get_turf(src))
				settle_original(corpse)
			else
				next_step = world.time + movement_interval()
				pursuing = TRUE
				INVOKE_ASYNC(src, PROC_REF(pursue), corpse)
				return
		var/datum/claim = debt?.next_claim()
		if(!claim)
			curse_fulfilled = TRUE
			qdel(src)
			return PROCESS_KILL
		var/atom/money_location = debt.location_of(claim)
		if(get_turf(money_location) == get_turf(src))
			var/mob/living/carrier = debt.carrier_of(claim)
			if(carrier)
				contact(carrier)
			debt.collect(claim)
			return
		next_step = world.time + movement_interval()
		pursuing = TRUE
		INVOKE_ASYNC(src, PROC_REF(pursue), money_location)
		return
	next_step = world.time + movement_interval()
	pursuing = TRUE
	INVOKE_ASYNC(src, PROC_REF(pursue), target)

/mob/living/basic/immortal_snail/proc/prefetch_route(atom/target)
	var/turf/destination = get_turf(target)
	if(route_pending || world.time < next_route_refresh || !destination || destination.z != z || destination == get_turf(src))
		return
	if(length(route) && route_destination == destination)
		return
	route_pending = TRUE
	next_route_refresh = world.time + 1 SECONDS
	INVOKE_ASYNC(src, PROC_REF(refresh_route), WEAKREF(target), destination)

/mob/living/basic/immortal_snail/proc/refresh_route(datum/weakref/navigation_ref, turf/destination)
	var/turf/start = get_turf(src)
	var/list/new_route = find_route(destination)
	if(QDELETED(src))
		return
	route_pending = FALSE
	// A moving target does not invalidate the route to its last known position.
	// Keep advancing while the next refresh catches up instead of stopping.
	var/atom/target = navigation_ref.resolve()
	var/turf/current_target_turf = get_turf(target)
	if(QDELETED(target) || !current_target_turf || current_target_turf.z != destination.z || z != destination.z)
		return
	if(get_turf(src) != start)
		var/current_index = new_route.Find(get_turf(src))
		if(!current_index)
			return
		new_route.Cut(1, current_index + 1)
	route = new_route
	route_destination = destination

/// The usual JPS search, owned by this mob so Destroy can cancel it immediately.
/mob/living/basic/immortal_snail/proc/find_route(turf/destination)
	var/list/result = list()
	var/datum/pathfind/jps/search = new
	search.setup(src, SSid_access.get_region_access_list(list(REGION_ALL_GLOBAL)), world.maxx * world.maxy, FALSE, null, list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), result)), destination, null, TRUE, DIAGONAL_REMOVE_CLUNKY)
	if(!search.start())
		qdel(search)
		return list()
	pending_paths += search
	SSpathfinder.run_pathfind(search)
	UNTIL(length(result) || QDELETED(src))
	pending_paths -= search
	if(QDELETED(src) || !length(result) || !islist(result[1]))
		return list()
	return result[1]

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
			new /obj/effect/temp_visual/small_smoke/halfsecond(get_turf(src))
			forceMove(pick(arrivals))
			new /obj/effect/temp_visual/small_smoke/halfsecond(get_turf(src))
			route.Cut()
		pursuing = FALSE
		return
	if(get_turf(src) == destination)
		if(isliving(target))
			contact(target)
		pursuing = FALSE
		return
	var/list/path_access = SSid_access.get_region_access_list(list(REGION_ALL_GLOBAL))
	var/datum/can_pass_info/pass_info = new(src, path_access)
	var/turf/current_turf = get_turf(src)
	var/turf/cached_next = length(route) ? route[1] : null
	// A new wall or closed container can invalidate a cached route. Search for
	// another corridor/door before treating that obstacle as a chemical target.
	if(!cached_next || !CAN_STEP(current_turf, cached_next, FALSE, pass_info, null))
		// JPS's scan loops still compare against the limit when zero is supplied.
		var/datum/weakref/navigation_ref = WEAKREF(target)
		target = null // Do not keep the victim alive while the search yields.
		var/list/new_route = find_route(destination)
		if(QDELETED(src))
			return
		target = navigation_ref.resolve()
		route = new_route
		route_destination = destination
	if(QDELETED(src))
		return
	var/turf/current_target_turf = get_turf(target)
	if(QDELETED(target) || !current_target_turf || current_target_turf.z != z)
		route.Cut()
		pursuing = FALSE
		return
	// Prefer a real route around obstacles. If sealed in, chew toward the target
	// one tile at a time until the pathfinder can find a route again.
	var/fallback_direction = get_dir(src, destination)
	if(ISDIAGONALDIR(fallback_direction))
		fallback_direction &= EAST|WEST
	var/turf/next = length(route) ? route[1] : get_step(src, fallback_direction)
	if(isclosedturf(next))
		var/step_direction = get_dir(src, next)
		if(!chemically_breach(next))
			pursuing = FALSE
			return
		next = get_step(src, step_direction)
	if(next)
		for(var/obj/obstacle in next)
			if(!obstacle.density)
				continue
			if(pass_flags & obstacle.pass_flags_self)
				continue
			if(!chemically_breach(obstacle))
				pursuing = FALSE
				return
		if(!next.density)
			// The standard delay helper clamps to at least one pixel per tick,
			// which finishes a slow glide early. Preserve the fractional rate.
			Move(next, get_dir(src, next), MOVEMENT_ADJUSTED_GLIDE_SIZE(movement_interval(next), 1))
		if(get_turf(src) == next && length(route))
			route.Cut(1, 2)
		else
			route.Cut()
		next_step = world.time + movement_interval()
	pursuing = FALSE

/// Actual reagent effects do the work first; the curse only overrides chemical
/// immunity after giving the normal reactions time to finish.
/mob/living/basic/immortal_snail/proc/chemically_breach(atom/obstacle)
	if(QDELETED(obstacle) || !obstacle.density)
		return TRUE
	if(pass_flags & obstacle.pass_flags_self)
		return TRUE
	if(chemical_target?.resolve() != obstacle)
		chemical_target = WEAKREF(obstacle)
		chemical_started = world.time
		next_chemical_dose = 0
		chemical_escalated = FALSE
	if(world.time >= chemical_started + 17.5 SECONDS)
		obstacle.visible_message(span_danger("[src]'s curse tears through the chemically scarred [obstacle]!"))
		if(isturf(obstacle))
			var/turf/blocked_turf = obstacle
			blocked_turf.ChangeTurf(/turf/open/floor/plating)
		else
			qdel(obstacle)
		return TRUE
	if(isturf(obstacle))
		var/turf/blocked_turf = obstacle
		var/datum/component/thermite/coating = blocked_turf.GetComponent(/datum/component/thermite)
		if(!coating)
			var/datum/reagent/thermite/thermite = GLOB.chemical_reagents_list[/datum/reagent/thermite]
			thermite.expose_turf(blocked_turf, istype(blocked_turf, /turf/closed/wall/r_wall) ? 50 : 30)
			coating = blocked_turf.GetComponent(/datum/component/thermite)
			blocked_turf.visible_message(span_warning("[src] coats [blocked_turf] in thermite!"))
		if(coating && !coating.burn_timer && coating.burn_require > 0 && coating.amount >= coating.burn_require)
			var/datum/reagent/clf3/igniter = GLOB.chemical_reagents_list[/datum/reagent/clf3]
			igniter.expose_turf(blocked_turf, 5)
			blocked_turf.fire_act(2500, 5)
			blocked_turf.visible_message(span_danger("[src] ignites the thermite with chlorine trifluoride!"))
		if(coating?.burn_timer && !chemical_escalated)
			// Accelerate this coating's native melt callback without changing other thermite.
			chemical_escalated = TRUE
			deltimer(coating.burn_timer)
			coating.burn_timer = addtimer(coating.burn_callback, min(coating.amount * 0.245 SECONDS, 14 SECONDS), TIMER_STOPPABLE)
	else if(isobj(obstacle))
		var/obj/blocked_object = obstacle
		if(world.time >= next_chemical_dose)
			var/datum/reagent/toxin/acid/fluacid/acid = GLOB.chemical_reagents_list[/datum/reagent/toxin/acid/fluacid]
			if(blocked_object.uses_integrity)
				acid.expose_obj(blocked_object, 300)
			next_chemical_dose = world.time + 4.2 SECONDS
			blocked_object.visible_message(span_warning("[src] drenches [blocked_object] in sizzling fluorosulfuric acid!"))
		if(!chemical_escalated && world.time >= chemical_started + 4.2 SECONDS)
			chemical_escalated = TRUE
			var/datum/reagent/clf3/incendiary = GLOB.chemical_reagents_list[/datum/reagent/clf3]
			// Concentrate the chemical attack on the obstruction, not its floor.
			incendiary.expose_obj(blocked_object, 10)
			blocked_object.fire_act(2500, 10)
			blocked_object.visible_message(span_danger("[src] follows the acid with a burst of chlorine trifluoride!"))
	return QDELETED(obstacle) || !obstacle.density

/mob/living/basic/immortal_snail/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/turf/previous = isturf(old_loc) ? old_loc : null
	var/turf/current = get_turf(src)
	// Teleports do not paint a trail across levels or leave old patches behind.
	if(!previous || !current || previous.z != current.z || get_dist(previous, current) != 1)
		QDEL_LIST(slime_trail)
		slime_trail = list()
	else
		for(var/obj/effect/decal/cleanable/immortal_snail_slime/patch as anything in slime_trail.Copy())
			if(QDELETED(patch) || patch.loc == previous || patch.loc == current)
				slime_trail -= patch
				qdel(patch)
		if(isfloorturf(previous))
			slime_trail += new /obj/effect/decal/cleanable/immortal_snail_slime(previous)
		while(length(slime_trail) > 3)
			var/obj/effect/decal/cleanable/immortal_snail_slime/oldest = slime_trail[1]
			slime_trail.Cut(1, 2)
			qdel(oldest)
	for(var/mob/living/victim in loc)
		if(victim != src)
			collision_contact(victim)

/obj/effect/decal/cleanable/immortal_snail_slime
	name = "snail slime"
	desc = "A glistening, dangerously slippery trail of slime."
	icon = 'icons/effects/water.dmi'
	icon_state = "wet_floor_static"
	color = "#9ebf74"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/immortal_snail_slime/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 80, SLIPPERY_TURF | SLIDE | GALOSHES_DONT_HELP)

/mob/living/basic/immortal_snail/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(isliving(entered) && entered != src)
		INVOKE_ASYNC(src, PROC_REF(collision_contact), entered)

/// Incidental overlap only kills the cursed target and debtors, not ordinary passersby.
/mob/living/basic/immortal_snail/proc/collision_contact(mob/living/victim)
	if(QDELETED(src) || QDELETED(victim))
		return
	if(victim == original_target() || victim == corpse_ref?.resolve() || (debt && debt.claims[victim]))
		contact(victim)
		return
	if(!debt)
		return
	for(var/datum/holder as anything in debt.claims)
		if(debt.carrier_of(holder) == victim)
			contact(victim)
			return

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
	if(QDELETED(victim) || victim == src)
		return
	var/is_target = victim == original_target() || victim == corpse_ref?.resolve()
	if(is_target && !original_settled)
		log_combat(src, victim, victim.stat == DEAD ? "settled the curse on their corpse" : "killed by contact")
		settle_original(victim)
		return
	if(victim.stat == DEAD)
		return
	log_combat(src, victim, "killed by contact")
	victim.death()

/mob/living/basic/immortal_snail/proc/settle_original(mob/living/victim)
	if(original_settled || QDELETED(victim))
		return
	original_dead = TRUE
	original_settled = TRUE
	corpse_ref = WEAKREF(victim)
	if(available_credits(victim) < contract_value)
		ADD_TRAIT(victim, TRAIT_NO_SPECIAL_REVIVAL, REF(src))
		victim.gib(no_brain = TRUE, no_organs = TRUE, no_bodyparts = TRUE)
	else
		if(victim.stat != DEAD)
			victim.death()
		if(iscarbon(victim))
			var/mob/living/carbon/carbon_victim = victim
			carbon_victim.become_husk(REF(src))
	corpse_ref = null
