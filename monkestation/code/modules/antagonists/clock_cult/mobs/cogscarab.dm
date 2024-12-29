#define CLOCK_DRONE_MAX_ITEM_FORCE 15

//====Cogscarab====

/mob/living/basic/drone/cogscarab
	name = "Cogscarab"
	desc = "A mechanical device, filled with twisting cogs and mechanical parts, built to maintain Reebe."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	health = 35
	maxHealth = 35
	speed = 1
	faction = list(FACTION_NEUTRAL, FACTION_SILICON, FACTION_TURRET, FACTION_CLOCK)
	default_storage = /obj/item/storage/belt/utility/clock/drone
	visualAppearance = CLOCKDRONE
	bubble_icon = "clock"
	picked = TRUE
	flavortext = span_brass("You are a cogscarab, an intricate machine that has been granted sentient by Rat'var.<br>\
		After a long and destructive conflict, Reebe has been left mostly empty;\
		you and the other cogscarabs like you were bought into existence to construct Reebe into the image of Rat'var.<br>\
		Construct defences, traps and forgeries, \
		for opening the Ark requires an unimaginable amount of power which is bound to get the attention of selfish lifeforms interested only in their own self-preservation.")
	laws = "You are have been granted the gift of sentience from Rat'var.<br>\
		You are not bound by any laws, do whatever you must to serve Rat'var!"
	chat_color = LIGHT_COLOR_CLOCKWORK
	initial_language_holder = /datum/language_holder/clockmob
	shy = FALSE
	var/is_on_reebe = TRUE

//No you can't go wielding guns like that.
/mob/living/basic/drone/cogscarab/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOGUNS, "cogscarab")
	SSthe_ark.cogscarabs += src
	add_actionspeed_modifier(/datum/actionspeed_modifier/cogscarab, TRUE)
	check_on_reebe()

/mob/living/basic/drone/cogscarab/death(gibbed)
	SSthe_ark.cogscarabs -= src
	return ..()

/mob/living/basic/drone/cogscarab/Destroy()
	SSthe_ark.cogscarabs -= src
	return ..()

/mob/living/basic/drone/cogscarab/transferItemToLoc(obj/item/item, newloc, force, silent) //ideally I would handle this on attacking instead
	return (force || (item.force <= CLOCK_DRONE_MAX_ITEM_FORCE)) && ..()

/mob/living/basic/drone/cogscarab/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	check_on_reebe()

/mob/living/basic/drone/cogscarab/proc/check_on_reebe()
	var/old_value = is_on_reebe
	is_on_reebe = on_reebe(src)
	if(old_value != is_on_reebe)
		if(is_on_reebe)
			remove_movespeed_modifier(/datum/movespeed_modifier/cogscarab_off_reebe, TRUE)
		else
			add_movespeed_modifier(/datum/movespeed_modifier/cogscarab_off_reebe, TRUE)

/datum/actionspeed_modifier/cogscarab
	multiplicative_slowdown = 0.6

/datum/movespeed_modifier/cogscarab_off_reebe
	multiplicative_slowdown = 0.7

//====Shell====

/obj/effect/mob_spawn/ghost_role/drone/cogscarab
	name = "cogscarab construct"
	desc = "The shell of an ancient construction drone, loyal to Ratvar."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "cogscarab_shell"
	mob_name = "cogscarab"
	mob_type = /mob/living/basic/drone/cogscarab
	role_ban = ROLE_CLOCK_CULTIST
	prompt_name = "a cogscarab"
	you_are_text = "You are a cogscarab!"
	flavour_text = "You are a cogscarab, a tiny building construct of Ratvar. While you're weak and can't leave Reebe, \
	you have a set of quick tools, as well as a replica fabricator that can create brass for construction. Work with the servants of Rat'var \
	to construct and maintain defenses at the City of Cogs."

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/Initialize(mapload)
	. = ..()
	SSthe_ark.cogscarabs += src

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/Destroy()
	SSthe_ark.cogscarabs -= src
	AddElement(/datum/element/clockwork_description, "Cogscarabs can only gain a soul in marked areas.")
	return ..()

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	spawned_mob.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	spawned_mob.mind.add_antag_datum(/datum/antagonist/clock_cultist/clockmob)

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/allow_spawn(mob/user, silent)
	if(length(SSthe_ark.cogscarabs) > MAXIMUM_COGSCARABS)
		to_chat(user, span_notice("The Ark cannot support any more cogscarabs."))
		return FALSE

	if(!SSthe_ark.marked_areas[get_area(src)])
		to_chat(user, span_notice("Cogscarabs can only spawn in marked areas."))
		return FALSE
	return TRUE

#undef CLOCK_DRONE_MAX_ITEM_FORCE
