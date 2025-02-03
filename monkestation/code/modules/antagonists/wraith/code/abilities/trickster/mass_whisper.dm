/datum/action/cooldown/spell/wraith/mass_whisper
	name = "Mass Whisper"
	desc = "Send a message to everypne you can see."
	button_icon_state = "mass_whisper"

	essence_cost = 5
	cooldown_time = 10 SECONDS

	antimagic_flags = MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND

	var/message

/datum/action/cooldown/spell/wraith/mass_whisper/before_cast(atom/cast_on)
	. = ..()
	message = tgui_input_text(owner, "What do you wish to whisper?", "Prepare whisper")
	if(!message)
		return . | SPELL_CANCEL_CAST

	var/affected_targets = 0
	for(var/mob/living/mob in oview(8, owner))
		if(mob.mind)
			affected_targets++

	if(!affected_targets)
		to_chat(owner, span_revennotice("Nobody to whisper to!"))
		. |= SPELL_CANCEL_CAST

/datum/action/cooldown/spell/wraith/mass_whisper/cast(mob/living/cast_on)
	. = ..()
	for(var/mob/living/mob in oview(8, owner))
		if(!mob.mind)
			continue

		log_directed_talk(owner, mob, message, LOG_SAY, name)

		var/formatted_message = span_revennotice("[message]")

		var/failure_message_for_ghosts = ""

		to_chat(owner, "<span class='revenboldnotice'>You transmit to [mob]:</span> [formatted_message]")
		if(!mob.can_block_magic(antimagic_flags, charge_cost = 0)) //hear no evil
			mob.balloon_alert(mob, "you hear a voice")
			to_chat(mob, "<span class='revenboldnotice'>You hear a voice in your head...</span> [formatted_message]")
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
			var/to_link = FOLLOW_LINK(ghost, mob)
			var/to_mob_name = span_name("[mob]")

			to_chat(ghost, "[from_link] [from_mob_name] [formatted_message] [to_link] [to_mob_name]")
