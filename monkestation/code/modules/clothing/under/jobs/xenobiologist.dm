/obj/item/clothing/under/rank/rnd/xenobiologist
	desc = "It's special fibers lets it handle biohazards better. It has the pink stripe of a xenobiologist."
	name = "xenobiologist's jumpsuit"
	icon_state = "xenobio"
	inhand_icon_state = "w_suit"
	resistance_flags = NONE
	armor_type = /datum/armor/rnd_xenobiologist

/datum/armor/rnd_xenobiologist
	bio = 50

/obj/item/clothing/under/rank/rnd/xenobiologist/skirt
	name = "xenobiologist's jumpskirt"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "xenobio_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
