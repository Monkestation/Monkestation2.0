/datum/antagonist/monsterhunter
	name = "\improper Monster Hunter"
	roundend_category = "Monster Hunters"
	antagpanel_category = "Monster Hunter"
	job_rank = ROLE_MONSTERHUNTER
	hud_icon = 'icons/mob/huds/antag_hud.dmi'
	antag_hud_name = "hunter"
	preview_outfit = /datum/outfit/monsterhunter
	antag_moodlet = /datum/mood_event/monster_hunter
	show_to_ghosts = TRUE
	ui_name = "AntagInfoMonsterHunter"
	stinger_sound = 'sound/music/antag/monster_hunter.ogg'
	var/list/datum/action/powers = list()
	/// Have we chosen a weapon yet?
	var/weapon_claimed = FALSE
	var/give_objectives = TRUE
	///how many rabbits have we found
	var/rabbits_spotted = 0
	///the list of white rabbits
	var/list/obj/effect/bnnuy/rabbits = list()
	/// The rabbits the rifts let onto the station.
	var/list/mob/living/basic/wonderland_rabbit/wonderland_rabbits = list()
	///the red card tied to this trauma if any
	var/obj/item/rabbit_locator/locator
	///tracks the hunter and whatever they're inside, so the rabbit images follow them
	var/datum/movement_detector/rabbit_tracker
	///have we triggered the apocalypse
	var/apocalypse = FALSE
	///a list of our prey
	var/list/datum/mind/prey = list()
	/// A list of traits innately granted to monster hunters.
	var/static/list/granted_traits = list(
		TRAIT_FEARLESS, // to ensure things like fear of heresy or blood or whatever don't fuck them over
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOSOFTCRIT,
		TRAIT_RUSTIMMUNE,
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
	RegisterSignals(current_mob, list(COMSIG_USER_ITEM_INTERACTION, COMSIG_USER_ITEM_INTERACTION_SECONDARY), PROC_REF(on_item_interaction))
	rabbit_tracker = new(current_mob, CALLBACK(src, PROC_REF(update_bnnuy_visibility)))

/datum/antagonist/monsterhunter/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.remove_traits(granted_traits, HUNTER_TRAIT)
	current_mob.faction -= FACTION_RABBITS
	current_mob.update_sight()
	UnregisterSignal(current_mob, list(COMSIG_MOB_LOGIN, COMSIG_USER_ITEM_INTERACTION, COMSIG_USER_ITEM_INTERACTION_SECONDARY))
	QDEL_NULL(rabbit_tracker)

/datum/antagonist/monsterhunter/on_gain()
	owner.special_role = ROLE_MONSTERHUNTER
	//Give Hunter Objective
	if(give_objectives)
		find_monster_targets()
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, lazy_load_template), LAZY_TEMPLATE_KEY_WONDERLAND)
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
	spawn_rabbits()
	var/datum/action/cooldown/spell/track_monster/track = new
	track.Grant(owner.current)
	powers += track
	START_PROCESSING(SSprocessing, src)
	return ..()

/datum/antagonist/monsterhunter/on_removal()
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(src, COMSIG_GAIN_INSIGHT)
	owner.remove_traits(mind_traits, HUNTER_TRAIT)
	QDEL_LIST(rabbits)
	QDEL_LIST(wonderland_rabbits)
	locator?.hunter = null
	locator = null
	to_chat(owner.current, span_userdanger("(WRITER TODO) red queen - she shrinks and goes quiet (the kitten nod from the handoff)"))
	to_chat(owner.current, span_userdanger("You are no longer a Monster Hunter."))
	owner.special_role = null
	return ..()

/datum/antagonist/monsterhunter/proc/spawn_rabbits(amount = 5)
	for(var/turf/chosen_location as anything in pick_noise_station_turfs(amount - length(rabbits), 4, list(/obj/effect/bnnuy)))
		log_game("Generated monster hunter rabbit at [AREACOORD(chosen_location)]")
		testing("Generated monster hunter rabbit at [AREACOORD(chosen_location)]")
		rabbits += new /obj/effect/bnnuy(chosen_location, src)

	var/rabbit_count = length(rabbits)
	if(rabbit_count < amount)
		message_admins("WARNING: there may not be enough monster hunter rabbits (there should be [amount], but there's only [rabbit_count])")
		CRASH("WARNING: there may not be enough monster hunter rabbits (there should be [amount], but there's only [rabbit_count])")

/datum/antagonist/monsterhunter/proc/setup_bnuuy_images()
	SIGNAL_HANDLER
	for(var/obj/effect/bnnuy/bnnuy as anything in rabbits)
		if(QDELETED(bnnuy))
			continue
		bnnuy.update_far_image(owner.current)

