///Tracking reasons
/datum/antagonist/heretic_monster
	name = "\improper Eldritch Horror"
	roundend_category = "Heretics"
	antagpanel_category = ANTAG_GROUP_HORRORS
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic_beast"
	suicide_cry = "MY MASTER SMILES UPON ME!!"
	show_in_antagpanel = FALSE
	show_in_roundend = FALSE // handled by the heretic's roundend report
	stinger_sound = 'sound/music/antag/heretic/heretic_gain.ogg'
	/// Our master (a heretic)'s mind.
	var/datum/mind/master

/datum/antagonist/heretic_monster/on_removal()
	if(!silent)
		if(master?.current)
			to_chat(master.current, span_warning("The essence of [owner], your servant, fades from your mind."))
		if(owner.current)
			to_chat(owner.current, span_deconversion_message("Your mind begins to fill with haze - your master is no longer[master ? " [master]":""], you are free!"))
			owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] been freed from the chains of the Mansus!"), ignored_mobs = owner.current)

	if(IS_WEAKREF_OF(master?.current, owner.enslaved_to))
		owner.enslaved_to = null

	master = null
	return ..()

/datum/antagonist/heretic_monster/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/target = mob_override || owner.current
	ADD_TRAIT(target, TRAIT_HERETIC_SUMMON, REF(src))
	RegisterSignal(target, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	REMOVE_TRAIT(target, TRAIT_HERETIC_SUMMON, REF(src))
	UnregisterSignal(target, list(COMSIG_MOVABLE_HEAR, COMSIG_ATOM_EXAMINE))
	return ..()

/*
 * Set our [master] var to a new mind.
 */
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	owner.enslave_mind_to_creator(master.current)

	var/datum/objective/master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Assist your master, [master]."
	master_obj.completed = TRUE

	objectives += master_obj
	owner.announce_objectives()
	to_chat(owner, span_boldnotice("You are a [ishuman(owner.current) ? "shambling corpse returned" : "horrible creation brought"] to this plane through the Gates of the Mansus."))
	to_chat(owner, span_notice("Your master is [span_heretic_master("[master]")]. Assist [master.current.p_them()] to all ends."))

	var/datum/antagonist/heretic/master_heretic = master.has_antag_datum(/datum/antagonist/heretic)
	if(master_heretic)
		LAZYOR(master_heretic.monsters_summoned, owner)

/**
 * Makes it so stuff our master's speech is more noticable by adding a chat effect to it.
 */
/datum/antagonist/heretic_monster/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	if(hearing_args[HEARING_SPEAKER] == master?.current)
		hearing_args[HEARING_SPANS] = list("heretic_master") + hearing_args[HEARING_SPANS]

/**
 * Ensure their heretic master can tell that this is specifically their minion on examine.
 */
/datum/antagonist/heretic_monster/proc/on_examine(mob/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!user.mind)
		return
	if(user.mind == master)
		examine_text += span_heretic_master("[source.p_They()] [source.p_are()] your servant!")
		return
	var/datum/antagonist/heretic_monster/monster = user.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
	if(monster?.master == master || IS_WEAKREF_OF(master.current, user.mind.enslaved_to))
		examine_text += span_heretic_master("[source.p_They()] [source.p_are()] a fellow servant of [master]!")
