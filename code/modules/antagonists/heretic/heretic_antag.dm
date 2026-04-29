

/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 *
 * Used in creating spooky-text for heretic ascension announcements.
 */
/proc/generate_heretic_text(length = 25)
	if(!isnum(length)) // stupid thing so we can use this directly in replacetext
		length = 25
	. = ""
	for(var/i in 1 to length)
		. += pick("!", "$", "^", "@", "&", "#", "*", "(", ")", "?")

/// The heretic antagonist itself.
/datum/antagonist/heretic
	name = "\improper Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	ui_name = "AntagInfoHeretic"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic"
	hijack_speed = 0.5 // only if ascended or moon
	suicide_cry = "THE MANSUS SMILES UPON ME!!"
	preview_outfit = /datum/outfit/heretic
	can_assign_self_objectives = TRUE
	default_custom_objective = "Turn a department into a testament for your dark knowledge."
	hardcore_random_bonus = TRUE
	stinger_sound = 'sound/music/antag/heretic/heretic_gain.ogg'
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_OBSERVER_VISIBLE_PANEL
	antag_count_points = 15

	info_background_icon_state = "bg_heretic"
	info_overlay_icon_state = "bg_heretic_border"

	/// Contains multiple separate heretic shops so you can choose between multiple when buying.
	var/list/heretic_shops = list(
		HERETIC_KNOWLEDGE_START = list(),
		HERETIC_KNOWLEDGE_TREE = list(),
		HERETIC_KNOWLEDGE_SHOP = list(),
		HERETIC_KNOWLEDGE_DRAFT = list()
	)
	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava, /turf/open/chasm))
	/// A static list of all paths we can take and related info for the UI
	var/static/list/path_info = list()
	/// Assoc list of [typepath] = [knowledge instance]. A list of all knowledge this heretic's reserached.
	var/list/researched_knowledge = list()
	/// List that keeps track of which items have been gifted to the heretic after a cultist was sacrificed. Used to alter drop chances to reduce dupes.
	var/list/unlocked_heretic_items = list(
		/obj/item/melee/sickly_blade/cursed = 0,
		/obj/item/clothing/neck/heretic_focus/crimson_medallion = 0,
		/mob/living/basic/construct/harvester/heretic = 0,
	)
	/// Weakrefs to the minds of monsters have been successfully summoned. Includes ghouls.
	var/list/datum/mind/monsters_summoned
	/// Lazy list of minds that are our current sacrifice targets.
	var/list/datum/mind/current_sac_targets
	/// Lazy list containing all the minds we've ever had as sacrifice targets. Used for the end-of-round report.
	var/list/datum/mind/all_sac_targets
	/// Lazy list of minds that we have sacrificed.
	var/list/datum/mind/completed_sacrifices
	/// Whether or not the heretic can make unlimited blades, but unable to blade break to teleport
	var/unlimited_blades = FALSE
	/// Whether we are allowed to ascend
	var/feast_of_owls = FALSE
	/// Whether we give this antagonist objectives on gain.
	var/give_objectives = TRUE
	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// Whether we're drawing a rune or not
	var/drawing_rune = FALSE
	/// The path our heretic has chosen.
	var/datum/heretic_knowledge_tree_column/heretic_path
	/// A sum of how many knowledge points this heretic CURRENTLY has. Used to research.
	var/knowledge_points = 2
	/// Points used for purchasing from the sidepath shop, tracked separately from regular knowledge points, these can ONLY be used from the sidepath, where the main ones can be used on both
	var/sidepath_points = 0
	/// The time between gaining influence passively. The heretic gain +1 knowledge points every this duration of time.
	var/passive_gain_timer = 20 MINUTES
	/// Tracks how many knowledge points the heretic has aqcuired. Once you get enough points you lose the ability to blade break
	var/knowledge_gained = 0
	/// The organ slot we place our Living Heart in.
	var/living_heart_organ_slot = ORGAN_SLOT_HEART
	/// A list of TOTAL how many sacrifices completed. (Includes high value sacrifices)
	var/total_sacrifices = 0
	/// A list of TOTAL how many high value sacrifices completed. (Heads of staff)
	var/high_value_sacrifices = 0
	/// The total number of essences siphoned from influences.
	var/essences_siphoned = 0
	/// Controls what types of turf we can spread rust to
	var/rust_strength = 1
	/// Simpler version of above used to limit amount of loot that can be hoarded
	var/rewards_given = 0
	/// Our heretic passive level. Tracked here in case of body moving shenanigans
	var/passive_level = 1
	/// How many points are needed to gain a visible heretic aura
	var/points_to_aura = 8

/datum/antagonist/heretic/Destroy()
	for(var/datum/mind/old_target as anything in current_sac_targets)
		UnregisterSignal(old_target, COMSIG_MIND_CRYOED)
	LAZYNULL(monsters_summoned)
	LAZYNULL(current_sac_targets)
	LAZYNULL(all_sac_targets)
	LAZYNULL(completed_sacrifices)
	return ..()

/datum/antagonist/heretic/proc/get_icon_of_knowledge(datum/heretic_knowledge/knowledge)
	//basic icon parameters
	var/icon_path = 'icons/mob/actions/actions_ecult.dmi'
	var/icon_state = "eye"
	var/icon_frame = knowledge.research_tree_icon_frame
	var/icon_dir = knowledge.research_tree_icon_dir
	//can't imagine why you would want this one, so it can't be overridden by the knowledge
	var/icon_moving = 0

	// we need to convert this to a typepath
	if(istype(knowledge))
		knowledge = knowledge.type

	//item transmutation knowledge does not generate its own icon due to implementation difficulties, the icons have to be specified in the override vars

	//if the knowledge has a special icon, use that
	if(!isnull(knowledge.research_tree_icon_path))
		icon_path = knowledge.research_tree_icon_path
		icon_state = knowledge.research_tree_icon_state

	//if the knowledge is a spell, use the spell's button
	else if(ispath(knowledge,/datum/heretic_knowledge/spell))
		var/datum/heretic_knowledge/spell/spell_knowledge = knowledge
		var/datum/action/result_action = spell_knowledge.action_to_add
		icon_path = result_action.button_icon
		icon_state = result_action.button_icon_state

	//if the knowledge is a summon, use the mob sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/summon))
		var/datum/heretic_knowledge/summon/summon_knowledge = knowledge
		var/mob/living/result_mob = summon_knowledge.mob_to_summon
		icon_path = result_mob.icon
		icon_state = result_mob.icon_state

	//if the knowledge is an ascension, use the achievement sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/ultimate))
		var/datum/heretic_knowledge/ultimate/ascension_knowledge = knowledge
		var/datum/award/achievement/misc/achievement = ascension_knowledge.ascension_achievement
		if(!isnull(achievement))
			icon_path = achievement.icon
			icon_state = achievement.icon_state

	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

