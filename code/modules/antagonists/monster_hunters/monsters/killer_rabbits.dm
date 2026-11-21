/**
 * Spawned by rabbit power
 */
/mob/living/basic/killer_rabbit
	name = "killer baby rabbit"
	desc = "A cute little rabbit, surely its harmless... right?"
	icon = 'icons/mob/rabbit.dmi'
	icon_state = "killer_rabbit"
	maxHealth = 5
	speed = 0.7
	melee_damage_lower = 5
	melee_damage_upper = 5
	faction = list(FACTION_RABBITS)
	ai_controller = /datum/ai_controller/basic_controller/killer_rabbit
	basic_mob_flags = DEL_ON_DEATH
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST

	habitable_atmos = null
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

/mob/living/basic/killer_rabbit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL)
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))

/mob/living/basic/killer_rabbit/proc/hostile_attackingtarget(mob/living/basic/source, atom/target, success)
	SIGNAL_HANDLER

	if(!success || !isliving(target))
		return
	for(var/mob/living/victim in range(4, src))
		if(victim == src)
			continue
		victim.Knockdown(3 SECONDS)
		var/atom/throw_target = get_edge_target_turf(victim, get_dir(src, victim) || pick(GLOB.alldirs))
		addtimer(CALLBACK(victim, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 10, 4, null, TRUE, FALSE, null, MOVE_FORCE_STRONG, TRUE), 0.2 SECONDS)
	explosion(src, heavy_impact_range = 1, light_impact_range = 1, flame_range = 2)
	gib(src)

