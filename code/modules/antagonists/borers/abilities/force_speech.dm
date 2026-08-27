/datum/action/cooldown/borer/force_speak
	name = "Force Host Speak"
	cooldown_time = 25 SECONDS
	button_icon_state = "speak"
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Forces your host to speak any words you desire.\
	"
	var/static/list/blacklist = null

/datum/action/cooldown/borer/force_speak/New(Target, original)
	. = ..()
	if(blacklist)
		return

	blacklist = list(
		"*surrender",
		"*collapse",
		"*faint",
		"*piss",
	)

/datum/action/cooldown/borer/force_speak/Activate(mob/living/basic/cortical_borer/user)
	var/mob/living/carbon/human/host = user.human_host
	var/borer_message = trimtext(tgui_input_text(user, "What would you like to force your host to say?", "Force Speak", encode = FALSE))
	if(!borer_message)
		owner.balloon_alert(owner, "no message given")
		return

	if(!IsAvailable(TRUE) || user.human_host != host || (borer_message in blacklist))
		return ..()

	to_chat(host, span_boldwarning("Your voice moves without your permission!"))
	host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * user.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)
	host.say(message = borer_message, forced = "borer ([key_name(user)])")
	var/turf/human_turf = get_turf(user.human_host)
	var/logging_text = "[key_name(user)] forced [key_name(user.human_host)] to say [borer_message] at [loc_name(human_turf)]"
	user.log_message(logging_text, LOG_GAME)
	user.human_host.log_message(logging_text, LOG_GAME)

	cooldown_time = initial(cooldown_time)
	if(HAS_MIND_TRAIT(host, TRAIT_WILLING_HOST))
		cooldown_time *= 0.2

	return ..()
