/mob/living/basic/crawling_shadows
	//appearance variables
	name = "crawling shadows"
	desc = "A formless mass of nothingness with piercing white eyes."
	icon = 'icons/mob/simple/darkspawn.dmi' //Placeholder sprite
	icon_state = "crawling_shadows"
	icon_living = "crawling_shadows"
	initial_language_holder = /datum/language_holder/darkspawn
	//survival variables
	maxHealth = 5
	health = 5
	pressure_resistance = INFINITY
	habitable_atmos = null
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY

	//movement variables
	movement_type = FLYING
	speed = 1
	pass_flags = PASSTABLE | PASSMOB | PASSDOORS | PASSMACHINE

	//combat variables
	melee_damage_lower = 5
	melee_damage_upper = 5

	//sight variables
	lighting_cutoff_red = 12
	lighting_cutoff_green = 0
	lighting_cutoff_blue = 50
	lighting_cutoff = LIGHTING_CUTOFF_HIGH

	//death variables
	basic_mob_flags = DEL_ON_DEATH
	death_message = "trembles, form rapidly dispersing."
	death_sound = 'sound/effects/magic/darkspawn/devour_will_victim.ogg'

	//attack flavour
	speak_emote = list("whispers")
	attack_verb_continuous = "assails"
	attack_verb_simple = "assail"
	attack_sound = 'sound/effects/magic/voidblink.ogg'
	response_help_simple = "disturbs"
	response_harm_simple = "flails at"
	ai_controller = null

	/// For spooky sound effects
	var/move_count = 0

/mob/living/basic/crawling_shadows/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/basic/crawling_shadows/Move()
	. = ..()
	update_light_speed()
	move_count++
	if(move_count >= 4)
		playsound(get_turf(src), "crawling_shadows_walk", 25, 0)
		move_count = 0

/mob/living/basic/crawling_shadows/proc/update_light_speed()
	var/turf/T = get_turf(src)
	var/lums = GET_SIMPLE_LUMCOUNT(T)
	if(lums < SHADOW_SPECIES_BRIGHT_LIGHT)
		speed = 0 //Faster, too
		alpha = max(alpha - ((SHADOW_SPECIES_BRIGHT_LIGHT - lums) * 60), 0) //Rapidly becomes more invisible in the dark
	else
		speed = 1
		alpha = min(alpha + (lums * 30), 255) //Slowly becomes more visible in brighter light
	update_basic_mob_varspeed()
