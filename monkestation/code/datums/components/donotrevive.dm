/**
 * donotrevive.dm: For when they need to STAY dead.
 *
 * When someone dies with this, it calls ghostize with can_reenter_body false, so theyre out of their body for good. as if they ghosted/went DNR automatically.
 * Medbay hates him! See how he wastes doctors time with this one simple trick!
 *
 */
/datum/component/donotrevive
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/donotrevive/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/donotrevive/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(check_death))

/datum/component/donotrevive/UnregisterFromParent(datum/target)
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)

/datum/component/donotrevive/proc/check_death(mob/living/source)
	source.ghostize(FALSE) //Get em outta here! FALSE sets can_reenter_corpse false, so this, does it SO MUCH simpler than i expected.
	source.mind = null //And get em outta here forever!
	source.med_hud_set_status() //And let them know hes outta here!
