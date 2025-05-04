/datum/antagonist/monsterhunter
	name = "\improper Monster Hunter"
	roundend_category = "Monster Hunters"
	antagpanel_category = "Monster Hunter"
	job_rank = ROLE_MONSTERHUNTER
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	antag_hud_name = "hunter"
	preview_outfit = /datum/outfit/monsterhunter
	antag_moodlet = /datum/mood_event/monster_hunter
	show_to_ghosts = TRUE
	ui_name = "AntagInfoMonsterHunter"
	var/list/datum/action/powers = list()
	/// Have we chosen a weapon yet?
	var/weapon_claimed = FALSE
	var/give_objectives = TRUE
	///how many rabbits have we found
	var/rabbits_spotted = 0
	///the list of white rabbits
	var/list/obj/effect/bnnuy/rabbits = list()
	///the red card tied to this trauma if any
	var/obj/item/rabbit_locator/locator
	///have we triggered the apocalypse
	var/apocalypse = FALSE
	///a list of our prey
	var/list/datum/mind/prey = list()
	/// A list of traits innately granted to monster hunters.
	var/static/list/granted_traits = list(
		TRAIT_FEARLESS, // to ensure things like fear of heresy or blood or whatever don't fuck them over
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOSOFTCRIT,
	)
	/// A list of traits innately granted to the mind of monster hunters.
	var/static/list/mind_traits = list(
		TRAIT_OCCULTIST,
		TRAIT_UNCONVERTABLE,
		TRAIT_MADNESS_IMMUNE, // You merely adopted the madness. I was born in it, molded by it.
	)
	/// A typecache of ability types that will be revealed to the monster hunter when they gain insight.
	var/static/list/monster_abilities = typecacheof(list(
		/datum/action/changeling,
		/datum/action/cooldown/bloodsucker
	))

/datum/antagonist/monsterhunter/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.add_traits(granted_traits, HUNTER_TRAIT)
	current_mob.update_sight()
	current_mob.faction |= FACTION_RABBITS
	RegisterSignal(current_mob, COMSIG_MOB_LOGIN, PROC_REF(setup_bnuuy_images))
	RegisterSignal(current_mob, COMSIG_MOVABLE_MOVED, PROC_REF(update_bnnuy_visibility))

/datum/antagonist/monsterhunter/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.remove_traits(granted_traits, HUNTER_TRAIT)
	current_mob.faction -= FACTION_RABBITS
	current_mob.update_sight()
	UnregisterSignal(current_mob, list(COMSIG_MOB_LOGIN, COMSIG_MOVABLE_MOVED))

/datum/antagonist/monsterhunter/on_gain()
	owner.special_role = ROLE_MONSTERHUNTER
	//Give Hunter Objective
	if(give_objectives)
		find_monster_targets()
	INVOKE_ASYNC(src, PROC_REF(load_wonderland))
	owner.add_traits(mind_traits, HUNTER_TRAIT)
	//Teach Stake crafting
	owner.teach_crafting_recipe(/datum/crafting_recipe/hardened_stake)
	owner.teach_crafting_recipe(/datum/crafting_recipe/silver_stake)
	var/mob/living/carbon/criminal = owner.current
	var/obj/item/rabbit_locator/card = new(criminal.drop_location(), src)
	var/list/slots = list("backpack" = ITEM_SLOT_BACKPACK, "left pocket" = ITEM_SLOT_LPOCKET, "right pocket" = ITEM_SLOT_RPOCKET)
	if(!criminal.equip_in_one_of_slots(card, slots, qdel_on_fail = FALSE))
		card.moveToNullspace()
		grant_drop_ability(card)
	RegisterSignal(src, COMSIG_GAIN_INSIGHT, PROC_REF(insight_gained))
	for(var/i in 1 to 5)
		var/turf/rabbit_hole = get_safe_random_station_turf_equal_weight()
		rabbits += new /obj/effect/bnnuy(rabbit_hole, src)
	var/obj/effect/bnnuy/gun_holder = pick(rabbits)
	gun_holder.drop_gun = TRUE
	var/datum/action/cooldown/spell/track_monster/track = new
	track.Grant(owner.current)
	return ..()

