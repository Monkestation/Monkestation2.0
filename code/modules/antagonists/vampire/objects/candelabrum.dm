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

/obj/structure/vampire/candelabrum/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

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

/obj/structure/vampire/candelabrum/proc/distance_toggle(datum/source, atom/location, control, params, mob/user)
	SIGNAL_HANDLER
	if(anchored && !user.incapacitated() && !user.get_active_held_item() && IS_VAMPIRE(user) && !user.Adjacent(src))
		set_lit(!lit)
		to_chat(user, span_notice("You wave your hand towards \the [src], [lit ? "igniting" : "extinguishing"] it."), type = MESSAGE_TYPE_INFO)

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
