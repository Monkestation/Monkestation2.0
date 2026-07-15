#define PKBORG_DAMPEN_CYCLE_DELAY (2 SECONDS)

/obj/item/cautery/prt //it's a subtype of cauteries so that it inherits the cautery sprites and behavior and stuff, because I'm too lazy to make sprites for this thing
	name = "plating repair tool"
	desc = "A tiny heating device that's powered by a cyborg's excess heat. Its intended purpose is to repair burnt or damaged hull platings, but it can also be used as a crude lighter or cautery."
	toolspeed = 1.5 //it's not designed to be used as a cautery (although it's close enough to one to be considered to be a proper cautery instead of just a hot object for the purposes of surgery)
	heat = 3800 //this thing is intended for metal-shaping, so it's the same temperature as a lit welder
	resistance_flags = FIRE_PROOF //if it's channeling a cyborg's excess heat, it's probably fireproof
	force = 5
	damtype = BURN
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg') //the usesounds of a lit welder
	hitsound = 'sound/items/welder.ogg' //the hitsound of a lit welder

//Peacekeeper Cyborg Projectile Dampenening Field
/obj/item/borg/projectile_dampen
	name = "\improper hyperkinetic dampening projector"
	desc = "A device that projects a dampening field that weakens kinetic energy above a certain threshold. <span class='boldnotice'>Projects a field that drains power per second while active, that will weaken and slow damaging projectiles inside its field.</span> Still being a prototype, it tends to induce a charge on ungrounded metallic surfaces."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	base_icon_state = "shield"
	/// The cyborg who is actively using us.
	var/mob/living/silicon/robot/active_cyborg = null
	/// The dampening field that we're projecting around us.
	var/datum/proximity_monitor/advanced/bubble/projectile_dampener/peaceborg/dampening_field
	/// The radius of our dampening field.
	var/field_radius = 3
	/// The energy cost per projectile damage whenever a projectile enters the dampening field.
	var/cost_per_projectile_damage = 0.15 KILO WATTS
	/// When the active cyborg's cell drops below this percentage, it will automatically turn off.
	var/cyborg_cell_critical_percentage = 0.1
	/// The activation cooldown.
	COOLDOWN_DECLARE(cycle_cooldown)

/obj/item/borg/projectile_dampen/Destroy()
	deactivate_field()
	return ..()

/obj/item/borg/projectile_dampen/update_icon_state()
	icon_state = "[base_icon_state][active_cyborg ? TRUE : FALSE]"
	return ..()

/obj/item/borg/projectile_dampen/attack_self(mob/user)
	if(!iscyborg(user))
		to_chat(user, span_notice("This device doesn't seem to work for non-cyborgs."))
		return
	if(!COOLDOWN_FINISHED(src, cycle_cooldown))
		to_chat(user, span_boldwarning("[src] is still recycling its projectors!"))
		return
	COOLDOWN_START(src, cycle_cooldown, PKBORG_DAMPEN_CYCLE_DELAY)
	if(active_cyborg)
		to_chat(user, span_boldnotice("You deactivate [src]."))
		deactivate_field(FALSE)
		return
	if(user.has_buckled_mobs())
		to_chat(user, span_warning("[src]'s safety cutoff prevents you from activating it due to living beings being ontop of you!"))
		return
	var/mob/living/silicon/robot/cyborg_user = user
	if(!cyborg_user.cell)
		to_chat(cyborg_user, span_warning("You need a cell to activate this!"))
		return
	var/charge_requirement = cyborg_user.cell.maxcharge * cyborg_cell_critical_percentage
	if(cyborg_user.cell.charge < charge_requirement)
		to_chat(cyborg_user, span_warning("You cell needs [display_energy(charge_requirement)] to activate this!"))
		return
	to_chat(cyborg_user, span_boldnotice("You activate [src]."))
	activate_field(cyborg_user)

/obj/item/borg/projectile_dampen/cyborg_unequip(mob/user)
	if(!active_cyborg)
		return
	deactivate_field(FALSE)

