/datum/material_trait/serrated
	name = "Serrated"
	desc = "Adds 10 to wound bonus."
	reforges = 6
	value_bonus = 25
	examine_text = "Looks unpleasant to be cut by."

/datum/material_trait/serrated/post_parent_init(atom/movable/parent)
	if(isitem(parent))
		var/obj/item/item = parent
		item.wound_bonus += 10
