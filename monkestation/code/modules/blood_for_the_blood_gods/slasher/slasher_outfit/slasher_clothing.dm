/obj/item/clothing/mask/gas/slasher
	name = "slasher's gas mask"
	desc = "A close-fitting sealed gas mask, this one seems to be protruding some kind of dark aura."

	icon = 'monkestation/icons/mob/slasher/slasher_items.dmi'
	worn_icon = 'monkestation/icons/mob/slasher/slasher_wornstates.dmi'
	icon_state = "slasher_firemask"
	inhand_icon_state = null
	flash_protect = FLASH_PROTECTION_WELDER
	clothing_flags = MASKINTERNALS
	flags_inv = HIDEFACIALHAIR | HIDEHAIR
	visor_flags_inv = 0
	flags_cover = MASKCOVERSEYES | PEPPERPROOF
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slowdown = 0

/obj/item/clothing/mask/gas/slasher/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/mask/gas/slasher/adjustmask()
	return

/obj/item/clothing/mask/gas/slasher/cluwne
	name = "cluwne mask"
	icon_state = "cluwne_mask"
	desc = "A close-fitting sealed mask, this one seems to be protruding some kind of dark aura."
	flags_inv = HIDEFACIALHAIR

/obj/item/clothing/mask/gas/slasher/brute
	name = "dome helmet"
	icon_state = "brute_mask"
	desc = "A close-fitting sealed helmet, this one seems to be protruding some kind of dark aura."

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

/obj/item/clothing/suit/apron/slasher/cluwne
	name = "damned suspenders"
	icon_state = "cluwne_apron"
	desc = "A pair of suspenders that seem to be stitched together from the souls of the damned."

/obj/item/clothing/suit/apron/slasher/brute
	name = "soul-steel armor"
	icon_state = "brute_apron"
	desc = "A set of armor that grows stronger with each soul claimed."

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

/obj/item/clothing/under/slasher/cluwne
	name = "cluwne jumpsuit"
	icon_state = "cluwne_under"
	desc = "A cluwne jumpsuit, suspenders sold separately cause fuck these bastards."

/obj/item/storage/belt/slasher
	name = "slasher's trap fanny pack"
	desc = "A place to put all your traps."
	/// reference to the owning slasher datum
	var/datum/antagonist/slasher/slasher_owner

/obj/item/storage/belt/slasher/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 15
	atom_storage.max_slots = 3
	atom_storage.set_holdable(/obj/item/restraints/legcuffs/beartrap/slasher)
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/storage/belt/slasher/equipped(mob/living/user, slot)
	. = ..()
	slasher_owner = IS_SLASHER(user)
	if(!slasher_owner)
		return
	for(var/obj/item/restraints/legcuffs/beartrap/slasher/trap in src)
		trap.set_slasher(slasher_owner)

/obj/item/storage/belt/slasher/PopulateContents()
	SSwardrobe.provide_type(/obj/item/restraints/legcuffs/beartrap/slasher, src)
	SSwardrobe.provide_type(/obj/item/restraints/legcuffs/beartrap/slasher, src)
	SSwardrobe.provide_type(/obj/item/restraints/legcuffs/beartrap/slasher, src)

/obj/item/restraints/legcuffs/beartrap/slasher
	name = "barbed bear trap"
	breakouttime = 2 SECONDS
	alpha = 160
	var/datum/antagonist/slasher/slasher_owner

/obj/item/restraints/legcuffs/beartrap/slasher/Destroy()
	if(slasher_owner)
		slasher_owner.linked_traps -= src
	return ..()

/obj/item/restraints/legcuffs/beartrap/slasher/proc/set_slasher(datum/antagonist/slasher/slasherdatum)
	if(slasher_owner)
		slasher_owner.linked_traps -= src
	slasher_owner = slasherdatum
	if(slasher_owner)
		slasher_owner.linked_traps += src

/obj/item/storage/belt/slasher/cluwne
	name = "cluwne's trap fanny pack"
	desc = "A place to put all your clowny traps."
	icon_state = "clown"
	inhand_icon_state = "clown"
	worn_icon_state = "clown"