/datum/antagonist/heretic/proc/get_knowledge_data(datum/heretic_knowledge/knowledge, list/source_list, done = FALSE, category = HERETIC_KNOWLEDGE_TREE)
	if(!length(source_list))
		CRASH("get_knowledge_data called without source_list! (Got: [source_list || "empty list"])")
	var/list/knowledge_data = list()
	var/cost = source_list[knowledge][HKT_COST]

	knowledge_data["path"] = knowledge
	knowledge_data["icon_params"] = get_icon_of_knowledge(knowledge)
	knowledge_data["name"] = initial(knowledge.name)
	knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
	knowledge_data["cost"] = cost
	knowledge_data["depth"] = source_list[knowledge][HKT_DEPTH]
	knowledge_data["bgr"] = source_list[knowledge][HKT_UI_BGR]
	knowledge_data[HKT_CATEGORY] = category
	knowledge_data["ascension"] = ispath(knowledge, /datum/heretic_knowledge/ultimate)

	knowledge_data["done"] = done
	if(!done)
		knowledge_data["can_research"] = can_buy_knowledge(knowledge, category, cost)
	//description of a knowledge might change, make sure we are not shown the initial() value in that case
	var/list/knowledge_info = researched_knowledge[knowledge]
	if(islist(knowledge_info))
		var/datum/heretic_knowledge/knowledge_instance = knowledge_info[HKT_INSTANCE]

		knowledge_data["desc"] = knowledge_instance.desc
		knowledge_data["info"] = knowledge_instance.transmute_text
		knowledge_data["notice"] = knowledge_instance.notice
	else
		knowledge_data["desc"] = initial(knowledge.desc)
		knowledge_data["info"] = initial(knowledge.transmute_text)
		knowledge_data["notice"] = initial(knowledge.notice)

	if(ispath(knowledge, /datum/heretic_knowledge/ultimate))
		var/ascension_check = can_ascend()
		if(ascension_check != HERETIC_CAN_ASCEND)
			knowledge_data["disabled"] = TRUE
			knowledge_data["notice"] += "<br>[ascension_check]"

	return knowledge_data

/datum/antagonist/heretic/proc/can_buy_knowledge(datum/heretic_knowledge/knowledge, shop_category = HERETIC_KNOWLEDGE_TREE, cost = 0)
	if(!researchable_knowledge(knowledge, shop_category))
		return FALSE
	if(shop_category == HERETIC_KNOWLEDGE_SHOP && sidepath_points >= cost)
		return TRUE
	return knowledge_points >= cost

/datum/antagonist/heretic/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui?.set_autoupdate(FALSE)

/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()
	data["charges"] = knowledge_points
	data["sidepath_charges"] = sidepath_points

	data["objectives"] = get_objectives()
	data["can_change_objective"] = can_assign_self_objectives

	data["paths"] = path_info
	data["passive_level"] = passive_level

	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["points_to_aura"] = points_to_aura

	var/list/tree_data = list()
	var/list/shop_knowledge = list()

	// This should be cached in some way, but the fact that final knowledge
	// has to update its disabled state based on whether all objectives are complete,
	// makes this very difficult. I'll figure it out one day maybe
	for(var/knowledge_path in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_path]
		/// draft knowledges are only shown post-research
		var/list/knowledge_data = get_knowledge_data(knowledge_path, researched_knowledge, TRUE, knowledge_info[HKT_CATEGORY])
		var/category = knowledge_info[HKT_CATEGORY]

		var/depth = knowledge_info[HKT_DEPTH]
		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		if(category == HERETIC_KNOWLEDGE_SHOP || category == HERETIC_KNOWLEDGE_DRAFT)
			shop_knowledge += list(knowledge_data)
			continue

		tree_data[depth]["nodes"] += list(knowledge_data)

	// TODO: sanity for purchasing categories as bypasses are likely rn
	var/list/heretic_tree = heretic_shops[HERETIC_KNOWLEDGE_TREE]
	var/list/researchable_knowledges = get_researchable_knowledge()
	for(var/datum/heretic_knowledge/knowledge_path as anything in heretic_tree)
		if(ispath(knowledge_path, /datum/heretic_knowledge/limited_amount/starting))
			continue
		var/list/knowledge_info = heretic_tree[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge_path, heretic_tree, FALSE)

		var/depth = knowledge_data[HKT_DEPTH]

		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		tree_data[depth]["nodes"] += list(knowledge_data)


	if(!heretic_path)
		data["knowledge_tiers"] = tree_data
		return data

	var/list/heretic_drafts = heretic_shops[HERETIC_KNOWLEDGE_DRAFT]
	for(var/datum/heretic_knowledge/knowledge_path as anything in heretic_drafts)
		var/list/knowledge_info = heretic_drafts[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge_path, heretic_drafts, FALSE, HERETIC_KNOWLEDGE_DRAFT)

		var/depth = knowledge_data[HKT_DEPTH]
		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		tree_data[depth]["nodes"] += list(knowledge_data)

	data["knowledge_tiers"] = tree_data
	var/list/shop = heretic_shops[HERETIC_KNOWLEDGE_SHOP]
	for(var/knowledge_path in shop)
		var/list/knowledge_info = shop[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue

		var/list/knowledge_data = get_knowledge_data(knowledge_path, shop, FALSE, HERETIC_KNOWLEDGE_SHOP)
		shop_knowledge += list(knowledge_data)

	data["knowledge_shop"] = shop_knowledge

	return data

/datum/antagonist/heretic/hijack_speed()
	if(!ascended && heretic_path?.route != PATH_MOON)
		return 0
	return ..()

/datum/antagonist/heretic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("research")
			var/datum/heretic_knowledge/researched_path = text2path(params["path"])
			if(!ispath(researched_path, /datum/heretic_knowledge))
				CRASH("Heretic attempted to learn non-heretic_knowledge path! (Got: [researched_path || "invalid path"])")
			var/shop_category = params["category"]
			if(!researchable_knowledge(researched_path, shop_category))
				message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn knowledge they can't learn!")
				CRASH("Heretic attempted to learn knowledge they can't learn! (Got: [researched_path])")
			if(ispath(researched_path, /datum/heretic_knowledge/ultimate) && can_ascend() != HERETIC_CAN_ASCEND)
				message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn ascension knowledge without completing objectives!")
				CRASH("Heretic attempted to learn a final knowledge despite not being able to ascend!")


			if(!purchase_knowledge(researched_path, shop_category))
				return FALSE
			SStgui.update_uis(src)
			log_heretic_knowledge("[key_name(owner)] gained knowledge: [researched_path::name]")
			SSblackbox.record_feedback("tally", "heretic_knowledge_researched", 1, "[researched_path::name]")
			return TRUE

/datum/antagonist/heretic/proc/researchable_knowledge(datum/heretic_knowledge/knowledge_path, shop_category = HERETIC_KNOWLEDGE_TREE)
	if(!length(heretic_shops[shop_category]))
		return FALSE
	var/list/knowledge_info = heretic_shops[shop_category][knowledge_path]
	if(knowledge_info[HKT_ID] in get_researchable_knowledge())
		return TRUE
	return FALSE

/datum/antagonist/heretic/submit_player_objective(retain_existing = FALSE, retain_escape = TRUE, force = FALSE)
	if (isnull(owner) || isnull(owner.current))
		return
	var/confirmed = tgui_alert(
		owner.current,
		message = "Are you sure? You will no longer be able to Ascend.",
		title = "Reject the call?",
		buttons = list("Yes", "No"),
	) == "Yes"
	if (!confirmed)
		return
	return ..()

/datum/antagonist/heretic/ui_status(mob/user, datum/ui_state/state)
	if(isnull(owner.current) || owner.current.stat == DEAD) // If the owner is dead, we can't show the UI.
		return UI_UPDATE
	return ..()

/datum/antagonist/heretic/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)

	// MOTHBLOCKS TOOD: Copied and pasted from cult, make this its own proc

	// The sickly blade is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/sickly_blade/blade_type = /obj/item/melee/sickly_blade
	icon.Blend(icon(blade_type::lefthand_file, blade_type::inhand_icon_state), ICON_OVERLAY)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/antagonist/heretic/farewell()
	if(!silent && owner.current)
		to_chat(owner.current, span_userdanger("Your mind begins to flare as the otherwordly knowledge escapes your grasp!"))
	return ..()

