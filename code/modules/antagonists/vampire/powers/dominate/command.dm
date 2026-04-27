/**
 *	Command
 *	 Gives a one-word brainwash-command to a target for 60 seconds.
 * 	Level 2: Now lasts 180 seconds.
 */
/datum/action/cooldown/vampire/targeted/command
	name = "Command"
	desc = "Dominate the mind of another with a simple command."
	button_icon_state = "power_command"
	power_explanation = "Click any player to attempt to compel them.\n\
		If your target is already commanded, a Curator, or a vampire, you will fail.\n\
		Once commanded, the target will do their best to fulfill it, with a duration scaling with level.\n\
		If your target is mindshielded, your command's duration will be halved, and commanding them will take longer.\n\
		At level 1, your command will stay for 60 seconds.\n\
		At level 2, it will remain for 3 minutes.\n\
		Be smart with your wording. They will become pacified, and won't obey violent commands.\n\
		In addition, attacking your target will immediately snap them out of their compulsion."
	vampire_power_flags = NONE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 120
	cooldown_time = 80 SECONDS
	target_range = 3
	power_activates_immediately = FALSE
	prefire_message = "Whom will you subvert to your will?"
	ranged_mousepointer = 'icons/effects/mouse_pointers/vampire_command.dmi'

	/// How long the command is in effect.
	var/power_time = 60 SECONDS
	/// How long you have to channel in order to command someone.
	var/channel_time = 8 SECONDS

	/// Reference to the target
	var/datum/weakref/target_ref

/datum/action/cooldown/vampire/targeted/command/two
	name = "Command"
	power_time = 180 SECONDS
	vitaecost = 240
	cooldown_time = 200 SECONDS
	target_range = 6
	channel_time = 5 SECONDS