/datum/antagonist/monsterhunter/on_removal()
	UnregisterSignal(src, COMSIG_GAIN_INSIGHT)
	owner.remove_traits(mind_traits, HUNTER_TRAIT)
	QDEL_LIST(rabbits)
	locator?.hunter = null
	locator = null
	to_chat(owner.current, span_userdanger("Your hunt has ended: You enter retirement once again, and are no longer a Monster Hunter."))
	owner.special_role = null
	return ..()

/datum/antagonist/monsterhunter/proc/load_wonderland()
	var/static/wonderland_loaded = FALSE
	if(wonderland_loaded)
		return

	wonderland_loaded = TRUE
	var/datum/map_template/wonderland/wonderland_template = new
	if(!wonderland_template.load_new_z())
		wonderland_loaded = FALSE
		QDEL_NULL(wonderland_template)
		message_admins("Failed to load Wonderland z-level!")
		CRASH("Failed to load Wonderland z-level!")

/datum/antagonist/monsterhunter/proc/setup_bnuuy_images()
	SIGNAL_HANDLER
	for(var/obj/effect/bnnuy/bnnuy as anything in rabbits)
		if(QDELETED(bnnuy))
			continue
		owner.current?.client?.images |= bnnuy.hunter_image

/datum/antagonist/monsterhunter/proc/update_bnnuy_visibility(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	for(var/obj/effect/bnnuy/bnnuy as anything in rabbits)
		if(QDELETED(bnnuy))
			continue
		bnnuy.update_mouse_opacity(source)

/datum/antagonist/monsterhunter/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)

/datum/antagonist/monsterhunter/ui_data(mob/user)
	var/completed = TRUE
	for(var/datum/objective/objective as anything in objectives)
		if(!objective.check_completion())
			completed = FALSE
			break
	return list(
		"weapon_claimed" = weapon_claimed,
		"rabbits_spotted" = rabbits_spotted,
		"rabbits_remaining" = length(rabbits),
		"all_completed" = completed,
		"apocalypse" = apocalypse,
		"objectives" = get_objectives(full_checks = TRUE),
	)

/datum/antagonist/monsterhunter/ui_static_data(mob/user)
	var/list/weapons = list()
	for(var/obj/item/melee/trick_weapon/trick_weapon as anything in subtypesof(/obj/item/melee/trick_weapon))
		weapons += list(list(
			"id" = trick_weapon,
			"name" = trick_weapon::name,
			"desc" = trick_weapon::ui_desc,
			"icon" = trick_weapon::icon,
			"icon_state" = trick_weapon::icon_state_preview || trick_weapon::icon_state,
		))
	return list("weapons" = weapons)

/datum/antagonist/monsterhunter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	switch(action)
		if("select")
			. = TRUE
			if(isnull(params["weapon"]) || weapon_claimed)
				return
			var/weapon_type = text2path(params["weapon"])
			if(!ispath(weapon_type, /obj/item/melee/trick_weapon))
				return
			weapon_claimed = TRUE
			purchase(weapon_type, user)
		if("reckoning")
			. = TRUE
			if(apocalypse || length(rabbits) > 0)
				return
			for(var/datum/objective/objective as anything in objectives)
				if(!objective.check_completion())
					return
			var/turf/current_turf = get_turf(user)
			if(!is_station_level(current_turf.z))
				to_chat(user, span_warning("The pull of the ice moon isn't strong enough here..."))
				return
			apocalypse = TRUE
			user.log_message("initiated the Wonderland Apocalypse.", LOG_GAME)
			message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(user)] has initiated the Wonderland Apocalypse."))
			force_event(/datum/round_event_control/wonderlandapocalypse, "a monster hunter turning into a beast")

/datum/antagonist/monsterhunter/proc/purchase(obj/item/weapon_type, mob/living/user)
	user.log_message("claimed the [weapon_type::name] ([weapon_type]) as their Monster Hunter weapon.", LOG_GAME)
	var/obj/item/melee/trick_weapon/weapon = new weapon_type

	var/datum/action/cooldown/spell/summonitem/recall = new
	recall.mark_item(weapon)
	recall.Grant(user)

	podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = weapon
	))

