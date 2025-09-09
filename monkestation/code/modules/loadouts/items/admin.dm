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
	item_path = /obj/item/clothing/under/rank/centcom/officer_skirt

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
