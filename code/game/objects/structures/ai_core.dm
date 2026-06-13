#define AI_CORE_BRAIN(X) X.braintype == "Android" ? "brain" : "MMI"

/obj/structure/ai_core
	density = TRUE
	anchored = FALSE
	name = "\improper AI core"
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "0"
	desc = "The framework for an artificial intelligence core."
	max_integrity = 500
	var/state = EMPTY_CORE
	var/datum/ai_laws/laws
	var/obj/item/mmi/core_mmi
	var/can_deconstruct = FALSE

/obj/structure/ai_core/Initialize(mapload)
	. = ..()
	laws = new
	laws.set_laws_config()

/obj/structure/ai_core/examine(mob/user)
	. = ..()
	if(anchored)
		return .
	if(state != EMPTY_CORE)
		. += span_notice("It has some <b>bolts</b> that could be tightened.")
	else
		. += span_notice("It has some <b>bolts</b> that could be tightened. The frame can be <b>melted</b> down.")

/obj/structure/ai_core/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == core_mmi)
		core_mmi = null
		update_appearance()

/obj/structure/ai_core/Destroy()
	QDEL_NULL(core_mmi)
	QDEL_NULL(laws)
	return ..()

/obj/structure/ai_core/latejoin_inactive
	name = "networked AI beacon"
	desc = "This machine is connected by bluespace transmitters to NTNet, allowing for an AI personality to be downloaded to it on the fly mid-shift."
	anchored = TRUE
	state = AI_READY_CORE
	var/available = TRUE
	var/safety_checks = TRUE
	var/active = TRUE

/obj/structure/ai_core/latejoin_inactive/Initialize(mapload)
	. = ..()
	circuit = new(src)
	core_mmi = new(src)
	core_mmi.brain = new(core_mmi)
	core_mmi.update_appearance()
	GLOB.latejoin_ai_cores += src

/obj/structure/ai_core/latejoin_inactive/Destroy()
	GLOB.latejoin_ai_cores -= src
	return ..()

/obj/structure/ai_core/latejoin_inactive/examine(mob/user)
	. = ..()
	. += "Its transmitter seems to be <b>[active? "on" : "off"]</b>."
	. += span_notice("You could [active? "deactivate" : "activate"] it with a multitool.")

/obj/structure/ai_core/latejoin_inactive/proc/is_available() //If people still manage to use this feature to spawn-kill AI latejoins ahelp them.
	if(!available)
		return FALSE
	if(!safety_checks)
		return TRUE
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(!(A.area_flags & BLOBS_ALLOWED))
		return FALSE
	if(!A.power_equip)
		return FALSE
	if(!SSmapping.level_trait(T.z,ZTRAIT_STATION))
		return FALSE
	if(!isfloorturf(T))
		return FALSE
	return TRUE

/obj/structure/ai_core/latejoin_inactive/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_MULTITOOL)
		active = !active
		to_chat(user, span_notice("You [active? "activate" : "deactivate"] \the [src]'s transmitters."))
		return
	return ..()

/obj/structure/ai_core/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(state == AI_READY_CORE)
		if(!core_mmi)
			balloon_alert(user, "no brain installed!")
			return ITEM_INTERACT_SUCCESS
		else if(!core_mmi.brainmob?.mind || suicide_check())
			balloon_alert(user, "brain is inactive!")
			return ITEM_INTERACT_SUCCESS
		else
			balloon_alert(user, "connecting neural network...")
			if(!tool.use_tool(src, user, 10 SECONDS))
				return ITEM_INTERACT_SUCCESS
			if(!ai_structure_to_mob())
				return ITEM_INTERACT_SUCCESS
			balloon_alert(user, "connected neural network")
			return ITEM_INTERACT_SUCCESS

/obj/structure/ai_core/attackby(obj/item/P, mob/living/user, params)
	if(!anchored)
		if(P.tool_behaviour == TOOL_WELDER)
			if(state != EMPTY_CORE)
				balloon_alert(user, "core must be empty to deconstruct it!")
				return

			if(!P.tool_start_check(user, amount=0))
				return

			balloon_alert(user, "deconstructing frame...")
			if(P.use_tool(src, user, 20, volume=50) && state == EMPTY_CORE)
				balloon_alert(user, "deconstructed frame")
				deconstruct(TRUE)
			return
		else
			if(!(user.istate & ISTATE_HARM))
				balloon_alert(user, "bolt it down first!")
				return
			else
				return ..()
	return ..()

