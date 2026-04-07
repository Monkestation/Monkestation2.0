//need to convert this to using the element
/obj/item/clothing/accessory/gang_pin
	name = "Gang Pin"
	desc = "A pin showing affiliation to a gang."
	icon_state = "anti_sec"

/obj/item/clothing/accessory/gang_pin/Initialize(mapload)
	. = ..()
	SSgangs.register_gang_clothing(src, 2)

/obj/item/clothing/accessory/gang_pin/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	. = ..()

/obj/item/clothing/accessory/gang_pin/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	. = ..()
