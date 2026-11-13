/// Makes it so that when a slime's core has plasma poured on it, it builds a new body and moves the brain into it.
/obj/item/organ/internal/brain/slime/check_for_repair(obj/item/item, mob/user)
	if(!item.is_drainable() || !item.reagents.has_reagent(/datum/reagent/toxin/plasma)) //attempt to heal the brain
		return ..()
	var/has_dnr_quirk = locate(/datum/quirk/dnr) in stored_quirks

	if(mind?.dnr || has_dnr_quirk)
		to_chat(user, span_warning("The soul of [src] has departed..."))
		user.balloon_alert(user, "core's soul has departed...")
		return FALSE

	if (item.reagents.get_reagent_amount(/datum/reagent/toxin/plasma) < 100)
		user.balloon_alert(user, "too little plasma!")
		return FALSE

	user.visible_message(
		span_notice("[user] starts to slowly pour the contents of [item] onto [src]. It seems to bubble and roil, beginning to stretch its cytoskeleton outwards..."),
		span_notice("You start to slowly pour the contents of [item] onto [src]. It seems to bubble and roil, beginning to stretch its membrane outwards..."),
		span_hear("You hear bubbling.")
	)
	user.balloon_alert_to_viewers("pouring plasma...")

	if(brainmob)
		brainmob.notify_ghost_cloning("Someone is pouring plasma on your core!")
		brainmob.grab_ghost()

	if(!do_after(user, 30 SECONDS, src))
		to_chat(user, span_warning("You failed to pour the contents of [item] onto [src]!"))
		return FALSE

	if(mind?.dnr || has_dnr_quirk)
		to_chat(user, span_warning("The soul of [src] has departed..."))
		user.balloon_alert(user, "core's soul has departed...")
		return FALSE

	if (item.reagents.get_reagent_amount(/datum/reagent/toxin/plasma) < 100) // minor exploit but might as well patch it
		user.balloon_alert(user, "too little plasma!")
		return FALSE

	user.visible_message(
		span_notice("[user] pours the contents of [item] onto [src], causing it to form a proper cytoplasm and outer membrane."),
		span_notice("You pour the contents of [item] onto [src], causing it to form a proper cytoplasm and outer membrane."),
		span_hear("You hear a splat.")
	)

	item.reagents.remove_reagent(/datum/reagent/toxin/plasma, 100)
	rebuild_body(user)
	return TRUE