/datum/antagonist/monsterhunter/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/hunter = new
	var/icon/white_rabbit = icon('monkestation/icons/mob/rabbit.dmi', "white_rabbit")
	var/icon/red_rabbit = icon('monkestation/icons/mob/rabbit.dmi', "killer_rabbit")
	var/icon/hunter_icon = render_preview_outfit(/datum/outfit/monsterhunter, hunter)

	var/icon/final_icon = hunter_icon
	white_rabbit.Shift(EAST,8)
	white_rabbit.Shift(NORTH,18)
	red_rabbit.Shift(WEST,8)
	red_rabbit.Shift(NORTH,18)
	red_rabbit.Blend(rgb(165, 165, 165, 165), ICON_MULTIPLY)
	white_rabbit.Blend(rgb(165, 165, 165, 165), ICON_MULTIPLY)
	final_icon.Blend(white_rabbit, ICON_UNDERLAY)
	final_icon.Blend(red_rabbit, ICON_UNDERLAY)

	final_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	qdel(hunter)

	return finish_preview_icon(final_icon)

/datum/outfit/monsterhunter
	name = "Monster Hunter (Preview Only)"

	l_hand = /obj/item/knife/butcher
	mask = /obj/item/clothing/mask/monster_preview_mask
	uniform = /obj/item/clothing/under/suit/black
	suit =  /obj/item/clothing/suit/hooded/techpriest
	head = /obj/item/clothing/head/hooded/techpriest
	gloves = /obj/item/clothing/gloves/color/white

/// Called when using admin tools to give antag status
/datum/antagonist/monsterhunter/admin_add(datum/mind/new_owner, mob/admin)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	new_owner.add_antag_datum(src)

/// Called when removing antagonist using admin tools
/datum/antagonist/monsterhunter/admin_remove(mob/user)
	if(!user)
		return
	message_admins("[key_name_admin(user)] has removed [name] antagonist status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed [name] antagonist status from [key_name(owner)].")
	on_removal()

/datum/antagonist/monsterhunter/proc/add_objective(datum/objective/added_objective)
	objectives += added_objective

/datum/antagonist/monsterhunter/proc/remove_objectives(datum/objective/removed_objective)
	objectives -= removed_objective

