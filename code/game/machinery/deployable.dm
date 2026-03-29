#define SINGLE "single"
#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define METAL 1
#define WOOD 2
#define SAND 3

//Barricades/cover

/obj/structure/barricade
	name = "chest high wall"
	desc = "Looks like this would make good cover."
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	var/proj_pass_rate = 50 //How many projectiles will pass the cover. Lower means stronger cover
	var/bar_material = METAL
	//monkestation edit: var for allowing a mover to pass through the barricade if the turf they move from has a barricade, this sounds dumb
	var/pass_same_type = TRUE

/obj/structure/barricade/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		make_debris()
	qdel(src)

/obj/structure/barricade/proc/make_debris()
	return

/obj/structure/barricade/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item.tool_behaviour == TOOL_WELDER && !(user.istate & ISTATE_HARM) && bar_material == METAL)
		if(atom_integrity < max_integrity)
			if(!attacking_item.tool_start_check(user, amount=0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(attacking_item.use_tool(src, user, 40, volume=40))
				atom_integrity = clamp(atom_integrity + 20, 0, max_integrity)
	else
		return ..()

/obj/structure/barricade/CanAllowThrough(atom/movable/mover, border_dir)//So bullets will fly over and stuff.
	. = ..()
	if((locate(/obj/structure/barricade) in get_turf(mover)) && pass_same_type)
		return TRUE
	else if(isprojectile(mover))
		if(!anchored)
			return TRUE
		var/obj/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(proj_pass_rate))
			return TRUE
		return FALSE

/////BARRICADE TYPES///////
/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	resistance_flags = FLAMMABLE
	bar_material = WOOD
	var/drop_amount = 3

/obj/structure/barricade/wooden/Initialize(mapload)
	. = ..()

	var/static/list/tool_behaviors = list(TOOL_CROWBAR = list(SCREENTIP_CONTEXT_LMB = "Deconstruct"))
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)
	register_context()

/obj/structure/barricade/wooden/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item,/obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/sheet/mineral/wood/W = attacking_item
		if(W.amount < 5)
			to_chat(user, span_warning("You need at least five wooden planks to make a wall!"))
			return
		else
			to_chat(user, span_notice("You start adding [attacking_item] to [src]..."))
			playsound(src, 'sound/items/hammering_wood.ogg', 50, vary = TRUE)
			if(do_after(user, 5 SECONDS, target=src) && W.use(5))
				var/turf/T = get_turf(src)
				T.PlaceOnTop(/turf/closed/wall/mineral/wood/nonmetal)
				qdel(src)
				return
	return ..()

/obj/structure/barricade/wooden/crowbar_act(mob/living/user, obj/item/tool)
	loc.balloon_alert(user, "deconstructing barricade...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume=50))
		return
	loc.balloon_alert(user, "barricade deconstructed")
	tool.play_tool_sound(src)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), drop_amount)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/barricade/wooden/crude
	name = "crude plank barricade"
	desc = "This space is blocked off by a crude assortment of planks."
	icon_state = "woodenbarricade-old"
	drop_amount = 1
	max_integrity = 50
	proj_pass_rate = 65
	layer = SIGN_LAYER

/obj/structure/barricade/wooden/crude/snow
	desc = "This space is blocked off by a crude assortment of planks. It seems to be covered in a layer of snow."
	icon_state = "woodenbarricade-snow-old"
	max_integrity = 75

/obj/structure/barricade/wooden/make_debris()
	new /obj/item/stack/sheet/mineral/wood(get_turf(src), drop_amount)

/obj/structure/barricade/sandbags
	name = "sandbags"
	desc = "Bags of sand. Self explanatory."
	icon = 'icons/obj/smooth_structures/sandbags.dmi'
	icon_state = "sandbags-0"
	base_icon_state = "sandbags"
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags_self = LETPASSTHROW
	bar_material = SAND
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SANDBAGS
	canSmoothWith = SMOOTH_GROUP_SANDBAGS + SMOOTH_GROUP_SECURITY_BARRICADE + SMOOTH_GROUP_WALLS

/obj/structure/barricade/sandbags/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)

/obj/structure/barricade/security
	name = "security barrier"
	desc = "A deployable barrier. Provides good cover in fire fights."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	density = FALSE
	anchored = FALSE
	max_integrity = 200 //monkestation edit 180 to 200
	proj_pass_rate = 20
	armor_type = /datum/armor/barricade_security

	light_inner_range = 0.5
	light_outer_range = 1 // luminosity when locked
	light_color = COLOR_MAROON
	light_system = OVERLAY_LIGHT

	var/deploy_time = 5 SECONDS //monkestation edit
	var/deploy_message = TRUE
	var/locked = FALSE
	/// prevents toggling the lock before the deploy time is done
	var/deploy_lock = FALSE
	var/lock_broken = FALSE
	pass_same_type = FALSE

/datum/armor/barricade_security
	melee = 10
	bullet = 60 //monkestation edit: 50 to 60
	laser = 60 //monkestation edit: 50 to 60
	energy = 60 //monkestation edit: 50 to 60
	bomb = 10
	fire = 10