/// rifts are invisible, so a weapon click "on" one really lands on the floor or whatever junk is sitting on that tile
/datum/antagonist/monsterhunter/proc/on_item_interaction(mob/living/user, atom/target, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(ismob(target) || !istype(tool, /obj/item/melee/trick_weapon))
		return NONE
	var/obj/effect/bnnuy/rift = locate() in get_turf(target)
	if(!(rift in rabbits) || rift == target)
		return NONE
	INVOKE_ASYNC(rift, TYPE_PROC_REF(/atom, item_interaction), user, tool, modifiers)
	return ITEM_INTERACT_SUCCESS

/datum/antagonist/monsterhunter/proc/update_bnnuy_visibility(atom/movable/tracked, atom/movable/mover, atom/old_loc, dir)
	for(var/obj/effect/bnnuy/bnnuy as anything in rabbits)
		if(QDELETED(bnnuy))
			continue
		bnnuy.update_far_image(tracked)

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
			"icon" = trick_weapon::icon_preview || trick_weapon::icon,
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
				to_chat(user, span_warning("(WRITER TODO) red queen - not here, the coronation happens on the station"))
				return
			to_chat(user, span_hearts_tantrum("(WRITER TODO) hearts - this is where she takes over. everyone's sentenced, right now"))
			apocalypse = TRUE
			user.log_message("initiated the Wonderland Apocalypse.", LOG_GAME)
			message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(user)] has initiated the Wonderland Apocalypse."))
			force_event(/datum/round_event_control/wonderlandapocalypse, "a monster hunter turning into a beast")

/datum/antagonist/monsterhunter/proc/purchase(obj/item/weapon_type, mob/living/user)
	user.log_message("claimed the [weapon_type::name] ([weapon_type]) as their Monster Hunter weapon.", LOG_GAME)
	var/obj/item/melee/trick_weapon/weapon = new weapon_type

	var/datum/action/cooldown/spell/summonitem/wonderland/recall = new
	recall.mark_item(weapon)
	recall.Grant(user)
	powers += recall

	deliver_thru_rabbit_hole(weapon, get_turf(user))

