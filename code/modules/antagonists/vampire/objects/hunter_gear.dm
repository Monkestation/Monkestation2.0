/obj/item/clothing/suit/armor/vamphunter
	name = "vampire hunter garb"
	desc = "This worn outfit saw much use back in the day. Internal reinforcements help protect against bites and scratches."
	allowed = list(
		/obj/item/book/bible,
		/obj/item/book/kindred,
		/obj/item/food/garlic_kimchi,
		/obj/item/food/garlicbread,
		/obj/item/food/grown/garlic,
		/obj/item/reagent_containers/cup/glass/bottle/garlic_extract,
		/obj/item/reagent_containers/cup/glass/bottle/holywater,
		/obj/item/stake,
	)
	icon = 'icons/vampires/vamp_obj.dmi'
	worn_icon = 'icons/vampires/worn.dmi'
	icon_state = "monsterhunter"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor_type = /datum/armor/jacket_curator
	strip_delay = 8 SECONDS
	equip_delay_other = 6 SECONDS

/datum/armor/jacket_curator
	melee = 25
	bullet = 10
	laser = 25
	energy = 10
	acid = 45
	wound =  10

/obj/item/clothing/head/helmet/vamphunter_hat
	name = "vampire hunter hat"
	desc = "This hat saw much use back in the day."
	icon = 'icons/vampires/vamp_obj.dmi'
	worn_icon = 'icons/vampires/worn.dmi'
	icon_state = "monsterhunterhat"
	inhand_icon_state = null
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEEYES
	armor_type = /datum/armor/helmet_chaplain
	strip_delay = 8 SECONDS
	dog_fashion = null
