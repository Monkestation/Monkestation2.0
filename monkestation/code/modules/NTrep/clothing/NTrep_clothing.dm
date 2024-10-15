/obj/item/clothing/under/rank/centcom/nanotrasen_representative
	name = "Nanotrasen representative's suit"
	inhand_icon_state = "dg_suit"
	icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_jumpsuit"
	can_adjust = FALSE


/obj/item/clothing/under/rank/centcom/nanotrasen_representative/skirt
	name = "Nanotrasen representative's suit"
	inhand_icon_state = "dg_suit"
	icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_jumpskirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hats/nanotrasen_representative
	name = "Nanotrasen representative's hat"
	inhand_icon_state = "dg_suit"
	icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_hat"

/obj/item/clothing/suit/armor/vest/nanotrasen_representative
	name = "Nanotrasen representative's suit"
	inhand_icon_state = "dg_suit"
	icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_vest"

/obj/item/clothing/suit/armor/vest/nanotrasen_representative/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)


/obj/item/clothing/suit/armor/vest/nanotrasen_representative/bathrobe
	name = "Nanotrasen representative's suit"
	inhand_icon_state = "dg_suit"
	icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/code/modules/NTrep/clothing/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_bathrobe"
