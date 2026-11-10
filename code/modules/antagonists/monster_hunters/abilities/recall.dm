/datum/action/cooldown/spell/summonitem/wonderland
	name = "Summon Trick Weapon"
	desc = "Beckon forth to your trick weapon, having it fall into your hands."

/datum/action/cooldown/spell/summonitem/wonderland/try_recall_item(mob/living/caster)
	var/obj/recalled = marked_item
	var/turf/origin = get_turf(recalled)
	. = ..()
	var/turf/destination = get_turf(recalled)
	if(!origin || origin == destination)
		return
	new /obj/effect/temp_visual/wonderland_hole(origin)
	new /obj/effect/temp_visual/rabbit_hole_stand_in(origin, recalled)
	var/turf/caster_turf = get_turf(caster)
	new /obj/effect/temp_visual/wonderland_hole(caster_turf)
	new /obj/effect/temp_visual/rabbit_hole_stand_in(caster_turf, recalled, TRUE, 0.5 SECONDS)

// can't unlink your trick weapon, sorry
/datum/action/cooldown/spell/summonitem/wonderland/try_unlink_item(mob/living/caster)
	return FALSE
