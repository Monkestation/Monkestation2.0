/obj/item/food/egg/borer_egg
	name = "borer egg"
	desc = "An egg of a creature that is known to crawl inside of you, be careful."
	icon = 'icons/mob/borer/borer.dmi'
	icon_state = "brainegg"
	layer = BELOW_MOB_LAYER
	food_reagents = list(/datum/reagent/consumable/eggyolk = 2, /datum/reagent/consumable/eggwhite = 4, /datum/reagent/drug/methamphetamine/borer_version = 4)
	chick_throw_prob = 0 // please no
	food_buffs = STATUS_EFFECT_FOOD_HEALTH_LARGE
	preserved_food = TRUE // Egg Cuticle
	fresh_mutation = TRUE // If we dont set this to true the borers become chicken when incubated.
	obj_flags = NONE
	/// The spawner that ghosts use to actually get created
	var/obj/effect/mob_spawn/ghost_role/borer_egg/host_spawner

/obj/item/food/egg/borer_egg/Destroy(force)
	if(host_spawner)
		QDEL_NULL(host_spawner)
	return ..()

/obj/item/food/egg/borer_egg/attack_ghost(mob/user)
	if(host_spawner)
		host_spawner.attack_ghost(user)
	return ..()

/obj/item/food/egg/borer_egg/attack_self(mob/user, modifiers)
	to_chat(user, span_notice("You crush [src] within your grasp."))
	new /obj/effect/decal/cleanable/food/egg_smudge(user.drop_location())
	qdel(src)

/obj/effect/mob_spawn/ghost_role/borer_egg
	name = "borer egg"
	desc = "An egg of a creature that is known to crawl inside of you, be careful."
	icon = 'icons/mob/borer/borer.dmi'
	icon_state = "brainegg"
	layer = BELOW_MOB_LAYER
	density = FALSE
	mob_type = /mob/living/basic/cortical_borer
	role_ban = ROLE_CORTICAL_BORER
	show_flavor = TRUE
	prompt_name = "cortical borer"
	you_are_text = "You are a Cortical Borer."
	flavour_text = "You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! \
					You only grow/heal/talk when inside a host!"
	important_text = "As a borer, you have the option to be friendly or not. \n\
					Note that how you act will determine how a host responds. \n\
					Do not wordlessly resort to mechanics within a host. \n\
					You can talk to other borers using ; and your host by just speaking normally. \n\
					You are unable to speak outside of a host, but are able to emote."
	dont_be_a_shit = FALSE
	/// What the generation of the borer egg is
	var/generation = 0
	/// The egg that is attached to this mob spawn
	var/obj/item/food/egg/borer_egg/host_egg = /obj/item/food/egg/borer_egg
	/// The team we should make our borers join
	var/datum/team/cortical_borers/borer_team

/obj/effect/mob_spawn/ghost_role/borer_egg/Initialize(mapload)
	. = ..()
	host_egg = new(drop_location())
	host_egg.host_spawner = src
	forceMove(host_egg)
	var/area/src_area = get_area(src)
	if(src_area)
		notify_ghosts(
			"A cortical borer egg has been laid in \the [src_area.name].",
			source = src,
			action = NOTIFY_PLAY,
			notify_flags = (NOTIFY_CATEGORY_NOFLASH & ~GHOST_NOTIFY_NOTIFY_SUICIDERS),
			ignore_key = POLL_IGNORE_DRONE,
		)

/obj/effect/mob_spawn/ghost_role/borer_egg/Destroy()
	host_egg = null
	borer_team = null
	return ..()

/obj/effect/mob_spawn/ghost_role/borer_egg/special(mob/living/basic/cortical_borer/spawned_mob, mob/mob_possessor)
	spawned_mob.generation = generation
	. = ..()
	if(borer_team)
		var/datum/antagonist/cortical_borer/antag = spawned_mob.mind.has_antag_datum(/datum/antagonist/cortical_borer)
		borer_team.add_member(spawned_mob.mind, antag)
	qdel(host_egg)
