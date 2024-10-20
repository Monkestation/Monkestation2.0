/mob/proc/occult_muted()
	if (reagents && reagents.has_reagent(/datum/reagent/water/holywater))
		return TRUE
	return FALSE

//Requires either a target/location or both
//Requires a_icon holding the animation
//Requires either a_icon_state of the animation or the flick_anim
//Does not require sleeptime, specifies for how long the animation should be allowed to exist before returning to pool
//Does not require animation direction, but you can specify
//Does not require a name
/proc/anim(turf/location as turf,target as mob|obj,a_icon,a_icon_state as text,flick_anim as text,sleeptime = 15,direction as num, name as text, lay as num, offX as num, offY as num, col as text, alph as num,plane as num, var/trans, var/invis, var/animate_movement, var/blend)
//This proc throws up either an icon or an animation for a specified amount of time.
//The variables should be apparent enough.
	if(!location && target)
		location = get_turf(target)
		if (!location)//target in nullspace
			return
	if(location && !target)
		target = location
	if(!location && !target)
		return
	var/obj/effect/abstract/animation = new /obj/effect/abstract(location)
	if(name)
		animation.name = name
	if(direction)
		animation.dir = direction
	if(alph)
		animation.alpha = alph
	if(invis)
		animation.invisibility = invis
	if(blend)
		animation.blend_mode = blend
	animation.icon = a_icon
	animation.animate_movement = animate_movement
	animation.mouse_opacity = 0
	if(!lay)
		animation.layer = target:layer+1
	else
		animation.layer = lay
	if(target && istype(target,/atom))
		if(!plane)
			animation.plane = target:plane
		else
			animation.plane = plane
	if(offX)
		animation.pixel_x = offX
	if(offY)
		animation.pixel_y = offY
	if(col)
		animation.color = col
	if(trans)
		animation.transform = trans
	if(a_icon_state)
		animation.icon_state = a_icon_state
	else
		animation.icon_state = "blank"
		flick(flick_anim, animation)

	spawn(max(sleeptime, 5))
		qdel(animation)

	return animation

/atom/proc/get_cult_power()
	return 0

/mob/get_cult_power()
	var/static/list/valid_cultpower_slots = list(
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_BACK,
		ITEM_SLOT_FEET,
	)
	var/power = 0
	for (var/slot in valid_cultpower_slots)
		var/obj/item/I = get_item_by_slot(slot)
		if (istype(I))
			power += I.get_cult_power()

	return power


/mob/proc/get_convertibility()
	if (!mind || stat == DEAD)
		return CONVERTIBLE_NOMIND

	if (IS_CULTIST(src))
		return CONVERTIBLE_ALREADY

	return 0

/mob/living/carbon/get_convertibility()
	var/convertibility = ..()

	if (!convertibility)
		//TODO: chaplain stuff
		//this'll do in the meantime
		if (mind.assigned_role == "Chaplain")
			return CONVERTIBLE_NEVER

		if (is_banned_from(src.key, ROLE_CULTIST))
			return CONVERTIBLE_NEVER

		return CONVERTIBLE_CHOICE

	return convertibility//no mind, dead, or already a cultist

/mob/living/carbon/proc/update_convertibility()
	var/convertibility = get_convertibility()
	var/image/I =  image('monkestation/code/modules/bloody_cult/icons/hud.dmi', src, "hudblank")
	switch(convertibility)
		if (CONVERTIBLE_ALWAYS)
			I.icon_state = "convertible"
		if (CONVERTIBLE_CHOICE)
			I.icon_state = "maybeconvertible"
		if (CONVERTIBLE_IMPLANT)
			I.icon_state = "unconvertible"
		if (CONVERTIBLE_NEVER)
			I.icon_state = "unconvertible2"

	I.pixel_y = 16
	I.plane = HUD_PLANE
	I.appearance_flags |= RESET_COLOR|RESET_ALPHA

	//inspired from the rune color matrix because boy am I proud of it
	animate(I, color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 2)//9
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1.7)//8
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1.4)//7
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1.1)//6
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 0.8)//5
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 0.5)//4
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 0.2)//3
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 0.1)//2
	animate(color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 5)//1

	return I

/mob/living/carbon/proc/boxify(var/delete_body = TRUE, var/new_anim = TRUE, var/box_state = "cult")//now its own proc so admins may atomProcCall it if they so desire.
	var/turf/T = get_turf(src)
	for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
		if (M.client)
			M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_failure.ogg', 75, 0, -4)
	if (new_anim)
		var/obj/effect/cult_ritual/conversion/anim = new(T)
		anim.icon_state = ""
		flick("rune_convert_failure",anim)
		anim.Die()
	var/obj/item/storage/cult/coffer = new(T)
	coffer.icon_state = box_state
	var/obj/item/reagent_containers/cup/cult/cup = new(coffer)
	var/datum/blood_type/type = get_blood_type()
	cup.reagents.add_reagent(type.reagent_type, 50)

	for(var/obj/item/I in src)
		dropItemToGround(I)
		if(I)
			I.forceMove(T)
			I.dropped(src)
			I.forceMove(coffer)
	if (delete_body)
		qdel(src)

/proc/cheap_pythag(const/Ax, const/Ay)
	var/dx = abs(Ax)
	var/dy = abs(Ay)

	if (dx >= dy)
		return dx + (0.5 * dy) // The longest side add half the shortest side approximates the hypotenuse.
	else
		return dy + (0.5 * dx)
