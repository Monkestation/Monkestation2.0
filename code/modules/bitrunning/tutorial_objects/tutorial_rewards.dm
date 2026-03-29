/atom/proc/reward_tutorial_completion(mob/rewardee, monkecoins_awarded) // is this atom proc stinky? idk, but im not good enough at coding to make anything better than this implementation right now. so im going to wait until/if maints yell at this.
	if(!rewardee.client || !rewardee.ckey)
		CRASH("No client and/or C-key to award monkecoins to!")

	var/datum/preferences/pref = rewardee.client.prefs
	if(text2num(pref.exp[EXP_TYPE_LIVING]) >= 24)
		return //no you can't farm if you're not a FNG
	pref.adjust_metacoins(rewardee.ckey, monkecoins_awarded, "For completing tutorials as a new player! :)", TRUE, FALSE)
