/datum/surgery/advanced/brainwashing
	requires_bodypart_type = BODYTYPE_ORGANIC

/datum/surgery/advanced/brainwashing/mechanic
	requires_bodypart_type = BODYTYPE_ROBOTIC // monke edit: IPC law 2 download BonziBuddy
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/brainwash,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
		)
