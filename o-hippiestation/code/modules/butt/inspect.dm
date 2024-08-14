/mob/living/carbon/human/grabbedby(mob/living/carbon/user, supress_message)
	if(check_inspect_butt(user))
		return
	return ..()

/mob/living/carbon/human/proc/check_inspect_butt(mob/living/carbon/user)
	if(user.zone_selected != BODY_ZONE_PRECISE_GROIN || w_uniform)
		return FALSE

	var/obj/item/organ/internal/butt/B = get_organ_by_type(/obj/item/organ/internal/butt)
	if(!B)
		to_chat(user, span_warning("There is nothing to inspect!"))
		return FALSE

	user.visible_message(span_warning("[user] starts inspecting [user == src ? "his own" : "[src]'s"] ass!"), span_warning("You start inspecting [user == src ? "your" : "[src]'s"] ass!"))
	if(!do_after(user, 40, src))
		return TRUE //stops people from being pulled while not adjacent
	if(B.open_butt_pocket(user))
		return TRUE
	return FALSE

