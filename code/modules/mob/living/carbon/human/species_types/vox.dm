/datum/species/vox
	name = "\improper Vox"
	plural_form = "Voces"
	id = SPECIES_VOX
	changesource_flags = NONE
	visual_gender = FALSE
	sexes = FALSE // its a bird looking... thing?

	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_AUGMENTS,
		TRAIT_FEATHERED,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NO_ZOMBIFY,
	)
	external_organs = list(
		/obj/item/organ/external/head_quills = "Ruff Hawk",
		/obj/item/organ/external/face_quills = "None",
		/obj/item/organ/external/tail/vox = "Azure Tail",
	)
	no_equip_flags = ITEM_SLOT_NECK
	death_sound = 'sound/voice/vox/vox_DeathGasp.ogg'
	meat = /obj/item/food/meat/slab/chicken
	species_language_holder = /datum/language_holder/vox
	mutanttongue = /obj/item/organ/internal/tongue/vox
	mutanteyes = /obj/item/organ/internal/eyes/vox
	mutantlungs = /obj/item/organ/internal/lungs/vox
	exotic_bloodtype = BLOOD_TYPE_HEMOLYMPH
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/vox,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/vox,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/vox,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/vox,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/vox,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/vox,
	)

/datum/species/vox/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_HUMAN_EQUIPPING_ITEM, PROC_REF(on_owner_equipping_item))
	human_who_gained_species.set_voice_pack("misc.vox")

/datum/species/vox/on_species_loss(mob/living/carbon/human/human_who_lost_species, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(human_who_lost_species, COMSIG_HUMAN_EQUIPPING_ITEM)

/datum/species/vox/proc/on_owner_equipping_item(mob/living/carbon/human/owner, obj/item/equip_target, slot)
	SIGNAL_HANDLER
	if(!equip_target)
		return
	var/obj/item/clothing/clothing_to_equip
	if(isclothing(equip_target))
		clothing_to_equip = equip_target
	if(clothing_to_equip && clothing_to_equip.clothing_flags & VOX_CLOTHING) // vox clothing, we good
		return
	if(!(equip_target.slot_flags & ITEM_SLOT_BACK) && !(equip_target.slot_flags & ITEM_SLOT_EARS) && !(equip_target.slot_flags & ITEM_SLOT_HEAD) && !(equip_target.slot_flags & ITEM_SLOT_MASK))
		to_chat(owner, span_warning("[src] doesn't fit!"))
		return COMPONENT_BLOCK_EQUIP
	if(equip_target.slot_flags & ITEM_SLOT_HEAD && check_coverage_conflict(equip_target))
		to_chat(owner, span_warning("[src] doesn't fit!"))
		return COMPONENT_BLOCK_EQUIP
	if(equip_target.slot_flags & ITEM_SLOT_MASK && check_coverage_conflict(equip_target))
		to_chat(owner, span_warning("[src] doesn't fit!"))
		return COMPONENT_BLOCK_EQUIP

/datum/species/vox/proc/check_coverage_conflict(obj/item/item_to_check)
	if(item_to_check.flags_inv & HIDEMASK)
		return TRUE
	if(item_to_check.flags_inv & HIDEEARS)
		return TRUE
	if(item_to_check.flags_inv & HIDEFACE)
		return TRUE
	if(item_to_check.flags_inv & HIDEHAIR)
		return TRUE
	if(item_to_check.flags_inv & HIDEFACIALHAIR)
		return TRUE
	if(item_to_check.flags_inv & HIDESNOUT)
		return TRUE
	return FALSE

/datum/species/vox/get_species_description()
	return "The Vox are a race of spacefaring avians. They have a penchant for capitalism and goods peddling, deep space salvage, and sometimes interstellar crime. They speak in outlandish accents and are widely considered a nomadic pest in the eyes of the average human. The presence of these ruthless and irritating space vultures is mostly tolerated because of CentComm policy and the technology the Vox gather."

/obj/item/bodypart/head/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	lip_style = NONE
	head_flags = null
	should_draw_greyscale = FALSE

/obj/item/bodypart/head/vox/Initialize(mapload)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_x = list(
			"east" = 5,
			"west" = -5,
		),
		offset_y = list(
			"north" = -2,
			"south" = -2,
			"east" = -1,
			"west" = -1,
		),
	)
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_x = list(
			"east" = 2,
			"west" = -2,
		),
		offset_y = list(
			"north" = -1,
			"south" = -1,
			"east" = -1,
			"west" = -1,
		),
	)
	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_x = list(
			"east" = 3,
			"west" = -3,
		),
		offset_y = list(
			"north" = -1,
			"south" = -1,
			"east" = -1,
			"west" = -1,
		),
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_x = list(
			"east" = 3,
			"west" = -3,
		),
	)
	return ..()

/obj/item/bodypart/chest/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	ass_image = 'icons/ass/asslizard.png'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)

	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)

	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/vox/Initialize(mapload)
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list(
			"north" = -1,
			"south" = 1,
			"east" = 2,
			"west" = -2,
		),
		offset_y = list(
			"north" = -3,
			"south" = -3,
			"east" = -3,
			"west" = -3,
		),
	)
	return ..()

/obj/item/bodypart/arm/right/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)

	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/vox/Initialize(mapload)
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list(
			"north" = 1,
			"south" = -1,
			"east" = 2,
			"west" = -2,
		),
		offset_y = list(
			"north" = -3,
			"south" = -3,
			"east" = -3,
			"west" = -3,
		),
	)
	return ..()

/obj/item/bodypart/leg/left/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	bodypart_traits = list(TRAIT_HARD_SOLES)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
	)

	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	bodypart_traits = list(TRAIT_HARD_SOLES)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
	)

	should_draw_greyscale = FALSE

/obj/item/clothing/under/vox
	name = "alien clothing"
	desc = "A strange set of pants and straps."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-jumpsuit"
	clothing_flags = VOX_CLOTHING
	inhand_icon_state = null
	no_worn_offset = TRUE
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/mask/breath/vox
	name = "bizarre breath mask"
	desc = "A close-fitting mask that can be connected to an air supply. This one is enlogated and tapered, strange."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "voxmask"
	clothing_flags = VOX_CLOTHING
	no_worn_offset = TRUE

/obj/item/clothing/head/helmet/space/vox
	name = "alien helmet"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-pressure-helmet"
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | PLASMAMAN_HELMET_EXEMPT | HEADINTERNALS | VOX_CLOTHING
	flags_inv = HIDEMASK|HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT


/obj/item/clothing/suit/space/vox
	name = "alien pressure suit"
	desc = "A huge, pressurized suit, designed for distinctly nonhuman proportions. It looks unusually cheap."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-pressure-suit"
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | VOX_CLOTHING
