/mob/living/carbon/slip(knockdown_amount, obj/slipped_on, lube_flags, paralyze, force_drop = FALSE)
	if(movement_type & (FLYING | FLOATING))
		return FALSE
	if(!(lube_flags & SLIDE_ICE))
		log_combat(src, (slipped_on || get_turf(src)), "slipped on the", null, ((lube_flags & SLIDE) ? "(SLIDING)" : null))
	..()
	return loc.handle_slip(src, knockdown_amount, slipped_on, lube_flags, paralyze, force_drop)

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(!. || (movement_type & FLOATING)) //floating is easy
		return
	if(nutrition <= 0 || stat == DEAD)
		return
	var/hunger_loss = HUNGER_FACTOR / 10
	if(m_intent != MOVE_INTENT_WALK)
		hunger_loss *= 2
	adjust_nutrition(-1 * hunger_loss)

/mob/living/carbon/set_usable_legs(new_value)
	. = ..()
	if(isnull(.))
		return
	if(. == 0)
		if(usable_legs != 0) //From having no usable legs to having some.
			REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(usable_legs == 0 && !(movement_type & (FLYING | FLOATING))) //From having usable legs to no longer having them.
		ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		if(!usable_hands)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)


/mob/living/carbon/set_usable_hands(new_value)
	. = ..()
	if(isnull(.))
		return
	if(. == 0)
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
	else if(usable_hands == 0 && default_num_hands > 0) //From having usable hands to no longer having them.
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)

/mob/living/carbon/on_movement_type_flag_enabled(datum/source, flag, old_movement_type)
	. = ..()
	if(movement_type & (FLYING | FLOATING) && !(old_movement_type & (FLYING | FLOATING)))
		update_limbless_locomotion()
		update_limbless_movespeed_mod()

/mob/living/carbon/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	. = ..()
	if(old_movement_type & (FLYING | FLOATING) && !(movement_type & (FLYING | FLOATING)))
		update_limbless_locomotion()
		update_limbless_movespeed_mod()
