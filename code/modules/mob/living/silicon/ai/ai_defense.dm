
/mob/living/silicon/ai/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/ai_module))
		var/obj/item/ai_module/MOD = tool
		if(!mind) //A player mind is required for law procs to run antag checks.
			to_chat(user, span_warning("[src] is entirely unresponsive!"))
			return ITEM_INTERACT_BLOCKING
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
		return ITEM_INTERACT_SUCCESS

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
