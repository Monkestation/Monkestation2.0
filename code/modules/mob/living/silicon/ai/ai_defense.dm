
/mob/living/silicon/ai/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/ai_module))
		var/obj/item/ai_module/MOD = attacking_item
		if(!mind) //A player mind is required for law procs to run antag checks.
			to_chat(user, span_warning("[src] is entirely unresponsive!"))
			return
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
		return

	return ..()

/mob/living/silicon/ai/blob_act(obj/structure/blob/B)
	return FALSE

/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	return FALSE

/mob/living/silicon/ai/emp_act(severity)
	return

/mob/living/silicon/ai/ex_act(severity, target)
	return

/mob/living/silicon/ai/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash, length = 25)
	return // no eyes, no flashing

/mob/living/silicon/ai/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if((user.istate & ISTATE_HARM))
		return
	balloon_alert(user, "[!is_anchored ? "tightening" : "loosening"] bolts...")
	balloon_alert(src, "bolts being [!is_anchored ? "tightened" : "loosened"]...")
	if(!tool.use_tool(src, user, 4 SECONDS))
		return ITEM_INTERACT_SUCCESS
	flip_anchored()
	balloon_alert(user, "bolts [is_anchored ? "tightened" : "loosened"]")
	balloon_alert(src, "bolts [is_anchored ? "tightened" : "loosened"]")
	return ITEM_INTERACT_SUCCESS
