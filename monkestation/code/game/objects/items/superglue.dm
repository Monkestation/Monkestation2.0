/obj/item/syndie_glue
	name = "bottle of super glue"
	desc = "A black market brand of high strength adhesive, rarely sold to the public. Do not ingest."
	icon = 'monkestation/icons/obj/tools.dmi'
	icon_state	= "glue"
	w_class = WEIGHT_CLASS_SMALL
	var/uses = 1

/obj/item/syndie_glue/suicide_act(mob/living/carbon/M)
	return //todo

/obj/item/syndie_glue/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(uses == 0)
		to_chat(user, "<span class='warning'>The bottle of glue is empty!</span>")
		return ITEM_INTERACT_BLOCKING
	if(!isitem(interacting_with))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/thingy = interacting_with
	if(HAS_TRAIT_FROM(thingy, TRAIT_NODROP, GLUED_ITEM_TRAIT))
		to_chat(user, "<span class='warning'>[interacting_with] is already sticky!</span>")
		return ITEM_INTERACT_BLOCKING
	uses -= 1
	ADD_TRAIT(thingy, TRAIT_NODROP, GLUED_ITEM_TRAIT)
	thingy.desc += " It looks sticky."
	to_chat(user, "<span class='notice'>You smear the [thingy] with glue, making it incredibly sticky!</span>")
	if(uses <= 0)
		icon_state = "glue_used"
		name = "empty bottle of super glue"
		ADD_TRAIT(src, TRAIT_TRASH_ITEM, INNATE_TRAIT)
	return ITEM_INTERACT_SUCCESS
