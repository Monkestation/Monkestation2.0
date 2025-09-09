//Blight: Taints nearby humans and in general messes living stuff up.
/datum/action/cooldown/spell/aoe/revenant/blight
	name = "Blight"
	desc = "Taints the area causing nearby living things to waste away."
	button_icon_state = "blight"
	cooldown_time = 20 SECONDS

	aoe_radius = 3
	cast_amount = 50
	unlock_amount = 75

/datum/action/cooldown/spell/aoe/revenant/blight/cast_on_thing_in_aoe(turf/victim, mob/living/basic/revenant/caster)
	for(var/mob/living/mob in victim)
		if(mob == caster)
			continue
		if(mob.can_block_magic(antimagic_flags))
			to_chat(caster, span_warning("The spell had no effect on [mob]!"))
			continue
		if(HAS_TRAIT(mob, TRAIT_REVENANT_BLIGHT_PROTECTION))
			to_chat(mob, span_revenminor("Your body is tingling, you feel a cold sensation envelope you before passing."))
			to_chat(caster, span_warning("[mob] seems to have holy energy still flowing through them."))
			continue
		new /obj/effect/temp_visual/revenant(mob.loc)
		if(iscarbon(mob))
			if(ishuman(mob))
				mob.apply_status_effect(/datum/status_effect/revenant_blight) // Applies blight or increase severity.
			else
				mob.reagents?.add_reagent(/datum/reagent/toxin/plasma, 5)
		else
			mob.adjustToxLoss(5)
	for(var/obj/structure/spacevine/vine in victim) //Fucking with botanists, the ability.
		vine.add_atom_colour(COLOR_REVENANT_PLANTBLIGHT, TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(vine.loc)
		QDEL_IN(vine, 1 SECOND)
	for(var/obj/structure/glowshroom/shroom in victim)
		shroom.add_atom_colour(COLOR_REVENANT_PLANTBLIGHT, TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(shroom.loc)
		QDEL_IN(shroom, 1 SECOND)
	for(var/atom/movable/tray in victim)
		if(!tray.GetComponent(/datum/component/plant_growing))
			continue

		new /obj/effect/temp_visual/revenant(tray.loc)
		SEND_SIGNAL(tray, COMSIG_GROWING_ADJUST_TOXIN, rand(45, 55))
		SEND_SIGNAL(tray, COMSIG_GROWING_ADJUST_PEST, rand(8, 10))
		SEND_SIGNAL(tray, COMSIG_GROWING_ADJUST_WEED, rand(8, 10))
