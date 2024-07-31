GLOBAL_LIST_EMPTY_TYPED(infected_cleanables, /obj/effect/decal/cleanable)

/obj/effect/decal/cleanable/Initialize(mapload, list/datum/disease/diseases)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/decal/cleanable/LateInitialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(handle_pathogen_images)), 0.1 SECONDS, TIMER_DELETE_ME)

/obj/effect/decal/cleanable/proc/handle_pathogen_images()
	if(!length(diseases))
		return
	GLOB.infected_cleanables += src
	if(!pathogen)
		pathogen = image('monkestation/code/modules/virology/icons/effects.dmi', src, "pathogen_blood")
		pathogen.plane = HUD_PLANE
		pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
	for (var/mob/wearer in GLOB.science_goggles_wearers)
		wearer.client?.images |= pathogen

/obj/effect/decal/cleanable/Destroy()
	GLOB.infected_cleanables -= src
	return ..()

/obj/effect/decal/cleanable/Entered(mob/living/perp)
	..()
	infection_attempt(perp)

/obj/effect/decal/cleanable/infection_attempt(mob/living/perp)
	//Now if your feet aren't well protected, or are bleeding, you might get infected.
	var/block = 0
	var/bleeding = 0
	if (perp.body_position & LYING_DOWN)
		block = perp.check_contact_sterility(BODY_ZONE_EVERYTHING)
		bleeding = perp.check_bodypart_bleeding(BODY_ZONE_EVERYTHING)
	else
		block = perp.check_contact_sterility(BODY_ZONE_LEGS)
		bleeding = perp.check_bodypart_bleeding(BODY_ZONE_LEGS)

	for(var/datum/disease/advanced/contained_virus as anything in diseases)
		if (!block && (contained_virus.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
			perp.infect_disease(contained_virus, notes="(Contact, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over [src]])")
		else if (bleeding && (contained_virus.spread_flags & DISEASE_SPREAD_BLOOD))
			perp.infect_disease(contained_virus, notes="(Blood, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over [src]])")
