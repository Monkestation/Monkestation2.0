/obj/structure/vampire/candelabrum
	name = "candelabrum"
	desc = "It burns slowly, but doesn't radiate any heat."
	icon = 'icons/vampires/vamp_obj.dmi'
	icon_state = "candelabrum"
	base_icon_state = "candelabrum"
	light_color = "#66FFFF"
	light_power = 3
	light_outer_range = 2
	light_on = FALSE
	density = FALSE
	anchored = FALSE
	ghost_desc = "This is a magical candle which drains the sanity of non-vampires and non-vassals."
	vampire_desc = "This is a magical candle which drains the sanity of mortals who are not under your command while it is active."
	vassal_desc = "This is a magical candle which drains the sanity of the fools who haven't yet accepted your master."
	curator_desc = "This is a blue Candelabrum, which causes insanity to those near it while active."
	var/lit = FALSE

/obj/structure/vampire/candelabrum/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CLICK, PROC_REF(distance_toggle))
	update_appearance()
	register_context()

/obj/structure/vampire/candelabrum/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/vampire/candelabrum/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(!HAS_MIND_TRAIT(user, TRAIT_VAMPIRE_ALIGNED) || held_item)
		return NONE
	if(!anchored)
		if(Adjacent(user))
			context[SCREENTIP_CONTEXT_LMB] = "Bolt"
			return CONTEXTUAL_SCREENTIP_SET
		return NONE

	var/is_full_vampire = IS_VAMPIRE(user)
	if(Adjacent(user) || is_full_vampire)
		context[SCREENTIP_CONTEXT_LMB] = lit ? "Extinguish" : "Light"
		. = CONTEXTUAL_SCREENTIP_SET

	if(is_full_vampire)
		context[SCREENTIP_CONTEXT_RMB] = lit ? "Extinguish All Nearby" : "Light All Nearby"
		. = CONTEXTUAL_SCREENTIP_SET


/obj/structure/vampire/candelabrum/update_icon_state()
	icon_state = "[base_icon_state][lit ? "_lit" : ""]"
	return ..()

/obj/structure/vampire/candelabrum/update_overlays()
	. = ..()
	if(lit)
		. += emissive_appearance(icon, "[base_icon_state]_emissive", src)

/obj/structure/vampire/candelabrum/update_desc(updates)
	if(lit)
		desc = initial(desc)
	else
		desc = "Despite not being lit, it makes your skin crawl."
	return ..()

/obj/structure/vampire/candelabrum/bolt()
	set_density(TRUE)
	return ..()

/obj/structure/vampire/candelabrum/unbolt()
	set_density(FALSE)
	return ..()

/obj/structure/vampire/candelabrum/set_anchored(anchorvalue)
	. = ..()
	if(!anchored)
		set_lit(FALSE)

/obj/structure/vampire/candelabrum/attack_hand(mob/living/user, list/modifiers)
	if(!..())
		return
	if(anchored && HAS_MIND_TRAIT(user, TRAIT_VAMPIRE_ALIGNED))
		set_lit(!lit)
	return ..()

/obj/structure/vampire/candelabrum/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!anchored || !IS_VAMPIRE(user))
		return

	user.balloon_alert_to_viewers("gestures dramatically")
	dramatic_toggle_all(user, !lit)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/vampire/candelabrum/proc/dramatic_toggle_all(mob/user, value)
	var/turf/our_turf = get_turf(src)
	var/list/nearby_candels = list()
	for(var/obj/structure/vampire/candelabrum/candel in view(7, src) | view(user))
		if(!candel.anchored || candel.lit == value)
			continue
		nearby_candels[candel] = get_dist(our_turf, get_turf(candel))

	if(!length(nearby_candels))
		return

	sortTim(nearby_candels, cmp = value ? GLOBAL_PROC_REF(cmp_numeric_asc) : GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)

	// maximum aurafarming
	user.visible_message(
		span_notice("[user] waves [user.p_their()] hand around, [value ? "igniting" : "extinguishing"] nearby candelabrums with a single gesture."),
		span_notice("You wave your hand around, [value ? "igniting" : "extinguishing"] nearby candelabrums with a single gesture."),
	)
	for(var/i = 1 to length(nearby_candels))
		var/obj/structure/vampire/candelabrum/candel = nearby_candels[i]
		addtimer(CALLBACK(candel, PROC_REF(set_lit), value), i * (0.2 SECONDS), TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/structure/vampire/candelabrum/proc/distance_toggle(datum/source, atom/location, control, params, mob/user)
	SIGNAL_HANDLER
	if(!anchored || user.incapacitated() || user.get_active_held_item() || !IS_VAMPIRE(user) || user.Adjacent(src))
		return
	var/list/modifiers = params2list(params)
	user.balloon_alert_to_viewers("gestures dramatically")
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		dramatic_toggle_all(user, !lit)
	else
		set_lit(!lit)
		// gotta aurafarm
		user.visible_message(
			span_notice("[user] waves [user.p_their()] hand towards \the [src], causing its cold flame to [lit ? "ignite" : "extinguish"]."),
			span_notice("You wave your hand towards \the [src], [lit ? "igniting" : "extinguishing"] it."),
		)

/obj/structure/vampire/candelabrum/proc/set_lit(value)
	if(lit == value)
		return
	lit = value
	if(lit)
		set_light_on(TRUE)
		START_PROCESSING(SSobj, src)
	else
		set_light_on(FALSE)
		STOP_PROCESSING(SSobj, src)
	update_light()
	update_appearance()

/obj/structure/vampire/candelabrum/process()
	if(!lit)
		return PROCESS_KILL
	for(var/mob/living/carbon/nearby_people in viewers(7, src))
		/// We don't want vampires or vassals affected by this
		if(HAS_MIND_TRAIT(nearby_people, TRAIT_VAMPIRE_ALIGNED) || IS_VAMPIRE_HUNTER(nearby_people))
			continue
		nearby_people.set_hallucinations_if_lower(10 SECONDS)
		nearby_people.add_mood_event("vampcandle", /datum/mood_event/vampcandle)
