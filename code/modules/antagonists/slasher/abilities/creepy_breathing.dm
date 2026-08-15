/datum/action/cooldown/slasher/creepy_breathing
	name = "Creepy Breathing"
	desc = "Breath Creepily. (bind this to a key for quick access to being a creep)"
	button_icon = 'icons/obj/medical/organs/organs.dmi'
	button_icon_state = "lungs-ashwalker"
	cooldown_time = 5 SECONDS

/datum/action/cooldown/slasher/creepy_breathing/Activate(atom/target)
	. = ..()
	if(isliving(owner))
		owner.emote("breathein")
		sleep(2 SECONDS)
		owner.emote("breatheout")
		var/mob/living/slash = owner
		slash.adjustOxyLoss(-5)
