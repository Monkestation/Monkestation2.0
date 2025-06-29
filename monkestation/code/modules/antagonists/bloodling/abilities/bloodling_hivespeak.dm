/datum/action/cooldown/bloodling_hivespeak
	name = "Hivespeak"
	desc = "Whispered words that all in your hive can hear."
	button_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	background_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	background_icon_state = "button_bg"
	button_icon_state = "hivemind"

/datum/action/cooldown/bloodling_hivespeak/IsAvailable(feedback = FALSE)
	. = ..()

	if(IS_BLOODLING_OR_THRALL(owner))
		return TRUE
	return

/datum/action/cooldown/bloodling_hivespeak/Activate()
	. = ..()

	var/input = tgui_input_text(usr, "Message to tell your hive", "Commune of Hive")
	if(!input || !IsAvailable(feedback = TRUE))
		return

	var/list/filter_result = CAN_BYPASS_FILTER(usr) ? null : is_ic_filtered(input)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(usr) ? null : is_soft_ic_filtered(input)
	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[html_encode(input)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[input]\"")
	commune(usr, input)

/datum/action/cooldown/bloodling_hivespeak/proc/commune(mob/living/user, message)
	var/title = "Thrall"
	var/span = "noticealien"
	if(!message)
		return
	if(user.mind && IS_BLOODLING(user))
		span = "alertalien"
		title = "Bloodling the"

	var/my_message = "<span class='[span]'><b>Hivespeak: [title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span> <br>"
	for(var/player in GLOB.player_list)
		var/mob/reciever = player
		if(IS_BLOODLING_OR_THRALL(reciever))
			to_chat(reciever, my_message)
		else if(reciever in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(reciever, user)
			to_chat(reciever, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="bloodling_speak")
