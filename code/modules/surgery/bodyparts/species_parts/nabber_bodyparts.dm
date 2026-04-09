//TODO: ARM OFFSETS
#define NABBER_PUNCH_LOW 3 // Base punch damage.
#define NABBER_PUNCH_HIGH 5
#define BODYPART_ICON_NABBER 'modular_iris/monke_ports/gas/icons/bodyparts/nabber_parts_greyscale.dmi'
#define NABBER_BRUTE_MODIFIER 0.90 //10% total incoming brute damage reduction atop of armor. Reduces toolboxes from 12 damage to ~10 (9.8) but does not significantly affect AP using weapons
#define NABBER_BURN_MODIFIER 1.3 // 0.65x incoming brute, 1.3x burn. 1.8x was way too high and allowed you to be crit in 3 hits from a regular welder.

//Nabbers limbs.
/obj/item/bodypart/head/mutant/nabber
	icon_greyscale = 'icons/mob/species/nabber/nabber_parts_greyscale.dmi'
	limb_id = SPECIES_NABBER
	brute_modifier = NABBER_BRUTE_MODIFIER
	burn_modifier = NABBER_BURN_MODIFIER
	bodytype =  BODYTYPE_ORGANIC | BODYTYPE_CUSTOM

/obj/item/bodypart/head/mutant/nabber/Initialize(mapload)
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_y = list("north" = 9, "south" = 7, "east" = 9, "west" = 9),
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_y = list("north" = 8, "south" = 9, "east" = 8.5, "west" = 8.5),
		offset_x = list("north" = 0, "south" = -0.15, "east" = 2.7, "west" = -2.7),
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_y = list("north" = 7, "south" = 7, "east" = 7, "west" = 7),
	)
	return ..()

/obj/item/bodypart/head/mutant/nabber/Destroy()
	. = ..()
	QDEL_NULL(worn_ears_offset) //ABSOLUTELY ensure we are qdelling here, if not, rely on backups.
	QDEL_NULL(worn_head_offset)
	QDEL_NULL(worn_mask_offset)

/obj/item/bodypart/chest/mutant/nabber
	icon_greyscale = 'icons/mob/species/nabber/nabber_parts_greyscale.dmi'
	biological_state = BIO_STANDARD_UNJOINTED
	limb_id = SPECIES_NABBER
	brute_modifier = NABBER_BRUTE_MODIFIER
	burn_modifier = NABBER_BURN_MODIFIER
	bodytype =  BODYTYPE_ORGANIC | BODYTYPE_CUSTOM

/obj/item/bodypart/chest/mutant/nabber/Initialize(mapload)
	worn_back_offset = new(
		attached_part = src,
		feature_key = OFFSET_BACK,
		offset_y = list("north" = 5, "south" = 5, "east" = 5, "west" = 5),
	)
	worn_accessory_offset = new(
		attached_part = src,
		feature_key = OFFSET_ACCESSORY,
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	) //temporary
	worn_suit_storage_offset = new(
		attached_part = src,
		feature_key = OFFSET_S_STORE,
		offset_x = list("north" = 0, "south" = 0, "east" = 3, "west" = -3),
		offset_y = list("north" = 5, "south" = 5, "east" = 5, "west" = 5),
	)
	return ..()

/obj/item/bodypart/chest/mutant/nabber/Destroy()
	. = ..()
	QDEL_NULL(worn_back_offset) // ditto
	QDEL_NULL(worn_accessory_offset)
	QDEL_NULL(worn_suit_storage_offset)

/obj/item/bodypart/arm/left/mutant/nabber/Initialize(mapload)
	held_hand_offset =  new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = 2, "south" = -2, "east" = 0, "west" = -3, "northwest" = 0, "southwest" = 0, "northeast" = -6, "southeast" = -6),
		offset_y = list("north" = -1, "south" = -1, "east" = -1, "west" = -1),
	)
	return ..()

/obj/item/bodypart/arm/right/mutant/nabber/Initialize(mapload)
	held_hand_offset =  new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = -2, "south" = 2, "east" = 0, "west" = 3, "northwest" = 0, "southwest" = 0, "northeast" = 6, "southeast" = 6),
		offset_y = list("north" = -1, "south" = -1, "east" = -1, "west" = -1),
	)
	return ..()

/obj/item/bodypart/arm/left/mutant/nabber
	icon_greyscale = 'icons/mob/species/nabber/nabber_parts_greyscale.dmi'
	limb_id = SPECIES_NABBER
	unarmed_damage_low = NABBER_PUNCH_LOW
	unarmed_damage_high = NABBER_PUNCH_HIGH
	brute_modifier = NABBER_BRUTE_MODIFIER
	burn_modifier = NABBER_BURN_MODIFIER
	bodytype =  BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	biological_state = BIO_STANDARD_UNJOINTED
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/mutant/nabber
	icon_greyscale = 'icons/mob/species/nabber/nabber_parts_greyscale.dmi'
	limb_id = SPECIES_NABBER
	unarmed_damage_low = NABBER_PUNCH_LOW
	unarmed_damage_high = NABBER_PUNCH_HIGH
	brute_modifier = NABBER_BRUTE_MODIFIER
	burn_modifier = NABBER_BURN_MODIFIER
	bodytype =  BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	biological_state = BIO_STANDARD_UNJOINTED
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/leg/left/mutant/nabber
	icon_greyscale = 'icons/mob/species/nabber/nabber_parts_greyscale.dmi'
	limb_id = SPECIES_NABBER
	brute_modifier = NABBER_BRUTE_MODIFIER
	burn_modifier = NABBER_BURN_MODIFIER
	biological_state = BIO_STANDARD_UNJOINTED
	bodytype =  BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	footprint_sprite = FOOTPRINT_SPRITE_SNAKE

/obj/item/bodypart/leg/right/mutant/nabber
	icon_greyscale = 'icons/mob/species/nabber/nabber_parts_greyscale.dmi'
	limb_id = SPECIES_NABBER
	brute_modifier = NABBER_BRUTE_MODIFIER
	burn_modifier = NABBER_BURN_MODIFIER
	bodytype =  BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	biological_state = BIO_STANDARD_UNJOINTED
	footprint_sprite = FOOTPRINT_SPRITE_SNAKE

#undef NABBER_PUNCH_LOW
#undef NABBER_PUNCH_HIGH
#undef BODYPART_ICON_NABBER
#undef NABBER_BURN_MODIFIER
#undef NABBER_BRUTE_MODIFIER
