//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

//Haha get it? they're both moons. titan and ganymede.
/datum/species/ganymede
	name = "Ganymedian"
	id = "ganymede"
	fixed_mut_color = "#655a6b"
	inherent_traits = list(TRAIT_NO_TRANSFORMATION_STING, TRAIT_NO_DNA_COPY, TRAIT_NO_UNDERWEAR, TRAIT_MUTANT_COLORS, TRAIT_NOBREATH, TRAIT_NOHUNGER, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT, TRAIT_NOLIMBDISABLE, TRAIT_NODISMEMBER, TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE, TRAIT_STABLEHEART, TRAIT_VIRUSIMMUNE, TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_NOGUNS, TRAIT_PIERCEIMMUNE,
		TRAIT_SHOCKIMMUNE, TRAIT_RADIMMUNE)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	changesource_flags = MIRROR_BADMIN
	mutanteyes = /obj/item/organ/internal/eyes/night_vision/ganymede
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ganymede,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)
	sexes = FALSE

/obj/item/bodypart/head/ganymede
	head_flags = HEAD_HAIR | HEAD_EYEHOLES | HEAD_DEBRAIN | HEAD_EYECOLOR

/obj/item/clothing/head/ganymedian
	name = "Ganymedian Helmet"
	desc = "A robust-looking helmet from Ganymede."
	icon = 'monkestation/icons/mob/large-worn-icons/64x64/head.dmi'
	worn_icon = 'monkestation/icons/mob/large-worn-icons/64x64/head.dmi'
	icon_state = "ganymede"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor_type = /datum/armor/ganymedian_armor

/datum/armor/ganymedian_armor
	melee = 50
	bullet = 65
	laser = 65
	energy = 45
	bomb = 100
	bio = 30
	fire = 70
	acid = 30

/obj/item/clothing/head/ganymedian/equipped(mob/user, slot)
	if(slot == ITEM_SLOT_HEAD)
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
		item_flags |= DROPDEL
	return ..()

/obj/item/clothing/suit/ganymedian
	name = "Ganymedian Armor"
	desc = "Robust-looking armor from Ganymede."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/suit.dmi'
	icon_state = "ganymede"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	armor_type = /datum/armor/ganymedian_armor

/obj/item/clothing/suit/ganymedian/equipped(mob/user, slot)
	if(slot == ITEM_SLOT_SUITSTORE)
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
		item_flags |= DROPDEL
	return ..()

/obj/item/tank/jetpack/ganypack
	name = "Ganypack"
	desc = "An alien-made jetpack, capable of infinite spaceflight."
	worn_icon = 'monkestation/icons/mob/clothing/back.dmi'
	icon = 'monkestation/icons/obj/infinity.dmi'
	icon_state = "ganypack"
	worn_icon_state = "flightpack"
	gas_type = null
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)

/obj/item/tank/jetpack/ganypack/turn_off(mob/user)
	. = ..()
	slowdown = 0

/obj/item/tank/jetpack/ganypack/turn_on(mob/user)
	. = ..()
	slowdown = 1

/obj/item/tank/jetpack/ganypack/allow_thrust(num, mob/living/user)
	return TRUE

/obj/item/tank/jetpack/ganypack/ex_act(severity, target)
	return

/obj/item/tank/jetpack/ganypack/equipped(mob/user, slot)
	if(slot == ITEM_SLOT_BACK)
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
		item_flags |= DROPDEL
	return ..()

/obj/item/clothing/under/color/ganymedian
	name = "ganymedian jumpsuit"
	desc = "It's uh, not actually a jumpsuit. This is, in fact, a literal placeholder!"
	icon_state = "jumpsuit"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	has_sensor = NO_SENSORS
	can_adjust = FALSE

/obj/item/clothing/under/ganymedian/equipped(mob/user, slot)
	if(slot == ITEM_SLOT_SUITSTORE)
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
		item_flags |= DROPDEL
	return ..()

/obj/item/clothing/shoes/ganymedian
	name = "ganymedian shoes"
	desc = "It's uh, not actually shoes. This is, in fact, a literal placeholder!"
	icon_state = "sneakers"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL

/obj/item/clothing/shoes/ganymedian/equipped(mob/user, slot)
	if(slot == ITEM_SLOT_FEET)
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
		item_flags |= DROPDEL
	return ..()

/datum/component/chasm/droppable(atom/movable/AM)
	. = ..()
	if(isganymede(AM))
		return FALSE