/obj/item/organ/internal/brain/slime/proc/rebuild_body(mob/user, nugget = TRUE, revival_policy = POLICY_REVIVAL) as /mob/living/carbon/human
	if(rebuilt)
		return owner

	GLOB.dead_oozeling_cores -= src
	set_organ_damage(0) // heals the brain fully

	if(istype(loc, /mob/living/basic/mining/legion))
		var/mob/living/basic/mining/legion/legion = loc
		legion.gib()
	else if(istype(loc, /obj/effect/abstract/chasm_storage))
		// oh fuck we're reviving in a chasm somehow, uhhhh, quick, find us the nearest non-chasm turf
		for(var/turf/turf as anything in spiral_range_turfs(5, get_turf(src), TRUE))
			if(!isopenturf(turf) || isgroundlessturf(turf) || turf.is_blocked_turf(exclude_mobs = TRUE))
				continue
			forceMove(turf)
			break

	if(gps_active) // making sure the gps signal is removed if it's active on revival
		qdel(GetComponent(/datum/component/gps))

	//we have the plasma. we can rebuild them.
	brainmob?.mind?.grab_ghost()
	if(isnull(mind))
		if(isnull(brainmob))
			user?.balloon_alert(user, "this brain is not a viable candidate for repair!")
			return null
		if(isnull(brainmob.stored_dna))
			user?.balloon_alert(user, "this brain does not contain any dna!")
			return null
		if(isnull(brainmob.client))
			user?.balloon_alert(user, "this brain does not contain a mind!")
			return null
		if(HAS_TRAIT(brainmob.mind, TRAIT_NO_SPECIAL_REVIVAL))
			user?.balloon_alert(user, "this brain can't be revived!")
			return null

	if(ismob(loc))
		var/mob/holder = loc
		holder.dropItemToGround(src, force = TRUE, silent = TRUE)

	var/mob/living/carbon/human/new_body = new /mob/living/carbon/human(drop_location())

	rebuilt = TRUE

	var/client/original_client = brainmob?.client || mind?.current?.client
	original_client?.prefs?.safe_transfer_prefs_to(new_body)
	if(stored_language_holder)
		new_body.get_language_holder()?.copy_languages(stored_language_holder)
		QDEL_NULL(stored_language_holder)
	if(voice)
		new_body.copy_voice_from(src)
	new_body.underwear = "Nude"
	new_body.undershirt = "Nude"
	new_body.socks = "Nude"
	stored_dna.copy_dna(new_body.dna, COPY_DNA_SE | COPY_DNA_SPECIES)
	new_body.physique = stored_physique
	new_body.real_name = new_body.dna.real_name
	new_body.name = new_body.dna.real_name
	new_body.updateappearance(mutcolor_update = TRUE)
	new_body.domutcheck()
	if(!nugget)
		new_body.set_nutrition(NUTRITION_LEVEL_FED)
		reequip_items(new_body)
	new_body.blood_volume = nugget ? (BLOOD_VOLUME_SAFE + 60) : BLOOD_VOLUME_NORMAL
	REMOVE_TRAIT(new_body, TRAIT_NO_TRANSFORM, REF(src))
	for(var/datum/quirk/quirk in stored_quirks)
		quirk.add_to_holder(new_body, quirk_transfer = TRUE) // Return their old quirk to them.
	stored_quirks.Cut()
	if(original_client)
		var/list/skip_quirks = list()
		for(var/datum/quirk/quirk_type as anything in subtypesof(/datum/quirk))
			if(quirk_type::quirk_flags & QUIRK_OOZELING_SKIP)
				skip_quirks += quirk_type
		SSquirks.AssignQuirks(new_body, original_client, blacklist = skip_quirks) // Still need to copy over the rest of their quirks.
	var/obj/item/organ/internal/brain/new_body_brain = new_body.get_organ_slot(ORGAN_SLOT_BRAIN)
	qdel(new_body_brain)
	forceMove(new_body)
	Insert(new_body)
	if(nugget)
		for(var/obj/item/bodypart/bodypart as anything in new_body.bodyparts)
			if(istype(bodypart, /obj/item/bodypart/chest))
				continue
			bodypart.drop_limb() // Drop limb should delete the limb for oozelings unless someone changes it.
		new_body.visible_message(span_warning("[new_body]'s torso \"forms\" from [new_body.p_their()] core, yet to form the rest."))
		to_chat(owner, span_purple("Your torso fully forms out of your core, yet to form the rest."))
		//Make oozelings revive similar to other species.
		new_body.set_jitter_if_lower(200 SECONDS)
		new_body.emote("scream")
	else
		new_body.visible_message(span_warning("[new_body]'s body fully forms from [new_body.p_their()] core!"))
		to_chat(owner, span_purple("Your body fully forms from your core!"))

	membrane_mur.Remove(brainmob)
	brainmob?.mind?.transfer_to(new_body)
	new_body.grab_ghost()
	transfer_observers_to(new_body)

	readd_to_body(new_body)
	drop_items_to_ground(new_body.drop_location())

	var/policy = get_policy(revival_policy)
	if(policy)
		to_chat(new_body, policy, avoid_highlighting = TRUE)

	SEND_SIGNAL(mind, COMSIG_OOZELING_REVIVED, new_body, src, nugget)
	return new_body

ADMIN_VERB(cmd_admin_heal_oozeling, R_ADMIN, FALSE, "Heal Oozeling Core", "Use this to heal Oozeling cores.", ADMIN_CATEGORY_DEBUG)
	VERB_ARG_TYPED(core, VERB_ARG_TYPE_OBJ, VERB_ARG_SOURCE_WORLD, /obj/item/organ/internal/brain/slime)
	if(QDELETED(core))
		to_chat(user, span_boldannounce("Invalid Oozeling Core."), confidential = TRUE)
		return
	var/mob/living/carbon/human/new_body = core.rebuild_body(nugget = FALSE)

	var/log_msg
	var/msg
	if(!isnull(new_body))
		log_msg = "[key_name(user)] healed / revived [key_name(new_body)]"
		msg = span_danger("Admin [key_name_admin(user)] healed / revived [ADMIN_LOOKUPFLW(new_body)]!")
	else
		log_msg = "[key_name(user)] attempted to heal / revive [key_name(core)]. A body was not reconstructed."
		msg = span_danger("Admin [key_name_admin(user)] attempted to heal / revive [ADMIN_LOOKUPFLW(core)]! A body was not reconstructed.")
	log_admin(log_msg)
	message_admins(msg)
	admin_ticket_log(new_body, log_msg)
	BLACKBOX_LOG_ADMIN_VERB("Heal Oozeling Core")
