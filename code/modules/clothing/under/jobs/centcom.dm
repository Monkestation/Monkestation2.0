/obj/item/clothing/under/rank/centcom
	icon = 'icons/obj/clothing/under/centcom.dmi'
	worn_icon = 'icons/mob/clothing/under/centcom.dmi'

/obj/item/clothing/under/rank/centcom/commander
	name = "\improper CentCom commander's suit"
	desc = "It's a suit worn by CentCom's highest-tier Commanders."
	icon_state = "centcom"
	inhand_icon_state = "dg_suit"

/obj/item/clothing/under/rank/centcom/commander/skirt
	name = "\improper CentCom commander's suitskirt"
	desc = "It's a suitskirt worn by CentCom's highest-tier Commanders."
	icon_state = "centcom_skirt"
	inhand_icon_state = "dg_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/official
	name = "\improper CentCom official's suit"
	desc = "A suit worn by CentCom Officials, with a silver belt buckle to indicate their rank from a glance."
	icon_state = "official"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/official/skirt
	name = "\improper CentCom official's suitskirt"
	desc = "A suitskirt worn by CentCom Officials, with a silver belt buckle to indicate their rank from a glance."
	icon_state = "official_skirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/intern
	name = "\improper CentCom intern's outfit"
	desc = "It's an outfit worn by those interning for CentCom. The top is styled after a polo shirt for easy identification."
	icon_state = "intern"
	inhand_icon_state = "dg_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/centcom/officer
	name = "\improper CentCom turtleneck suit"
	desc = "A casual, yet refined green turtleneck, used by CentCom Officers. It has a fragrance of aloe."
	icon_state = "officer"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/officer/replica
	name = "\improper CentCom turtleneck replica"
	desc = "A cheap copy of the CentCom turtleneck! A Donk Co. logo can be seen on the collar."

/obj/item/clothing/under/rank/centcom/officer/skirt
	name = "\improper CentCom turtleneck suitskirt"
	desc = "A skirt version of the CentCom turtleneck, rarer and more sought after than the original."
	icon_state = "officer_skirt"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/officer_skirt/replica
	name = "\improper CentCom turtleneck skirt replica"
	desc = "A cheap copy of the CentCom turtleneck skirt! A Donk Co. logo can be seen on the collar."


/obj/item/clothing/under/rank/centcom/military
	name = "tactical combat uniform"
	desc = "A dark colored uniform worn by CentCom's conscripted military forces."
	icon_state = "military"
	inhand_icon_state = "bl_suit"
	armor_type = /datum/armor/centcom_military
	can_adjust = FALSE

/datum/armor/centcom_military
	melee = 10
	bio = 10
	fire = 50
	acid = 40

/obj/item/clothing/under/rank/centcom/military/eng
	name = "tactical engineering uniform"
	desc = "A dark colored uniform worn by CentCom's regular military engineers."
	icon_state = "military_eng"

/obj/item/clothing/under/rank/centcom/corporate_liaison
	name = "liaison's suit"
	desc = "A suit worn by those who work for the company. But don't let that fool you, they are pretty okay."
	icon_state = "liaison"
	inhand_icon_state = "b_suit"
	alt_covers_chest = TRUE


/obj/item/clothing/under/rank/centcom/corporate_liaison/skirt
	name = "representative's suitskirt"
	desc = "A suitskirt worn by those who work for the company. But don't let that fool you, they are pretty okay."
	icon_state = "liaison_skirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/moffuchi //now you may ask why is this a centcom subtype. simple answer, there's a centcom moth conspiriacy. long answer, it's a replacement for the domino joke unifrom from the blueshift folder under monkestation modules that i hate so much but felt like it was worth bringing here when rearranging files.
	name = "moffuchi uniform"
	desc = "A uniform worn by those who work for Moffuchi's Pizzeria. The uniform has a logo of a moth with a line underneath reading \"Family style pizza for 2 centuries.\""
	icon_state = "moffuchi"
	inhand_icon_state = "b_suit"
	can_adjust = FALSE
