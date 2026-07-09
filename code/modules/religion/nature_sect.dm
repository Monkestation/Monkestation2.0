/datum/religion_sect/plant_sect
	name = "Nature"
	desc = "A sect dedicated to nature, plants, and animals. Sacrificing seeds grants you favor."
	quote = "Living plant people? What has the world come to!"
	tgui_icon = "tree"
	alignment = ALIGNMENT_GOOD
	max_favor = 10000
	desired_items = list(
		/obj/item/food/grown,)
	rites_list = list(
		/datum/religion_rites/create_sandstone,
		/datum/religion_rites/summon_animals,
		/datum/religion_rites/photogeist,
		/datum/religion_rites/create_podperson,
		/datum/religion_rites/grass_generator,)
	altar_icon_state = "convertaltar-green"

//plant bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/plant_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/plant_sect/on_sacrifice(obj/item/N, mob/living/L)
	if(!istype(N, /obj/item/food/grown))
		return
	adjust_favor(25, L)
	to_chat(L, span_notice("You offer [N] to [GLOB.deity], pleasing them and gaining 25 favor in the process."))
	qdel(N)
	return TRUE
/**** Plant rites ****/
/datum/religion_rites/summon_animals
	name = "Create Life"
	desc = "Creates a few animals, this can range from butterflys to giant frogs! Please be careful."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Great Mother ...",
		"... bring us new life ...",
		"... to join with our nature ...",
		"... and live amongst us ...")
	invoke_msg = "... We summon thee, Animals from the Byond!" //might adjust to beyond due to ooc/ic/meta
	favor_cost = 250

/datum/religion_rites/summon_animals/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/bluespace_fissure/long(altar_turf)
	user.visible_message(span_notice("A tear in reality appears above the altar!"))
	return ..()

/datum/religion_rites/summon_animals/invoke_effect(mob/living/user, atom/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 8)
		var/mob/living/spawned_mob = create_random_mob(altar_turf, FRIENDLY_SPAWN)
		spawned_mob.faction |= FACTION_NEUTRAL
	playsound(altar_turf, 'sound/ambience/servicebell.ogg', 25, TRUE)
	if(prob(0.1))
		playsound(altar_turf, 'sound/effects/bamf.ogg', 100, TRUE)
		altar_turf.visible_message(span_boldwarning("A large form seems to be forcing its way into your reality via the portal [user] opened! RUN!!!"))
		new /mob/living/simple_animal/hostile/jungle/leaper(altar_turf)
	return ..()

/datum/religion_rites/create_sandstone
	name = "Create Sandstone"
	desc = "Create Sandstone for soil production to help create a plant garden."
	ritual_length = 35 SECONDS
	ritual_invocations = list(
		"Bring to us ...",
		"... the stone we need ...",
		"... so we can toil away ...",
	)
	invoke_msg = "and spread many seeds."
	favor_cost = 100

/datum/religion_rites/create_sandstone/invoke_effect(mob/living/user, atom/religious_tool)
	new /obj/item/stack/sheet/mineral/sandstone/thirty(get_turf(religious_tool))
	playsound(get_turf(religious_tool), 'sound/effects/pop_expl.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/grass_generator
	name = "Blessing of Nature"
	desc = "Summon a moveable object that slowly generates grass and fairy-grass around itself while healing anyone nearby."
	ritual_length = 60 SECONDS
	ritual_invocations = list(
		"Let the plantlife grow ...",
		"... let it grow across the land ...",
		"... far and wide it shall spread ...",
		"... show us true nature ...",
		"... and we shall worship it all ...")
	invoke_msg = "... in our own personal haven."
	favor_cost = 1000

/datum/religion_rites/grass_generator/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/open/T = get_turf(religious_tool)
	if(istype(T))
		new /obj/structure/destructible/religion/nature_pylon(T)
	return ..()

/datum/religion_rites/create_podperson
	name = "Nature Conversion"
	desc = "Convert a human-esque individual into a being of nature. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"By the power of nature ...",
		"... We call upon you, in this time of need ...",
		"... to merge us with all that is natural ...",
	)
	invoke_msg = "... May the grass be greener on the other side, show us what it means to be one with nature!!"
	favor_cost = 500

/datum/religion_rites/create_podperson/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,span_warning("You're going to convert the one buckled on [movable_reltool]."))
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,span_warning("This rite requires a religious device that individuals can be buckled to."))
			return FALSE
		if(ispodperson(user))
			to_chat(user,span_warning("You've already converted yourself. To convert others, they must be buckled to [movable_reltool]."))
			return FALSE
		to_chat(user,span_warning("You're going to convert yourself with this ritual."))
	return ..()

/datum/religion_rites/create_podperson/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/pod)
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE

/datum/religion_rites/photogeist
	name = "Summon Photogeist"
	desc = "Summons forth a holy photogeist that can heal fellow creatures. Note, it will be dormant till a ghost inhabits it, and it only understands Sylvan."
	ritual_length = 15 SECONDS
	invoke_msg = "please, great kudzu, give us an angel to watch over us."
	favor_cost = 400

/datum/religion_rites/photogeist/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/effect/mob_spawn/ghost_role/photogeist(altar_turf)
	return TRUE
