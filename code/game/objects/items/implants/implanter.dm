/**
 * Players can use this item to put obj/item/implant's in living mobs. Can be renamed with a pen.
 */
/obj/item/implanter
	name = "implanter"
	desc = "A sterile automatic implant injector."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "implanter0"
	inhand_icon_state = "syringe_0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 6, /datum/material/glass=SMALL_MATERIAL_AMOUNT *2)
	///The implant in our implanter
	var/obj/item/implant/imp = null
	///Type of implant this will spawn as imp upon being spawned
	var/imp_type = null

/obj/item/implanter/update_icon_state()
	icon_state = "implanter[imp ? 1 : 0]"
	return ..()

/obj/item/implanter/attack(mob/living/target, mob/user)
	if(!(istype(target) && user && imp))
		return

	if(target != user)
		target.visible_message(span_warning("[user] is attempting to implant [target]."))
		if(!do_after(user, 5 SECONDS, target))
			return

	if(!(src && imp))
		return

	if(imp.implant(target, user))
		if (target == user)
			to_chat(user, span_notice("You implant yourself."))
		else
			target.visible_message(span_notice("[user] implants [target]."), span_notice("[user] implants you."))
		imp = null
		update_appearance()
	else
		to_chat(user, span_warning("[src] fails to implant [target]."))

/obj/item/implanter/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!IS_WRITING_UTENSIL(tool))
		return NONE
	if(!user.can_write(tool))
		return ITEM_INTERACT_BLOCKING

	var/new_name = tgui_input_text(user, "What would you like the label to be?", name, max_length = MAX_NAME_LEN)
	if(user.get_active_held_item() != tool)
		return ITEM_INTERACT_BLOCKING
	if(!user.can_perform_action(src))
		return ITEM_INTERACT_BLOCKING
	if(new_name)
		name = "implanter ([new_name])"
	else
		name = "implanter"
	return ITEM_INTERACT_SUCCESS

/obj/item/implanter/Initialize(mapload)
	. = ..()
	if(!imp && imp_type)
		imp = new imp_type(src)
	update_appearance()
