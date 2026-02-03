/obj/item/clothing/head
	name = BODY_ZONE_HEAD
	icon = 'icons/obj/clothing/head/default.dmi'
	worn_icon = 'icons/mob/clothing/head/default.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/hats_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/hats_righthand.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	blood_overlay_type = "helmetblood"
	/// Can hats be stacked on top?
	var/can_stack_hat = TRUE

///Special throw_impact for hats to frisbee hats at people to place them on their heads/attempt to de-hat them.
/obj/item/clothing/head/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	. = ..()
	///if the thrown object's target zone isn't the head
	if(thrownthing.target_zone != BODY_ZONE_HEAD)
		return
	///ignore any hats with the tinfoil counter-measure enabled
	if(clothing_flags & ANTI_TINFOIL_MANEUVER)
		return
	///if the hat happens to be capable of holding contents and has something in it. mostly to prevent super cheesy stuff like stuffing a mini-bomb in a hat and throwing it
	if(LAZYLEN(contents))
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/H = hit_atom
		if(istype(H.head, /obj/item))
			var/obj/item/WH = H.head
			///check if the item has NODROP
			if(HAS_TRAIT(WH, TRAIT_NODROP))
				H.visible_message(span_warning("[src] bounces off [H]'s [WH.name]!"), span_warning("[src] bounces off your [WH.name], falling to the floor."))
				return
			///check if the item is an actual clothing head item, since some non-clothing items can be worn
			if(istype(WH, /obj/item/clothing/head))
				var/obj/item/clothing/head/WHH = WH
				///SNUG_FIT hats are immune to being knocked off
				if(WHH.clothing_flags & SNUG_FIT)
					H.visible_message(span_warning("[src] bounces off [H]'s [WHH.name]!"), span_warning("[src] bounces off your [WHH.name], falling to the floor."))
					return
			///if the hat manages to knock something off
			if(H.dropItemToGround(WH))
				H.visible_message(span_warning("[src] knocks [WH] off [H]'s head!"), span_warning("[WH] is suddenly knocked off your head by [src]!"))
		if(H.equip_to_slot_if_possible(src, ITEM_SLOT_HEAD, 0, 1, 1))
			H.visible_message(span_notice("[src] lands neatly on [H]'s head!"), span_notice("[src] lands perfectly onto your head!"))
			H.update_held_items() //force update hands to prevent ghost sprites appearing when throw mode is on
		return
	if(iscyborg(hit_atom))
		var/mob/living/silicon/robot/R = hit_atom
		var/obj/item/worn_hat = R.hat
		if(worn_hat && HAS_TRAIT(worn_hat, TRAIT_NODROP))
			R.visible_message(span_warning("[src] bounces off [worn_hat], without an effect!"), span_warning("[src] bounces off your mighty [worn_hat.name], falling to the floor in defeat."))
			return
		if(is_type_in_typecache(src, GLOB.blacklisted_borg_hats))//hats in the borg's blacklist bounce off
			R.visible_message(span_warning("[src] bounces off [R]!"), span_warning("[src] bounces off you, falling to the floor."))
			return
		else
			R.visible_message(span_notice("[src] lands neatly on top of [R]!"), span_notice("[src] lands perfectly on top of you."))
			R.place_on_head(src) //hats aren't designed to snugly fit borg heads or w/e so they'll always manage to knock eachother off




/obj/item/clothing/head/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damagedhelmet")

	if(!(flags_inv & HIDEHAIR))
		if(ismob(loc) && ishuman(loc))
			var/mob/living/carbon/human/user = loc
			var/obj/item/bodypart/head/head = user.get_bodypart(BODY_ZONE_HEAD)
			if(head.head_flags & HEAD_HAIR)
				var/datum/sprite_accessory/hair/hair_style = GLOB.hairstyles_list[user.hairstyle]
				if(hair_style?.vertical_offset)
					standing.pixel_y = hair_style.vertical_offset

	if(contents)
		var/current_hat = 1
		for(var/obj/item/clothing/head/selected_hat in contents)
			var/head_icon = 'icons/mob/clothing/head/beanie.dmi'
			if(selected_hat.worn_icon)
				head_icon = selected_hat.icon
			var/mutable_appearance/hat_adding = selected_hat.build_worn_icon(HEAD_LAYER, head_icon, FALSE, FALSE)
			hat_adding.pixel_y = ((current_hat * 2) - 1)
			hat_adding.pixel_x = (rand(-1, 1))
			current_hat++
			. += hat_adding

/obj/item/clothing/head/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_head()

////////////////////
/// Hat Stacking ///
////////////////////
#define HAT_CAP 20 //Maximum number of hats stacked upon the base hat.
#define ADD_HAT 0
#define REMOVE_HAT 1

