/// Handheld thingy that sticks to one slime and shows its stats live
/obj/item/slime_rancher_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats, \
		including whether it's primed to produce an extract or split next. \
		Keeps a lock on the last slime you pointed it at."
	icon = 'icons/obj/device.dmi'
	icon_state = "slime_scanner"
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	flags_1 = CONDUCT_1
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2)
	/// The slime we're currently locked onto, so the panel keeps updating as it eats
	var/mob/living/basic/slime/slime

/obj/item/slime_rancher_scanner/Initialize(mapload)
	. = ..()
	register_context()
	register_item_context()

/obj/item/slime_rancher_scanner/Destroy(force)
	unset_slime()
	return ..()

/obj/item/slime_rancher_scanner/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item == src && !isnull(slime))
		context[SCREENTIP_CONTEXT_RMB] = "Clear scanned slime"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/slime_rancher_scanner/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(!isslime(target))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Scan slime"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/slime_rancher_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(!user.can_read(src))
		return ITEM_INTERACT_BLOCKING
	if(!isslime(interacting_with))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return ITEM_INTERACT_BLOCKING

	set_slime(user, interacting_with)
	ui_interact(user)
	return ITEM_INTERACT_SUCCESS

/// Swaps which slime we're watching
/obj/item/slime_rancher_scanner/proc/set_slime(mob/living/user, mob/living/basic/slime/new_slime)
	if(!isslime(new_slime))
		return
	if(new_slime == slime)
		balloon_alert(user, "already tracking [slime]")
		return
	unset_slime()
	slime = new_slime
	RegisterSignal(slime, COMSIG_QDELETING, PROC_REF(unset_slime))
	RegisterSignal(slime, COMSIG_SLIME_UPDATE_MOOD, PROC_REF(on_slime_mood_change))
	balloon_alert(user, "scanned [slime]")
	playsound(src, 'sound/items/healthanalyzer.ogg', 20, TRUE, -2, TRUE, FALSE)

/obj/item/slime_rancher_scanner/proc/unset_slime()
	SIGNAL_HANDLER
	if(isnull(slime))
		return
	UnregisterSignal(slime, list(COMSIG_QDELETING, COMSIG_SLIME_UPDATE_MOOD))
	slime = null
	if(!QDELETED(src))
		SStgui.update_uis(src)

/obj/item/slime_rancher_scanner/proc/on_slime_mood_change(datum/source)
	SIGNAL_HANDLER
	SStgui.update_uis(src)

/// the whole point of a ranching scanner is watching the pen from outside it, so let it reach
/obj/item/slime_rancher_scanner/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/slime_rancher_scanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimeRancherScanner", name)
		ui.open()

/obj/item/slime_rancher_scanner/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(!. && !QDELETED(slime))
		balloon_alert(user, "stopped tracking [slime]")
		unset_slime()

/obj/item/slime_rancher_scanner/ui_data(mob/user)
	if(isnull(slime))
		return list("scanned" = FALSE)

	var/sprite_icon = get_icon_dmi_path(slime)
	var/list/data = list(
		"scanned" = TRUE,
		"name" = slime.name,
		"color" = slime.slime_type.color,
		"color_hex" = slime.slime_type.rgb_code,
		"sprite_icon" = sprite_icon,
		"sprite_state" = slime.icon_state,
		// the face is a separate overlay, so the panel stacks it on top of the body itself
		"mood_state" = (!slime.stat && slime.current_mood && slime.current_mood != SLIME_MOOD_NONE) ? "aslime-[slime.current_mood]" : null,
		"transparent" = slime.slime_type.transparent,
		"life_stage" = slime.life_stage,
		"health" = round(slime.health, 1),
		"max_health" = slime.maxHealth,
		"nutrition" = floor(slime.nutrition),
		"powerlevel" = slime.powerlevel,
		"cores" = slime.cores,
		"growth" = slime.amount_grown,
		"ranch_progress" = floor(slime.ranch_progress),
		"split_cost" = slime.primed_split_cost,
		"mutation_chance" = slime.mutation_chance,
		"crossbreed_modification" = slime.crossbreed_modification,
		"crossbreed_progress" = slime.applied_crossbreed_amount,
		"mutations" = list(),
	)

	for(var/datum/slime_mutation/mutation as anything in slime.mutation_progress)
		data["mutations"] += list(mutation_data(mutation))

	return data

// ui static data so we don't have to hardcode these on the tgui side of things
/obj/item/slime_rancher_scanner/ui_static_data(mob/user)
	return list(
		"max_growth" = SLIME_EVOLUTION_THRESHOLD,
		"max_crossbreed_progress" = SLIME_EXTRACT_CROSSING_REQUIRED,
		"max_powerlevel" = SLIME_MAX_POWER,
		"max_nutrition" = SLIME_MAX_NUTRITION,
		"extract_cost" = SLIME_RANCH_EXTRACT_COST,
		"nutrition_starving" = SLIME_STARVE_NUTRITION,
		"nutrition_hungry" = SLIME_HUNGER_NUTRITION,
	)

/// How far along one mutation is, used for ui_data
/obj/item/slime_rancher_scanner/proc/mutation_data(datum/slime_mutation/mutation) as /list
	var/datum/slime_type/target = mutation.mutates_into
	var/list/entry = list(
		"color" = target::color,
		"color_hex" = target::rgb_code,
		"ready" = mutation.is_satisfied(),
		"items" = list(),
		"drains" = list(),
	)

	for(var/obj/item/wanted as anything in mutation.total_items)
		entry["items"] += list(list(
			"name" = wanted::name,
			"icon" = wanted::icon,
			"icon_state" = wanted::icon_state,
			"done" = !(wanted in mutation.needed_items),
		))

	for(var/prey_type, drain_total in mutation.latch_totals)
		var/mob/living/prey = prey_type
		entry["drains"] += list(list(
			"name" = prey::name,
			"icon" = prey::icon,
			"icon_state" = prey::icon_state,
			"total" = drain_total,
			"drained" = drain_total - (mutation.latch_needed[prey_type] || 0),
		))

	return entry

/datum/design/slime_rancher_scanner
	name = "Slime Scanner"
	desc = "A device that analyzes a slime's internal composition and ranching progress."
	id = "slime_rancher_scanner"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2)
	build_path = /obj/item/slime_rancher_scanner
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_XENOBIOLOGY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
