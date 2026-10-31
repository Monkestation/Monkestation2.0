#define COST_PER_AIRLOCK 1

/obj/structure/door_assembly/door_assembly_bronze/clock
	airlock_type = /obj/machinery/door/airlock/bronze/clock

/obj/structure/door_assembly/door_assembly_bronze/seethru/clock
	airlock_type = /obj/machinery/door/airlock/bronze/clock/glass

/obj/machinery/door/airlock/bronze/clock
	assemblytype = /obj/structure/door_assembly/door_assembly_bronze/clock
	hackProof = TRUE
	aiControlDisabled = AI_WIRE_DISABLED
	req_access = list(ACCESS_CLOCKCULT)
	damage_deflection = 6

/obj/machinery/door/airlock/bronze/clock/Initialize(mapload)
	. = ..()
	if(on_reebe(src))
		damage_deflection = 0
		if(!mapload)
			SSthe_ark.reebe_clockwork_airlock_count++

/obj/machinery/door/airlock/bronze/clock/Destroy()
	if(on_reebe(src))
		SSthe_ark.reebe_clockwork_airlock_count--
	return ..()

/obj/machinery/door/airlock/bronze/clock/canAIControl(mob/user)
	return (IS_CLOCK(user) && !isAllPowerCut())

/obj/machinery/door/airlock/bronze/clock/on_break()
	set_panel_open(TRUE)

/obj/machinery/door/airlock/bronze/clock/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return

/obj/machinery/door/airlock/bronze/clock/isElectrified()
	return FALSE

/obj/machinery/door/airlock/bronze/clock/ratvar_act()
	return FALSE

/obj/machinery/door/airlock/bronze/clock/hasPower()
	return TRUE

/obj/machinery/door/airlock/bronze/clock/allowed(mob/living/user)
	if(!density || IS_CLOCK(user))
		return TRUE

	else if(!on_reebe(src))
		user.Paralyze(1 SECONDS)
		user.electrocute_act(10, src, 1, SHOCK_NOGLOVES|SHOCK_SUPPRESS_MESSAGE)
		to_chat(user, span_warning("You feel a sudden jolt as you touch [src]!"))
	return FALSE

/obj/machinery/door/airlock/bronze/clock/emp_act(severity)
	return

/obj/machinery/door/airlock/bronze/clock/emag_act(mob/user, obj/item/card/emag/emag_card) //emags are magical but not THAT magical
	return FALSE

/obj/machinery/door/airlock/bronze/clock/glass
	name = "clear bronze airlock"
	assemblytype = /obj/structure/door_assembly/door_assembly_bronze/seethru/clock
	glass = TRUE
	opacity = FALSE

//player made airlocks drain passive power when placed near other airlocks
/obj/machinery/door/airlock/bronze/clock/player_made
	//var/list/tracked_airlocks
	///How much passive power are we using
	var/power_usage = 0

/obj/machinery/door/airlock/bronze/clock/player_made/Initialize(mapload)
	. = ..()
	var/list/tracked_airlocks = list()
	var/total_cost = 0
	for(var/obj/machinery/door/airlock/bronze/clock/player_made/airlock in orange(1, src))
		tracked_airlocks += airlock
		total_cost -= COST_PER_AIRLOCK * 2

	if(!SSthe_ark.adjust_passive_power(total_cost, TRUE))
		deconstruct(FALSE, should_del = FALSE)
		visible_message(span_warning("\The [src] is unable to sustain its power draw and collapses!"))
		return INITIALIZE_HINT_QDEL

	for(var/obj/machinery/door/airlock/bronze/clock/player_made/lock in tracked_airlocks)
		track_airlock(lock, TRUE)

/obj/machinery/door/airlock/bronze/clock/player_made/examine(mob/user)
	. = ..()
	if(isobserver(user) || IS_CLOCK(user))
		. += span_brass("Due to instability, clockwork airlocks placed near each other must drain passive power to stop from collapsing, \
						this one is currently draining [power_usage] power.")

/obj/machinery/door/airlock/bronze/clock/player_made/proc/track_airlock(obj/machinery/door/airlock/bronze/clock/player_made/tracked, recurse = FALSE)
	RegisterSignal(tracked, COMSIG_QDELETING, PROC_REF(on_tracked_qdel))
	if(recurse)
		tracked.track_airlock(src)
	power_usage += COST_PER_AIRLOCK
	SSthe_ark.adjust_passive_power(-COST_PER_AIRLOCK)

/obj/machinery/door/airlock/bronze/clock/player_made/proc/on_tracked_qdel(obj/machinery/door/airlock/bronze/clock/player_made/tracked)
	untrack_airlock(tracked, TRUE)

/obj/machinery/door/airlock/bronze/clock/player_made/proc/untrack_airlock(obj/machinery/door/airlock/bronze/clock/player_made/untracked, recurse = FALSE)
	if(recurse)
		untracked.untrack_airlock(src)
	SSthe_ark.adjust_passive_power(COST_PER_AIRLOCK)
	power_usage -= COST_PER_AIRLOCK

/obj/machinery/door/airlock/bronze/clock/player_made/glass
	name = "clear bronze airlock"
	assemblytype = /obj/structure/door_assembly/door_assembly_bronze/seethru/clock
	glass = TRUE
	opacity = FALSE

#undef COST_PER_AIRLOCK
