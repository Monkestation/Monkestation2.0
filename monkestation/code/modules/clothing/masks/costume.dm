// Sprungle's mask

/obj/item/clothing/mask/sprungle
	name = "porcelain mask"
	desc = "An ill omen of things to come."
	icon_state = "protector"
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT|HIDEHAIR

/obj/item/clothing/mask/sprungle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "hood")

/obj/item/clothing/mask/sprungle/personal
	name = "golden mask"
	icon_state = "lordprotector"
