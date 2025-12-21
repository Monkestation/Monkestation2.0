/datum/component/abberant_eater
	var/list/extra_foods = list()
	var/excluding_subtypes = FALSE
	var/nutritional_value = 10

/datum/component/abberant_eater/Initialize(list/food_list, exclude_subtypes = FALSE, nutritional_value = 10)
	if(!length(food_list))
		return COMPONENT_INCOMPATIBLE
	src.nutritional_value = nutritional_value
	src.excluding_subtypes = exclude_subtypes
	extra_foods = excluding_subtypes ? typecacheof(food_list, only_root_path = TRUE) : food_list

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(try_eat))

/datum/component/abberant_eater/proc/try_eat(mob/living/nerd, obj/item/weapon, mob/living/attacker)
	if(nerd.istate & ISTATE_HARM)
		return FALSE
	if(nerd != attacker)
		return FALSE

	var/can_we_eat = excluding_subtypes ? is_type_in_typecache(weapon, extra_foods) : is_type_in_list(weapon, extra_foods)
	if(!can_we_eat)
		return FALSE

	var/eatverb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	nerd.nutrition += nutritional_value

	switch(nerd.nutrition)
		if(NUTRITION_LEVEL_FAT to INFINITY)
			nerd.visible_message(span_notice("[nerd] forces [nerd.p_them()]self to eat \the [weapon]"), span_notice("You force yourself to eat \the [weapon]"))
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_FAT)
			nerd.visible_message(span_notice("[nerd] [eatverb]s \the [weapon]]."), span_notice("You [eatverb] \the [weapon]."))
		if(0 to NUTRITION_LEVEL_STARVING)
			nerd.visible_message(span_notice("[nerd] hungrily [eatverb]s \the [weapon], gobbling it down!"), span_notice("You hungrily [eatverb] \the [weapon], gobbling it down!"))
			nerd.changeNext_move(CLICK_CD_MELEE * 0.5)
	qdel(weapon)
	playsound(nerd.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	return COMPONENT_NO_AFTERATTACK
