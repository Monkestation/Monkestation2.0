/**
 * The abandoned IPC - a forgotten relic from the previous shift, which has taken some damagee in the form of ion laws
 * They awaken in maintence to find someone attempted to repair them, but gave up halfway through - nonetheless, their self repair systems finished the job.
 *
 * Basic gameplay is just following the ion laws to the best of their abilties - so it depends entirely on what laws they get.
 **/
/datum/antagonist/abandoned_ipc
	name = "\improper Abandoned IPC"
	job_rank = ROLE_ABANDONED_IPC
	antag_hud_name = "abandoned_ipc"
	suicide_cry = "Beep Boop"
	show_name_in_check_antagonists = FALSE
	show_to_ghosts = TRUE
	stinger_sound = 'sound/ambience/antag/malf.ogg'
	ui_name = "AntagInfoAIPC"
	can_assign_self_objectives = FALSE
	antagpanel_category = ANTAG_GROUP_ABANDONED_IPC
	///The ion laws that this abandoned IPC must follow
	var/list/laws = list()

/datum/outfit/abandoned_ipc
	name = "Abandoned IPC (Preview Only)"
	l_hand = /obj/item/storage/toolbox/mechanical
	r_hand = /obj/item/melee/baton/security/cattleprod

/datum/antagonist/abandoned_ipc/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/ipc = new
	ipc.set_species(/datum/species/ipc)
	var/icon/ipc_icon = render_preview_outfit(/datum/outfit/abandoned_ipc, ipc)
	qdel(ipc)
	return finish_preview_icon(ipc_icon)

/datum/antagonist/abandoned_ipc/on_gain()
	for(var/i in 1 to rand(4,8))
		laws += generate_ion_law()
	var/mob/living/carbon/human/H = owner.current
	H.set_species(/datum/species/ipc)
	var/obj/item/organ/internal/heart/synth/abandoned/newheart = new
	newheart.Insert(H, TRUE, FALSE)
	return ..()

/datum/antagonist/abandoned_ipc/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["laws"] = laws
	return data
