//canopic box
/obj/item/storage/box/canopic_box
	name = "canopic box"
	desc = "An ornate stone box inscribed with ancient hieroglyphs."
	icon = 'icons/obj/storage/canopic.dmi'
	icon_state = "canopic_box"
	inhand_icon_state = "canopic_box"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboardbox_pickup.ogg'
//jackal canopic
/obj/item/storage/box/canopic_jackal
	name = "jackal canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	icon = 'icons/obj/storage/canopic.dmi'
	icon_state = "canopic_jackal"
	inhand_icon_state = "canopic_jackal"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboardbox_pickup.ogg'
/obj/item/storage/box/canopic_jackal/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	update_appearance()
//human canopic
/obj/item/storage/box/canopic_human
	name = "human canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	icon = 'icons/obj/storage/canopic.dmi'
	icon_state = "canopic_human"
	inhand_icon_state = "canopic_human"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboardbox_pickup.ogg'
/obj/item/storage/box/canopic_human/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	update_appearance()
//monke canopic
/obj/item/storage/box/canopic_monke
	name = "monke canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	icon = 'icons/obj/storage/canopic.dmi'
	icon_state = "canopic_monke"
	inhand_icon_state = "canopic_monke"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboardbox_pickup.ogg'
/obj/item/storage/box/canopic_monke/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	update_appearance()
//hawk canopic
/obj/item/storage/box/canopic_hawk
	name = "hawk canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	icon = 'icons/obj/storage/canopic.dmi'
	icon_state = "canopic_hawk"
	inhand_icon_state = "canopic_hawk"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboardbox_pickup.ogg'
/obj/item/storage/box/canopic_hawk/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	update_appearance()
