/datum/action/cooldown/spell/summonitem/wonderland
	name = "Mind Your Things"
	desc = "A proper hunter does not misplace their tools. \
		Wonderland will fetch it for you, this once. \
		And the next time. \
		Do stop dropping it."
	invocation = "Everything in its place."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

/datum/action/cooldown/spell/summonitem/wonderland/mark_item(obj/to_mark)
	. = ..()
	astype(to_mark, /obj/item/melee/trick_weapon)?.bind_to_recall()
	name = initial(name)

/datum/action/cooldown/spell/summonitem/wonderland/try_recall_item(mob/living/caster)
	var/turf/origin = get_turf(marked_item)
	. = ..()
	if(isnull(origin))
		return
	var/turf/destination = get_turf(marked_item)
	if(isnull(origin) || origin == destination)
		return
	new /obj/effect/temp_visual/wonderland_hole(origin)
	new /obj/effect/temp_visual/rabbit_hole_stand_in(origin, marked_item)
	var/turf/caster_turf = get_turf(caster)
	new /obj/effect/temp_visual/wonderland_hole(caster_turf)
	new /obj/effect/temp_visual/rabbit_hole_stand_in(caster_turf, marked_item, TRUE, 0.5 SECONDS)

// can't unlink your trick weapon, sorry
/datum/action/cooldown/spell/summonitem/wonderland/try_unlink_item(mob/living/caster)
	return FALSE