/// Activates the item.
/obj/item/borg/projectile_dampen/proc/activate_field(mob/living/silicon/robot/cyborg_user)
	deactivate_field()
	active_cyborg = cyborg_user
	active_cyborg.model.allow_riding = FALSE
	dampening_field = new(active_cyborg, field_radius, TRUE, src, /datum/dampener_projectile_effects/peacekeeper)
	RegisterSignal(active_cyborg, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(dampening_field, COMSIG_DAMPENER_CAPTURE, PROC_REF(on_projectile_capture))
	update_appearance()

/// Deactivates the item.
/obj/item/borg/projectile_dampen/proc/deactivate_field(silent = TRUE)
	if(!QDELETED(dampening_field))
		qdel(dampening_field)
	dampening_field = null
	if(!QDELETED(active_cyborg))
		active_cyborg.model.allow_riding = TRUE
		UnregisterSignal(active_cyborg, COMSIG_LIVING_DEATH)
	active_cyborg = null
	if(!silent)
		visible_message(span_warning("\The [src] shuts off!"))
	update_appearance()

/// Called when our active cyborg died.
/obj/item/borg/projectile_dampen/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER
	deactivate_field()

/// Called when a projectile enters our dampening field.
/obj/item/borg/projectile_dampen/proc/on_projectile_capture(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER
	if(!projectile.is_hostile_projectile())
		return
	if(!active_cyborg.cell || !active_cyborg.cell.use(projectile.damage * cost_per_projectile_damage) || (active_cyborg.cell.charge < (active_cyborg.cell.maxcharge * cyborg_cell_critical_percentage)))
		visible_message(span_warning("[src] blinks \"ENERGY DEPLETED\"."))
		deactivate_field()

#undef PKBORG_DAMPEN_CYCLE_DELAY

// Bare minimum omni-toolset for modularity.
/obj/item/borg/cyborg_omnitool
	name = "cyborg omni-toolset"
	desc = "You shouldn't see this in-game normally."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "toolkit_mediborg"
	/// Our tools (list of item typepaths).
	var/list/obj/item/omni_toolkit = list()
	/// Map of solid objects internally used by the omni-tool.
	var/list/obj/item/atoms = list()
	/// Object we are referencing to for force, sharpness and sound.
	var/obj/item/reference
	/// Is the toolset upgraded or not?
	var/upgraded = FALSE

/obj/item/borg/cyborg_omnitool/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/borg/cyborg_omnitool/Destroy(force)
	for(var/obj/item/tool_path as anything in atoms)
		var/obj/item/tool = atoms[tool_path]
		if(!QDELETED(tool)) // If we are sharing tools from our other omnitool brothers, we don't want to re-delete them if they got deleted first.
			qdel(tool)
	atoms.Cut()

	return ..()

/obj/item/borg/cyborg_omnitool/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if (!issilicon(user))
		return
	var/mob/living/silicon/robot/as_cyborg = user
	if (!(src in as_cyborg.held_items))
		context[SCREENTIP_CONTEXT_RMB] = "Select Tool"
	return CONTEXTUAL_SCREENTIP_SET

/**
 * Sets the new internal tool to be used.
 * Arguments
 *
 * * obj/item/ref - typepath for the new internal omnitool
 */
/obj/item/borg/cyborg_omnitool/proc/set_internal_tool(obj/item/tool)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!tool)
		reference = null
		tool_behaviour = initial(tool_behaviour)
		return
	for(var/obj/item/internal_tool as anything in omni_toolkit)
		if(internal_tool == tool)
			reference = internal_tool
			tool_behaviour = initial(internal_tool.tool_behaviour)
			break

/obj/item/borg/cyborg_omnitool/get_all_tool_behaviours()
	. = list()
	for(var/obj/item/tool as anything in omni_toolkit)
		. += initial(tool.tool_behaviour)

/// The omnitool interacts with real world objects based on the state it has assumed.
/obj/item/borg/cyborg_omnitool/get_proxy_attacker_for(atom/target, mob/user)
	if(!reference)
		return src

	// First check if we have the tool.
	var/obj/item/tool = atoms[reference]
	if(!QDELETED(tool))
		return tool

	// Else try to borrow an in-built tool from our other omnitool brothers to save & share memory & such.
	var/mob/living/silicon/robot/borg = user
	for(var/obj/item/borg/cyborg_omnitool/omni_tool in borg.model.basic_modules)
		if(omni_tool == src)
			continue
		tool = omni_tool.atoms[reference]
		if(!QDELETED(tool))
			atoms[reference] = tool
			return tool

	// If all else fails, just make a new one from scratch.
	tool = new reference(user)
	// The internal tool is considered part of the tool itself, so don't let it be dropped.
	tool.item_flags |= ABSTRACT
	ADD_TRAIT(tool, TRAIT_NODROP, INNATE_TRAIT)
	atoms[reference] = tool
	tool.toolspeed = upgraded ? initial(tool.toolspeed) * 0.5 : initial(tool.toolspeed)
	return tool

/obj/item/borg/cyborg_omnitool/attack_self(mob/user)
	// Build the radial menu options.
	var/list/radial_menu_options = list()
	var/list/tool_map = list()
	for(var/obj/item as anything in omni_toolkit)
		var/tool_name = initial(item.name)
		radial_menu_options[tool_name] = image(icon = initial(item.icon), icon_state = initial(item.icon_state))
		tool_map[tool_name] = item

	// Assign the new tool behaviour.
	var/internal_tool_name = show_radial_menu(user, src, radial_menu_options, require_near = TRUE, tooltips = TRUE)
	if(!internal_tool_name)
		return

	// Set the reference & update icons.
	set_internal_tool(tool_map[internal_tool_name])
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'sound/items/tools/change_jaws.ogg', 50, TRUE)

