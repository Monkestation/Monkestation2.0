// Based on holopad rays. Causes a Shadow to move from T to C
// "sprite" var can be replaced to use another icon_state from icons/effects/96x96.dmi
/proc/shadow(atom/C, turf/T, sprite = "rune_blind")
	var/disty = C.y - T.y
	var/distx = C.x - T.x
	var/newangle
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360
	var/matrix/M1 = matrix()
	var/matrix/M2 = turn(M1.Scale(1, sqrt(distx*distx+disty*disty)), newangle)
	return anim(target = C, a_icon = 'monkestation/code/modules/bloody_cult/icons/96x96.dmi', flick_anim = sprite, offX = -32, offY = -32, plane = ABOVE_LIGHTING_PLANE, trans = M2)



//Requires either a target/location or both
//Requires a_icon holding the animation
//Requires either a_icon_state of the animation or the flick_anim
//Does not require sleeptime, specifies for how long the animation should be allowed to exist before returning to pool
//Does not require animation direction, but you can specify
//Does not require a name
/proc/anim(turf/location as turf, target as mob|obj, a_icon, a_icon_state as text, flick_anim as text, sleeptime = 15, direction as num, name as text, lay as num, offX as num, offY as num, col as text, alph as num, plane as num, trans, invis, animate_movement, blend)
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
	if(target && istype(target, /atom))
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

/mob/proc/occult_muted()
	if (reagents && reagents.has_reagent(/datum/reagent/water/holywater))
		return TRUE
	return FALSE


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
	animate(I, color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 2)//9
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.7)//8
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.4)//7
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.1)//6
	animate(color = list(1.5, 0.27, 0, 0, 0, 1.5, 0.27, 0, 0.27, 0, 1.5, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.8)//5
	animate(color = list(1.375, 0.19, 0, 0, 0, 1.375, 0.19, 0, 0.19, 0, 1.375, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.5)//4
	animate(color = list(1.25, 0.12, 0, 0, 0, 1.25, 0.12, 0, 0.12, 0, 1.25, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.2)//3
	animate(color = list(1.125, 0.06, 0, 0, 0, 1.125, 0.06, 0, 0.06, 0, 1.125, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.1)//2
	animate(color = list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 5)//1

	return I

/mob/living/carbon/proc/boxify(delete_body = TRUE, new_anim = TRUE, box_state = "cult")//now its own proc so admins may atomProcCall it if they so desire.
	var/turf/T = get_turf(src)
	for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
		if (M.client)
			M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_failure.ogg', 75, 0, -4)
	if (new_anim)
		var/obj/effect/cult_ritual/conversion/anim = new(T)
		anim.icon_state = ""
		flick("rune_convert_failure", anim)
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

/proc/get_distant_turf(turf/T, direction, distance)
	if(!T || !direction || !distance)
		return

	var/dest_x = T.x
	var/dest_y = T.y
	var/dest_z = T.z

	if(direction & NORTH)
		dest_y = min(world.maxy, dest_y+distance)
	if(direction & SOUTH)
		dest_y = max(0, dest_y-distance)
	if(direction & EAST)
		dest_x = min(world.maxy, dest_x+distance)
	if(direction & WEST)
		dest_x = max(0, dest_x-distance)

	return locate(dest_x, dest_y, dest_z)

/// Returns whether the given mob is convertable to the blood cult, monkestation edit: or clock cult
/proc/is_convertable_to_cult(mob/living/target, datum/team/cult/specific_cult, for_clock_cult) //monkestation edit: adds for_clock_cult
	if(!istype(target))
		return FALSE
	if(isnull(target.mind) || !GET_CLIENT(target))
		return FALSE
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE)) // monkestation edit: mind.unconvertable -> TRAIT_UNCONVERTABLE
		return FALSE
	if(ishuman(target) && target.mind.holy_role)
		return FALSE
	var/mob/living/master = target.mind.enslaved_to?.resolve()
	if(master && (for_clock_cult ? !IS_CLOCK(master) : !IS_CULTIST(master))) //monkestation edit: master is now checked based off of for_clock_cult
		return FALSE
	if(IS_HERETIC_OR_MONSTER(target))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD) || isbot(target)) //monkestation edit: moved isdrone() as well as issilicon() to the next check down
		return FALSE //can't convert machines, shielded, or braindead
	if((isdrone(target) || issilicon(target)) && !for_clock_cult) //monkestation edit: clock cult converts them into cogscarabs and clock borgs
		return FALSE //monkestation edit
	if(for_clock_cult ? IS_CULTIST(target) : IS_CLOCK(target)) //monkestation edit
		return FALSE //monkestation edit
	return TRUE

/proc/locate_team(type)
	return locate(type) in GLOB.antagonist_teams