/datum/antagonist/heretic/on_gain()
	generate_heretic_starting_knowledge(heretic_shops[HERETIC_KNOWLEDGE_START])
	if(!length(path_info))
		for(var/datum/heretic_knowledge_tree_column/path as anything in subtypesof(/datum/heretic_knowledge_tree_column))
			path = new path()
			path_info += list(path.get_ui_data(src, HERETIC_KNOWLEDGE_START))
			qdel(path)

	if(give_objectives)
		forge_primary_objectives(heretic_shops[HERETIC_KNOWLEDGE_TREE])

	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge, HERETIC_KNOWLEDGE_START, update = FALSE)

	owner.current.AddElement(/datum/element/rust_healing, FALSE, 1.5, 5)

	// ADD_TRAIT(owner, TRAIT_SEE_BLESSED_TILES, REF(src))
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer) // Gain +1 knowledge every 20 minutes.

	RegisterSignal(SSdcs, COMSIG_GLOB_MONSTER_HUNTER_QUERY, PROC_REF(query_for_monster_hunter))
	RegisterSignal(owner, COMSIG_OOZELING_REVIVED, PROC_REF(on_oozeling_revive))
	return ..()

/datum/antagonist/heretic/on_removal()
	UnregisterSignal(SSdcs, COMSIG_GLOB_MONSTER_HUNTER_QUERY)
	UnregisterSignal(owner, COMSIG_OOZELING_REVIVED)

	if(owner.current)
		for(var/knowledge_path in researched_knowledge)
			var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
			knowledge.on_lose(owner.current, src, being_removed = TRUE)
			QDEL_NULL(researched_knowledge[knowledge_path][HKT_INSTANCE])

	// REMOVE_TRAIT(owner, TRAIT_SEE_BLESSED_TILES, REF(src))
	owner.current.RemoveElement(/datum/element/rust_healing, FALSE, 1.5, 5)
	QDEL_NULL(heretic_path)
	return ..()

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, "Ancient knowledge described to you has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	/* our_mob.add_faction(FACTION_HERETIC) */
	our_mob.faction += FACTION_HERETIC

	if(!issilicon(our_mob))
		GLOB.reality_smash_track.add_tracked_mind(owner)

	ADD_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, REF(src))
	RegisterSignal(our_mob, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_cult_sacrificed))
	RegisterSignals(our_mob, list(COMSIG_MOB_BEFORE_SPELL_CAST, COMSIG_MOB_SPELL_ACTIVATED), PROC_REF(on_spell_cast))
	RegisterSignal(our_mob, COMSIG_USER_ITEM_INTERACTION, PROC_REF(on_item_use))
	RegisterSignal(our_mob, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(after_fully_healed))
	RegisterSignal(our_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_heretic_examine))
	RegisterSignal(our_mob, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_aura_overlay))

	RegisterSignals(
		our_mob,
		list(SIGNAL_ADDTRAIT(TRAIT_HERETIC_AURA_HIDDEN), SIGNAL_REMOVETRAIT(TRAIT_HERETIC_AURA_HIDDEN)),
		PROC_REF(update_heretic_aura)
	)

	our_mob.update_appearance(UPDATE_OVERLAYS)

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, removing = FALSE)
	our_mob.faction -= FACTION_HERETIC

	if(owner in GLOB.reality_smash_track.tracked_heretics)
		GLOB.reality_smash_track.remove_tracked_mind(owner)

	REMOVE_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, REF(src))
	UnregisterSignal(
		our_mob,
		list(
			COMSIG_MOB_BEFORE_SPELL_CAST,
			COMSIG_MOB_SPELL_ACTIVATED,
			COMSIG_USER_ITEM_INTERACTION,
			COMSIG_LIVING_POST_FULLY_HEAL,
			COMSIG_LIVING_CULT_SACRIFICED,
			COMSIG_ATOM_EXAMINE,
			COMSIG_ATOM_UPDATE_OVERLAYS,
			SIGNAL_ADDTRAIT(TRAIT_HERETIC_AURA_HIDDEN),
			SIGNAL_REMOVETRAIT(TRAIT_HERETIC_AURA_HIDDEN)
		)
	)
	our_mob.update_appearance(UPDATE_OVERLAYS)

/// Removes the ability to blade break and removes the cap on how many blades you can craft
/datum/antagonist/heretic/proc/disable_blade_breaking()
	if(unlimited_blades)
		return
	var/mob/heretic_mob = owner.current
	unlimited_blades = TRUE
	to_chat(heretic_mob, span_boldwarning("You have gained a lot of power, the mansus will no longer allow you to break your blades, but you can now make as many as you wish."))
	heretic_mob.balloon_alert(heretic_mob, "blade breaking disabled!")
	update_heretic_aura()
	show_to_ghosts = TRUE // you're visible anyways

/// Adds an overlay to the heretic
/datum/antagonist/heretic/proc/update_heretic_aura()
	SIGNAL_HANDLER
	if(!QDELETED(owner.current))
		owner.current.update_appearance(UPDATE_OVERLAYS)
	return TRUE

/datum/antagonist/heretic/proc/add_aura_overlay(mob/living/source, list/overlays)
	SIGNAL_HANDLER
	if(!should_show_aura())
		return
	var/mutable_appearance/aura = mutable_appearance('icons/mob/effects/heretic_aura.dmi', "heretic_aura")
	aura.appearance_flags |= RESET_COLOR
	if(HAS_TRAIT(source, TRAIT_HERETIC_AURA_HIDDEN))
		aura.alpha = 150 // minimize visual clutter, but hopefully it's still visible enough
	overlays += aura
	overlays += emissive_appearance('icons/mob/effects/heretic_aura.dmi', "heretic_aura_e", source)

/datum/antagonist/heretic/proc/should_show_aura()
	if(ascended) // duh
		return TRUE
	if(!can_assign_self_objectives)
		return FALSE // We spurned the offer of the Mansus :(
	if(!unlimited_blades/* || HAS_TRAIT(owner.current, TRAIT_HERETIC_AURA_HIDDEN) */)
		return FALSE // No aura if we have the trait or is too early still
	if(feast_of_owls)
		return FALSE // No use in giving the aura to a heretic that can't ascend
	if(heretic_path?.route == PATH_LOCK)
		return FALSE // Lock heretics never get this aura
	return TRUE

