/datum/action/cooldown/spell/pointed/wraith/absorb_corpse
	name = "Absorb Corpse"
	desc = "Consume a dead, not completelly decayed target's soul to permanently gain more essence regeneration."
	button_icon_state = "absorb_corpse"

	essence_cost = 20
	cooldown_time = 45 SECONDS

/datum/action/cooldown/spell/pointed/wraith/absorb_corpse/before_cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!ismob(cast_on))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

	if(!istype(cast_on))
		to_chat(owner, span_warning("[cast_on]'s soul is unworthy of harvest."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

	if(cast_on.soul_sucked || !cast_on.mind)
		to_chat(owner, span_warning("[cast_on] does not possess a soul!"))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

	if(cast_on.stat != DEAD)
		to_chat(owner, span_warning("This human is not dead. You can't steal their soul."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

	var/obj/item/organ/internal/heart/target_heart = cast_on.get_organ_slot(ORGAN_SLOT_HEART)
	if(!target_heart || target_heart?.damage >= target_heart.maxHealth)
		to_chat(owner, span_warning("This human is too decayed to have their soul harvested."))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/absorb_corpse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!istype(cast_on)) // what happen
		return

	cast_on.soul_sucked = TRUE
	cast_on.visible_message(span_warning("[cast_on] floats into the air, as they rapidly go pale!"))
	animate(cast_on, 3 SECONDS, pixel_y = cast_on.pixel_y + 16)
	sleep(5 SECONDS)

	if(HAS_TRAIT(cast_on, TRAIT_USES_SKINTONES)) // make them deathly white, afterall they dont have a soul anymore
		cast_on.skin_tone = "albino"
		cast_on.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
	else
		var/datum/color_palette/generic_colors/located = cast_on.dna.color_palettes[/datum/color_palette/generic_colors]
		located.mutant_color = "#FFFFFF"

	cast_on.update_body(is_creating = TRUE)

	animate(cast_on, 0.5 SECOND, pixel_y = cast_on.pixel_y - 16)
	cast_on.visible_message("[cast_on] lands with a loud thud on the floor!")

	to_chat(owner, span_revennotice("You successfully consumed [cast_on]'s soul!"))

	cooldown_time += 15 SECONDS
	var/mob/living/basic/wraith/true_owner = owner
	if(istype(true_owner))
		true_owner.essence_gain += 2
		true_owner.eaten_corpses++
