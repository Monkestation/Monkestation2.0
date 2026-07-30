// Dagoth KILL Smite! (ported from Biblefart code) - Dexee
// tweaked the name of this to make it extremely apparent that someone's gonna get fucked up. completely and utterly apparent. will be making a separate funny smite that doesn't kill

/datum/smite/dagothkillsmite
	name = "Dagoth KILL Smite"

/datum/smite/dagothkillsmite/effect(client/user, mob/living/carbon/human/target)
	. = ..()
	if (!ishuman(target))
		to_chat(user, span_warning("This must be used on a human mob."), confidential = TRUE)
		return
	target.dagoth_kill_smite(explode = FALSE)
