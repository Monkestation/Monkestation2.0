/obj/item/effect_granter/jaundice
	name = "Jaundice Yourself"
	icon_state = "jaundice"

/obj/item/effect_granter/jaundice/grant_effect(mob/living/carbon/granter)
	if(!HAS_TRAIT(granter, TRAIT_USES_SKINTONES))
		to_chat(granter, span_notice("Sorry but your skin can not visibly turn jaundiced!"))
		return FALSE

	var/mob/living/carbon/human/jaundiced_human = granter
	jaundiced_human.skin_tone = "simpsons_yellow"
	jaundiced_human.update_body(is_creating = TRUE)
	. = ..()
