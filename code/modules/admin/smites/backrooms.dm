/// Makes the target clip out of reality and into the backrooms
/datum/smite/backrooms
	name = "Backrooms"

/datum/smite/backrooms/effect(client/user, mob/living/target)
	if(!length(SSmapping.levels_by_trait(ZTRAIT_PROCEDURAL_MAINTS)))
		to_chat(user, span_warning("The backrooms aren't loaded this round!"))
		return
	. = ..()
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob/living, clip_into_backrooms))
