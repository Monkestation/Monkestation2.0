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
	var/obj/item/organ/internal/cyberimp/arm/item_set/doorjack/canopener = new
	canopener.Insert(H, TRUE, FALSE)
	return ..()

/datum/antagonist/abandoned_ipc/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["laws"] = laws
	return data

/datum/antagonist/abandoned_ipc/get_admin_commands()
	. = ..()
	.["Add law"] = CALLBACK(src, PROC_REF(admin_add_law))
	.["Remove law"] = CALLBACK(src, PROC_REF(admin_remove_law))

/datum/antagonist/abandoned_ipc/proc/admin_add_law(mob/admin)
	var/new_law = tgui_input_text(admin, "What law?", "Ai law 2 open")
	laws += new_law
	owner.current.balloon_alert(owner.current, "laws updated!")
	message_admins("[key_name_admin(admin)] has added a law to an abandoned IPC [key_name_admin(owner)]. New law is [span_blue(new_law)].")
	log_admin("[key_name(admin)] has added a law to an abandoned IPC [key_name(owner)]. New law is [new_law].")

/datum/antagonist/abandoned_ipc/proc/admin_remove_law(mob/admin)
	var/gone_law = tgui_input_list(admin, "What law?", "AI law 2 close", laws)
	laws -= gone_law
	owner.current.balloon_alert(owner.current, "laws updated!")
	message_admins("[key_name_admin(admin)] has removed a law from an abandoned IPC [key_name_admin(owner)]. Removed law is [span_blue(gone_law)].")
	log_admin("[key_name(admin)] has removed a law from an abandoned IPC [key_name(owner)]. Removed law is [gone_law].")

/obj/item/organ/internal/cyberimp/arm/item_set/doorjack
	name = "Doorjack Implant"
	desc = "An internal doorjack implant. Useful for getting through doors!"
	icon_state = "toolkit_doorjack"
	contents = newlist(/obj/item/internal_doorjack)
	zone = "r_arm"

/obj/item/internal_doorjack
	name = "integrated Doorjack"
	desc = "A built in doorjack, attached to your arm. Can be used to open doors."
	icon = "wawa"
	icon_state = 'icons/obj/card.dmi'

// update_icon(ALL, AIRLOCK_EMAG, 1)
