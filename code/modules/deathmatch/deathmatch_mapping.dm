/area/deathmatch/fullbright
	name = "Deathmatch Arena"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED

/area/deathmatch/fullbright/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/obj/effect/landmark/deathmatch_player_spawn
	name = "Deathmatch Player Spawner"

/obj/lightning_thrower
	name = "overcharged SMES"
	desc = "An overclocked SMES, bursting with power."
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/power.dmi'
	icon_state = "smes"
	/// do we currently want to shock diagonal tiles? if not, we shock cardinals
	var/throw_diagonals = FALSE
	/// flags we apply to the shock
	var/shock_flags = SHOCK_NOGLOVES
	/// damage of the shock
	var/shock_damage = 20
	/// list of turfs that are currently shocked so we can unregister the signal
	var/list/signal_turfs = list()
	/// how long do we shock
	var/shock_duration = 0.5 SECONDS

/obj/lightning_thrower/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/lightning_thrower/Destroy()
	. = ..()
	clear_signals()
	signal_turfs = null
	STOP_PROCESSING(SSprocessing, src)

/obj/lightning_thrower/process(seconds_per_tick)
	var/list/dirs = throw_diagonals ? GLOB.diagonals : GLOB.cardinals
	throw_diagonals = !throw_diagonals
	playsound(src, 'sound/magic/lightningbolt.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
	if(length(signal_turfs))
		clear_signals()
	for(var/direction in dirs)
		var/victim_turf = get_step(src, direction)
		if(isclosedturf(victim_turf))
			continue
		Beam(victim_turf, icon_state="lightning[rand(1,12)]", time = shock_duration)
		RegisterSignal(victim_turf, COMSIG_ATOM_ENTERED, PROC_REF(shock_victim)) //we cant move anyway
		signal_turfs += victim_turf
		for(var/mob/living/victim in victim_turf)
			shock_victim(null, victim)
	addtimer(CALLBACK(src, PROC_REF(clear_signals)), shock_duration)

/obj/lightning_thrower/proc/clear_signals()
	for(var/turf in signal_turfs)
		UnregisterSignal(turf, COMSIG_ATOM_ENTERED)
		signal_turfs -= turf

/obj/lightning_thrower/proc/shock_victim(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim))
		return
	victim.electrocute_act(shock_damage, src, flags = shock_flags)
