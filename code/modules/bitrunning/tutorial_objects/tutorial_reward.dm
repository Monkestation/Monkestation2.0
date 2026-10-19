/*
	Below is the tutorial_reward datum, for standardizing tutorial completion. it handles: checks, reward, and feedback (message, sound).
	Simply instance this datum on init and call .award() and it will handle everything for you.
	Refer to /obj/item/autopsy_scanner/tutorial for simplest implementation.
*/
/datum/tutorial_reward
	var/list/players_that_completed = list()
	var/reward = TUTORIAL_REWARD_LOW
	var/reward_message = "has completed the tutorial!"

/datum/tutorial_reward/New(tutorial_reward, message)
	. = ..()
	if(tutorial_reward)
		reward = tutorial_reward
	if(message)
		reward_message = message

/datum/tutorial_reward/proc/award(mob/living/user)
	if(user.ckey in players_that_completed)
		user.balloon_alert(user, "already completed!")
		to_chat(user, span_warning("You have already completed this tutorial!"))
		return

	playsound(user, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50)
	user.visible_message(span_notice("[user] [reward_message]"))
	players_that_completed += user.ckey

	//gives metacoins
	if(!user.client || !user.ckey)
		CRASH("No client and/or C-key to award monkecoins to!")

	var/datum/preferences/pref = user.client.prefs
	if(text2num(pref.exp[EXP_TYPE_LIVING]) >= 24)
		return //no you can't farm if you're not a FNG
	pref.adjust_metacoins(user.ckey, reward, "For completing tutorials as a new player! :)", TRUE, FALSE)
