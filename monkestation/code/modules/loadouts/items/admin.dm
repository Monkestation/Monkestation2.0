/datum/loadout_item/neck/admin_cloak
	name = "Admin Cloak"
	requires_purchase = FALSE
	admin_only = TRUE
	item_path = /obj/item/clothing/neck/admincloak

/datum/loadout_item/neck/mentor_cloak
	name = "Mentor Cloak"
	requires_purchase = FALSE
	mentor_only = TRUE
	item_path = /obj/item/clothing/neck/mentorcloak

/datum/loadout_item/neck/mentor_cloak/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only, override_items)
	if(!visuals_only)
		spawn_in_backpack(outfit, item_path, equipper)

/datum/loadout_item/under/miscellaneous/adminturtleneck
	name = "CentCom Turtleneck"
	requires_purchase = FALSE
	admin_only = TRUE
	item_path = /obj/item/clothing/under/rank/centcom/officer

/datum/loadout_item/under/miscellaneous/adminturtleneckskirt
	name = "CentCom Turtleneck Skirt"
	requires_purchase = FALSE
	admin_only = TRUE
	item_path = /obj/item/clothing/under/rank/centcom/officer/skirt

// Abraxis's loadout

/datum/loadout_item/head/cent_admiral_hat  //
	name = "Centcom Admiral's Campaign hat"
	item_path = /obj/item/clothing/head/hats/warden/drill/centcom_admiral
	restricted_roles = list(JOB_NANOTRASEN_REPRESENTATIVE)
	requires_purchase = FALSE
	admin_only = TRUE

/datum/loadout_item/suit/cent_admiral_jacket  //
	name = "Centcom Admiral's Coat"
	item_path = /obj/item/clothing/suit/armor/centcom_admiral
	restricted_roles = list(JOB_NANOTRASEN_REPRESENTATIVE)
	requires_purchase = FALSE
	admin_only = TRUE

/datum/loadout_item/under/miscellaneous/cent_admiral  //
	name = "Centcom Admiral's Uniform"
	item_path = /obj/item/clothing/under/rank/centcom/admiral
	restricted_roles = list(JOB_NANOTRASEN_REPRESENTATIVE)
	requires_purchase = FALSE
	admin_only = TRUE

/datum/loadout_item/gloves/cent_admiral //
	name = "Centcom Admiral's Gloves"
	item_path = /obj/item/clothing/gloves/admiral
	requires_purchase = FALSE
	admin_only = TRUE

/datum/loadout_item/shoes/cent_admiral  //
	name = "Centcom Admiral's Shoes"
	item_path = /obj/item/clothing/shoes/admiral
	requires_purchase = FALSE
	admin_only = TRUE

// Sprungle's loadout

/datum/loadout_item/mask/sprungle_mask
	name = "Porcelain Facemask"
	requires_purchase = FALSE
	admin_only = TRUE
	item_path = /obj/item/clothing/mask/sprungle

/datum/loadout_item/mask/sprungle_golden_mask
	name = "Golden Facemask"
	requires_purchase = FALSE
	admin_only = TRUE
	item_path = /obj/item/clothing/mask/sprungle/personal

// SpeebusDaGeebus
/obj/item/infinite_cigar_box
	name = "\improper paradoxical premium Classic cigar case"
	desc = "A case of incredibly expensive cigars, that never seems to run out."
	icon_state = "intern_cigar_box"
	icon = 'icons/obj/cigarettes.dmi'
	var/spawn_type = /obj/item/clothing/mask/cigarette/cigar/intern

/obj/item/infinite_cigar_box/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/clothing/mask/cigarette/cigar))
		to_chat(user, "you stuff [attacking_item] into the [src], and it seems to fall into a infinite void")
		qdel(attacking_item)
		return TRUE

/obj/item/infinite_cigar_box/attack_self(mob/user, modifiers)
	to_chat(user, "you pull a cigar from the [src]")
	var/obj/item/new_cigar = new spawn_type
	user.put_in_hands(new_cigar)
	playsound(src, 'sound/weapons/gun/general/mag_bullet_insert.ogg', 30, TRUE)

/obj/item/infinite_cigar_box/contraband
	name = "\improper paradoxical premium Prohibition cigar case"
	desc = "A case of seemingly infinte prohibition era cigars, with a purple wrap and a exotic smell."
	icon_state = "intern_cigar_box_purple"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/intern/purple

/datum/loadout_item/inhand/cigar_box
	name = "Paradoxical Premium Classic Cigar Case"
	item_path = /obj/item/infinite_cigar_box
	requires_purchase = FALSE
	admin_only = TRUE
	ckeywhitelist = list("speebusdageebus")

/datum/loadout_item/inhand/cigar_box/purple
	name = "Paradoxical Premium Prohibition Cigar Case"
	item_path = /obj/item/infinite_cigar_box/contraband
