#define VASSAL_SCAN_MIN_DISTANCE 5
#define VASSAL_SCAN_MAX_DISTANCE 500
/// 2s update time.
#define VASSAL_SCAN_PING_TIME 20

/datum/antagonist/vassal
	name = "\improper Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "vassal"
	show_in_roundend = FALSE
	hud_icon = 'monkestation/icons/bloodsuckers/bloodsucker_icons.dmi'
	antag_count_points = 2

	/// The Master Bloodsucker's antag datum.
	var/datum/antagonist/bloodsucker/master
	/// List of all Purchased Powers, like Bloodsuckers.
	var/list/datum/action/powers = list()
	///Whether this vassal is already a special type of Vassal.
	var/special_type = FALSE
	///Description of what this Vassal does.
	var/vassal_description
	/// A link to our team monitor, used to track our master.
	var/datum/component/team_monitor/monitor

/datum/antagonist/vassal/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.clear_mood_event("vampcandle")
	add_team_hud(current_mob)
	current_mob.grant_language(/datum/language/vampiric, source = LANGUAGE_VASSAL)
	setup_monitor(current_mob)
	RegisterSignal(current_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login))

/datum/antagonist/vassal/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	QDEL_NULL(monitor)
	current_mob.remove_language(/datum/language/vampiric, source = LANGUAGE_VASSAL)
	UnregisterSignal(current_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login))

/datum/antagonist/vassal/after_body_transfer(mob/living/old_body, mob/living/new_body)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/antagonist, add_team_hud), new_body), 0.5 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE) //i don't trust this to not act weird

/datum/antagonist/vassal/proc/setup_monitor(mob/target)
	QDEL_NULL(monitor)
	if(QDELETED(master?.owner?.current) || QDELETED(master.tracker))
		return
	monitor = target.AddComponent(/datum/component/team_monitor, REF(master))
	monitor.add_to_tracking_network(master.tracker.tracking_beacon)
	monitor.show_hud(target)

/datum/antagonist/vassal/add_team_hud(mob/target)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
	))

	var/datum/atom_hud/alternate_appearance/basic/has_antagonist/hud = team_hud_ref.resolve()

	var/list/mob/living/mob_list = list()
	mob_list += master.owner.current
	for(var/datum/antagonist/vassal/vassal as anything in master.vassals)
		mob_list += vassal.owner.current

	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if(!(antag_hud.target in mob_list))
			continue
		antag_hud.show_to(target)
		hud.show_to(antag_hud.target)

/datum/antagonist/vassal/pre_mindshield(mob/implanter, mob/living/mob_override)
	return COMPONENT_MINDSHIELD_PASSED

