/datum/crafting_recipe/organ
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/sheet/fleshmass = 6,
	)
	time = 1.5 SECONDS
	category = CAT_ORGANS
	always_available = FALSE

/datum/crafting_recipe/organ/heart
	name = "Human Heart"
	result = /obj/item/organ/internal/heart
	reqs = list(
		/obj/item/stack/sheet/cloth = 3,
		/obj/item/stack/sheet/fleshmass = 8,
	)
	time = 1.5 SECONDS
	category = CAT_ORGANS

/datum/crafting_recipe/organ/humam_liver
	name = "Human Liver"
	result = /obj/item/organ/internal/liver
	reqs = list(
		/obj/item/stack/sheet/cloth = 2,
		/obj/item/stack/sheet/fleshmass = 6,
	)

/datum/crafting_recipe/organ/human_spleen
	name = "Human Spleen"
	result = /obj/item/organ/internal/spleen
	reqs = list(
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/fleshmass = 4,
	)

/datum/crafting_recipe/organ/human_butt
	name = "Human Butt"
	result = /obj/item/organ/internal/butt
	reqs = list(
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/fleshmass = 3,
	)

/datum/crafting_recipe/organ/human_appendix
	name = "Human Appendix"
	result = /obj/item/organ/internal/appendix
	reqs = list(
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/fleshmass = 2,
	)

/datum/crafting_recipe/organ/human_bladder
	name = "Human Bladder"
	result = /obj/item/organ/internal/bladder
	reqs = list(
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/fleshmass = 3,
	)

/datum/crafting_recipe/organ/human_eyes
	name = "Human Eyes"
	result = /obj/item/organ/internal/eyes
	reqs = list(
		/obj/item/stack/sheet/cloth = 2,
		/obj/item/stack/sheet/fleshmass = 6,
	)

/datum/crafting_recipe/organ/human_ears
	name = "Human Ears"
	result = /obj/item/organ/internal/ears
	reqs = list(
		/obj/item/stack/sheet/cloth = 2,
		/obj/item/stack/sheet/fleshmass = 6,
	)

/datum/crafting_recipe/organ/human_tongue
	name = "Human Tongue"
	result = /obj/item/organ/internal/tongue
	reqs = list(
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/fleshmass = 4,
	)

/datum/crafting_recipe/organ/human_stomach
	name = "Human Stomach"
	result = /obj/item/organ/internal/stomach
	reqs = list(
		/obj/item/stack/sheet/cloth = 2,
		/obj/item/stack/sheet/fleshmass = 6,
	)

/datum/crafting_recipe/organ/monkey_tail
	name = "Monkey Tail"
	result = /obj/item/organ/external/tail/monkey
	reqs = list(
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/fleshmass = 3,
	)
