/obj/item/clothing/mask/gas/slasher
	name = "slasher's gas mask"
	desc = "A close-fitting sealed gas mask, this one seems to be protruding some kind of dark aura."

	icon = 'monkestation/icons/mob/slasher/slasher_items.dmi'
	worn_icon = 'monkestation/icons/mob/slasher/slasher_wornstates.dmi'
	icon_state = "slasher_firemask"
	inhand_icon_state = null
	flash_protect = FLASH_PROTECTION_WELDER
	clothing_flags = HIDEHAIR | HIDEFACIALHAIR | MASKINTERNALS
	flags_cover = PEPPERPROOF | MASKCOVERSEYES
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slowdown = 0

/obj/item/clothing/mask/gas/slasher/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/mask/gas/slasher/adjustmask()
	return



/obj/item/clothing/suit/apron/slasher
	name = "butcher's apron"
	desc = "A brown butcher's apron, you can feel an aura of something dark radiating off of it."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'monkestation/icons/mob/slasher/slasher_items.dmi'
	worn_icon = 'monkestation/icons/mob/slasher/slasher_wornstates.dmi'
	icon_state = "slasher_apron"
	inhand_icon_state = null
	armor_type = /datum/armor/slasher/level0

/datum/armor/slasher/level0 // start
	melee = 10
	bullet = 10
	laser = 10
	energy = 10
	fire = 10
	acid = 10
	bio = 10

/datum/armor/slasher/level1 // after 6 claimed souls
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	fire = 30
	acid = 30
	bio = 66

/datum/armor/slasher/level2 // after 12 claimed souls
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	fire = 50
	acid = 50
	bio = 50

/datum/armor/slasher/level3 //after 18 claimed souls
	melee = 70
	bullet = 70
	laser = 70
	energy = 70
	fire = 70
	acid = 70
	bio = 70

/obj/item/clothing/suit/apron/slasher/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/under/slasher
	name = "butcher's jumpsuit"
	icon = 'monkestation/icons/mob/slasher/slasher_items.dmi'
	worn_icon = 'monkestation/icons/mob/slasher/slasher_wornstates.dmi'
	icon_state = "slasher_under"
	inhand_icon_state = null
	desc = "A brown butcher's jumpsuit, you can feel an aura of something dark radiating off of it."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/under/slasher/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/storage/belt/slasher
	name = "slasher's trap fanny pack"
	desc = "A place to put all your traps."

/obj/item/storage/belt/slasher/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 15
	atom_storage.max_slots = 5
	atom_storage.set_holdable(/obj/item/restraints/legcuffs/beartrap/slasher)
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/belt/slasher/PopulateContents()
	SSwardrobe.provide_type(/obj/item/restraints/legcuffs/beartrap/slasher, src)
	SSwardrobe.provide_type(/obj/item/restraints/legcuffs/beartrap/slasher, src)
	SSwardrobe.provide_type(/obj/item/restraints/legcuffs/beartrap/slasher, src)
	SSwardrobe.provide_type(/obj/item/restraints/legcuffs/beartrap/slasher, src)
	SSwardrobe.provide_type(/obj/item/restraints/legcuffs/beartrap/slasher, src)

/obj/item/restraints/legcuffs/beartrap/slasher
	name = "barbed bear trap"
	breakouttime = 2 SECONDS
