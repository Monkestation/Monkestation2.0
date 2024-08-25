/mob/living/simple_animal/hostile/retaliate/clowndola
	name = "Clowndola"
	real_name = "Clowndola"
	desc = "Clowndola is the noisy walker. Having no hands he embodies the Taoist principle of honk (HonkMother) while his crazy eyes shows his utter and complete acceptance of the world as it is. Its hide is extremely valuable."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	icon_state = "clowndola"
	icon_living = "clowndola"
	//icon_dead = "clowndola_dead"
	icon = 'icons/mob/simple/gondolas.dmi'
	//Gondolas aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	maxHealth = 100
	health = 100
	attack_sound = list('sound/items/airhorn2.ogg', 'sound/items/airhorn.ogg', 'sound/items/carhorn.ogg', 'sound/items/bikehorn.ogg')
	speak_chance = 20
	turns_per_move = 1
	maxHealth = 80
	health = 80
	loot = list(/obj/effect/decal/cleanable/blood/gibs, /obj/item/stack/sheet/animalhide/gondola = 1, /obj/item/food/meat/slab/clowndola = 1)
	obj_damage = 0
	harm_intent_damage = 1
	melee_damage_lower = 1
	melee_damage_upper = 1
	attack_same = FALSE
	attack_verb_continuous = "honks at"
	attack_verb_simple = "honk"
	faction = list(FACTION_GONDOLA)
	environment_smash = ENVIRONMENT_SMASH_NONE
	mouse_opacity = MOUSE_OPACITY_ICON
	robust_searching = 1
	unique_name = 1
	speak_emote = list("honk!", "Honk?", "HONK HONK")

	rapid_melee = 4
	var/list/injection_reagents


/mob/living/simple_animal/hostile/retaliate/clowndola/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/T = target
		if(T.reagents)
			if(health <= maxHealth/2)
				injection_reagents = list(
					/datum/reagent/drug/happiness = 1,
					/datum/reagent/consumable/superlaughter = 1,
					/datum/reagent/consumable/banana = 1
				)
			else
				injection_reagents = list(
					/datum/reagent/drug/happiness = 1,
					/datum/reagent/consumable/laughter = 1,
					/datum/reagent/consumable/banana = 1
				)
			for(var/reagent in injection_reagents)
				T.reagents.add_reagent(reagent, injection_reagents[reagent])


/mob/living/simple_animal/hostile/retaliate/clowndola/examine(mob/user)
	. = ..()
	if(health >= maxHealth)
		. += "<span class='info'>It looks healthy and has a crazy smile for no apparent reason.</span>"
	else
		. += "<span class='info'>It looks like it's been roughed up.</span>"

/mob/living/simple_animal/hostile/retaliate/clowndola/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/food/grown/banana/mime))
		src.Disorient(5 SECONDS, 0, paralyze = 5 SECONDS, stack_status = TRUE)
		addtimer(CALLBACK(src, PROC_REF(mimebananaEaten)), 5 SECONDS)
		qdel(O)
		return
	return ..()

/mob/living/simple_animal/hostile/retaliate/clowndola/proc/mimebananaEaten()
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	visible_message(span_warning("[src] explodes!"))
	new /obj/effect/gibspawner/generic(get_turf(src))
	death(src)
