//canopic box sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_box
	name = "canopic box"
	desc = "An ornate stone box inscribed with ancient hieroglyphs."
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic_box.dmi'
	icon_state = "canopic_box"
	inhand_icon_state = "canopic_box"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
/datum/crafting_recipe/canopic_box
	name = "canopic box"
	result = /obj/item/storage/box/canopic_box
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 5,
		/obj/item/stack/sheet/mineral/wood = 10,
		/obj/item/stack/sheet/leather = 2,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS

//jackal canopic sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_jackal
	name = "jackal canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic.dmi'
	icon_state = "canopic_jackal"
	inhand_icon_state = "canopic_jackal"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
/datum/crafting_recipe/canopic_jackal
	name = "jackal canopic jar"
	result = /obj/item/storage/box/canopic_jackal
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS
//human canopic sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_human
	name = "human canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic.dmi'
	icon_state = "canopic_human"
	inhand_icon_state = "canopic_human"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
/datum/crafting_recipe/canopic_human
	name = "human canopic jar"
	result = /obj/item/storage/box/canopic_human
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS
//monke canopic sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_monke //creates the object
	name = "monke canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic.dmi'
	icon_state = "canopic_monke"
	inhand_icon_state = "canopic_monke"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
/obj/item/storage/box/canopic_monke/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_TINY
	update_appearance()
/datum/crafting_recipe/canopic_monke //creates the crafting recipe
	name = "monke canopic jar"
	result = /obj/item/storage/box/canopic_monke
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS
//hawk canopic sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_hawk //creates the object
	name = "hawk canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic.dmi'
	icon_state = "canopic_hawk"
	inhand_icon_state = "canopic_hawk"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
/datum/crafting_recipe/canopic_hawk //creates the crafting recipe
	name = "hawk canopic jar"
	result = /obj/item/storage/box/canopic_hawk
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS
