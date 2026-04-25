/obj/item/effect_granter/amogus
	name = "Amogus Yourself"
	icon_state = "nugget"

/obj/item/effect_granter/amogus/grant_effect(mob/living/carbon/granter)
	if(ismonkey(granter) || isgoblin(granter))
		to_chat(granter, span_notice("Sorry but your species is to small to be turned into amogus, you have not been charged."))
		return FALSE
	granter.apply_displacement_icon(/obj/effect/distortion/large/amogus)
	granter.AddElement(/datum/element/waddling)
	granter.can_be_held = TRUE
	return ..()
