/**
 * Helper proc to check if someone has a shadow tumor
 */
/proc/get_shadow_tumor(mob/living/source)
	if(!istype(source))
		return
	var/obj/item/organ/tumor = source.get_organ_slot(ORGAN_SLOT_BRAIN_TUMOR)
	if(!tumor || !istype(tumor, /obj/item/organ/internal/shadowtumor)) //if they somehow lose their tumor in an unusual way
		return
	return tumor


/datum/antagonist/thrall_darkspawn
	name = "Darkspawn Thrall"
	job_rank = ROLE_DARKSPAWN
	antag_hud_name = "thrall"
	roundend_category = "thralls"
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_IGNORE
	antagpanel_category = "Darkspawn"
	hud_icon = 'icons/mob/huds/antag_hud.dmi'
	antag_moodlet = /datum/mood_event/thrall_darkspawn
	stinger_sound = 'sound/ambience/antag/darkspawn/become_veil.ogg'
	antag_count_points = 5 //conversion
	///The abilities granted to the thrall
	var/list/abilities = list(/datum/action/cooldown/spell/toggle/nightvision, /datum/action/cooldown/spell/pointed/darkspawn_build/thrall_eye/thrall)
	///The darkspawn team that the thrall is on
	var/datum/team/darkspawn/team

/datum/antagonist/thrall_darkspawn/antag_panel_data()

	return "The Darkspawn are your master! Protect them, spread the darkness, and bring them wills to absorb!"

/datum/antagonist/thrall_darkspawn/get_team()
	return team

/datum/antagonist/thrall_darkspawn/on_gain()
	owner.special_role = "thrall"
	message_admins("[key_name_admin(owner.current)] was thralled by a darkspawn!")
	log_game("[key_name(owner.current)] was thralled by a darkspawn!")
	for (var/datum/team/darkspawn/T in GLOB.antagonist_teams)
		team = T
	if(!team)
		team = new
		stack_trace("thrall made without darkspawns")
	return ..()

/datum/antagonist/thrall_darkspawn/on_removal()
	message_admins("[key_name_admin(owner.current)] was dethralled!")
	log_game("[key_name(owner.current)] was dethralled!")
	owner.special_role = null
	var/mob/living/M = owner.current
	M.faction -= FACTION_DARKSPAWN
	if(issilicon(M))
		M.audible_message(span_notice("[M] lets out a short blip, followed by a low-pitched beep."))
		to_chat(M,span_userdanger("You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a thrall! Though you try, you cannot remember anything about your servitude..."))
	else
		M.visible_message(span_big("[M] looks like their mind is their own again!"))
		to_chat(M,span_userdanger("A piercing white light floods your eyes. Your mind is your own again! Though you try, you cannot remember anything about the darkspawn or your time under their command..."))
	return ..()

/datum/antagonist/thrall_darkspawn/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	team?.add_thrall(owner)

	add_team_hud(current_mob)
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(thrall_life))
	RegisterSignal(current_mob, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	current_mob.update_appearance(UPDATE_OVERLAYS)
	current_mob.grant_language(/datum/language/shadowtongue, source = LANGUAGE_DARKSPAWN)
	current_mob.faction |= FACTION_DARKSPAWN

	current_mob.AddComponent(/datum/component/internal_cam, list(ROLE_DARKSPAWN))
	var/datum/component/internal_cam/cam = current_mob.GetComponent(/datum/component/internal_cam)
	cam?.change_cameranet(GLOB.thrallnet)

	for(var/spell in abilities)
		if(isarachnid(current_mob) && ispath(spell, /datum/action/cooldown/spell/toggle/nightvision))
			continue //arachnids dont need it really.
		var/datum/action/cooldown/spell/new_spell = new spell(owner)
		new_spell.Grant(current_mob)

	if(isliving(current_mob))
		var/obj/item/organ/internal/shadowtumor/thrall/tumor = current_mob.get_organ_slot(ORGAN_SLOT_BRAIN_TUMOR)
		if(!tumor || !istype(tumor))
			tumor = new
			tumor.Insert(current_mob, FALSE, FALSE)
			if(team)
				tumor.antag_team = team

/datum/antagonist/thrall_darkspawn/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	team?.remove_thrall(owner)

	UnregisterSignal(current_mob, COMSIG_LIVING_LIFE)
	UnregisterSignal(current_mob, COMSIG_ATOM_UPDATE_OVERLAYS)
	current_mob.update_appearance(UPDATE_OVERLAYS)
	current_mob.remove_language(/datum/language/shadowtongue, source = LANGUAGE_DARKSPAWN)
	current_mob.faction -= FACTION_DARKSPAWN

	qdel(current_mob.GetComponent(/datum/component/internal_cam))
	for(var/datum/action/cooldown/spell/spells in current_mob.actions)
		if(spells.type in abilities)//no keeping your abilities
			spells.Remove(current_mob)
			qdel(spells)
	qdel(get_shadow_tumor(current_mob))
	current_mob.update_sight()

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Antag hud---------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/thrall_darkspawn/add_team_hud(mob/target, antag_to_check)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
		//antag_to_check || type,
	))

	var/datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn/hud = team_hud_ref.resolve()

	// Add HUDs that they couldn't see before
	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn/antag_hud as anything in GLOB.has_antagonist_huds)
		if(istype(antag_hud, /datum/atom_hud/alternate_appearance/basic/has_antagonist/darkspawn))
			antag_hud.show_to(target)
			hud.show_to(antag_hud.target)

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Body Sigil--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/thrall_darkspawn/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(!ishuman(source))
		return

	//draw both the overlay itself and the emissive overlay
	var/mutable_appearance/overlay = mutable_appearance('icons/mob/simple/darkspawn.dmi', "veil_sigils", -UNDER_SUIT_LAYER)
	overlay.color = COLOR_DARKSPAWN_PSI
	overlays += overlay

////////////////////////////////////////////////////////////////////////////////////
//-----------Check if the thrall has a tumor, if not, dethrall them---------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/thrall_darkspawn/proc/thrall_life(mob/living/source, seconds_per_tick, times_fired)
	if(!source || source.stat == DEAD)
		return
	if(!get_shadow_tumor(source)) //if they somehow lose their tumor in an unusual way
		source.remove_thrall()

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Antag greet--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/thrall_darkspawn/greet()
	to_chat(owner, span_progenitor("Krx'lna tyhx graha xthl'kap" ))

	var/list/flavour = list()
	if(isipc(owner.current))
		flavour += "You feel the warm consciousness welcome your own. Realization spews forth as the veil recedes."
	else
		flavour += "You feel the vast consciousness slowly consume your own and the veil falls away."
	flavour += "Serve the darkspawn above all else. Your former allegiances are now forfeit."
	flavour += "Their goal is yours, and yours is theirs."
	to_chat(owner, span_velvet(flavour.Join("<br>")))

	to_chat(owner, span_notice("<i>Use <b>.[MODE_KEY_DARKSPAWN]</b> before your messages to speak over the Mindlink.</i>"))
	to_chat(owner, span_notice("<i>Blending in with regular crewmembers will generate willpower for your masters.</i>"))
	to_chat(owner, span_notice("<i>Ask for help from your masters or fellows if you're new to this role.</i>"))
	flash_color(owner, flash_color = COLOR_VELVET, flash_time = 10 SECONDS)
	play_stinger()

/datum/antagonist/thrall_darkspawn/roundend_report()
	return "[printplayer(owner)]"