/datum/antagonist/heretic/proc/on_heretic_examine(mob/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	var/datum/antagonist/heretic_monster/minion = user.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
	if(minion?.master == owner)
		examine_text += span_heretic_master("[source.p_They()] [source.p_are()] your master!")
	if(ascended)
		examine_text += "<span class='[heretic_path.examine_class]'>[span_big(span_bold(heretic_path.ascension_examine_text(source)))]</span>"
		return
	if(!should_show_aura())
		return
	var/mob/heretic_mob = owner.current
	var/potential_string = "[heretic_mob.p_They()] [heretic_mob.p_are()] crackling with a swirling green vortex of energy."
	if(can_ascend() == HERETIC_CAN_ASCEND)
		potential_string += " [heretic_mob.p_They()] [heretic_mob.p_are()] shedding [heretic_mob.p_their()] mortal shell!"
	examine_text += span_green(potential_string)

/datum/antagonist/heretic/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(old_body == new_body) // if they were using a temporary body
		return

	for(var/knowledge_path in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
		knowledge.on_lose(old_body, src)
		knowledge.on_gain(new_body, src)

/*
 * Signal proc for [COMSIG_MOB_BEFORE_SPELL_CAST] and [COMSIG_MOB_SPELL_ACTIVATED].
 *
 * Checks if our heretic has [TRAIT_ALLOW_HERETIC_CASTING] or is ascended.
 * If so, allow them to cast like normal.
 * If not, cancel the cast, and returns [SPELL_CANCEL_CAST].
 */
/datum/antagonist/heretic/proc/on_spell_cast(mob/living/source, datum/action/cooldown/spell/spell)
	SIGNAL_HANDLER

	// Heretic spells are of the forbidden school, otherwise we don't care
	if(spell.school != SCHOOL_FORBIDDEN)
		return

	// If we've got the trait, we don't care
	if(HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
		return
	// All powerful, don't care
	if(ascended)
		return

	// We shouldn't be able to cast this! Cancel it.
	source.balloon_alert(source, "you need a focus!")
	return SPELL_CANCEL_CAST

/*
 * Signal proc for [COMSIG_USER_ITEM_INTERACTION].
 *
 * If a heretic is holding a pen in their main hand,
 * and have mansus grasp active in their offhand,
 * they're able to draw a transmutation rune.
 */
/datum/antagonist/heretic/proc/on_item_use(mob/living/source, atom/target, obj/item/weapon, list/modifiers)
	SIGNAL_HANDLER
	if(!IS_WRITING_UTENSIL(weapon))
		return NONE
	if(!isturf(target) || !isliving(source))
		return NONE

	var/obj/item/offhand = source.get_inactive_held_item()
	if(QDELETED(offhand) || !istype(offhand, /obj/item/melee/touch_attack/mansus_fist))
		return NONE

	try_draw_rune(source, target, additional_checks = CALLBACK(src, PROC_REF(check_mansus_grasp_offhand), source))
	return ITEM_INTERACT_SUCCESS

/**
 * Attempt to draw a rune on [target_turf].
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/try_draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if(!isopenturf(nearby_turf) || is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			target_turf.balloon_alert(user, "invalid placement for rune!")
			return

	if(locate(/obj/effect/heretic_rune) in range(3, target_turf))
		target_turf.balloon_alert(user, "too close to another rune!")
		return

	if(drawing_rune)
		target_turf.balloon_alert(user, "already drawing a rune!")
		return

	INVOKE_ASYNC(src, PROC_REF(draw_rune), user, target_turf, drawing_time, additional_checks)

/**
 * The actual process of drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	drawing_rune = TRUE

	var/rune_colour = GLOB.heretic_path_to_color[heretic_path?.route || PATH_START]
	target_turf.balloon_alert(user, "drawing rune...")
	var/obj/effect/temp_visual/drawing_heretic_rune/drawing_effect
	if (drawing_time < (10 SECONDS))
		drawing_effect = new /obj/effect/temp_visual/drawing_heretic_rune/fast(target_turf, rune_colour)
	else
		drawing_effect = new(target_turf, rune_colour)

	if(!do_after(user, drawing_time, target_turf, extra_checks = additional_checks, hidden = TRUE))
		target_turf.balloon_alert(user, "interrupted!")
		new /obj/effect/temp_visual/drawing_heretic_rune/fail(target_turf, rune_colour)
		qdel(drawing_effect)
		drawing_rune = FALSE
		return

	qdel(drawing_effect)
	target_turf.balloon_alert(user, "rune created")
	new /obj/effect/heretic_rune/big(target_turf, rune_colour)
	drawing_rune = FALSE

/**
 * Callback to check that the user's still got their Mansus Grasp out when drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 */
/datum/antagonist/heretic/proc/check_mansus_grasp_offhand(mob/living/user)
	var/obj/item/offhand = user.get_inactive_held_item()
	return !QDELETED(offhand) && istype(offhand, /obj/item/melee/touch_attack/mansus_fist)

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL],
/// Gives the heretic aliving heart on aheal or organ refresh
/datum/antagonist/heretic/proc/after_fully_healed(mob/living/source, heal_flags)
	SIGNAL_HANDLER

	if(heal_flags & (HEAL_REFRESH_ORGANS|HEAL_ADMIN))
		var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
		heart_knowledge.on_research(source, src)

/// Signal proc for [COMSIG_LIVING_CULT_SACRIFICED] to reward cultists for sacrificing a heretic
/datum/antagonist/heretic/proc/on_cult_sacrificed(mob/living/source, list/invokers)
	SIGNAL_HANDLER

	notify_ghosts(
		"[owner.name], a heretic, has just been sacrificed to Nar'Sie!",
		source = source.loc,
		action = NOTIFY_ORBIT,
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
		header = "touhou hijack lol",
	)

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) // uhh let's find the guy to shove him back in
		if((ghost.mind?.current == source) && ghost.client) // is it the same guy and do they have the same client
			ghost.reenter_corpse() // shove them in! it doesnt do it automatically

	// Drop all items and splatter them around messily.
	var/list/dustee_items = source.unequip_everything()
	for(var/obj/item/loot as anything in dustee_items)
		loot.throw_at(get_step_rand(source), 2, 4, pick(invokers), TRUE)

	// Create the blade, give it the heretic and a randomly-chosen master for the soul sword component
	var/obj/item/melee/cultblade/haunted/haunted_blade = new(get_turf(source), source, pick(invokers))

	// Cool effect for the rune as well as the item
	var/obj/effect/rune/convert/conversion_rune = locate() in get_turf(source)
	if(conversion_rune)
		conversion_rune.gender_reveal(
			outline_color = COLOR_HERETIC_GREEN,
			ray_color = null,
			do_float = FALSE,
			do_layer = FALSE,
		)

	haunted_blade.gender_reveal(outline_color = null, ray_color = COLOR_HERETIC_GREEN)

	for(var/mob/living/culto as anything in invokers)
		to_chat(culto, span_cultlarge("\"A follower of the forgotten gods! You must be rewarded for such a valuable sacrifice.\""))

	// Locate a cultist team (Is there a better way??)
	var/mob/living/random_cultist = pick(invokers)
	var/datum/antagonist/cult/antag = random_cultist.mind.has_antag_datum(/datum/antagonist/cult)
	ASSERT(antag)
	var/datum/team/cult/cult_team = antag.get_team()

	// Unlock one of 3 special items!
	var/list/possible_unlocks
	for(var/i in cult_team.unlocked_heretic_items)
		if(cult_team.unlocked_heretic_items[i])
			continue
		LAZYADD(possible_unlocks, i)
	if(length(possible_unlocks))
		var/result = pick(possible_unlocks)
		cult_team.unlocked_heretic_items[result] = TRUE

		for(var/datum/mind/mind as anything in cult_team.members)
			if(mind.current)
				SEND_SOUND(mind.current, 'sound/magic/clockwork/narsie_attack.ogg')
				to_chat(mind.current, span_cultlarge(span_warning("Arcane and forbidden knowledge floods your forges and archives. The cult has learned how to create the ")) + span_cultlarge(span_hypnophrase("[result]!")))

	conversion_rune.flash_lighting_fx(range = 7, power = 3, color = COLOR_HERETIC_GREEN, duration = 5 SECONDS)

	return SILENCE_SACRIFICE_MESSAGE|DUST_SACRIFICE

/**
 * Creates an animation of the item slowly lifting up from the floor with a colored outline, then slowly drifting back down.
 * Arguments:
 * * outline_color: Default is between pink and light blue, is the color of the outline filter.
 * * ray_color: Null by default. If not set, just copies outline. Used for the ray filter.
 * * anim_time: Total time of the animation. Split into two different calls.
 * * do_float: Lets you disable the sprite floating up and down.
 * * do_layer: Lets you disable the layering increase.
 */
/obj/proc/gender_reveal(
	outline_color = null,
	ray_color = null,
	anim_time = 10 SECONDS,
	do_float = TRUE,
	do_layer = TRUE,
)

	var/og_layer
	if(do_layer)
		// Layering above to stand out!
		og_layer = layer
		layer = ABOVE_MOB_LAYER

	// Slowly floats up, then slowly goes down.
	if(do_float)
		animate(src, pixel_y = 12, time = anim_time * 0.5, easing = QUAD_EASING | EASE_OUT)
		animate(pixel_y = 0, time = anim_time * 0.5, easing = QUAD_EASING | EASE_IN)

	// Adding a cool outline effect
	if(outline_color)
		add_filter("gender_reveal_outline", 3, list("type" = "outline", "color" = outline_color, "size" = 0.5))
		// Animating it!
		var/gay_filter = get_filter("gender_reveal_outline")
		animate(gay_filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
		animate(alpha = 40, time = 2.5 SECONDS)

	// Adding a cool ray effect
	if(ray_color)
		add_filter(name = "gender_reveal_ray", priority = 1, params = list(
				type = "rays",
				size = 45,
				color = ray_color,
				density = 6
			))
		// Animating it!
		var/ray_filter = get_filter("gender_reveal_ray")
		// I understand nothing but copypaste saves lives
		animate(ray_filter, offset = 100, time = 30 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(remove_gender_reveal_fx), og_layer), anim_time)

/**
 * Removes the non-animate effects from above proc
 */
/obj/proc/remove_gender_reveal_fx(og_layer)
	remove_filter(list("gender_reveal_outline", "gender_reveal_ray"))
	layer = og_layer

/**
 * Create our objectives for our heretic.
 */
/datum/antagonist/heretic/proc/forge_primary_objectives(heretic_research_tree)
	var/datum/objective/heretic_research/research_objective = new(heretic_research_tree = heretic_research_tree)
	research_objective.owner = owner
	objectives += research_objective

	var/num_heads = 0
	for(var/datum/mind/player_mind in get_crewmember_minds())
		if(QDELETED(player_mind.current) || player_mind.current.stat == DEAD)
			continue
		if(player_mind.assigned_role?.job_flags & JOB_HEAD_OF_STAFF)
			num_heads++

	var/datum/objective/minor_sacrifice/sac_objective = new()
	sac_objective.owner = owner
	if(num_heads < 2) // They won't get major sacrifice, so bump up minor sacrifice a bit
		sac_objective.target_amount = 6
		sac_objective.update_explanation_text()
	objectives += sac_objective

	if(num_heads >= 2)
		var/datum/objective/major_sacrifice/other_sac_objective = new()
		other_sac_objective.owner = owner
		objectives += other_sac_objective

/**
 * Add [target] as a sacrifice target for the heretic.
 */
/datum/antagonist/heretic/proc/add_sacrifice_target(target)
	. = FALSE
	var/datum/mind/target_mind = get_mind(target, include_last = TRUE)
	if(!target_mind)
		return FALSE
	if(target_mind in current_sac_targets)
		return TRUE
	var/mob/living/carbon/target_body = target_mind.current
	if(!istype(target_body))
		return FALSE
	LAZYOR(all_sac_targets, target_mind)
	LAZYADD(current_sac_targets, target_mind)
	RegisterSignal(target_mind, COMSIG_MIND_CRYOED, PROC_REF(on_sacrifice_target_cryoed))
	return TRUE

/**
 * Removes [target] from the heretic's sacrifice list.
 * Returns FALSE if no one was removed, TRUE otherwise
 */
/datum/antagonist/heretic/proc/remove_sacrifice_target(target, remove_from_all = FALSE)
	. = FALSE
	var/datum/mind/target_mind = get_mind(target, include_last = TRUE)
	if(!target_mind || !(target_mind in current_sac_targets))
		return
	LAZYREMOVE(current_sac_targets, target_mind)
	if(remove_from_all)
		LAZYREMOVE(all_sac_targets, target_mind)
	UnregisterSignal(target_mind, COMSIG_MIND_CRYOED)
	return TRUE

/**
 * Check to see if the given mob can be sacrificed.
 */
/datum/antagonist/heretic/proc/can_sacrifice(target)
	. = FALSE
	var/datum/mind/target_mind = get_mind(target, include_last = TRUE)
	if(!target_mind)
		return FALSE
	if(target_mind in current_sac_targets)
		return TRUE
	if(target_mind in completed_sacrifices)
		return FALSE
	if(target_mind.has_antag_datum(/datum/antagonist/cult))
		return TRUE
	// You can ALWAYS sacrifice heads of staff if you need to do so.
	if(can_sacrifice_any_head() && (target_mind.assigned_role?.job_flags & JOB_HEAD_OF_STAFF))
		return TRUE

/**
 * Check to see if we will allow any head of staff to be sacrificed.
 */
/datum/antagonist/heretic/proc/can_sacrifice_any_head()
	var/datum/objective/major_sacrifice/major_sacc_objective = locate() in objectives
	if(!major_sacc_objective)
		return FALSE
	if(major_sacc_objective.check_completion())
		return FALSE
	return TRUE

/**
 * Returns a list of the bodies of all current sacrifice targets.
 */
/datum/antagonist/heretic/proc/current_sacrifice_targets() as /list
	. = list()
	for(var/datum/mind/target_mind as anything in current_sac_targets)
		var/mob/living/living_target = target_mind.current
		if(!QDELETED(living_target))
			. += living_target

/**
 * Returns a list of minds of valid sacrifice targets from the current living players.
 */
/datum/antagonist/heretic/proc/possible_sacrifice_targets(include_current_targets = TRUE) as /list
	. = list()
	var/list/allied_minds = get_all_team_members(owner)
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(possible_target == owner || (possible_target in allied_minds))
			continue
		var/mob/living/body = possible_target.current
		if(QDELETED(body) || body.stat >= SOFT_CRIT)
			continue
		if(IS_WEAKREF_OF(owner.current, possible_target.enslaved_to)) // would be too easy
			continue
		if(!body.client || body.client?.is_afk())
			continue
		/* if(possible_target.get_effective_opt_in_level() < OPT_IN_YES_KILL)
			continue */
		if(!(possible_target.assigned_role?.job_flags & JOB_CREW_MEMBER))
			continue
		if(possible_target.assigned_role?.job_flags & JOB_CANNOT_BE_TARGET)
			continue
		if(!include_current_targets && (possible_target in current_sac_targets))
			continue
		if(possible_target in completed_sacrifices)
			continue
		var/turf/player_loc = get_turf(body)
		if(isnull(player_loc) || !is_station_level(player_loc.z))
			continue
		. += possible_target

/datum/antagonist/heretic/proc/on_sacrifice_target_cryoed(datum/mind/source, mob/living/cryoing_body)
	SIGNAL_HANDLER
	if(!(source in current_sac_targets))
		UnregisterSignal(source, COMSIG_MIND_CRYOED)
		CRASH("Somehow had COMSIG_MIND_CRYOED for a mind that wasn't a sacrifice target")
	var/datum/heretic_knowledge/hunt_and_sacrifice/sac_knowledge = get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	sac_knowledge.reroll_cryoed_target(source, src)

/**
 * Increments knowledge by one.
 * Used in callbacks for passive gain over time.
 */
/datum/antagonist/heretic/proc/passive_influence_gain()
	adjust_knowledge_points(1)
	if(owner?.current?.stat <= SOFT_CRIT)
		to_chat(owner.current, "[span_hear("You hear a whisper...")] [span_hypnophrase(pick_list(HERETIC_INFLUENCE_FILE, "drain_message"))]")
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer)

