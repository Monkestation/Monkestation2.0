/obj/item/chainsaw/energy_chainsaw
	name = "energy chainsaw"
	desc = "Become Leatherspace."
	icon = 'hippiestation/icons/obj/weapons.dmi'
	icon_state = "echainsaw_off"
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	force_on = 30
	hitsound = SFX_SWING_HIT
	toolspeed = 3 //it wouldnt be sharp if its off
	light_system = OVERLAY_LIGHT
	light_outer_range = 4
	light_power = 2
	light_on = FALSE
	light_color = COLOR_SOFT_RED
	//for use in emitting light see energy.dm
	var/list/possible_sword_colors = list(
		"red" = COLOR_SOFT_RED,
		"blue" = LIGHT_COLOR_LIGHT_CYAN,
		"green" = LIGHT_COLOR_GREEN,
		"purple" = LIGHT_COLOR_LAVENDER,
	)
	var/hacked = FALSE
	var/hacked_color

/obj/item/chainsaw/energy_chainsaw/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/chainsaw/energy_chainsaw/attack_self(mob/user)
	on = !on
	set_light_on(on)
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr." : "the chain stops glowing."]")
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(force)
	icon_state = "echainsaw_[on ? "on" : "off"]"
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = on
	if(on)
		if(hacked)
			icon_state = "echainsaw_rgb"
			START_PROCESSING(SSobj, src)
		hitsound = 'hippiestation/sound/weapons/echainsaw.ogg'
		chainsaw_loop.start()
	else
		hitsound = SFX_SWING_HIT
		chainsaw_loop.stop()
		STOP_PROCESSING(SSobj, src)
	toolspeed = on ? 0.2 : initial(toolspeed)
	if(src == user.get_active_held_item())
		user.update_held_items()
	update_item_action_buttons()

/obj/item/chainsaw/energy_chainsaw/multitool_act(mob/living/user, obj/item/tool)
	if(hacked)
		to_chat(user, span_warning("It's already fabulous!"))
		return
	hacked = TRUE
	if(on)
		icon_state = "echainsaw_rgb"
		START_PROCESSING(SSobj, src)
	to_chat(user, span_warning("RNBW_ENGAGE"))
	update_appearance(UPDATE_ICON_STATE)

/obj/item/chainsaw/energy_chainsaw/process()
	if(!on || !hacked)
		return
	if(!LAZYLEN(possible_sword_colors))
		possible_sword_colors = list(
			"red" = COLOR_SOFT_RED,
			"blue" = LIGHT_COLOR_LIGHT_CYAN,
			"green" = LIGHT_COLOR_GREEN,
			"purple" = LIGHT_COLOR_LAVENDER,
		)
		possible_sword_colors -= hacked_color

	hacked_color = pick(possible_sword_colors)
	set_light_color(possible_sword_colors[hacked_color])
	possible_sword_colors -= hacked_color

/obj/item/chainsaw/energy_chainsaw/mounted
	name = "mounted energy chainsaw"
	desc = "Byond Leatherspace"
	inhand_icon_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	toolspeed = 2
	hacked = FALSE
	light_color = COLOR_SOFT_RED

/obj/item/chainsaw/energy_chainsaw/mounted/multitool_act(mob/living/user, obj/item/tool)
	//swagger for twohanded only
	to_chat(user,span_warning("hacking something attatched to your body seems dangerous"))
	return

/obj/item/chainsaw/energy_chainsaw/mounted/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/chainsaw/energy_chainsaw/mounted/Destroy()
	var/obj/item/bodypart/part
	new /obj/item/chainsaw/energy_chainsaw(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/obj/item/chainsaw/energy_chainsaw/mounted/apply_components()
	AddComponent(/datum/component/butchering, \
		speed = 3 SECONDS, \
		effectiveness = 100, \
		bonus_modifier = 0, \
		butcher_sound = 'hippiestation/sound/weapons/echainsaw.ogg', \
		disabled = TRUE, \
		)