/datum/antagonist/monsterhunter/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/hunter = new
	var/icon/white_rabbit = icon('icons/mob/rabbit.dmi', "white_rabbit")
	var/icon/red_rabbit = icon('icons/mob/rabbit.dmi', "killer_rabbit")
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

	head = /obj/item/clothing/head/hats/queens_huntsman
	mask = /obj/item/clothing/mask/cursed_rabbit
	suit = /obj/item/clothing/suit/armor/queens_huntsman
	uniform = /obj/item/clothing/under/costume/queens_huntsman
	gloves = /obj/item/clothing/gloves/queens_huntsman
	shoes = /obj/item/clothing/shoes/queens_huntsman
	l_hand = /obj/item/melee/trick_weapon/beast_claw
	r_hand = /obj/item/gun/ballistic/revolver/hunter_revolver

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
	to_chat(owner.current, span_userdanger("(WRITER TODO) red queen - welcomes them as her pawn. pawns only go forward, reach the far side and u get crowned"))
	to_chat(owner.current, span_announce("(WRITER TODO) red queen - monsters are hiding in the crew, rifts are hiding in the floors. find one and u find the other. station's next after that"))
	to_chat(owner.current, span_announce("(WRITER TODO) red queen - anyone in ur way can be removed. cold about it, not bloodthirsty"))
	to_chat(owner.current, span_announce("(WRITER TODO) red queen - security won't get it, they never do. stay out of sight"))
	to_chat(owner.current, span_announce("(WRITER TODO) red queen - nicking a few things along the way is fine, a servant's owed something"))
	to_chat(owner.current, span_warning("(WRITER TODO) plain - ur the villain, not the hero. once ur prey is dead and every rift's open, u can drop wonderland on the whole station"))
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
		update_static_data_for_all_viewers()
		var/datum/mind/target = obj.target
		if(target)
			var/mob/target_body = target.current
			var/target_name = target.name || target_body?.real_name || target_body?.name
			var/list/abilities = list()
			for(var/datum/action/ability as anything in target_body?.actions)
				if(!is_type_in_typecache(ability, monster_abilities))
					continue
				abilities |= "[ability.name]"
			var/ability_list = english_list(abilities)
			var/datum/antagonist/heretic/heretic_target = target.has_antag_datum(/datum/antagonist/heretic)
			var/datum/antagonist/bloodsucker/bloodsucker_target = target.has_antag_datum(/datum/antagonist/bloodsucker)
			if(heretic_target)
				switch(heretic_target.heretic_path?.route || PATH_START)
					if(PATH_START)
						description = "(WRITER TODO) red queen - [target_name] hasn't even picked a path yet lol"
					if(PATH_ASH)
						description = "(WRITER TODO) red queen - [target_name] is the fire one"
					if(PATH_RUST)
						description = "(WRITER TODO) red queen - [target_name] rots stuff, rust and decay"
					if(PATH_FLESH)
						description = "(WRITER TODO) red queen - [target_name] does ghouls and meat, gross"
					if(PATH_VOID)
						description = "(WRITER TODO) red queen - [target_name] is cold and empty, void stuff"
					if(PATH_BLADE)
						description = "(WRITER TODO) red queen - [target_name] is the knives and duels one"
					if(PATH_COSMIC)
						description = "(WRITER TODO) red queen - [target_name] does star stuff"
					if(PATH_LOCK)
						description = "(WRITER TODO) red queen - [target_name] messes with doors and keys"
					if(PATH_MOON)
						description = "(WRITER TODO) red queen - [target_name] serves the *other* moon, the wrong one. tie it to the 'moonstruck jesters' line in moon_lore.dm"
					else
						description = "(WRITER TODO) red queen - [target_name] is a heretic, generic"
			else if(bloodsucker_target)
				var/clan_name = bloodsucker_target.my_clan?.name
				if(!clan_name)
					description = "(WRITER TODO) red queen - [target_name] hasn't picked a clan yet. list its tricks: [ability_list]"
				else
					switch(clan_name)
						if(CLAN_NONE)
							description = "(WRITER TODO) red queen - [target_name] is clanless, super plain. tricks: [ability_list]"
						if(CLAN_TREMERE)
							description = "(WRITER TODO) red queen - [target_name] does blood magic, and the chapel burns it. tricks: [ability_list]"
						if(CLAN_VENTRUE)
							description = "(WRITER TODO) red queen - [target_name] is picky about what it drinks, and it's raising a fave vassal into a bloodsucker. tricks: [ability_list]"
						if(CLAN_NOSFERATU)
							description = "(WRITER TODO) red queen - [target_name] can't pass as crew at all, lives in the vents. tricks: [ability_list]"
						if(CLAN_MALKAVIAN)
							description = "(WRITER TODO) red queen - [target_name] is completely nuts, rambling prophet type. tricks: [ability_list]"
						else
							description = "(WRITER TODO) red queen - [target_name] drinks people, generic bloodsucker. tricks: [ability_list]"
			else if(target.has_antag_datum(/datum/antagonist/changeling))
				description = "(WRITER TODO) red queen - [target_name] wears stolen faces. tricks: [ability_list]"
			else
				description = "(WRITER TODO) red queen - [target_name] isn't what it says it is. tricks: [ability_list]"

	rabbits_spotted++
	if(description)
		to_chat(owner.current, span_boldnotice("[description]"))

/datum/antagonist/monsterhunter/process(seconds_per_tick)
	var/list/watching = list()
	for(var/datum/objective/hunter/goal in objectives)
		if(goal.discovered)
			watching += goal.watch(wonderland_rabbits, seconds_per_tick)
	for(var/mob/living/basic/wonderland_rabbit/rabbit as anything in wonderland_rabbits)
		if(!(rabbit in watching))
			rabbit.stop_staring()

/datum/objective/hunter
	name = "hunt monster"
	explanation_text = "A monster target is aboard the station, identify and eliminate this threat."
	admin_grantable = FALSE
	/// Has our target been discovered?
	var/discovered = FALSE
	/// How long wonderland rabbits have had our target in view, in deciseconds. Resets while they're out of sight and not yet spotted.
	var/seen_time = 0
	/// How long no wonderland rabbit has had our target in view, in deciseconds.
	var/unseen_time = 0
	/// Whether the rabbits have caught sight of our target for long enough to tell the hunter where they are.
	var/spotted = FALSE
	/// The name of the area the hunter was last told our target was in.
	var/last_area_name

/// Times how long rabbits have had the target in view, and tells the hunter once it adds up. Returns the rabbits that can see the target right now.
/datum/objective/hunter/proc/watch(list/rabbits, seconds_per_tick)
	var/mob/living/prey = target.current
	. = list()
	if(!QDELETED(prey) && prey.stat != DEAD)
		for(var/mob/living/basic/wonderland_rabbit/rabbit as anything in rabbits)
			if(rabbit.stat == CONSCIOUS && can_see(rabbit, prey, 7))
				rabbit.set_staring(prey)
				. += rabbit
	var/mob/living/hunter = owner.current
	if(!length(.))
		unseen_time += seconds_per_tick SECONDS
		if(!spotted)
			seen_time = 0
		else if(unseen_time >= 30 SECONDS)
			spotted = FALSE
			seen_time = 0
			last_area_name = null
			to_chat(hunter, span_boldnotice("(WRITER TODO) red queen - rabbits lost track of [target.name || prey?.real_name]"))
		return
	unseen_time = 0
	seen_time += seconds_per_tick SECONDS
	if(!spotted && seen_time >= 10 SECONDS)
		spotted = TRUE
	if(!spotted)
		return
	var/area_name = get_area_name(prey)
	if(area_name == last_area_name)
		return
	last_area_name = area_name
	to_chat(hunter, span_boldnotice("(WRITER TODO) red queen - a rabbit's got eyes on [target.name || prey.real_name] in [area_name]"))

