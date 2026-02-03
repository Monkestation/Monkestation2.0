/mob/living/simple_animal/hostile/crawling_shadows
	//appearance variables
	name = "crawling shadows"
	desc = "A formless mass of nothingness with piercing white eyes."
	icon = 'icons/mob/simple/darkspawn.dmi' //Placeholder sprite
	icon_state = "crawling_shadows"
	icon_living = "crawling_shadows"
	initial_language_holder = /datum/language_holder/darkspawn
	//survival variables
	maxHealth = 20
	health = 20
	pressure_resistance = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	bodytemp_cold_damage_limit = 0
	bodytemp_heat_damage_limit = INFINITY

	//movement variables
	movement_type = FLYING
	speed = 0
	pass_flags = PASSTABLE | PASSMOB | PASSDOORS | PASSMACHINE

	//combat variables
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5

	//sight variables
	lighting_cutoff_red = 12
	lighting_cutoff_green = 0
	lighting_cutoff_blue = 50
	lighting_cutoff = LIGHTING_CUTOFF_HIGH

	//death variables
	del_on_death = TRUE
	death_message = "trembles, form rapidly dispersing."
	death_sound = 'sound/magic/darkspawn/devour_will_victim.ogg'

	//attack flavour
	speak_emote = list("whispers")
	attack_verb_simple = "assails"
	attack_sound = 'sound/magic/voidblink.ogg'
	response_help_simple = "disturbs"
	response_harm_simple = "flails at"

	var/move_count = 0 //For spooky sound effects
	var/knocking_out = FALSE

/mob/living/simple_animal/hostile/crawling_shadows/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/crawling_shadows/Move()
	. = ..()
	update_light_speed()
	move_count++
	if(move_count >= 4)
		playsound(get_turf(src), "crawling_shadows_walk", 25, 0)
		move_count = 0

/mob/living/simple_animal/hostile/crawling_shadows/proc/update_light_speed()
	var/turf/T = get_turf(src)
	var/lums = GET_SIMPLE_LUMCOUNT(T)
	if(lums < SHADOW_SPECIES_BRIGHT_LIGHT)
		speed = -1 //Faster, too
		alpha = max(alpha - ((SHADOW_SPECIES_BRIGHT_LIGHT - lums) * 60), 0) //Rapidly becomes more invisible in the dark
	else
		speed = 0
		alpha = min(alpha + (lums * 30), 255) //Slowly becomes more visible in brighter light
	update_simplemob_varspeed()
