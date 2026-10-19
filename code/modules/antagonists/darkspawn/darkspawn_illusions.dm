//////////Darkspawn specific illusions//////////////
/mob/living/simple_animal/hostile/illusion/darkspawn //simulacrum version
	desc = "They have a weird shimmering to them."
	maxHealth = 100
	health = 100
	pressure_resistance = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	bodytemp_cold_damage_limit = 0
	bodytemp_heat_damage_limit = INFINITY

	speed = -1
	pass_flags_self = PASSTABLE | PASSMOB | PASSDOORS | PASSMACHINE | PASSGRILLE | PASSGLASS

	attack_sound = 'sound/magic/voidblink.ogg'
	death_sound = 'sound/magic/darkspawn/devour_will_victim.ogg'
	attack_verb_simple = "gores"
	bubble_icon = "darkspawn"

	lighting_cutoff_red = 12
	lighting_cutoff_green = 0
	lighting_cutoff_blue = 50
	lighting_cutoff = LIGHTING_CUTOFF_HIGH
	faction = list(FACTION_DARKSPAWN)
	initial_language_holder = /datum/language_holder/darkspawn

/mob/living/simple_animal/hostile/illusion/darkspawn/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/illusion/darkspawn/Life(seconds_per_tick, times_fired)
	. = ..()
	var/turf/T = get_turf(src)
	if(istype(T))
		var/light_amount = GET_SIMPLE_LUMCOUNT(T)
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			adjustHealth(-2)

/mob/living/simple_animal/hostile/illusion/darkspawn/psyche //sentient version

/mob/living/simple_animal/hostile/illusion/darkspawn/psyche/copy_parent(mob/living/original, life, hp, damage, replicate)
	. = ..()
	life_span = INFINITY //doesn't actually despawn

/mob/living/simple_animal/hostile/illusion/darkspawn/psyche/mind_initialize()
	. = ..()
	if(!IS_PSYCHE(src))
		mind.add_antag_datum(/datum/antagonist/psyche)

///special antagonist used to give an internal camera and antag hud to non-thrall darkspawn teammates
/datum/antagonist/psyche
	name = "Darkspawn Psyche"
	job_rank = ROLE_DARKSPAWN
	antag_hud_name = "thrall"
	roundend_category = "thralls"
	antagpanel_category = "Darkspawn"
	antag_moodlet = /datum/mood_event/thrall_darkspawn

/datum/antagonist/psyche/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	add_team_hud(current_mob, /datum/antagonist/thrall_darkspawn)
	add_team_hud(current_mob, /datum/antagonist/darkspawn)

	current_mob.grant_language(/datum/language/shadowtongue, source = LANGUAGE_DARKSPAWN)
	current_mob.faction |= FACTION_DARKSPAWN

	current_mob.AddComponent(/datum/component/internal_cam, list(FACTION_DARKSPAWN))
	var/datum/component/internal_cam/cam = current_mob.GetComponent(/datum/component/internal_cam)
	if(cam)
		cam.change_cameranet(GLOB.thrallnet)

/datum/antagonist/psyche/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	current_mob.remove_language(/datum/language/shadowtongue, source = LANGUAGE_DARKSPAWN)
	current_mob.faction -= FACTION_DARKSPAWN
	qdel(current_mob.GetComponent(/datum/component/internal_cam))

/datum/antagonist/psyche/add_team_hud(mob/target, antag_to_check)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
		antag_to_check || type,
	))

	var/datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn/hud = team_hud_ref.resolve()

	// Add HUDs that they couldn't see before
	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn/antag_hud as anything in GLOB.has_antagonist_huds)
		if(istype(antag_hud, /datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn))
			antag_hud.show_to(target)
			hud.show_to(antag_hud.target)