/datum/antagonist/heretic/proc/adjust_knowledge_points(amount, update = TRUE)
	knowledge_points = max(0, knowledge_points + amount) // Don't allow negative knowledge points
	knowledge_gained += max(0, amount)
	if(knowledge_gained > points_to_aura && !unlimited_blades)
		disable_blade_breaking()
	if(update)
		update_heretic_aura()
		SStgui.update_uis(src)

/datum/antagonist/heretic/proc/adjust_sidepath_points(amount, update = TRUE)
	sidepath_points = max(0, sidepath_points + amount) // Don't allow negative sidepath points
	if(update)
		SStgui.update_uis(src)

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/succeeded = TRUE

	parts += printplayer(owner)
	if(heretic_path)
		parts += "They followed the <b><font color='[GLOB.heretic_path_to_color[heretic_path.route]]'>[heretic_path.route]</font></b>"
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"
	parts += "The heretic's sacrifice targets were: [roundend_sac_list()]."
	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(!objective.check_completion())
				succeeded = FALSE
			parts += "<b>Objective #[count]</b>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
			count++
	if(feast_of_owls)
		parts += span_greentext("Ascension Forsaken")
	if(ascended)
		parts += span_greentext(span_big("THE HERETIC ASCENDED!"))

	else
		if(succeeded)
			parts += span_greentext("The heretic was successful, but did not ascend!")
		else
			parts += span_redtext("The heretic has failed.")

	parts += "<b>Knowledge Researched:</b> "

	var/list/string_of_knowledge = list()

	for(var/knowledge_path in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_path]
		var/datum/heretic_knowledge/knowledge = knowledge_info[HKT_INSTANCE]
		string_of_knowledge += knowledge.name

	parts += english_list(string_of_knowledge)

	var/list/minions
	for(var/datum/mind/minion_mind as anything in monsters_summoned)
		// sanity check to skip i.e ghouls that got deconverted
		var/datum/antagonist/heretic_monster/minion_datum = minion_mind?.has_antag_datum(/datum/antagonist/heretic_monster)
		if(minion_datum?.master == owner)
			LAZYADD(minions, minion_mind)

	if(LAZYLEN(minions))
		parts += "<b>Their minions were:</b>"
		parts += printplayerlist(minions)

	return parts.Join("<br>")

