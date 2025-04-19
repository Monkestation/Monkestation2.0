/obj/item/weapon/blood_tesseract
	name = "blood tesseract"
	desc = "A small totem. Cultists use them as anchors from the other side of the veil to quickly swap gear."
	gender = NEUTER
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "tesseract"
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY

	var/discarded_types = list(
		/obj/item/clothing/shoes/cult,
		/obj/item/clothing/suit/hooded/cultrobes,
		/obj/item/clothing/gloves/color/black/cult,
		)

	var/list/stored_gear = list()

	var/obj/item/talisman/remaining = null

/obj/item/weapon/blood_tesseract/Destroy()
	if (loc)
		var/turf/T = get_turf(src)
		for(var/slot in stored_gear)
			var/obj/item/I = stored_gear["[slot]"]
			stored_gear -= slot
			I.forceMove(T)
		for(var/obj/A in contents)
			A.forceMove(T)
	if (remaining)
		QDEL_NULL(remaining)
	..()

/obj/item/weapon/blood_tesseract/throw_impact(atom/hit_atom)
	var/turf/T = get_turf(src)
	if(T)
		playsound(T, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "tesseract_break", plane = ABOVE_LIGHTING_PLANE)
	qdel(src)

/obj/item/weapon/blood_tesseract/examine(var/mob/user)
	..()
	if (IS_CULTIST(user))
		to_chat(user, span_info("Press it in your hands to discard currently equiped cult clothing and re-equip your stored items.") )

/obj/item/weapon/blood_tesseract/attack_self(var/mob/living/user)
	if (IS_CULTIST(user))
		//Alright so we'll discard cult gear and equip the stuff stored inside.
		anim(target = user, a_icon = 'icons/effects/64x64.dmi', flick_anim = "rune_tesseract", offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)
		user.dropItemToGround(src)
		if (remaining)
			remaining.forceMove(get_turf(user))
			user.put_in_hands(remaining)
			remaining = null

		var/obj/item/plasma_tank = null
		if(isplasmaman(user))
			plasma_tank = user.get_item_by_slot(ITEM_SLOT_SUITSTORE)

		for(var/obj/item/I in user)
			user.dropItemToGround(I)
			if (is_type_in_list(I, discarded_types))
				qdel(I)

		for(var/slot in stored_gear)
			var/obj/item/stored_slot = stored_gear["[slot]"]
			var/obj/item/user_slot = user.get_item_by_slot(text2num(slot))
			if (!user_slot)
				user.equip_to_slot_if_possible(stored_slot, text2num(slot))
			else
				if (istype(user_slot, /obj/item/storage/backpack/cultpack))
					if (istype(stored_slot, /obj/item/storage/backpack))
						//swapping backpacks
						for(var/obj/item/I in user_slot.contents)
							I.forceMove(stored_slot)
						user.dropItemToGround(user_slot)
						qdel(user_slot)
						user.equip_to_slot_if_possible(stored_slot, ITEM_SLOT_NECK)
					else
						//free backpack
						var/obj/item/storage/backpack/B = new(user)
						for(var/obj/item/I in user_slot)
							I.forceMove(B)
						user.dropItemToGround(user_slot)
						qdel(user_slot)
						user.equip_to_slot_if_possible(B, text2num(slot))
						user.put_in_hands(stored_slot)
				else
					user.dropItemToGround(user_slot)
					qdel(user_slot)
					user.equip_to_slot_if_possible(stored_slot, ITEM_SLOT_NECK)
			stored_gear.Remove(slot)
		if (plasma_tank)
			user.equip_to_slot_if_possible(plasma_tank, ITEM_SLOT_SUITSTORE)
		qdel(src)

/obj/item/weapon/blood_tesseract/narsie_act()
	return