/datum/antagonist/monsterhunter/greet()
	. = ..()
	to_chat(owner.current, span_userdanger("After witnessing recent events on the station, we return to your old profession, we are a Monster Hunter!"))
	to_chat(owner.current, span_announce("While we can kill anyone in our way to destroy the monsters lurking around, <b>causing property damage is unacceptable</b>."))
	to_chat(owner.current, span_announce("However, security WILL detain us if they discover our mission."))
	to_chat(owner.current, span_announce("In exchange for our services, it shouldn't matter if a few items are gone missing for our... personal collection."))
	owner.current.playsound_local(null, 'monkestation/sound/ambience/antag/monster_hunter.ogg', vol = 100, vary = FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/monsterhunter/proc/insight_gained()
	SIGNAL_HANDLER

	var/description
	var/datum/objective/hunter/obj
	var/list/unchecked_objectives
	for(var/datum/objective/hunter/goal in objectives)
		if(!goal.discovered)
			LAZYADD(unchecked_objectives, goal)
	if(unchecked_objectives)
		obj = pick(unchecked_objectives)
	if(obj)
		obj.uncover_target()
		to_chat(owner.current, span_userdanger("You have identified a monster, your objective list has been updated!"))
		update_static_data_for_all_viewers()
		var/datum/antagonist/heretic/heretic_target = IS_HERETIC(obj.target.current)
		if(heretic_target)
			description = "Your target, [heretic_target.owner.current.real_name], follows the [heretic_target.heretic_path], dear hunter."
		else
			description = "O' hunter, your target [obj.target.current.real_name] bears these lethal abilities: "
			var/list/abilities = list()
			for(var/datum/action/ability as anything in obj.target.current.actions)
				if(!is_type_in_typecache(ability, monster_abilities))
					continue
				abilities |= "[ability.name]"
			description += english_list(abilities)

	rabbits_spotted++
	to_chat(owner.current, span_boldnotice("[description]"))

/datum/objective/hunter
	name = "hunt monster"
	explanation_text = "A monster target is aboard the station, identify and eliminate this threat."
	admin_grantable = FALSE
	/// Has our target been discovered?
	var/discovered = FALSE

/datum/objective/hunter/proc/uncover_target()
	if(discovered)
		return
	discovered = TRUE
	update_explanation_text()
	to_chat(owner.current, span_userdanger("You have identified a monster, your objective list has been updated!"))
	owner.current?.log_message("identified one of their targets, [key_name(target.current)].", LOG_GAME)
	target.current?.log_message("was identified by [key_name(owner.current)], a Monster Hunter.", LOG_GAME, log_globally = FALSE)
	var/datum/antagonist/monsterhunter/hunter_datum = owner.has_antag_datum(/datum/antagonist/monsterhunter)
	hunter_datum?.update_static_data_for_all_viewers()

/datum/objective/hunter/check_completion()
	return completed || !considered_alive(target)

/datum/objective/hunter/update_explanation_text()
	if(!discovered)
		explanation_text = initial(explanation_text)
		return
	var/target_name = target.name || target.current?.real_name || target.current?.real_name
	var/datum/antagonist/bloodsucker/bloodsucker = target.has_antag_datum(/datum/antagonist/bloodsucker)
	var/datum/antagonist/heretic/heretic = target.has_antag_datum(/datum/antagonist/heretic)
	if(bloodsucker)
		explanation_text = "Slay the monster known as [target_name], a [bloodsucker.my_clan?.name || "clanless"] Bloodsucker."
	else if(heretic)
		explanation_text = "Slay the monster known as [target_name], a heretic of the [heretic.heretic_path]."
	else if(target.has_antag_datum(/datum/antagonist/changeling))
		explanation_text = "Slay the monster known as [target_name], a changeling."
	else
		explanation_text = "Slay the monster known as [target_name]."

/datum/antagonist/monsterhunter/proc/find_monster_targets()
	var/list/possible_targets = get_all_monster_hunter_prey(include_dead = FALSE)

	for(var/i in 1 to 3) //we get 3 targets
		if(!length(possible_targets))
			break
		var/datum/objective/hunter/kill_monster = new
		kill_monster.owner = owner
		var/datum/mind/target = pick_n_take(possible_targets)
		kill_monster.target = target
		prey += target
		add_objective(kill_monster)

/obj/item/clothing/mask/monster_preview_mask
	name = "Monster Preview Mask"
	worn_icon = 'monkestation/icons/mob/mask.dmi'
	worn_icon_state = "monoclerabbit"

/datum/antagonist/monsterhunter/roundend_report()
	var/list/parts = list()

	var/hunter_win = TRUE

	parts += printplayer(owner)

	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				hunter_win = FALSE
			count++

	if(apocalypse)
		parts += span_greentext(span_big("The apocalypse was unleashed upon the station!"))

	else
		if(hunter_win)
			parts += span_greentext("The hunter has eliminated all their prey!")
		else
			parts += span_redtext("The hunter has not eliminated all their prey...")

	return parts.Join("<br>")

/datum/antagonist/monsterhunter/proc/grant_drop_ability(obj/item/tool)
	var/datum/action/droppod_item/summon_tool = new(tool)
	summon_tool.Grant(owner.current)

/datum/action/droppod_item
	name = "Summon Monster Hunter Tools"
	desc = "Summon specific monster hunter tools that will aid us with our hunt."
	button_icon = 'icons/obj/device.dmi'
	button_icon_state = "beacon"

/datum/action/droppod_item/New(obj/item/target)
	. = ..()
	button_icon = target.icon
	button_icon_state = target.icon_state
	build_all_button_icons(UPDATE_BUTTON_ICON)

/datum/action/droppod_item/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	podspawn(list(
		"target" = get_turf(owner),
		"style" = STYLE_SYNDICATE,
		"spawn" = target,
	))
	qdel(src)
	return TRUE