/obj/item/borg/cyborg_omnitool/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return
	var/obj/item/active_tool = get_proxy_attacker_for(src, user)
	if(active_tool == src)
		return
	active_tool.attack_self_secondary(user, modifiers)

/obj/item/borg/cyborg_omnitool/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK) || !iscyborg(usr))
		return ..()
	var/mob/living/silicon/robot/user = usr
	if (!(src in user.held_items))
		attack_self(user)
	return ..()

/obj/item/borg/cyborg_omnitool/update_icon_state()
	if (reference)
		icon_state = reference.icon_state
	return ..()

/**
 * Sets the upgrade status of the omnitool.
 * Arguments
 *
 * * upgrade - TRUE/FALSE for upgraded
 */
/obj/item/borg/cyborg_omnitool/proc/set_upgraded(upgrade)
	if(upgraded == upgrade)
		return
	upgraded = upgrade
	for(var/tool_reference in atoms)
		var/obj/item/tool = atoms[tool_reference]
		if(QDELETED(tool))
			continue
		tool.toolspeed = upgraded ? initial(tool.toolspeed) * 0.5 : initial(tool.toolspeed)
	playsound(src, 'sound/items/tools/change_jaws.ogg', 50, TRUE)

/// Replaces an existing tool with a new tool.
/obj/item/borg/cyborg_omnitool/proc/replace_tool(replaced_tool_typepath, replacement_tool_typepath)
	if(!(replaced_tool_typepath in omni_toolkit))
		return
	var/tool_currently_used = FALSE
	if(reference == replaced_tool_typepath)
		tool_currently_used = TRUE
		set_internal_tool(null)
	var/obj/item/tool_previously_used = atoms[replaced_tool_typepath]
	if(!QDELETED(tool_previously_used))
		qdel(tool_previously_used)
	atoms -= replaced_tool_typepath
	omni_toolkit -= replaced_tool_typepath
	omni_toolkit += replacement_tool_typepath
	if(tool_currently_used)
		set_internal_tool(replacement_tool_typepath)
		update_appearance(UPDATE_ICON_STATE)

/obj/item/borg/cyborg_omnitool/medical
	name = "surgical omni-toolset"
	desc = "A set of surgical tools used by cyborgs to operate on various surgical operations."
	omni_toolkit = list(
		/obj/item/surgical_drapes/cyborg,
		/obj/item/scalpel/cyborg,
		/obj/item/surgicaldrill/cyborg,
		/obj/item/hemostat/cyborg,
		/obj/item/retractor/cyborg,
		/obj/item/cautery/cyborg,
		/obj/item/circular_saw/cyborg,
		/obj/item/bonesetter/cyborg,
	)

/obj/item/borg/cyborg_omnitool/medical/upgraded
	upgraded = TRUE

// Toolset for engineering cyborgs. This is all of the tools except for the welding tool since it's quite hard to implement (read: can't be arsed to).
/obj/item/borg/cyborg_omnitool/engineering
	name = "engineering omni-toolset"
	desc = "A set of engineering tools used by cyborgs to conduct various engineering tasks."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "toolkit_engiborg"
	omni_toolkit = list(
		/obj/item/wrench/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/multitool/cyborg,
	)

/obj/item/borg/cyborg_omnitool/engineering/examine(mob/user)
	. = ..()
	if(tool_behaviour != TOOL_MULTITOOL)
		return
	for(var/obj/item/multitool/tool in atoms)
		. += "Its multitool buffer contains [tool.buffer]"
		break

/obj/item/borg/cyborg_omnitool/engineering/syndie
	omni_toolkit = list(
		/obj/item/wrench/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/screwdriver/cyborg/nuke,
		/obj/item/crowbar/cyborg,
		/obj/item/multitool/cyborg,
	)

