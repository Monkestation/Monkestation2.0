/obj/item/clothing/suit/armor/vest/buoyantrigvest
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "security_rigvest"

/obj/item/clothing/suit/armor/centcom_admiral
	name = "\improper CentCom Admiral's"
	desc = "Perfect for hiding a spare pistol under."
	icon_state = "admiral"
	inhand_icon_state = "centcom"
	body_parts_covered = CHEST|GROIN|ARMS
	armor_type = /datum/armor/armor_centcom_formal
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'

/obj/item/clothing/suit/armor/centcom_admiral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)
