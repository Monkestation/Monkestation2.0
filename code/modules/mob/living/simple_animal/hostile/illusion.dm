/mob/living/simple_animal/hostile/illusion
	name = "illusion"
	desc = "It's a fake!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = "null"
	gender = NEUTER
	mob_biotypes = NONE
	melee_damage_lower = 5
	melee_damage_upper = 5
	istate = ISTATE_HARM|ISTATE_BLOCKING
	attack_verb_continuous = "gores"
	attack_verb_simple = "gore"
	maxHealth = 100
	health = 100
	speed = 0
	faction = list(FACTION_ILLUSION)
	///The world.time this despawns
	var/life_span = INFINITY
	var/mob/living/parent_mob
	var/multiply_chance = 0 //if we multiply on hit
	del_on_death = TRUE
	death_message = "vanishes into thin air! It was a fake!"

/mob/living/simple_animal/hostile/illusion/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(world.time > life_span)
		death()

/mob/living/simple_animal/hostile/illusion/proc/copy_parent(mob/living/original, life_span = 5 SECONDS, hp, damage, replicate = 0)
	appearance = original.appearance
	parent_mob = original
	setDir(original.dir)
	src.life_span = world.time + life_span
	if(isnum(hp))
		health = hp
	if(isnum(damage))
		melee_damage_lower = damage
		melee_damage_upper = damage
	multiply_chance = replicate
	faction -= FACTION_NEUTRAL
	transform = initial(transform)
	pixel_x = base_pixel_x
	pixel_y = base_pixel_y

/mob/living/simple_animal/hostile/illusion/examine(mob/user)
	if(parent_mob)
		return parent_mob.examine(user)
	else
		return ..()

/mob/living/simple_animal/hostile/illusion/AttackingTarget(atom/attacked_target)
	. = ..()
	if(. && isliving(target) && prob(multiply_chance))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return

		var/mob/living/simple_animal/hostile/illusion/clone = new(loc)
		clone.faction = faction.Copy()
		clone.copy_parent(parent_mob, 80, health/2, melee_damage_upper, multiply_chance/2)
		clone.GiveTarget(living_target)

///////Actual Types/////////

/mob/living/simple_animal/hostile/illusion/escape
	retreat_distance = 10
	minimum_distance = 10
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = -1
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/illusion/escape/AttackingTarget(atom/attacked_target)
	return FALSE

/mob/living/simple_animal/hostile/illusion/mirage
	AIStatus = AI_OFF
	density = FALSE

/mob/living/simple_animal/hostile/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()

/mob/living/simple_animal/hostile/illusion/blob //yes I should convert these to basic, counterpoint: I really dont want to
	melee_damage_type = BRAIN
	melee_damage_lower = 2
	melee_damage_upper = 2
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	maxHealth = 20
	health = 20
	pass_flags = parent_type::pass_flags | PASSBLOB

/mob/living/simple_animal/hostile/illusion/blob/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_BLOB_ALLY, INNATE_TRAIT)