/obj/structure/ai_core/proc/ai_structure_to_mob()
	var/mob/living/brain/the_brainmob = core_mmi.brainmob
	if(!the_brainmob.mind || suicide_check())
		return FALSE
	the_brainmob.mind.remove_antags_for_borging()
	if(!the_brainmob.mind.has_ever_been_ai)
		SSblackbox.record_feedback("amount", "ais_created", 1)
	var/mob/living/silicon/ai/ai_mob = null

	if(core_mmi.overrides_aicore_laws)
		ai_mob = new /mob/living/silicon/ai(loc, core_mmi.laws, the_brainmob)
		core_mmi.laws = null //MMI's law datum is being donated, so we need the MMI to let it go or the GC will eat it
	else
		ai_mob = new /mob/living/silicon/ai(loc, laws, the_brainmob)
		laws = null //we're giving the new AI this datum, so let's not delete it when we qdel(src) 5 lines from now

	var/datum/antagonist/malf_ai/malf_datum = IS_MALF_AI(ai_mob)
	if(malf_datum)
		malf_datum.add_law_zero()

	if(core_mmi.force_replace_ai_name)
		ai_mob.fully_replace_character_name(ai_mob.name, core_mmi.replacement_ai_name())
	if(core_mmi.braintype == "Android")
		ai_mob.posibrain_inside = TRUE
	deadchat_broadcast(" has been brought online at <b>[get_area_name(ai_mob, format_text = TRUE)]</b>.", span_name("[ai_mob]"), follow_target = ai_mob, message_type = DEADCHAT_ANNOUNCEMENT)
	qdel(src)
	return TRUE

/obj/structure/ai_core/update_icon_state()
	switch(state)
		if(EMPTY_CORE)
			icon_state = "0"
		if(CIRCUIT_CORE)
			icon_state = "1"
		if(SCREWED_CORE)
			icon_state = "2"
		if(CABLED_CORE)
			if(core_mmi)
				// monkestation edit start
				/* original
				icon_state = "3b"
				*/
				if (istype(core_mmi, /obj/item/mmi/posibrain))
					icon_state = "3c"
				else
					icon_state = "3b"
				// monkestation edit end
			else
				icon_state = "3"
		if(GLASS_CORE)
			icon_state = "4"
		if(AI_READY_CORE)
			icon_state = "ai-empty"
	return ..()

/// Quick proc to call to see if the brainmob inside of us has suicided. Returns TRUE if we have, FALSE in any other scenario.
/obj/structure/ai_core/proc/suicide_check()
	if(isnull(core_mmi) || isnull(core_mmi.brainmob))
		return FALSE
	return HAS_TRAIT(core_mmi.brainmob, TRAIT_SUICIDED)

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(card))
		if(card.flush)
			to_chat(user, span_alert("ERROR: AI flush is in progress, cannot execute transfer protocol."))
			return FALSE
	return TRUE

/obj/structure/ai_core/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
	if(core_mmi && core_mmi.brainmob)
		if(core_mmi.brainmob.mind)
			to_chat(user, span_warning("[src] already contains an active mind!"))
			return
		else if(suicide_check())
			to_chat(user, span_warning("[AI_CORE_BRAIN(core_mmi)] installed in [src] is completely useless!"))
			return
	//Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = FALSE
		AI.radio_enabled = TRUE
		AI.forceMove(loc) // to replace the terminal.
		to_chat(AI, span_notice("You have been uploaded to a stationary terminal. Remote device connection restored."))
		to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		card.AI = null
		AI.battery = circuit.battery
		if(core_mmi && core_mmi.braintype == "Android")
			AI.posibrain_inside = TRUE
		else
			AI.posibrain_inside = FALSE
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, span_alert("There is no AI loaded on this terminal."))

#undef AI_CORE_BRAIN