/datum/objective/hunter/Destroy()
	if(target)
		UnregisterSignal(target, list(COMSIG_HERETIC_PATH_CHOSEN, COMSIG_BLOODSUCKER_CLAN_CHOSEN))
	return ..()

/datum/objective/hunter/proc/uncover_target()
	if(discovered)
		return
	discovered = TRUE
	update_explanation_text()
	to_chat(owner.current, span_userdanger("You have identified a monster, your objective list has been updated!"))
	owner.current?.log_message("identified one of their targets, [key_name(target.current)].", LOG_GAME)
	target.current?.log_message("was identified by [key_name(owner.current)], a Monster Hunter.", LOG_GAME, log_globally = FALSE)
	RegisterSignals(target, list(COMSIG_HERETIC_PATH_CHOSEN, COMSIG_BLOODSUCKER_CLAN_CHOSEN), TYPE_PROC_REF(/datum/objective, update_explanation_text))

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
		if(!heretic.heretic_path || heretic.heretic_path.route == PATH_START)
			explanation_text = "Slay the monster known as [target_name], a heretic."
		else
			explanation_text = "Slay the monster known as [target_name], a heretic of the [heretic.heretic_path.route]."
	else if(target.has_antag_datum(/datum/antagonist/changeling))
		explanation_text = "Slay the monster known as [target_name], a changeling."
	else
		explanation_text = "Slay the monster known as [target_name]."
	SStgui.update_uis(owner.has_antag_datum(/datum/antagonist/monsterhunter))

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
	worn_icon = 'icons/mob/clothing/mask.dmi'
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
		parts += span_greentext(span_big("(WRITER TODO) narrator - the pawn made it to the far side and nobody remembers what it used to be"))

	else
		if(hunter_win)
			parts += span_greentext("(WRITER TODO) narrator - tidy hunt, but nobody got crowned")
		else
			parts += span_redtext("(WRITER TODO) narrator - the pawn got taken, which is what usually happens to pawns")

	return parts.Join("<br>")

/datum/antagonist/monsterhunter/proc/grant_drop_ability(obj/item/tool)
	var/datum/action/rabbit_hole_item/summon_tool = new(tool)
	summon_tool.Grant(owner.current)

/datum/action/rabbit_hole_item
	name = "Summon Monster Hunter Tools"
	desc = "Summon specific monster hunter tools that will aid us with our hunt."
	button_icon = 'icons/obj/devices/tracker.dmi'
	button_icon_state = "beacon"

/datum/action/rabbit_hole_item/New(obj/item/target)
	. = ..()
	button_icon = target.icon
	button_icon_state = target.icon_state
	build_all_button_icons(UPDATE_BUTTON_ICON)

/datum/action/rabbit_hole_item/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	deliver_thru_rabbit_hole(target, get_turf(owner))
	qdel(src)
	return TRUE

// you can pass a mob OR mind to this
/proc/is_monster_hunter_prey(victim)
	var/static/list/antag_datums_to_check
	if(!antag_datums_to_check)
		antag_datums_to_check = typecacheof(list(
			/datum/antagonist/bloodsucker,
			/datum/antagonist/changeling,
			/datum/antagonist/heretic,
			/datum/antagonist/heretic_monster,
			/datum/antagonist/teratoma, // as they're associated with changelings
			/datum/antagonist/vassal,
		))

	var/datum/mind/victim_mind = get_mind(victim, include_last = TRUE)
	if(!istype(victim_mind))
		return FALSE
	for(var/datum/antagonist/antag as anything in victim_mind.antag_datums)
		if(is_type_in_typecache(antag, antag_datums_to_check))
			return TRUE
	return FALSE

/proc/get_all_monster_hunter_prey(include_dead = FALSE)
	. = list()
	var/list/prey = list()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MONSTER_HUNTER_QUERY, prey)
	for(var/datum/mind/monster as anything in prey)
		var/mob/living/current = monster.current
		if(QDELETED(current) || (!include_dead && current.stat == DEAD))
			continue
		. += monster