/obj/structure/barricade/security/Initialize(mapload)
	. = ..()
	deploy_lock = TRUE
	addtimer(CALLBACK(src, PROC_REF(deploy)), deploy_time)
	update_appearance(UPDATE_OVERLAYS)
	register_context()

/obj/structure/barricade/security/examine(mob/user)
	. = ..()
	if(lock_broken)
		. += span_warning("Its control panel is smoking slightly.")

/obj/structure/barricade/security/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	if(ACCESS_SECURITY in user.get_access())
		context[SCREENTIP_CONTEXT_RMB] = locked ? "Unlock" : "Lock"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/barricade/security/update_overlays()
	. = ..()
	if(locked)
		. += emissive_appearance(icon, "barrier1-e", src, alpha = src.alpha)

/obj/structure/barricade/security/proc/deploy()
	toggle_lock(force = TRUE)
	set_anchored(TRUE)
	if(deploy_message)
		visible_message(span_warning("[src] deploys!"))
	deploy_lock = FALSE

/obj/structure/barricade/security/proc/toggle_lock(mob/living/user, force = FALSE)
	if(deploy_lock && !force)
		return
	if(lock_broken)
		balloon_alert(user, "controls fried!")
		return
	if(!locked)
		set_density(TRUE)
		icon_state = "barrier1"
		locked = TRUE
		playsound(src, 'sound/machines/boltsup.ogg', 45)
	else
		set_density(FALSE)
		icon_state = "barrier0"
		locked = FALSE
		playsound(src, 'sound/machines/boltsdown.ogg', 45)
	update_appearance(UPDATE_ICON)
	balloon_alert(user, "barrier [locked ? "locked" : "unlocked"]")

/obj/structure/barricade/security/attackby(obj/item/tool, mob/living/user, params)
	if(tool.GetID())
		var/obj/item/card/id/id_card = tool.GetID()
		if((ACCESS_SECURITY in id_card.GetAccess()))
			toggle_lock(user)
		else
			balloon_alert(user, "no access!")
	else
		return ..()

/obj/structure/barricade/security/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(ACCESS_SECURITY in user.get_access())
		toggle_lock(user)
	else
		balloon_alert(user, "no access!")

/obj/structure/barricade/security/wrench_act(mob/living/user, obj/item/tool, params)
	if(locked)
		balloon_alert(user, "must be unlocked first!")
		return
	if(!tool.use_tool(src, user, 2 SECONDS, volume=50))
		return
	set_anchored(!anchored)
	tool.play_tool_sound(src)
	user.balloon_alert_to_viewers("[anchored ? "anchored" : "unanchored"]")
	return ITEM_INTERACT_SUCCESS

/obj/structure/barricade/security/emp_act(severity)
	toggle_lock(force = TRUE)
	if(severity == EMP_HEAVY)
		lock_broken = TRUE
		do_sparks(rand(1,3), FALSE, src)

/obj/structure/barricade/security/emag_act(mob/user)
	if(!lock_broken)
		toggle_lock(force = TRUE)
		lock_broken = TRUE
		balloon_alert(user, "controls overloaded!")
		obj_flags |= EMAGGED
		do_sparks(rand(1,3), FALSE, src)

/obj/item/grenade/barrier
	name = "barrier grenade"
	desc = "Instant cover."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "wallbang"
	inhand_icon_state = "flashbang"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = SINGLE

/obj/item/grenade/barrier/examine(mob/user)
	. = ..()
	. += span_notice("Current Mode: [capitalize(mode)].  Alt-click to switch the current mode.")

/obj/item/grenade/barrier/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/grenade/barrier/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "wallbang-[mode]")
	. += emissive_appearance(icon, "wallbang-[mode]", src, alpha = src.alpha)


/obj/item/grenade/barrier/click_alt(mob/living/carbon/user)
	toggle_mode(user)
	return CLICK_ACTION_SUCCESS

/obj/item/grenade/barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if(SINGLE)
			mode = VERTICAL
		if(VERTICAL)
			mode = HORIZONTAL
		if(HORIZONTAL)
			mode = SINGLE
	playsound(src, 'sound/machines/click.ogg', 50)
	to_chat(user, span_notice("[src] is now in [mode] mode."))
	update_appearance(UPDATE_OVERLAYS)

/obj/item/grenade/barrier/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	new /obj/structure/barricade/security(get_turf(src.loc))
	switch(mode)
		if(VERTICAL)
			var/turf/target_turf = get_step(src, NORTH)
			if(!target_turf.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, SOUTH)
			if(!target_turf2.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf2)
		if(HORIZONTAL)
			var/turf/target_turf = get_step(src, EAST)
			if(!target_turf.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, WEST)
			if(!target_turf2.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf2)
	qdel(src)

/obj/item/grenade/barrier/ui_action_click(mob/user)
	toggle_mode(user)

/obj/item/deployable_turret_folded
	name = "folded heavy machine gun"
	desc = "A folded and unloaded heavy machine gun, ready to be deployed and used."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "folded_hmg"
	inhand_icon_state = "folded_hmg"
	max_integrity = 250
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

/obj/item/deployable_turret_folded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 5 SECONDS, /obj/machinery/deployable_turret/hmg, delete_on_use = TRUE)

#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND
