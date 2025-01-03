/datum/antagonist/vampire
	name = "\improper Vampire"
	roundend_category = "vampires"
	antagpanel_category = "Vampire"
	job_rank = ROLE_VAMPIRE
	hijack_speed = 0.5

	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	can_coexist_with_others = FALSE

	preview_outfit = /datum/outfit/vampire
	var/vampire_rank = 0
	var/starting_rank = 1
	//antag_hud_name = "vampire"
	//hud_icon = 'monkestation/icons/vampires/vampire_icons.dmi'

	ui_name = "AntagInfoVampire"

	/// Basically owner.current but as a human.
	var/mob/living/carbon/human/user

	/// Current amount of lifeforce.
	var/lifeforce = LIFEFORCE_PER_HUMAN // 1 human is worth an hour (30 min in masquerade)
	/// Lifeforce changes per second. Don't modify this directly.
	var/list/lifeforce_changes = list(LIFEFORCE_CHANGE_THIRST = LIFEFORCE_DRAIN_BASE)
	/// Cached value made from lifeforce_changes, don't change this directly.
	var/lifeforce_per_second = 0

	/// Whether or not masquerade is enabled. Masquerade hides obvious signs of being a vampire.
	var/masquerade_enabled = TRUE

	var/atom/movable/screen/vampire/lifeforce_counter/lifeforce_display
	var/atom/movable/screen/vampire/rank_counter/rank_display

	/// List of traits that are always active. Don't bloat this with 20 billion passives, reserve those for stat abilities.
	var/static/list/innate_traits = list(
		TRAIT_NOBLOOD,  // vampires are entirely bloodless and instead run on the lifeforce they *extract* from the blood of sapients
		TRAIT_STABLEHEART, // which also means they don't need a heart (stakes are... special, okay?)
		TRAIT_NOCRITDAMAGE, // helps with enthralling and also helps vampires save their thralls
		TRAIT_GENELESS // hulk + vampire = oh fuck no
	)

	/// List of traits that are removed when masquerade is enabled.
	var/static/list/visible_traits = list(
		TRAIT_COLDBLOODED,
		TRAIT_NO_MIRROR_REFLECTION,
		TRAIT_PALE_GREY_SKIN
	)

	/// List of traits that are added when masquerade is enabled.
	var/static/list/masquerade_traits = list(
		TRAIT_FAKEBLOOD,
		TRAIT_FAKEGENES
	)

	/// How many stat points the vampire has in total. Don't modify this directly.
	var/stat_points = 0

	/// How many available stat points the vampire has. Don't modify this directly.
	var/available_stat_points = 0

	/// How many stat points the vampire has spent. Don't modify this directly.
	var/spent_stat_points = 0

	/// The stats of the vampire. The cornerstone of progression alongside ranks. Don't modify this directly.
	VAR_PRIVATE/list/stats = list(
		VAMPIRE_STAT_BRUTALITY = 12, // DEBUG STATS, REMEMBER TO REVERT THESE LATER
		VAMPIRE_STAT_TENACITY = 12,
		VAMPIRE_STAT_PURSUIT = 12,
		VAMPIRE_STAT_RECOVERY = 12,
		VAMPIRE_STAT_PERCEPTION = 12,
		VAMPIRE_STAT_DISCRETION = 12
	)

	/// Associative list of abilities the vampire has unlocked.
	/// These are instances sorted by their type.
	var/list/current_abilities = list()

	/// The action that grants us night vision at will.
	var/datum/action/adjust_vision/vampire/vision_action

	/// The vampire clan datum of the vampire, if any.
	var/datum/vampire_clan/clan = null

	/// Modifier for feed rate. Value is in blood/s.
	/// The handling for this is weird as it only affects neck feeding.
	/// Wrist feeding uses the base value, neck feeding uses *double* the final value.
	var/datum/modifier/feed_rate_modifier = new(base_value = BLOOD_VOLUME_NORMAL / 30)

	/// Modifier for regen rate. Value is in health/s.
	var/datum/modifier/regen_rate_modifier = new(base_value = 1)

	/// Associative list of stat modifiers. Applied as multipliers. Don't modify this directly.
	var/list/stat_mods = list()