/obj/item/clothing/head/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!can_stack_hat)
		return ..()
	if(istype(attacking_item, /obj/item/clothing/head) && !istype(attacking_item, /obj/item/clothing/head/mob_holder) && !istype(src, /obj/item/clothing/head/mob_holder)) //No putting Ian on a hat or vice-reversa
		if(contents) 					//Checking for previous hats and preventing towers that are too large
			if(attacking_item.contents)
				if(attacking_item.contents.len + contents.len + 1 > HAT_CAP)
					to_chat(user, span_warning("You think that this hat tower is perfect the way it is and decide against adding another."))
					return
				for(var/obj/item/clothing/head/hat_movement in attacking_item.contents)
					hat_movement.name = initial(name)
					hat_movement.desc = initial(desc)
					hat_movement.forceMove(src)
			var/hat_count = contents.len
			if(hat_count + 1 > HAT_CAP)
				to_chat(user, span_warning("You think that this hat tower is perfect the way it is and decide against adding another."))
				return
		var/obj/item/clothing/head/new_hat = attacking_item
		if(user.transferItemToLoc(new_hat,src)) //Moving the new hat to the base hat's contents
			to_chat(user, span_notice("You place the [new_hat] upon the [src]."))
			update_hats(ADD_HAT, user)
	else
		. = ..()

/obj/item/clothing/head/attack_self(mob/user, modifiers)
	if(length(contents) > 0)
		for (var/obj/item/clothing/head/hat in contents)
			hat.forceMove(get_turf(user))
			hat.restore_initial()

		to_chat(user, span_warning("You take apart the pile of hats."))
		update_hats(NONE, user)


/obj/item/clothing/head/verb/detach_stacked_hat()
	set name = "Remove Stacked Hat"
	set category = "Object"
	set src in usr

	if(!isliving(usr) || !can_use(usr) || !length(contents))
		return
	update_hats(REMOVE_HAT, usr)

/obj/item/clothing/head/proc/restore_initial() //Why can't initial() be called directly by something?
	name = initial(name)
	desc = initial(desc)

/obj/item/clothing/head/proc/throw_hats(hat_count, turf/wearer_location, mob/user)
	for(var/obj/item/clothing/head/throwing_hat in contents)
		var/destination = get_edge_target_turf(wearer_location, pick(GLOB.alldirs))
		if(!hat_count) //Only throw X number of hats
			break
		throwing_hat.forceMove(wearer_location)
		throwing_hat.throw_at(destination, rand(1, 4), 10)
		throwing_hat.restore_initial()
		hat_count--
	update_hats(NONE, user)
	if(user)
		user.visible_message(span_warning("[user]'s hats go flying off!"))

/obj/item/clothing/head/proc/update_hats(hat_removal, mob/living/user)
	if(hat_removal)
		var/obj/item/clothing/head/hat_to_remove = contents[length(contents)] //Get the last item in the hat and hand it to the user.
		hat_to_remove.restore_initial()
		remove_verb(user, /obj/item/clothing/head/verb/detach_stacked_hat)
		user.put_in_hands(hat_to_remove)

	cut_overlays()

	switch(length(contents)) //Section for naming/description
		if(0)
			restore_initial()
			remove_verb(user, /obj/item/clothing/head/verb/detach_stacked_hat)
		if (1,2)
			name = "Pile of Hats"
			desc = "A meagre pile of hats"
		if (3)
			name = "Stack of Hats"
			desc = "A decent stack of hats"
		if(5,6)
			name = "Towering Pillar of Hats"
			desc = "A magnificent display of pride and wealth"
		if(7,8)
			name = "A Dangerous Amount of Hats"
			desc = "A truly grand tower of hats"
		if(9,10)
			name = "A Lesser Hatularity"
			desc = "A tower approaching unstable levels of hats"
		if(11,12,13,14,15)
			name = "A Hatularity"
			desc = "A tower that has grown far too powerful"
		if(16,17,18,19)
			name = "A Greater Hatularity"
			desc = "A monument to the madness of man"
		if(20)
			name = "The True Hat Tower"
			desc = "<span class='narsiesmall'>AFTER NINE YEARS IN DEVELOPMENT, HOPEFULLY IT WILL HAVE BEEN WORTH THE WAIT</span>"

	if(length(contents) > 0)
		desc += "<BR>You can use it in hand to separate all the hats."

		//This section prepares the in-hand and on-ground icon states for the hats.
		var/current_hat = 1
		for(var/obj/item/clothing/head/selected_hat in contents)
			selected_hat.cut_overlays()
			selected_hat.forceMove(src)
			selected_hat.name = initial(name)
			selected_hat.desc = initial(desc)
			var/mutable_appearance/hat_adding = mutable_appearance(selected_hat.icon, "[initial(selected_hat.icon_state)]")
			hat_adding.pixel_y = ((current_hat * 6) - 1)
			hat_adding.pixel_x = (rand(-1, 1))
			current_hat++
			add_overlay(hat_adding)

		add_verb(user, /obj/item/clothing/head/verb/detach_stacked_hat) //Verb for removing hats.

	worn_overlays() //This is where the actual worn icon is generated
	user.update_worn_head() //Regenerate the wearer's head appearance so that they have real-time hat updates.

#undef HAT_CAP
#undef ADD_HAT
#undef REMOVE_HAT