/**
 * Returns a list of minds that were sacrifice targets or sacrificed, for the roundend report.
 */
/datum/antagonist/heretic/proc/roundend_sac_list()
	. = @"[ ERROR, PLEASE REPORT TO GITHUB! ]"
	var/list/names = list()
	for(var/datum/mind/target_mind as anything in all_sac_targets)
		names += (target_mind in completed_sacrifices) ? "<b>[target_mind.name]</b>" : "[target_mind.name]"
	return english_list(names, nothing_text = "No one")

/datum/antagonist/heretic/get_admin_commands()
	. = ..()

	switch(has_living_heart())
		if(HERETIC_NO_LIVING_HEART)
			.["Give Living Heart"] = CALLBACK(src, PROC_REF(give_living_heart))
		if(HERETIC_HAS_LIVING_HEART)
			.["Add Heart Target (Marked Mob)"] = CALLBACK(src, PROC_REF(add_marked_as_target))
			.["Remove Heart Target"] = CALLBACK(src, PROC_REF(remove_target))

	.["Adjust Knowledge Points"] = CALLBACK(src, PROC_REF(admin_change_points))
	.["Adjust Sidepath Points"] = CALLBACK(src, PROC_REF(admin_change_sidepath_points))
	.["Give Focus"] = CALLBACK(src, PROC_REF(admin_give_focus))
	if(heretic_path && heretic_path.route != PATH_START)
		.["Give Blade"] = CALLBACK(src, PROC_REF(give_blade))
		.["Give Robes"] = CALLBACK(src, PROC_REF(give_robes))
	if(passive_level < 3)
		.["Upgrade Passive Level (to [passive_level + 1])"] = CALLBACK(src, PROC_REF(increase_passive_level))

/**
 * Admin proc for giving a heretic their path's blade easily.
 */
/datum/antagonist/heretic/proc/give_blade(mob/admin)
	var/datum/heretic_knowledge/limited_amount/starting/base_knowledge = get_knowledge(heretic_path.start) // they should always have base knowledge if they have a path...
	var/blade_path = base_knowledge.result_atoms[1]
	owner.current.put_in_hands(new blade_path(owner.current.drop_location()))
	to_chat(admin, span_notice("Granted [ADMIN_LOOKUPFLW(owner.current)] their path's armor."), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)

/**
 * Admin proc for giving a heretic their path's robes easily.
 */
/datum/antagonist/heretic/proc/give_robes(mob/admin)
	var/datum/heretic_knowledge/armor/armor_knowledge = new heretic_path.robes // just in case they don't have the robes researched yet
	var/robes_path = armor_knowledge.result_atoms[1]
	qdel(armor_knowledge)
	owner.current.equip_to_slot_if_possible(new robes_path(owner.current.drop_location()), ITEM_SLOT_OCLOTHING)
	to_chat(admin, span_notice("Granted [ADMIN_LOOKUPFLW(owner.current)] their path's robes."), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)

/**
 * Admin proc for upgrading a heretic's passive level easily.
 */
