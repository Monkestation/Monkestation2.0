// Swaps the AI core to a ghost role and vice versa
/obj/structure/ai_core/deactivated/attackby(obj/item/P, mob/user, params)
	if((P.tool_behaviour == TOOL_MULTITOOL) && (state = AI_READY_CORE))
		if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
			to_chat(user, span_warning("Central Command has temporarily outlawed posibrain sentience in this sector..."))
		new /obj/effect/mob_spawn/ghost_role/ai_core_searching(src.loc)
		qdel(src)

/obj/effect/mob_spawn/ghost_role/ai_core_searching
	name = "AI Personality"
	desc = "A dormant artifical personality on the NTnet. Capable of interfacing with various station electronics and preform tasks."
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai-empty"
	layer = BELOW_MOB_LAYER
	density = TRUE
	mob_name = "AI core"
	mob_type = /mob/living/silicon/ai/spawned
	role_ban = ROLE_POSITRONIC_BRAIN
	show_flavor = FALSE
	prompt_name = "AI Personality"
	you_are_text = "You are a Artifical intelligence."
	flavour_text = "A dormant artifical personality on the NTnet. A signal from a station is being sent out requesting assistance."
	important_text = "You MUST read and follow your laws carefully."
	spawner_job_path = /datum/job/ai

/obj/effect/mob_spawn/ghost_role/ai_core_searching/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_MULTITOOL)
		if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
			to_chat(user, span_warning("Central Command has temporarily outlawed posibrain sentience in this sector..."))
		new /obj/structure/ai_core/deactivated(src.loc)
		qdel(src)
