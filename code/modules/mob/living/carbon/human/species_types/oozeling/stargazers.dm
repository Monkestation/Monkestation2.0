// Stargazers are the telepathic branch of oozelings, able to project psychic messages and to link minds with willing participants.

/datum/species/oozeling/stargazer
	name = "\improper Stargazer"
	plural_form = "Stargazers"
	id = SPECIES_STARGAZER
	extra_actions = list(/datum/action/innate/project_thought)

/datum/species/oozeling/stargazer/on_species_gain(mob/living/carbon/slime, datum/species/old_species)
	. = ..()
	slime.AddComponent( \
		/datum/component/mind_linker/active_linking, \
		network_name = "Slime Link", \
		chat_color = "#00ced1", \
		signals_which_destroy_us = list(COMSIG_SPECIES_LOSS), \
		linker_action_path = /datum/action/innate/link_minds, \
		show_balloon_alert = TRUE, \
	)

/datum/action/innate/project_thought
	name = "Send Thought"
	desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/project_thought/Activate()
	var/mob/living/carbon/human/telepath = owner
	if(telepath.stat == DEAD || !is_species(telepath, /datum/species/oozeling/stargazer))
		return
	var/list/recipient_options = list()
	for(var/mob/living/recipient in oview(telepath))
		if(!recipient.mind || !recipient.client)
			continue
		recipient_options += recipient
	if(!length(recipient_options))
		to_chat(telepath, span_warning("You don't see anyone to send your thought to."))
		return
	var/mob/living/recipient = tgui_input_list(telepath, "Choose a telepathic message recipient", "Telepathy", sort_names(recipient_options))
	if(isnull(recipient))
		return
	var/msg = tgui_input_text(telepath, title = "Telepathy")
	if(!msg)
		return
	if(recipient.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		to_chat(telepath, span_warning("As you reach into [recipient]'s mind, you are stopped by a mental blockage. It seems you've been foiled."))
		return
	log_directed_talk(telepath, recipient, msg, LOG_SAY, "slime telepathy")
	recipient.balloon_alert(recipient, "you hear an alien voice in your head...")
	to_chat(recipient, "[span_notice("You hear an alien voice in your head... ")]<font color=#008CA2>[msg]</font>")
	to_chat(telepath, span_notice("You telepathically said: \"[msg]\" to [recipient]"))
	for(var/dead in GLOB.dead_mob_list)
		if(!isobserver(dead))
			continue
		var/follow_link_user = FOLLOW_LINK(dead, telepath)
		var/follow_link_target = FOLLOW_LINK(dead, recipient)
		to_chat(dead, "[follow_link_user] [span_name("[telepath]")] [span_alertalien("Slime Telepathy --> ")] [follow_link_target] [span_name("[recipient]")] [span_noticealien("[msg]")]")

#define DOAFTER_SOURCE_LINK_MINDS "doafter_link_minds"

/datum/action/innate/link_minds
	name = "Link Minds"
	desc = "Link someone's mind to your Slime Link, allowing them to communicate telepathically with other linked minds."
	button_icon_state = "mindlink"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	/// The species required to use this ability. Typepath.
	var/req_species = /datum/species/oozeling/stargazer

/datum/action/innate/link_minds/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/innate/link_minds/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(!ishuman(owner) || !is_species(owner, req_species))
		return FALSE
	if(DOING_INTERACTION(owner, DOAFTER_SOURCE_LINK_MINDS))
		return FALSE

	return TRUE

/datum/action/innate/link_minds/Activate()
	var/mob/living/living_target = owner.pulling
	if(!isliving(living_target) || (owner.grab_state < GRAB_AGGRESSIVE && (living_target.status_flags & CANPUSH) && !HAS_TRAIT(living_target, TRAIT_PUSHIMMUNE)))
		to_chat(owner, span_warning("You need to aggressively grab someone to link minds!"))
		return

	if(living_target.stat == DEAD)
		to_chat(owner, span_warning("They're dead!"))
		return

	to_chat(owner, span_notice("You begin linking [living_target]'s mind to yours..."))
	to_chat(living_target, span_warning("You feel a foreign presence within your mind..."))

	if(!do_after(owner, 6 SECONDS, target = living_target, extra_checks = CALLBACK(src, PROC_REF(while_link_callback), living_target), interaction_key = DOAFTER_SOURCE_LINK_MINDS))
		to_chat(owner, span_warning("You can't seem to link [living_target]'s mind."))
		to_chat(living_target, span_warning("The foreign presence leaves your mind."))
		return

	if(QDELETED(src) || QDELETED(owner) || QDELETED(living_target))
		return

	var/datum/component/mind_linker/linker = target
	if(!linker.link_mob(living_target))
		to_chat(owner, span_warning("You can't seem to link [living_target]'s mind."))
		to_chat(living_target, span_warning("The foreign presence leaves your mind."))


/// Callback ran during the do_after of Activate() to see if we can keep linking with someone.
/datum/action/innate/link_minds/proc/while_link_callback(mob/living/linkee)
	if(!is_species(owner, req_species))
		return FALSE
	if(!owner.pulling)
		return FALSE
	if(owner.pulling != linkee)
		return FALSE
	if(owner.grab_state < GRAB_AGGRESSIVE)
		return FALSE
	if(linkee.stat == DEAD)
		return FALSE

	return TRUE

#undef DOAFTER_SOURCE_LINK_MINDS
