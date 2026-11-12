/obj/item/smithed_part/weapon_part/shield/buckler
	icon_state = "buckler"
	base_name = "unfinished buckler"
	weapon_name = "buckler"
	block_sound = 'sound/items/weapons/block_shield.ogg'
	desc = "A simple round shield."

	weapon_inhand_icon_state = "buckler"
	hilt_icon = 'icons/modules/smithing/forge_items.dmi'
	hilt_icon_state = "buckler"
	worn_icon = 'icons/modules/smithing/forge_weapon_worn.dmi'
	worn_icon_state = "buckler_back"

/obj/item/smithed_part/weapon_part/shield/buckler/finish_weapon()
	slot_flags = ITEM_SLOT_BACK
	var quality = (smithed_quality * 0.01)
	force = floor(10 * quality)
	throwforce = floor(force/1.5)

	max_integrity = floor(((material_stats.hardness + material_stats.density)) * quality)
	atom_integrity = max_integrity
	block_chance = floor(((material_stats.hardness + material_stats.density)/6) * quality)

	w_class = WEIGHT_CLASS_NORMAL

	var/datum/armor/temp = new() //Scuffed, but no idea how to better.
	set_armor(temp.generate_new_with_modifiers(list(
		ACID = clamp(floor((material_stats.density / 1.4) * (smithed_quality/100)),30,100),
		BOMB = clamp(floor(((material_stats.density + material_stats.hardness)/2.8) * (smithed_quality/100)),30,100),
		BULLET = clamp(floor(((material_stats.density + material_stats.hardness)/2.8) * (smithed_quality/100)),30,100),
		ENERGY = clamp(floor((material_stats.refractiveness / 1.4) * (smithed_quality/100)),30,100),
		FIRE = clamp(floor(((100-material_stats.thermal)/1.4) * (smithed_quality/100)),30,100),
		LASER = clamp(floor(((material_stats.refractiveness + material_stats.density)/2.8) * (smithed_quality/100)),30,100),
		MELEE = clamp(floor(((material_stats.density + material_stats.hardness)/2.8) * (smithed_quality/100)),30,100),
		WOUND = clamp(floor((material_stats.density/1.4) * (smithed_quality/100)),30,100)
	)))
	QDEL_NULL(temp) //Thanks now back to the void with you
	..()

/obj/item/smithed_part/weapon_part/shield/pavise
	icon_state = "pavise"
	base_name = "unfinished pavise"
	weapon_name = "pavise"
	block_sound = 'sound/items/weapons/block_shield.ogg'
	desc = "A tall, robust shield."

	weapon_inhand_icon_state = "pavise"
	hilt_icon = 'icons/modules/smithing/forge_items.dmi'
	hilt_icon_state = "pavise"
	worn_icon = 'icons/modules/smithing/forge_weapon_worn.dmi'
	worn_icon_state = "pavise_back"

/obj/item/smithed_part/weapon_part/shield/pavise/finish_weapon()
	slot_flags = ITEM_SLOT_BACK
	var quality = (smithed_quality * 0.01)
	force = floor(10 * quality)
	throwforce = floor(force/2)
	block_chance = floor(((material_stats.hardness + material_stats.density)/3) * quality)

	max_integrity = floor(((material_stats.hardness + material_stats.density)*1.5) * quality)
	atom_integrity = max_integrity

	w_class = WEIGHT_CLASS_BULKY

	var/datum/armor/temp = new() //Scuffed, but no idea how to better.
	set_armor(temp.generate_new_with_modifiers(list(
		ACID = clamp(floor((material_stats.density / 1.4) * (smithed_quality/100)),40,100),
		BOMB = clamp(floor(((material_stats.density + material_stats.hardness)/2.8) * (smithed_quality/100)),40,100),
		BULLET = clamp(floor(((material_stats.density + material_stats.hardness)/2.8) * (smithed_quality/100)),40,100),
		ENERGY = clamp(floor((material_stats.refractiveness / 1.4) * (smithed_quality/100)),40,100),
		FIRE = clamp(floor(((100-material_stats.thermal)/1.4) * (smithed_quality/100)),40,100),
		LASER = clamp(floor(((material_stats.refractiveness + material_stats.density)/2.8) * (smithed_quality/100)),40,100),
		MELEE = clamp(floor(((material_stats.density + material_stats.hardness)/2.8) * (smithed_quality/100)),40,100),
		WOUND = clamp(floor((material_stats.density/1.4) * (smithed_quality/100)),40,100)
	)))
	QDEL_NULL(temp) //Thanks now back to the void with you
	..()


//Common code
/obj/item/smithed_part/weapon_part/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	//More likely to block tackles, body throws, and similar attacks
	if(attack_type == LEAP_ATTACK)
		final_block_chance += 25
	. = ..()
	if(.)
		on_shield_block(owner, hitby, attack_text, damage, attack_type)

/obj/item/smithed_part/weapon_part/shield/proc/on_shield_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if (atom_integrity <= damage)
		var/turf/owner_turf = get_turf(owner)
		owner_turf.visible_message(span_warning("[hitby] destroys [src]!"))
		playsound(owner, shield_break_sound, 50)
		qdel(src)
		return FALSE
	take_damage(damage)
	return TRUE
/obj/item/smithed_part/weapon_part/shield
	var/shield_break_sound = 'sound/effects/bang.ogg'

/obj/item/smithed_part/weapon_part/shield/examine(mob/user)
	. = ..()
	var/healthpercent = floor((atom_integrity/max_integrity) * 100)
	switch(healthpercent)
		if(50 to 99)
			. += span_info("It looks slightly damaged.")
		if(25 to 50)
			. += span_info("It appears heavily damaged.")
		if(0 to 25)
			. += span_warning("It's falling apart!")
