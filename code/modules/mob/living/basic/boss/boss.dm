//not quite simple animal megafauna but close enough
// port actual megafauna stuff once it gets used for lavaland megafauna
//im using it for stuff both of them get
/mob/living/basic/boss
	istate = ISTATE_HARM|ISTATE_BLOCKING
	status_flags = NONE
	abstract_type = /mob/living/basic/boss
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = MOB_ORGANIC|MOB_EPIC
	faction = list(FACTION_MINING, FACTION_BOSS)
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) // same as our megafauna
	obj_damage = 400
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	flags_1 = parent_type::flags_1 | PREVENT_CONTENTS_EXPLOSION_1
	/// Name for the GPS signal of the megafauna
	var/gps_name = null
	/// What crusher trophy/trophies this mob drops, if any
	/// Should be wrapped in a list for sanity when we pass it to the element.
	var/list/crusher_loot = null
	/// Loot dropped on death in normal circumstances
	var/list/regular_loot = list()

	/// What achievements do we give our defeater?
	var/list/achievements = null
	/// What type of achievement we give for crusher kills, if any.
	var/crusher_achievement_type = null
	/// What memory to give to victor who have killed us, if any.
	var/victor_memory_type = null

	// megafauna roar at intruders before attacking them
	/// Sound played when we warn someone who got too close
	var/rawr_sound = 'sound/mobs/non-humanoids/space_dragon/space_dragon_roar.ogg'
	/// Mobs we have warned already, by REF
	var/list/warned_players
	/// Cooldown between roars
	COOLDOWN_DECLARE(rawr_cooldown)

/mob/living/basic/boss/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wall_tearer, tear_time = 1 SECONDS)
	if(gps_name)
		AddComponent(/datum/component/gps, gps_name)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_MARTIAL_ARTS_IMMUNE, TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_NO_FLOATING_ANIM), MEGAFAUNA_TRAIT)
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/simple_flying)
	if(length(regular_loot))
		AddElement(/datum/element/death_drops, string_list(regular_loot))
	handle_crusher_loot()
	handle_achievements()

/mob/living/basic/boss/gib(no_brain, no_organs, no_bodyparts, safe_gib = TRUE)
	if(health > 0)
		return
	return ..()

/mob/living/basic/boss/dust(just_ash, drop_items, force)
	if(!force && health > 0)
		return
	return ..()

/mob/living/basic/boss/death(gibbed)
	if (health > 0 && !gibbed) // prevents instakills
		return
	return ..()

/mob/living/basic/boss/ex_act(severity, target)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			adjustBruteLoss(250)

		if (EXPLODE_HEAVY)
			adjustBruteLoss(100)

		if (EXPLODE_LIGHT)
			adjustBruteLoss(50)

	return TRUE

/mob/living/basic/boss/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(isliving(target) && should_devour(target))
		devour(target)
		return FALSE
	return ..()

/// Determines if this mob is worth devouring
/mob/living/basic/boss/proc/should_devour(mob/living/victim)
	return victim.stat == DEAD || (victim.health <= victim.dead_threshold && HAS_TRAIT(victim, TRAIT_NODEATH))

/// Devours a target and restores health to the megafauna
/mob/living/basic/boss/proc/devour(mob/living/victim)
	if(isnull(victim) || victim.has_status_effect(/datum/status_effect/gutted))
		return FALSE
	celebrate_kill(victim)
	if(!is_station_level(z) || client) //NPC monsters won't heal while on station
		heal_overall_damage(victim.maxHealth * 0.5)
	victim.investigate_log("has been devoured by [src].", INVESTIGATE_DEATHS)
	if(iscarbon(victim))
		qdel(victim.get_organ_slot(ORGAN_SLOT_LUNGS))
		qdel(victim.get_organ_slot(ORGAN_SLOT_HEART))
		qdel(victim.get_organ_slot(ORGAN_SLOT_LIVER))
	victim.adjustBruteLoss(500)
	victim.death() //make sure they die
	victim.apply_status_effect(/datum/status_effect/gutted)
	return TRUE

/// Small little taunt when we epically troll someone
/mob/living/basic/boss/proc/celebrate_kill(mob/living/poor_sap)
	visible_message(
		span_danger("[src] disembowels [poor_sap]!"),
		span_userdanger("You feast on [poor_sap]'s organs, restoring your health!"),
	)

/// Handles adding all relevant achievements when applicable (probably when we are defeated)
/// Achievements being null/no length is handled in the element itself.
/mob/living/basic/boss/proc/handle_achievements()
	if(length(achievements) <= 0)
		return
	AddElement(/datum/element/kill_achievement, string_list(achievements), crusher_achievement_type, victor_memory_type)

/// Handles adding crusher loot when applicable (probably when we are defeated)
/mob/living/basic/boss/proc/handle_crusher_loot()
	if(isnull(crusher_loot))
		return
	AddElement(\
		/datum/element/crusher_loot,\
		trophy_type = string_list(crusher_loot),\
		guaranteed_drop = 0.6,\
		drop_immediately = basic_mob_flags & DEL_ON_DEATH,\
	)

// megafauna roar at intruders before attacking them
/// Roars at everyone in the list. Called by the AI the first time someone gets close.
/mob/living/basic/boss/proc/warn_players(list/targets)
	playsound(src, rawr_sound, 100, extrarange = 5, falloff_distance = 6)
	if(prob(0.1))
		visible_message(span_userdanger("[src] roars loudly, visibly being annoyed with your presence!"))
		return
	visible_message(span_userdanger("[src] roars loudly!"))
