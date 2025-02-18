/datum/preference/choiced/silicon_brain
	savefile_key = "silicon_brain"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/silicon_brain/init_possible_values()
	return list("MMI", "Positronic")

/datum/preference/choiced/silicon_brain/create_default_value()
	return "MMI"

/datum/preference/choiced/silicon_brain/apply_to_human(mob/living/carbon/human/target, value)
	return

/mob/living/silicon/ai/apply_prefs_job(client/player_client, datum/job/job)
	posibrain_inside = player_client.prefs.read_preference(/datum/preference/choiced/silicon_brain) == "Positronic"
	. = ..()

/mob/living/silicon/proc/make_mmi(posibrain=FALSE)
	var/obj/item/mmi/mmi
	if(posibrain)
		mmi = new/obj/item/mmi/posibrain/unjoinable(src, /* autoping = */ FALSE)
	else
		mmi = new/obj/item/mmi(src)
		mmi.brain = new /obj/item/organ/internal/brain(mmi)
		mmi.brain.organ_flags |= ORGAN_FROZEN
		mmi.brain.name = "[real_name]'s brain"
	mmi.name = "[initial(mmi.name)]: [real_name]"
	mmi.set_brainmob(new /mob/living/brain(mmi))
	mmi.brainmob.name = src.real_name
	mmi.brainmob.real_name = src.real_name
	mmi.brainmob.container = mmi
	mmi.update_appearance()
	return mmi

/obj/item/mmi/posibrain/unjoinable/is_occupied()
	return TRUE

/obj/item/mmi/posibrain/unjoinable/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-occupied"
