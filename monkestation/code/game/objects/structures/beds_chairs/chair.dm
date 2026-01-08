//sandstone chair start
/obj/structure/chair/stool/sandstone
	name = "sandstone stool"
	desc = "Apply dummy thick cheeks."
	icon = 'monkestation/icons/obj/sandstone_structures.dmi'
	icon_state = "stool"
	resistance_flags = FIRE_PROOF
	can_buckle = FALSE
	buildstacktype = /obj/item/stack/sheet/mineral/sandstone
	buildstackamount = 1
	item_chair = /obj/item/chair/stool/sandstone

/obj/item/chair/stool/sandstone
	name = "sandstone stool"
	icon = 'monkestation/icons/obj/sandstone_structures.dmi'
	icon_state = "stool_toppled"
	inhand_icon_state = null
	origin_type = /obj/structure/chair/stool/sandstone
//sandstone chair end

/obj/structure/chair/silk
	name = "silk chair"
	icon = 'monkestation/icons/obj/silk_structures.dmi'
	icon_state = "chair"
	buildstacktype = /obj/item/stack/sheet/silk
	buildstackamount = 3
	item_chair = /obj/item/chair/silk
	resistance_flags = FLAMMABLE

/obj/item/chair/silk
	name = "silk chair"
	desc = "It's way too soft for it to make a dent on anything."
	icon = 'monkestation/icons/obj/silk_structures.dmi'
	icon_state = "chair_toppled"
	origin_type = /obj/structure/chair/silk
	custom_materials = null
	force = 0 //It's just silk
	throwforce = 0
	throw_range = 6
