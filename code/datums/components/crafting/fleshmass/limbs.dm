/datum/crafting_recipe/limb
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/sheet/fleshmass = 10,
	)
	time = 1.5 SECONDS
	category = CAT_LIMBS
	always_available = FALSE

/datum/crafting_recipe/limb/head
	name = "Human Head"
	result = /obj/item/bodypart/head
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/sheet/fleshmass = 15,
	)

/datum/crafting_recipe/limb/human_left_leg
	name = "Human Left Leg"
	result = /obj/item/bodypart/leg/left

/datum/crafting_recipe/limb/human_right_leg
	name = "Human Right Leg"
	result = /obj/item/bodypart/leg/right

/datum/crafting_recipe/limb/human_left_arm
	name = "Human Left Arm"
	result = /obj/item/bodypart/arm/left

/datum/crafting_recipe/limb/human_right_arm
	name = "Human Right Arm"
	result = /obj/item/bodypart/arm/right