/// This is called when the antagonist is successfully mindshielded.
/datum/antagonist/vassal/on_mindshield(mob/implanter, mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	target.log_message("has been deconverted from Vassalization by [implanter]!", LOG_ATTACK, color="#960000")
	owner.remove_antag_datum(/datum/antagonist/vassal)
	return COMPONENT_MINDSHIELD_DECONVERTED

/datum/antagonist/vassal/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER
	var/vassal_examine = return_vassal_examine(examiner)
	if(vassal_examine)
		examine_text += vassal_examine

/datum/antagonist/vassal/on_gain()
	ADD_TRAIT(owner, TRAIT_BLOODSUCKER_ALIGNED, REF(src))
	RegisterSignal(owner.current, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	/// Enslave them to their Master
	if(!master || !istype(master, master))
		return
	if(special_type)
		if(!master.special_vassals[special_type])
			master.special_vassals[special_type] = list()
		master.special_vassals[special_type] |= src
	master.vassals |= src
	owner.enslave_mind_to_creator(master.owner.current)
	owner.current.log_message("has been vassalized by [master.owner.current]!", LOG_ATTACK, color="#960000")
	/// Give Recuperate Power
	BuyPower(new /datum/action/cooldown/bloodsucker/recuperate)
	/// Give Objectives
	var/datum/objective/bloodsucker/vassal/vassal_objective = new
	vassal_objective.owner = owner
	objectives += vassal_objective
	/// Give Vampire Language & Hud
	owner.current.get_language_holder().omnitongue = TRUE
	owner.current.grant_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/vassal/on_removal()
	//Free them from their Master
	if(!QDELETED(master))
		if(special_type && master.special_vassals[special_type])
			master.special_vassals.Remove(special_type)
		master.vassals -= src
		owner.enslaved_to = null

	var/datum/antagonist/bloodsucker/converted_bloodsucker_datum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	//If this vassal has become a bloodsucker through ventrue conversion, we do not remove these things - but we do remove a couple other things instead
	if (!converted_bloodsucker_datum)
		REMOVE_TRAIT(owner, TRAIT_BLOODSUCKER_ALIGNED, REF(src))
		if(owner.current)
			UnregisterSignal(owner.current, COMSIG_ATOM_EXAMINE)
			REMOVE_TRAITS_IN(owner.current, BLOODSUCKER_TRAIT)

		//Remove Language & Hud
		owner.current?.remove_language(/datum/language/vampiric)
		//Remove Vassal Powers
		QDEL_LIST(powers)
	else
		var/datum/action/cooldown/bloodsucker/recuperate/recuperate_power = locate(/datum/action/cooldown/bloodsucker/recuperate) in converted_bloodsucker_datum.powers
		if (recuperate_power)
			converted_bloodsucker_datum.RemovePower(recuperate_power)

		var/datum/action/cooldown/bloodsucker/distress/distress_power = locate(/datum/action/cooldown/bloodsucker/distress) in converted_bloodsucker_datum.powers
		if (distress_power)
			converted_bloodsucker_datum.RemovePower(distress_power)

	// remove the monitor
	QDEL_NULL(monitor)

	return ..()

/datum/antagonist/vassal/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)

/datum/antagonist/vassal/greet()
	. = ..()
	if(silent)
		return

	to_chat(owner, span_userdanger("You are now the mortal servant of [master.owner.current], a Bloodsucker!"))
	to_chat(owner, span_boldannounce("The power of [master.owner.current.p_their()] immortal blood compels you to obey [master.owner.current.p_them()] in all things, even offering your own life to prolong theirs.\n\
		You are not required to obey any other Bloodsucker, for only [master.owner.current] is your master. The laws of Nanotrasen do not apply to you now; only your vampiric master's word must be obeyed.")) // if only there was a /p_theirs() proc...
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "You, becoming the mortal servant of <b>[master.owner.current]</b>, a bloodsucking vampire!<br>"
	/// Message told to your Master.
	to_chat(master.owner, span_userdanger("[owner.current] has become addicted to your immortal blood. [owner.current.p_they(TRUE)] [owner.current.p_are()] now your undying servant!"))
	master.owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	if(silent)
		return

	owner.current.visible_message(
		span_deconversion_message("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seem[owner.current.p_s()] calm, \
			like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self."), \
		span_deconversion_message("With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will."))
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	/// Message told to your (former) Master.
	if(master && master.owner)
		to_chat(master.owner, span_cultbold("You feel the bond with your vassal [owner.current] has somehow been broken!"))

/datum/antagonist/vassal/proc/on_login()
	SIGNAL_HANDLER
	var/mob/living/current = owner.current
	if(!QDELETED(current))
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/antagonist, add_team_hud), current), 0.5 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE) //i don't trust this to not act weird

/datum/antagonist/vassal/admin_add(datum/mind/new_owner, mob/admin)
	var/list/datum/mind/possible_vampires = list()
	for(var/datum/antagonist/bloodsucker/bloodsuckerdatums in GLOB.antagonists)
		var/datum/mind/vamp = bloodsuckerdatums.owner
		if(!vamp)
			continue
		if(!vamp.current)
			continue
		if(vamp.current.stat == DEAD)
			continue
		possible_vampires += vamp
	if(!length(possible_vampires))
		message_admins("[key_name_admin(usr)] tried vassalizing [key_name_admin(new_owner)], but there were no bloodsuckers!")
		return
	var/datum/mind/choice = input("Which bloodsucker should this vassal belong to?", "Bloodsucker") in possible_vampires
	if(!choice)
		return
	log_admin("[key_name_admin(usr)] turned [key_name_admin(new_owner)] into a vassal of [key_name_admin(choice)]!")
	var/datum/antagonist/bloodsucker/vampire = choice.has_antag_datum(/datum/antagonist/bloodsucker)
	master = vampire
	new_owner.add_antag_datum(src)
	to_chat(choice, span_notice("Through divine intervention, you've gained a new vassal!"))