/datum/antagonist/heretic/proc/increase_passive_level(mob/admin)
	if(passive_level == 1)
		SEND_SIGNAL(src, COMSIG_HERETIC_PASSIVE_UPGRADE_FIRST)
		to_chat(admin, span_notice("Upgraded the passive level of [ADMIN_LOOKUPFLW(owner.current)] to 2"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
	else
		SEND_SIGNAL(src, COMSIG_HERETIC_PASSIVE_UPGRADE_FINAL)
		to_chat(admin, span_notice("Upgraded the passive level of [ADMIN_LOOKUPFLW(owner.current)] to 3"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)

/**
 * Admin proc for giving a heretic a Living Heart easily.
 */
/datum/antagonist/heretic/proc/give_living_heart(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
	if(!heart_knowledge)
		to_chat(admin, span_warning("The heretic doesn't have a living heart knowledge for some reason. What?"))
		return

	heart_knowledge.on_research(owner.current, src)

/**
 * Admin proc for adding a marked mob to a heretic's sac list.
 */
/datum/antagonist/heretic/proc/add_marked_as_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/mob/living/carbon/human/new_target = admin.client?.holder.marked_datum
	if(!istype(new_target))
		to_chat(admin, span_warning("You need to mark a human to do this!"))
		return

	if(tgui_alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", list("Yes", "No")) == "Yes")
		to_chat(owner.current, span_danger("The Mansus has modified your targets. Go find them!"))
		to_chat(owner.current, span_danger("[new_target.real_name], the [new_target.mind?.assigned_role?.title || "human"]."))

	add_sacrifice_target(new_target)

/**
 * Admin proc for removing a mob from a heretic's sac list.
 */
/datum/antagonist/heretic/proc/remove_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/list/removable = list()
	for(var/datum/mind/old_target as anything in current_sac_targets)
		removable[old_target.name] = old_target

	var/name_of_removed = tgui_input_list(admin, "Choose a human to remove", "Who to Spare", removable)
	if(QDELETED(src) || !admin.client?.holder || isnull(name_of_removed))
		return
	var/datum/mind/chosen_target = removable[name_of_removed]
	if(!chosen_target)
		return

	if(!remove_sacrifice_target(chosen_target))
		to_chat(admin, span_warning("Failed to remove [name_of_removed] from [owner]'s sacrifice list. Perhaps they're no longer in the list anyways."))
		return

	if(tgui_alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", list("Yes", "No")) == "Yes")
		to_chat(owner.current, span_danger("The Mansus has modified your targets."))

/**
 * Admin proc for easily adding / removing knowledge points.
 */
/datum/antagonist/heretic/proc/admin_change_points(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/change_num = tgui_input_number(admin, "Add or remove knowledge points", "Points", 0, 100, -100)
	if(!change_num || QDELETED(src))
		return

	adjust_knowledge_points(change_num)

/**
 * Admin proc for easily adding / removing sidepath points.
 */
/datum/antagonist/heretic/proc/admin_change_sidepath_points(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return
	var/change_num = tgui_input_number(admin, "Add or remove sidepath points", "Points", 0, 100, -100)
	if(!change_num || QDELETED(src))
		return
	adjust_sidepath_points(change_num)

/**
 * Admin proc for giving a heretic a focus.
 */
/datum/antagonist/heretic/proc/admin_give_focus(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return

	var/mob/living/pawn = owner.current
	pawn.equip_to_slot_if_possible(new /obj/item/clothing/neck/heretic_focus(get_turf(pawn)), ITEM_SLOT_NECK, TRUE, TRUE)
	to_chat(pawn, span_hypnophrase("The Mansus has manifested you a focus."))

/datum/antagonist/heretic/antag_panel_data()
	var/list/string_of_knowledge = list()

	for(var/knowledge_path in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
		if(istype(knowledge, /datum/heretic_knowledge/ultimate))
			string_of_knowledge += span_bold(knowledge.name)
		else
			string_of_knowledge += knowledge.name

	return "<br><b>Research Done:</b><br>[english_list(string_of_knowledge, and_text = ", and ")]<br>"

/datum/antagonist/heretic/antag_panel_objectives()
	. = ..()

	. += "<br>"
	. += "<i><b>Current Targets:</b></i><br>"
	if(LAZYLEN(current_sac_targets))
		for(var/datum/mind/target as anything in current_sac_targets)
			. += " - <b>[target.name]</b>, the [target.assigned_role?.title || "human"].<br>"

	else
		. += "<i>None!</i><br>"
	. += "<br>"

/datum/antagonist/heretic/proc/purchase_knowledge(datum/heretic_knowledge/knowledge_type, category = HERETIC_KNOWLEDGE_TREE, update = TRUE)
	var/list/shop_list = heretic_shops[category]
	if(!shop_list)
		stack_trace("Heretic attempted to learn knowledge from a non-existent category! (Got: [category])")
		return FALSE

	var/list/knowledge_data = shop_list[knowledge_type]
	if(!knowledge_data)
		stack_trace("[type] purchase_knowledge was given a path that doesn't exist in the heretic [category] knowledge list! (Got: [knowledge_type])")
		return FALSE

	var/cost = knowledge_data[HKT_COST]
	if(!can_buy_knowledge(knowledge_type, category, cost))
		return FALSE
	if(!gain_knowledge(knowledge_type, category, FALSE))
		return FALSE
	if(category == HERETIC_KNOWLEDGE_SHOP && sidepath_points >= cost)
		adjust_sidepath_points(-cost, update)
	else
		adjust_knowledge_points(-cost, update)
	return TRUE
/**
 * Learns the passed [typepath] of knowledge, creating a knowledge datum
 * and adding it to our researched knowledge list.
 *
 * Returns TRUE if the knowledge was added successfully. FALSE otherwise.
 */
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type, category = HERETIC_KNOWLEDGE_TREE, update = TRUE)
	var/list/knowledge_list = heretic_shops[category]
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE
	var/list/knowledge_data = knowledge_list[knowledge_type]
	if(!islist(knowledge_data))
		knowledge_data = make_knowledge_entry(knowledge_type, category)
		heretic_shops[category][knowledge_type] = knowledge_data
	if(get_knowledge(knowledge_type))
		return FALSE
	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	if(!initialized_knowledge.pre_research(owner.current, src))
		return FALSE
	researched_knowledge[knowledge_type] = knowledge_data.Copy()
	researched_knowledge[knowledge_type][HKT_INSTANCE] = initialized_knowledge
	researched_knowledge[knowledge_type][HKT_CATEGORY] = category

	// case for letting you modify depth post-purchase
	var/purchased_depth = knowledge_data[HKT_PURCHASED_DEPTH]
	if(purchased_depth != 0 && isnum(purchased_depth))
		researched_knowledge[knowledge_type][HKT_DEPTH] = purchased_depth

	knowledge_list -= knowledge_type

	initialized_knowledge.on_research(owner.current, src)
	if(update)
		SStgui.update_uis(src)

	return TRUE

/**
 * Get a list of all knowledge IDs that we can currently research.
 */
/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_type in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_type]
		researchable_knowledge |= knowledge_info[HKT_NEXT]
		banned_knowledge |= knowledge_info[HKT_BAN]
		banned_knowledge |= knowledge_type
	if(feast_of_owls)
		var/list/shop = heretic_shops[HERETIC_KNOWLEDGE_SHOP]
		for(var/knowledge_path in shop)
			var/list/shop_info = shop[knowledge_path]
			researchable_knowledge |= shop_info[HKT_ID]
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/**
 * Check if the wanted type-path is in the list of research knowledge.
 */
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	var/list/knowledge_data = researched_knowledge[wanted]
	if(knowledge_data)
		return knowledge_data[HKT_INSTANCE]
	return null

/// Makes our heretic more able to rust things.
/// if side_path_only is set to TRUE, this function does nothing for rust heretics.
/datum/antagonist/heretic/proc/increase_rust_strength(side_path_only=FALSE)
	if(side_path_only && get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_rust))
		return

	rust_strength++

/**
 * Get a list of all rituals this heretic can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an list of knowledge datums sorted by knowledge priority.
 */
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_path in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
		if(!knowledge.can_be_invoked(src))
			continue
		rituals += knowledge

	return sortTim(rituals, GLOBAL_PROC_REF(cmp_heretic_knowledge))

/**
 * Checks to see if our heretic can ccurrently ascend.
 *
 * Returns FALSE if not all of our objectives are complete, or TRUE otherwise.
 */
/datum/antagonist/heretic/proc/can_ascend()
	if(feast_of_owls)
		return "The owls have taken your right of ascension (denied ascension)." // We sold our ambition for immediate power :/
	if(!can_assign_self_objectives)
		return "The Mansus has spurned you (denied ascension)."
	for(var/datum/objective/must_be_done as anything in objectives)
		if(!must_be_done.check_completion())
			return "Must complete all objectives before ascending."
	/* var/config_time = CONFIG_GET(number/minimum_ascension_time) MINUTES

	var/time_passed = STATION_TIME_PASSED()
	if(config_time >= time_passed)
		return "Too early, must wait [DisplayTimeText(config_time - time_passed)] before ascending." */
	return HERETIC_CAN_ASCEND

/**
 * Helper to determine if a Heretic
 * - Has a Living Heart
 * - Has a an organ in the correct slot that isn't a living heart
 * - Is missing the organ they need in the slot to make a living heart
 *
 * Returns HERETIC_NO_HEART_ORGAN if they have no heart (organ) at all,
 * Returns HERETIC_NO_LIVING_HEART if they have a heart (organ) but it's not a living one,
 * and returns HERETIC_HAS_LIVING_HEART if they have a living heart
 */
/datum/antagonist/heretic/proc/has_living_heart()
	var/obj/item/organ/our_living_heart = owner.current?.get_organ_slot(living_heart_organ_slot)
	if(!our_living_heart)
		return HERETIC_NO_HEART_ORGAN

	if(!HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		return HERETIC_NO_LIVING_HEART

	return HERETIC_HAS_LIVING_HEART

/datum/antagonist/heretic/proc/query_for_monster_hunter(datum/source, list/prey)
	SIGNAL_HANDLER
	// if you've sacced a head of staff, or passed the point where blade breaking gets disabled, you're potential prey
	if(high_value_sacrifices > 0 || unlimited_blades)
		prey += owner

/// Give oozeling heretics their living heart back when revived.
/datum/antagonist/heretic/proc/on_oozeling_revive(datum/source, mob/living/carbon/human/new_body, obj/item/organ/internal/brain/slime/core, nugget)
	SIGNAL_HANDLER
	var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
	heart_knowledge.on_research(new_body, src)

/datum/antagonist/heretic/antag_token(datum/mind/hosts_mind, mob/spender)
	. = ..()
	// go ahead and try to load the heretic sacrifice template after we make our heretic
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, lazy_load_template), LAZY_TEMPLATE_KEY_HERETIC_SACRIFICE)

/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
/datum/objective/minor_sacrifice
	name = "minor sacrifice"

/datum/objective/minor_sacrifice/New(text)
	. = ..()
	target_amount = 5
	update_explanation_text()

/datum/objective/minor_sacrifice/update_explanation_text()
	. = ..()
	explanation_text = "Sacrifice at least [target_amount] crewmembers."

/datum/objective/minor_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (heretic_datum.total_sacrifices >= target_amount)

/// Heretic's major sacrifice objective. "Major sacrifices" are heads of staff.
/datum/objective/major_sacrifice
	name = "major sacrifice"
	target_amount = 1
	explanation_text = "Sacrifice any head of staff."

/datum/objective/major_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (heretic_datum.high_value_sacrifices >= target_amount)

/// Heretic's research objective. "Research" is heretic knowledge nodes (You start with some).
/datum/objective/heretic_research
	name = "research"
	/// The length of a main path. Calculated once in New().
	var/static/main_path_length = 0

/datum/objective/heretic_research/New(text, heretic_research_tree)
	. = ..()

	if(!main_path_length)
		// Let's find the length of a main path. We'll use rust because it's the coolest.
		// (All the main paths are (should be) the same length, so it doesn't matter.)
		var/rust_paths_found = 0
		for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
			var/list/knowledge_data = heretic_research_tree[knowledge]
			if(knowledge_data && knowledge_data[HKT_ROUTE] == PATH_RUST)
				rust_paths_found++

		main_path_length = rust_paths_found

	// Factor in the length of the main path first.
	target_amount = main_path_length
	// Add in the base research we spawn with, otherwise it'd be too easy.
	target_amount += length(GLOB.heretic_start_knowledge)
	// And add in some buffer, to require some sidepathing, especially since heretics get some free side paths.
	target_amount += rand(5, 8)
	update_explanation_text()

/datum/objective/heretic_research/update_explanation_text()
	. = ..()
	explanation_text = "Research at least [target_amount] knowledge from the Mansus. You start with [length(GLOB.heretic_start_knowledge)] researched."

/datum/objective/heretic_research/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (length(heretic_datum.researched_knowledge) >= target_amount)

/datum/objective/heretic_summon
	name = "summon monsters"
	target_amount = 2
	explanation_text = "Summon 2 monsters from the Mansus into this realm."

/datum/objective/heretic_summon/check_completion()
	if(completed)
		return TRUE
	var/datum/antagonist/heretic/heretic_datum = owner.has_antag_datum(/datum/antagonist/heretic)
	if(LAZYLEN(heretic_datum?.monsters_summoned) >= target_amount)
		return TRUE
	return FALSE

/datum/outfit/heretic
	name = "Heretic (Preview only)"

	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch/rust
	head = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	r_hand = /obj/item/melee/touch_attack/mansus_fist

/datum/outfit/heretic/equip(mob/living/carbon/human/H, visualsOnly)
	// this is complete ass but I have no clue why I can't get this shit to work normally ~lucy
	if(visualsOnly && isdummy(H))
		H.add_overlay(icon(/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust::worn_icon, /obj/item/clothing/suit/hooded/cultrobes/eldritch/rust::icon_state + "_t", frame = 1))
		H.add_overlay(icon(/obj/item/melee/touch_attack/mansus_fist::righthand_file, /obj/item/melee/touch_attack/mansus_fist::inhand_icon_state, frame = 1))
		return TRUE
	else
		return ..()
