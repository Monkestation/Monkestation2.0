/datum/action/cooldown/spell/pointed/conjure/hex
	name = "Conjure Hex"
	desc = "Build a lesser construct to defend an area."

	school = SCHOOL_CONJURATION
	cooldown_time = 2 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	cast_range = 3
	cast_delay = 6 SECONDS
	summon_type = list(/mob/living/simple_animal/hostile/hex)


/datum/action/cooldown/spell/pointed/conjure/hex/post_summon(mob/living/simple_animal/hostile/hex/AM, mob/user)
	var/mob/living/basic/construct/artificer/perfect/builder = owner
	AM.master = builder
	AM.no_master = FALSE
	builder.minions.Add(AM)
	AM.setupglow(builder.construct_color)
	if (builder.minions.len >= 3)
		var/mob/living/simple_animal/hostile/hex/SA = builder.minions[1]
		builder.minions.Remove(SA)
		SA.master = null//The old hex will crumble on its own within the next 10 seconds.

	if (IS_CULTIST(builder))
		builder.DisplayUI("Cultist Right Panel")

	var/datum/antagonist/cult/cult_datum = user?.mind.has_antag_datum(/datum/antagonist/cult)
	cult_datum?.gain_devotion(40, DEVOTION_TIER_2, "summon_hex", AM)

/datum/action/cooldown/spell/pointed/conjure/struct
	name = "Conjure Structure"
	desc = "Raise a cult structure that you may then operate, such as an altar, a forge, or a spire."


	cast_range = 4
	cast_delay = 12 SECONDS
	summon_type = list(/obj/structure/cult/altar)

	school = SCHOOL_CONJURATION
	cooldown_time = 120 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	var/structure


/datum/action/cooldown/spell/pointed/conjure/struct/PreActivate(atom/target)
	if (locate(/obj/structure/cult) in range(owner, 1))
		to_chat(owner, span_warning("You cannot perform this ritual that close from another similar structure.") )
		return 1
	var/turf/T = owner.loc
	if (!istype(T))
		return 1
	var/list/choices = list(
		list("Altar", "radial_altar", "Allows for crafting soul gems, and performing various other cult rituals."),
		list("Spire", "radial_spire", "Allows all cultists in the level to communicate with each others using :x"),
		list("Forge", "radial_forge", "Enables the forging of cult blades and armor, as well as new construct shells. Raise the temperature of nearby creatures."),
	)

	var/list/made_choices = list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi', icon_state = choice[2])
		option.info = span_boldnotice(choice[3])
		made_choices[choice[1]] = option

	structure = show_radial_menu(owner, T, made_choices, 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi', "radial-cult")
	if (!T.Adjacent(owner) || !structure )
		return 1
	switch(structure)
		if("Altar")
			summon_type = list(/obj/structure/cult/altar)
		if("Spire")
			summon_type = list(/obj/structure/cult/spire)
		if("Forge")
			summon_type = list(/obj/structure/cult/forge)
	return Activate(target)

/datum/action/cooldown/spell/pointed/conjure/struct/post_summon(atom/movable/AM, mob/user)
	var/datum/antagonist/cult/cult_datum = user?.mind.has_antag_datum(/datum/antagonist/cult)
	cult_datum?.gain_devotion(10, DEVOTION_TIER_1, "raise_structure", structure)

/datum/action/cooldown/spell/pointed/conjure/pylon
	name = "Conjure Pylon"
	desc = "This spell conjures a fragile crystal from Nar-Sie's realm. Makes for a convenient light source, or a weak obstacle."

	school = SCHOOL_CONJURATION
	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	cast_range = 4
	cast_delay = 10 SECONDS
	summon_type = list(/obj/structure/cult/pylon)


/datum/action/cooldown/spell/pointed/conjure/pylon/post_summon(atom/movable/AM, mob/user)
	var/datum/antagonist/cult/cult_datum = user?.mind.has_antag_datum(/datum/antagonist/cult)
	cult_datum?.gain_devotion(10, DEVOTION_TIER_1, "raise_structure", "Pylon")


/datum/action/cooldown/spell/pointed/conjure/door
	name = "Conjure Door"
	desc = "This spell conjures a cult door. Those automatically open and close upon the passage of a cultist, construct or shade."
	school = SCHOOL_CONJURATION
	cooldown_time = 25 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	cast_range = 1
	cast_delay = 4 SECONDS

	summon_type = list(/obj/machinery/door/airlock/cult)



/datum/action/cooldown/spell/pointed/conjure/door/conjure_animation(obj/effect/abstract/animation, turf/target)
	animation.icon_state = ""
	flick("", animation)
	shadow(target, owner.loc, "artificer_convert")
	spawn(10)
		QDEL_NULL(animation)

/datum/action/cooldown/spell/pointed/conjure/door/post_summon(atom/movable/AM, mob/user)
	var/datum/antagonist/cult/cult_datum = user?.mind.has_antag_datum(/datum/antagonist/cult)
	cult_datum?.gain_devotion(10, DEVOTION_TIER_1, "summon_door", AM)
