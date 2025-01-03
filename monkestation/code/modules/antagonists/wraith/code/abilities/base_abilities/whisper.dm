/datum/action/cooldown/spell/pointed/wraith/whisper
	name = "Whisper"
	desc = "Send a message to whomever you click on."
	button_icon_state = "whisper"

	essence_cost = 1
	cooldown_time = 2 SECONDS

	antimagic_flags = MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND

	var/message

/datum/action/cooldown/spell/pointed/wraith/whisper/on_activation(atom/cast_on)
	. = ..()
	message = tgui_input_text(owner, "What do you wish to whisper?", "Prepare whisper")

/datum/action/cooldown/spell/pointed/wraith/whisper/before_cast(mob/living/cast_on)
	. = ..()
	if(!istype(cast_on) || !message)
		return . | SPELL_CANCEL_CAST

	if(!cast_on.mind)
		to_chat(owner, span_revennotice("The target is mindless!"))
		. |= SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/whisper/cast(mob/living/cast_on)
	. = ..()
	log_directed_talk(owner, cast_on, message, LOG_SAY, name)

	var/formatted_message = span_revennotice("[message]")

	var/failure_message_for_ghosts = ""

	to_chat(owner, "<span class='revenboldnotice'>You transmit to [cast_on]:</span> [formatted_message]")
	if(!cast_on.can_block_magic(antimagic_flags, charge_cost = 0)) //hear no evil
		cast_on.balloon_alert(cast_on, "you hear a voice")
		to_chat(cast_on, "<span class='revenboldnotice'>You hear a voice in your head...</span> [formatted_message]")
	else
		owner.balloon_alert(owner, "transmission blocked!")
		to_chat(owner, span_warning("Something has blocked your transmission!"))
		failure_message_for_ghosts = span_revenboldnotice(" (blocked by antimagic)")

	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, owner)
		var/from_mob_name = span_revenboldnotice("[owner] [src]")
		from_mob_name += failure_message_for_ghosts
		from_mob_name += span_revenboldnotice(":")
		var/to_link = FOLLOW_LINK(ghost, cast_on)
		var/to_mob_name = span_name("[cast_on]")

		to_chat(ghost, "[from_link] [from_mob_name] [formatted_message] [to_link] [to_mob_name]")
