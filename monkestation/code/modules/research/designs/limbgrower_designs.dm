/datum/design/spleen
	name = "Spleen"
	id = "spleen"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/spleen
	category = list(SPECIES_HUMAN, RND_CATEGORY_INITIAL)

/// Apid Organs
/datum/design/apid_eyes
	name = "Apid Eyes"
	id = "apid_eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 15)
	build_path = /obj/item/organ/internal/eyes/apid
	category = list(SPECIES_APID, RND_CATEGORY_INITIAL)

/datum/design/apid_tongue
	name = "Apid Tongue"
	id = "apid_tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 5)
	build_path = /obj/item/organ/internal/tongue/apid
	category = list(SPECIES_APID, RND_CATEGORY_INITIAL)

/datum/design/apid_wings
	name = "Apid Wings"
	id = "apid_wings"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/external/wings/apid
	category = list(SPECIES_APID)

/datum/design/apid_antennae
	name = "Apid Antennae"
	id = "apid_antennae"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 5)
	build_path = /obj/item/organ/external/antennae_apid
	category = list(SPECIES_APID, RND_CATEGORY_INITIAL)

/// Arachnid Organs

/datum/design/arachnid_eyes // Gives nightvision so not initial for now
	name = "Arachnid Eyes"
	id = "arachnid_eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 15)
	build_path = /obj/item/organ/internal/eyes/night_vision/arachnid
	category = list(SPECIES_ARACHNIDS, RND_CATEGORY_INITIAL)

/datum/design/arachnid_tongue
	name = "Arachnid Tongue"
	id = "arachnid_tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/tongue/arachnid
	category = list(SPECIES_ARACHNIDS, RND_CATEGORY_INITIAL)

/datum/design/chelicerae
	name = "Chelicerae"
	id = "chelicerae"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 5)
	build_path = /obj/item/organ/external/chelicerae
	category = list(SPECIES_ARACHNIDS, RND_CATEGORY_INITIAL)

/datum/design/arachnid_appendages
	name = "Arachnid Appendages"
	id = "arachnid_appendages"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/external/arachnid_appendages
	category = list(SPECIES_ARACHNIDS, RND_CATEGORY_INITIAL)

/// Ethereal Organs

/datum/design/ethereal_tail
	name = "Ethereal Tail"
	id = "ethereal_tail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/consumable/liquidelectricity = 15)
	build_path = /obj/item/organ/external/tail
	category = list(SPECIES_ETHEREAL, RND_CATEGORY_INITIAL)

/datum/design/ethereal_horns
	name = "Ethereal Horns"
	id = "ethereal_horns"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/consumable/liquidelectricity = 10)
	build_path = /obj/item/organ/external/ethereal_horns
	category = list(SPECIES_ETHEREAL, RND_CATEGORY_INITIAL)

/datum/design/ethereal_eyes
	name = "Ethereal Eyes"
	id = "ethereal_eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/consumable/liquidelectricity = 20)
	build_path = /obj/item/organ/internal/eyes/ethereal
	category = list(SPECIES_ETHEREAL, RND_CATEGORY_INITIAL)

/// Floran Organs
/datum/design/floran_eyes
	name = "Phytoid Eyes"
	id = "floran_eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/plantnutriment/eznutriment = 20, /datum/reagent/water = 10)
	build_path = /obj/item/organ/internal/eyes/floran
	category = list(SPECIES_FLORAN, RND_CATEGORY_INITIAL)

/datum/design/floran_tongue
	name = "Floran Tongue"
	id = "floran_tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/plantnutriment/eznutriment = 20, /datum/reagent/water = 10)
	build_path = /obj/item/organ/internal/tongue/floran
	category = list(SPECIES_FLORAN, RND_CATEGORY_INITIAL)

/datum/design/floran_leaves
	name = "Floran Leaves"
	id = "floran_leaf"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/plantnutriment/eznutriment = 20, /datum/reagent/water = 10) // plant
	build_path = /obj/item/organ/external/floran_leaves
	category = list(SPECIES_FLORAN)

/// Goblin
/datum/design/goblin_tongue
	name = "Goblin Tongue"
	id = "goblin_tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/tongue/goblin
	category = list(SPECIES_GOBLIN, RND_CATEGORY_INITIAL)

/datum/design/goblin_ears
	name = "Goblin Ears"
	id = "goblin_ears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/external/goblin_ears
	category = list(SPECIES_GOBLIN, RND_CATEGORY_INITIAL)

/datum/design/goblin_nose
	name = "Goblin Nose"
	id = "goblin_nose"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 5)
	build_path = /obj/item/organ/external/goblin_nose
	category = list(SPECIES_GOBLIN, RND_CATEGORY_INITIAL)

/// Moth

/datum/design/moth_eyes
	name = "Moth Eyes "
	id = "moth_eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/eyes/moth
	category = list(SPECIES_MOTH, RND_CATEGORY_INITIAL)

/datum/design/antennae
	name = "Moth Antennae"
	id = "moth_antennae"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/external/antennae
	category = list(SPECIES_MOTH, RND_CATEGORY_INITIAL)

/// Ornithid Organs

/datum/design/ornithid_tongue
	name = "ornithid "
	id = "ornithid"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/tongue/ornithid
	category = list(SPECIES_ORNITHID)

/datum/design/plumage
	name = "Plumage"
	id = "plumage"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/external/plumage
	category = list(SPECIES_ORNITHID, RND_CATEGORY_INITIAL)

/datum/design/ornithid_tail
	name = "Avian Tail "
	id = "ornithid_tail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/external/tail/avian
	category = list(SPECIES_ORNITHID, RND_CATEGORY_INITIAL)

/datum/design/ornithid_wings
	name = "Arm Wings "
	id = "ornithid_wings"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/external/wings/functional/arm_wings
	category = list(SPECIES_ORNITHID)

/// Satyr
/datum/design/satyr_horns
	name = "Satyr Horns"
	id = "satyr_horns"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 15)
	build_path = /obj/item/organ/external/horns/satyr_horns
	category = list(SPECIES_SATYR, RND_CATEGORY_INITIAL)

/datum/design/satyr_tail
	name = "Satyr Tail"
	id = "satyr_tail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/external/tail/satyr_tail
	category = list(SPECIES_SATYR, RND_CATEGORY_INITIAL)

/datum/design/satyr_fluff
	name = "Satyr Fluff"
	id = "satyr_fluff"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/external/satyr_fluff
	category = list(SPECIES_SATYR)

/obj/item/disk/design_disk/limbs/other
	name = "Misc. Organ Design Disk"
	limb_designs = list(/datum/design/satyr_fluff, /datum/design/floran_leaves, /datum/design/apid_wings, /datum/design/ornithid_tongue)

/datum/design/limb_disk/other
	name = "Misc. Organ Design Disk"
	desc = "Contains designs for organs for the limbgrower of all around the rim - Satyr Fluff, Floran Leaves, Apid Wings, Ornithid Tongues"
	id = "limbdesign_other"
	build_path = /obj/item/disk/design_disk/limbs/other
