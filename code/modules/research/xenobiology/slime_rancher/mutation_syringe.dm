/// One-shot syringe that permanently changes how a single slime behaves.
/obj/item/slime_mutation_syringe
	name = "slime mutation syringe"
	desc = "Infuses a mutation into a slime."
	icon = 'icons/obj/science/mutation_syringe.dmi'
	icon_state = "mutation_syringe"
	w_class = WEIGHT_CLASS_SMALL
	var/used = FALSE

/obj/item/slime_mutation_syringe/examine(mob/user)
	. = ..()
	if(used)
		. += span_warning("It has been completely used up.")

/obj/item/slime_mutation_syringe/interact_with_atom(mob/living/basic/slime/target, mob/living/user, list/modifiers)
	if(!isslime(target))
		return NONE
	if(used)
		balloon_alert(user, "used up!")
		return ITEM_INTERACT_BLOCKING
	if(target.stat == DEAD)
		balloon_alert(user, "it's dead!")
		return ITEM_INTERACT_BLOCKING
	if(already_applied(target))
		balloon_alert(user, "already has it!")
		return ITEM_INTERACT_BLOCKING
	apply_mutation(target)
	used = TRUE
	icon_state = "[initial(icon_state)]-empty"
	ADD_TRAIT(src, TRAIT_TRASH_ITEM, INNATE_TRAIT)
	user.balloon_alert_to_viewers("injected mutator")
	to_chat(user, span_notice("You inject [target] with [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/slime_mutation_syringe/proc/already_applied(mob/living/basic/slime/target)
	return FALSE

/obj/item/slime_mutation_syringe/proc/apply_mutation(mob/living/basic/slime/target)
	return

/obj/item/slime_mutation_syringe/cleaner
	name = "cleaner slime mutation syringe"
	icon_state = "cleaner_syringe"

/obj/item/slime_mutation_syringe/cleaner/already_applied(mob/living/basic/slime/target)
	return target.cleaner_slime

/obj/item/slime_mutation_syringe/cleaner/apply_mutation(mob/living/basic/slime/target)
	target.set_cleaner_slime(TRUE)

/obj/item/slime_mutation_syringe/gooey_cat
	name = "gooey cat slime mutation syringe"
	icon_state = "gooey_cat_syringe"

/obj/item/slime_mutation_syringe/gooey_cat/already_applied(mob/living/basic/slime/target)
	return target.cat_slime

/obj/item/slime_mutation_syringe/gooey_cat/apply_mutation(mob/living/basic/slime/target)
	target.cat_slime = TRUE
	// 0.5% chance for a witch hat, because cute
	if(!target.equipped_hat && prob(0.5))
		target.equip_hat(new /obj/item/clothing/head/wizard/marisa)
	target.regenerate_icons()