/obj/item/borg/handheld_jaunter
	name = "experimental jaunter"
	desc = "An experimental module that briefly creates a wormhole for accurate jaunting that has shown no side effects for inorganic matter."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "cyborg_jaunter"
	/// How many charges do we have right now?
	var/current_charges = 2
	/// How many charges can we store at a time?
	var/maximum_charges = 2
	/// The cooldown that tracks when to restore a charge.
	COOLDOWN_DECLARE(recharge_cooldown)

/obj/item/borg/handheld_jaunter/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/borg/handheld_jaunter/examine(mob/user)
	. = ..()
	. += span_notice("It has <b>[current_charges]</b> out of [maximum_charges] charges left.")

/obj/item/borg/handheld_jaunter/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, recharge_cooldown))
		return
	adjust_charge(1)
	COOLDOWN_START(src, recharge_cooldown, 4 SECONDS)

/obj/item/borg/handheld_jaunter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return try_teleport_to(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_FAILURE

/obj/item/borg/handheld_jaunter/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return try_teleport_to(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_FAILURE

/// Opens a portal and tries to teleport from one place to another.
/obj/item/borg/handheld_jaunter/proc/try_teleport_to(atom/target, mob/living/user)
	if(!current_charges)
		user.balloon_alert(user, "no charges!")
		return FALSE

	if(!user.client || !(target in view(user.client.view, user)))
		user.balloon_alert(user, "out of view!")
		return FALSE

	if(target.density)
		return FALSE

	adjust_charge(-1)
	COOLDOWN_START(src, recharge_cooldown, clamp(COOLDOWN_TIMELEFT(src, recharge_cooldown), 2 SECONDS, 4 SECONDS)) // Active use shall potentially delay it.

	var/turf/current_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	var/obj/effect/portal/inorganic/tunnel = new(current_turf, 1.5 SECONDS, null, FALSE, target_turf)
	if(tunnel.teleport(user))
		playsound(user, 'sound/magic/blink.ogg', 25, TRUE)
		current_turf.Beam(target_turf, "light_beam", time = 0.5 SECONDS)
	return TRUE

/obj/item/borg/handheld_jaunter/proc/adjust_charge(amount)
	if(!amount)
		return
	current_charges = clamp(current_charges + amount, 0, maximum_charges)
	if(maximum_charges > current_charges)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	if(loc)
		playsound(loc, 'sound/magic/charge.ogg', 50, TRUE)
		if(ismob(loc))
			balloon_alert(loc, "[current_charges]/[maximum_charges] charges!")

/obj/effect/portal/inorganic
	name = "wormhole"
	desc = "It looks highly unstable; It could close at any moment."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	mech_sized = TRUE
	light_on = FALSE
	wibbles = FALSE

/obj/effect/portal/inorganic/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if(!.)
		return
	if(issilicon(M) || !isliving(M))
		return
	var/mob/living/living_mob = M
	if(living_mob.mob_biotypes & MOB_ORGANIC)
		living_mob.adjust_confusion(8 SECONDS)
		living_mob.adjust_dizzy(8 SECONDS)
		shake_camera(living_mob, 2 SECONDS, 1)
		ADD_TRAIT(living_mob, TRAIT_POOR_AIM, type)
		addtimer(TRAIT_CALLBACK_REMOVE(living_mob, TRAIT_POOR_AIM, type), 8 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/borg/artifact_sticker_holder
	name = "analysis form holder"
	desc = "An built-in holder that automatically generates artifact analysis forms to write on and label artifacts with!"
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "analysisbin1"
	base_icon_state = "analysisbin"
	/// The sticker that we are holding.
	var/obj/item/sticker/analysis_form/sticker_to_apply

/obj/item/borg/artifact_sticker_holder/Initialize(mapload)
	. = ..()
	sticker_to_apply = new(src)

/obj/item/borg/artifact_sticker_holder/Destroy(force)
	QDEL_NULL(sticker_to_apply)
	return ..()

/obj/item/borg/artifact_sticker_holder/attackby(obj/item/item, mob/user, params)
	sticker_to_apply.attackby(item, user, params)

/obj/item/borg/artifact_sticker_holder/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ITEM_INTERACT_BLOCKING
	var/datum/component/artifact/artifact_component = interacting_with.GetComponent(/datum/component/artifact)
	if(!artifact_component)
		user.balloon_alert(user, "not an artifact!")
		return
	var/item_interact_result = sticker_to_apply.interact_with_atom(interacting_with, user, modifiers)
	if(item_interact_result & ITEM_INTERACT_SUCCESS)
		// Need to create a new sticker since the last one was used up.
		sticker_to_apply = new(src)
		return ITEM_INTERACT_SUCCESS