/datum/antagonist/vampire/on_gain()
	vampire_rank = starting_rank
	owner.current.playsound_local(get_turf(owner.current), 'monkestation/sound/vampires/vampire_alert.ogg', vol = 100, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	. = ..() // stupid hack to fix masquerade appearing before the antag panel
	set_rank(starting_rank, force_update = TRUE)

/datum/antagonist/vampire/apply_innate_effects(mob/living/mob_override)
	var/mob/living/carbon/human/target_mob = mob_override || owner.current
	if(!istype(target_mob))
		return

	user = target_mob

	update_lifeforce_changes()

	handle_clown_mutation(target_mob, "Your thirst for blood has overtaken your clownish nature, allowing you to wield weapons without harming yourself.")

	target_mob.add_traits(innate_traits, VAMPIRE_TRAIT)
	target_mob.blood_volume = BLOOD_VOLUME_NORMAL // if this somehow deviates, something is wrong as you have TRAIT_NOBLOOD and nothing should modify blood_volume if you have it

	update_masquerade() // keep this below add_traits or else hulk will break our shitcode (bodypart.variable_color)

	RegisterSignal(target_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(target_mob, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(target_mob, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_limb_attach))

	if(target_mob.hud_used)
		on_hud_created()
	else
		RegisterSignal(target_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

	check_new_unlocks() // we only do it this way once

/datum/antagonist/vampire/remove_innate_effects(mob/living/mob_override)
	var/mob/living/carbon/human/target_mob = mob_override || owner.current
	if(!istype(target_mob))
		return

	user = null

	handle_clown_mutation(target_mob, removing = FALSE)

	REMOVE_TRAITS_IN(target_mob, VAMPIRE_TRAIT)

	UnregisterSignal(target_mob, list(COMSIG_LIVING_LIFE, COMSIG_CARBON_POST_ATTACH_LIMB))

	QDEL_NULL(lifeforce_display)
	QDEL_NULL(rank_display)

	clear_abilities()

/datum/antagonist/vampire/proc/on_life(mob/living/carbon/human/user, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(user.stat != DEAD) // this is the easiest way to stop masquerade and thirst from draining lifeforce while you're dead (if something needs to use lifeforce while you're dead via lifeforce_changes, refactor this)
		adjust_lifeforce(lifeforce_per_second * seconds_per_tick)

	if(QDELETED(user)) // the above can dust us, avoid making stupid runtimes
		return

	if(!handle_starlight(seconds_per_tick))
		return // you're fine

	adjust_lifeforce(-seconds_per_tick) // you'll eventually dust without intervention

	user.adjust_fire_stacks(2 * seconds_per_tick) // the fire engulfs thee
	user.adjustFireLoss(10 * seconds_per_tick) // IT BURNS
	user.ignite_mob(silent = TRUE) // makes absolutely sure you stay lit

/// Handles starlight ignition (not damage over time) and returns whether the vampire is in starlight.
/datum/antagonist/vampire/proc/handle_starlight(seconds_per_tick)
	if(!is_in_starlight())
		REMOVE_TRAIT(user, TRAIT_NO_EXTINGUISH, VAMPIRE_TRAIT)
		return FALSE

	if(HAS_TRAIT_FROM(user, TRAIT_NO_EXTINGUISH, VAMPIRE_TRAIT))
		return TRUE

	user.visible_message(
		message = span_danger("[user]'s skin bursts into flames!"),
		self_message = span_userdanger("Your neophyte skin bursts into flames as it's bombarded by starlight!"),
		blind_message = span_hear("You hear searing flesh!")
	)

	ADD_TRAIT(user, TRAIT_NO_EXTINGUISH, VAMPIRE_TRAIT)
	set_masquerade(FALSE) // disables masquerade if it's on

	user.adjust_fire_stacks(5) // starts you off with a decent amount of fire stacks
	user.ignite_mob(silent = TRUE) // there's already a visible message, don't bother sending another

	return TRUE

/// Returns whether the vampire should be affected by starlight right now.
/datum/antagonist/vampire/proc/is_in_starlight()
	if(!isspaceturf(get_turf(user)))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_VAMPIRE_DEFIANCE)) // Vampires with Defiance are immune to starlight.
		return FALSE

	var/chest_covered = FALSE
	var/head_covered = FALSE
	for(var/obj/item/clothing/equipped in user.get_equipped_items())
		chest_covered ||= (equipped.body_parts_covered & CHEST) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE)
		head_covered ||= (equipped.body_parts_covered & HEAD) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE)

	if(head_covered && chest_covered) // good job, you get to live
		return FALSE

	return TRUE // good luck lmao

/datum/antagonist/vampire/proc/on_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	handle_starlight()

/datum/antagonist/vampire/proc/on_limb_attach(mob/living/carbon/human/user, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	if(masquerade_enabled)
		return
	limb.variable_color = "#b8b8b8" // stupid fucking hardcoded bullshit (variable body color will be refactored EVENTUALLY anyway)
	user.update_body_parts()

/datum/antagonist/vampire/ui_static_data(mob/user)
	var/list/data = list()

	data["in_clan"] = !!clan

	var/list/clan_data = list()
	if(clan)
		clan_data["clan_name"] = clan.name
		clan_data["clan_desc"] = clan.desc
		clan_data["clan_icon"] = clan.icon_state

	data["clan"] = clan_data

	for(var/datum/vampire_ability/ability as anything in current_abilities)
		data["ability"] += list(list(
			"ability_name" = ability.name,
			"ability_desc" = ability.desc,
			"ability_icon" = ability.granted_action?.button_icon_state,
		))

	return data + ..()

/datum/antagonist/vampire/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/vampire_icons))

/datum/antagonist/vampire/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("join_clan")
			if(clan)
				return
			assign_clan()
			ui.send_full_update(force = TRUE)
