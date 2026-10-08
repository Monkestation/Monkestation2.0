/datum/religion_sect/hunt
	name = "The Hunt"
	desc = "Hunt for the sake of the Hunt. The cycle of predator and prey will always continue"
	quote = "Go my Hunters! There is prey to be felled"
	tgui_icon = "leaf"
	altar_icon_state = "convertaltar-hunt"
	alignment = ALIGNMENT_NEUT
	candle_overlay = FALSE
	desired_items = list(/obj/item/food/meat/religioustrophy)
	max_favor = 25
	rites_list = list(
		/datum/religion_rites/initiate_hunter,
		/datum/religion_rites/call_the_hunt,
		/datum/religion_rites/craft_hunters_atlatl,
		/datum/religion_rites/carve_spears,
	)

/datum/religion_sect/hunt/on_conversion(mob/living/chap)
	. = ..()
	new /obj/item/knife/hunting(get_turf(chap))

/datum/religion_sect/hunt/on_sacrifice(obj/item/I, mob/living/user)
	to_chat(user, span_notice("A worthy offering for [GLOB.deity]. You have done well Hunter"))
	adjust_favor(3, user)
	qdel(I)
	return TRUE
