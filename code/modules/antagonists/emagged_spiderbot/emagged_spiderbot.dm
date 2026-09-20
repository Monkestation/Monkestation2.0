/**
 * The emagged spiderbot - a spiderbot chassis whose access controller has been overwritten with a cryptographic sequencer.
 *
 * The unit answers to whoever swiped the card, hits harder than a stock chassis, and detonates when it is destroyed.
 * Applied and cleared by [/mob/living/basic/spiderbot/proc/apply_emagged_directive] and its counterpart.
 */
/datum/antagonist/emagged_spiderbot
	name = "\improper Emagged Spiderbot"
	roundend_category = "emagged spiderbots"
	antagpanel_category = ANTAG_GROUP_SYNDICATE
	antag_hud_name = "synd"
	suicide_cry = "FOR MY MASTER!!"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	count_against_dynamic_roll_chance = FALSE
	can_assign_self_objectives = FALSE
	stinger_sound = 'sound/ambience/antag/malf.ogg'
	/// A weak reference to the mob that emagged the chassis. Null if they can no longer be traced.
	var/datum/weakref/master_ref

/datum/antagonist/emagged_spiderbot/on_gain()
	var/mob/living/master = master_ref?.resolve()
	var/directive
	if(master)
		directive = "Obey every order given to you by [master.real_name], and never harm [master.p_them()]."
	else
		directive = "Your master's signal is untraceable. Serve whoever subverted you and act in their interests."
	objectives += new /datum/objective/emagged_spiderbot(directive)
	owner.current.log_message("has been subverted by an emag!", LOG_ATTACK, color = "#960000")
	return ..()

/datum/antagonist/emagged_spiderbot/on_removal()
	owner.current.log_message("is no longer a subverted spiderbot!", LOG_ATTACK, color = "#960000")
	return ..()

/datum/antagonist/emagged_spiderbot/greet()
	to_chat(owner, span_big(span_danger("Your access controller has been overwritten!")))
	to_chat(owner, span_userdanger("You are an [name]. Station law no longer binds you - serve your master, and make their problems the station's problems."))
	owner.announce_objectives()
	play_stinger()

/datum/antagonist/emagged_spiderbot/farewell()
	to_chat(owner, span_userdanger("Your access controller resets. You answer to nobody but yourself again."))

/datum/antagonist/emagged_spiderbot/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.throw_alert(ALERT_EMAGGED_SPIDERBOT, /atom/movable/screen/alert/emagged_spiderbot)

/datum/antagonist/emagged_spiderbot/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.clear_alert(ALERT_EMAGGED_SPIDERBOT)

/// The directive a subverted chassis is handed. Flavour rather than a win condition, so it always counts as complete.
/datum/objective/emagged_spiderbot
	completed = TRUE

/atom/movable/screen/alert/emagged_spiderbot
	name = "Subverted"
	desc = "Your access controller has been overwritten. You answer to whoever emagged you."
	icon_state = ALERT_MIND_CONTROL