/datum/action/cooldown/vampire/targeted/command/can_use()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner

	// Must have ears
	if(!owner.get_organ_slot(ORGAN_SLOT_TONGUE))
		to_chat(owner, span_warning("You have no tongue with which to command!"))
		return FALSE

	// Must have mouth unobstructed
	if(carbon_owner.is_mouth_covered() || !isturf(carbon_owner.loc))
		owner.balloon_alert(owner, "your mouth is blocked.")
		return FALSE

	if(HAS_TRAIT(carbon_owner, TRAIT_MUTE) || !isturf(carbon_owner.loc))
		owner.balloon_alert(owner, "you cannot speak!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/targeted/command/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Must be a carbon or silicon
	if(!iscarbon(target_atom))
		return FALSE

	var/mob/living/living_target = target_atom
	// No mind
	if(!living_target.mind)
		owner.balloon_alert(owner, "[living_target] is mindless.")
		return FALSE

	// Vampire/Curator check
	if(IS_VAMPIRE(living_target) || IS_CURATOR(living_target) || HAS_MIND_TRAIT(living_target, TRAIT_UNCONVERTABLE))
		owner.balloon_alert(owner, "too powerful.")
		return FALSE

	// Is our target alive or unconcious?
	if(living_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[living_target] is not [(living_target.stat == DEAD || HAS_TRAIT(living_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE

	// Is our target deaf?
	if(!living_target.can_hear())
		owner.balloon_alert(owner, "[living_target] cannot hear you!")
		return FALSE

	// Is our target a silicon?
	if(issilicon(living_target))
		owner.balloon_alert(owner, "[living_target] cannot be compelled!")
		return FALSE

	// Already commanded?
	if(living_target.has_status_effect(/datum/status_effect/commanded))
		owner.balloon_alert(owner, "[living_target] is already compelled!")
		return FALSE

/datum/action/cooldown/vampire/targeted/command/fire_targeted_power(atom/target_atom)
	. = ..()

	var/mob/living/living_target = target_atom
	target_ref = WEAKREF(living_target)

	owner.balloon_alert(owner, "commanding [living_target]...")

	var/command = get_single_word_command()

	if(!command)
		deactivate_power()
		return

	// They left while we were writing
	if(!(living_target in hearers(target_range, owner)))
		deactivate_power()
		return

	var/modified_delay = channel_time
	if(HAS_TRAIT_NOT_FROM(living_target, TRAIT_MINDSHIELD, NANITES_TRAIT))
		modified_delay *= 1.5

	// instant on your own vassals
	var/datum/antagonist/vassal/victim_vassal = IS_VASSAL(living_target)
	if(victim_vassal && (victim_vassal in vampiredatum_power.vassals))
		modified_delay = 0

	if(modified_delay > 0)
		living_target.balloon_alert(living_target, "your thoughts begin to blur!")
		living_target.add_client_colour(/datum/client_colour/glass_colour/pink)
	if(!do_after(owner, modified_delay, living_target, IGNORE_TARGET_LOC_CHANGE | IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(continue_active)), hidden = TRUE))
		living_target.balloon_alert(living_target, "your thoughts come back into focus.")
		living_target.remove_client_colour(/datum/client_colour/glass_colour/pink)
		deactivate_power()
		return
	living_target.remove_client_colour(/datum/client_colour/glass_colour/pink)

	// they're out of range once more
	if(!(living_target in hearers(target_range, owner)))
		living_target.balloon_alert(living_target, "your thoughts come back into focus.")
		deactivate_power()
		return

	//Actually command them now
	owner.say(command, forced = "[type]")

	var/time_multiplier = 1
	if(HAS_TRAIT_NOT_FROM(living_target, TRAIT_MINDSHIELD, NANITES_TRAIT))
		time_multiplier = 0.5

	living_target.apply_status_effect(/datum/status_effect/commanded, owner, command, power_time * time_multiplier)

	power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!

/datum/action/cooldown/vampire/targeted/command/proc/get_single_word_command()
	. = TRUE
	var/command = tgui_input_text(owner, "What would you like to command?", "Input a command", "STOP", encode = FALSE, timeout = 2 MINUTES)
	if(QDELETED(src))
		return FALSE
	/* if(CHAT_FILTER_CHECK(command))
		to_chat(owner, span_warning("The command '[span_bold("[command]")]' is forbidden!"))
		return FALSE */
	if(findtext_char(command, " "))
		to_chat(owner, span_warning("Please only input a single word."))
		return FALSE
	if(length_char(command)  > 7)
		to_chat(owner, span_warning("Command too long!"))
		return FALSE
	if(copytext(command, 1, 5) == "kill" || copytext(command, 1, 7) == "murder" || copytext(command, 1, 8) == "suicide" || copytext(command, 1, 4) == "die")
		owner.balloon_alert(owner, "that won't work!")
		to_chat(owner, span_warning(" * Remember, victims will be pacified for the duration of the command!"))
		return FALSE

	return command

/datum/action/cooldown/vampire/targeted/command/continue_active()
	. = ..()
	if(!.)
		return FALSE

	if(!can_use())
		return FALSE

	var/mob/living/living_target = target_ref?.resolve()
	if(!living_target || !check_valid_target(living_target))
		return FALSE

/datum/action/cooldown/vampire/targeted/command/deactivate_power()
	. = ..()
	target_ref = null

/datum/status_effect/commanded
	id = "commanded"
	duration = 1 MINUTES
	tick_interval = STATUS_EFFECT_NO_TICK
	on_remove_on_mob_delete = TRUE
	alert_type = null
	/// The vampire that casted this command.
	var/mob/living/caster
	/// The actual command used for the objective.
	var/command
	/// The brainwash objectives, so we can unbrainwash when it ends.
	var/list/directives

/datum/status_effect/commanded/on_creation(mob/living/new_owner, mob/living/caster, command, duration)
	src.caster = caster
	src.command = command
	if(duration)
		src.duration = duration
	return ..()

/datum/status_effect/commanded/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	directives = brainwash(owner, "[command]!", "[caster.real_name]'s Command")

	// make sure they have a moment to realize what's going on
	owner.Immobilize(2 SECONDS, TRUE)
	to_chat(owner, "<br>" + span_awe(span_extremelybig("[command]!")) + "<br>", type = MESSAGE_TYPE_WARNING)

	// also log it.
	message_admins("[ADMIN_LOOKUPFLW(caster)] used the COMMAND ability on [ADMIN_LOOKUPFLW(owner)], commanding them to [command].")
	log_game("[key_name(caster)] used the command ability on [key_name(owner)], commanding them to [command].")

	owner.AddElement(/datum/element/relay_attackers)
	RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	return TRUE

/datum/status_effect/commanded/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED)
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	unbrainwash(owner, directives)
	directives = null
	owner.balloon_alert(caster, "[owner] snapped out of [owner.p_their()] trance!")
	caster = null

/datum/status_effect/commanded/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if(attacker != caster || !(attack_flags & ATTACKER_DAMAGING_ATTACK))
		return
	if(owner.pulledby == caster)
		caster.stop_pulling()
	owner.SetAllImmobility(0)
	if(caster.Adjacent(owner)) // give them a split second to run away
		caster.Stun(0.5 SECONDS, TRUE)
	to_chat(owner, span_awe(span_reallybig("You quickly come back to your senses as you're hit by [attacker]!")))
	qdel(src)
