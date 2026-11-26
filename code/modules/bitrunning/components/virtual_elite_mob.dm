/// Removes loot tables from megafauna and lowers their health.
/datum/element/virtual_elite_mob

/datum/element/virtual_elite_mob/Attach(datum/target)
	. = ..()
	if(!ismegafauna(target))
		return ELEMENT_INCOMPATIBLE

	if(istype(target, /mob/living/basic/boss))
		var/mob/living/basic/boss/basic_boss = target
		basic_boss.make_virtual_megafauna()
		return

	var/mob/living/simple_animal/hostile/megafauna/boss = target

	var/new_max = clamp(boss.maxHealth * 0.5, 600, 1200)
	boss.maxHealth = new_max
	boss.health = new_max
	boss.true_spawn = FALSE
	boss.loot.Cut()
	boss.loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
	boss.crusher_loot.Cut()
	boss.crusher_loot += /obj/structure/closet/crate/secure/bitrunning/encrypted

/// Removes all the loot and achievements from basic bosses for bitrunning
/mob/living/basic/boss/proc/make_virtual_megafauna()
	var/new_max = clamp(maxHealth * 0.5, 600, 1200)
	maxHealth = new_max
	health = new_max

	if(length(achievements))
		RemoveElement(/datum/element/kill_achievement, string_list(achievements), crusher_achievement_type, victor_memory_type)

	if(!isnull(crusher_loot))
		RemoveElement(\
			/datum/element/crusher_loot,\
			trophy_type = string_list(crusher_loot),\
			guaranteed_drop = 0.6,\
			drop_immediately = basic_mob_flags & DEL_ON_DEATH,\
		)

	if(length(regular_loot))
		RemoveElement(/datum/element/death_drops, string_list(regular_loot))
	AddElement(/datum/element/death_drops, string_list(list(/obj/structure/closet/crate/secure/bitrunning/encrypted)))
