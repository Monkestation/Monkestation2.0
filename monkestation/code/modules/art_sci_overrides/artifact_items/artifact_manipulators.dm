/obj/item/artifact_summon_wand
	name = "artifact manipulation wand"
	desc = "A one-use device capable of summoning an artifact from... somewhere. Using the item will change if the artifact should be a blank artifact or a random one. Slap an artifact with it to modify it with the inserted disk."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer2"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	var/obj/item/disk/artifact/slotted_disk
	var/blank_mode = TRUE

/obj/item/artifact_summon_wand/attack_self(mob/user, modifiers)
	. = ..()
	blank_mode = !blank_mode
	var/text_mod = blank_mode ? "a blank artifact." : "an artifact with effects from a slotted disk."
	to_chat(user,span_notice("You set [src] to create [text_mod]"))

/obj/item/artifact_summon_wand/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon,/obj/item/disk/artifact))
		if(slotted_disk)
			to_chat(user,span_notice("You swap the disk inside [src]"))
			weapon.forceMove(src)
			if(!user.put_in_hand(slotted_disk))
				slotted_disk.forceMove(get_turf(user))
			slotted_disk = weapon
		else
			to_chat(user,span_notice("You slot [weapon] inside [src]"))
			weapon.forceMove(src)
			slotted_disk = weapon
/obj/item/artifact_summon_wand/attack_self_secondary(mob/user, modifiers)
	. = ..()
	summon_artifact(user)

/obj/item/artifact_summon_wand/proc/summon_artifact(mob/user)
	var/turf/attempt_location = get_turf(get_step(user,user.dir))
	if(attempt_location.density)
		return
	visible_message(span_notice("[user] begins to summon an artifact using [src]!"),span_notice("You begin attempting to summon an artifact using [src]..."))
	if(do_after(user,5 SECOND))
		var/obj/new_artifact = spawn_artifact(attempt_location)
		var/datum/component/artifact/art_comp = new_artifact.GetComponent(/datum/component/artifact)
		if(!art_comp)
			visible_message(span_notice("Something goes wrong, and [src] fizzles!"))
			return
		if(blank_mode)
			art_comp.clear_out()
		else if (slotted_disk)
			art_comp.clear_out()
			if(slotted_disk.activator)
				art_comp.add_activator(slotted_disk.activator)
			if(slotted_disk.fault)
				art_comp.change_fault(slotted_disk.fault)
			if(slotted_disk.effect)
				art_comp.try_add_effect(slotted_disk.effect)
		visible_message(span_notice("[new_artifact] appears from nowhere!"),span_notice("You summon [new_artifact], and [src] disintegrates!"))
		if(slotted_disk)
			slotted_disk.forceMove(get_turf(user))
		slotted_disk = null
		qdel(src)
	else
		visible_message(span_notice("Something goes wrong, and [src] fizzles!"))

/obj/item/artifact_summon_wand/examine(mob/user)
	. = ..()
	if(slotted_disk)
		. += span_notice("Contains [slotted_disk]")

/obj/item/artifact_summon_wand/attack_atom(atom/attacked_atom, mob/living/user, params)
	. = ..()
	var/datum/component/artifact/art_comp = attacked_atom.GetComponent(/datum/component/artifact)
	if(art_comp && slotted_disk)
		visible_message(span_notice("[user] begins trying to configure [attacked_atom] with [src]!"),span_notice("You begin trying to configure the [attacked_atom] with [src]..."))
		if(do_after(user,5 SECOND))
			var/added_anything = FALSE
			if(slotted_disk.activator)
				added_anything |= art_comp.add_activator(slotted_disk.activator)
			if(slotted_disk.fault)
				added_anything |= art_comp.change_fault(slotted_disk.fault)
			if(slotted_disk.effect)
				added_anything |= art_comp.try_add_effect(slotted_disk.effect)
			if(added_anything)
				visible_message(span_notice("[user] configures the [attacked_atom] with [src]!"),span_notice("You configure the [attacked_atom] with [src], which switftly disintegrates!"))
				if(slotted_disk)
					slotted_disk.forceMove(get_turf(user))
				slotted_disk = null
				qdel(src)
			else
				visible_message(span_notice("...but nothing changed!"))
		else
			visible_message(span_notice("Something goes wrong, and [src] fizzles!"))


