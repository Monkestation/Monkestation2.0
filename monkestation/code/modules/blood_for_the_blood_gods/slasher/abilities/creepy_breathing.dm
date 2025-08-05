/datum/action/cooldown/slasher/creepy_breathing
	name = "Creepy Breathing"
	desc = "Breath Creepily. (bind this to a key for quick access to being a creep)"
	button_icon_state = "trail_blood"
	cooldown_time = 4 SECONDS

/datum/action/cooldown/slasher/creepy_breathing/Activate(atom/target)
	. = ..()
	if(isliving(owner))
		owner.emote("breathein")
		sleep(2 SECONDS)
		owner.emote("breatheout")
