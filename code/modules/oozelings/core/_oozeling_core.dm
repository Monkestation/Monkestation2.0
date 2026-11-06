/// A global list of dead/ejected oozeling cores.
GLOBAL_LIST_EMPTY_TYPED(dead_oozeling_cores, /obj/item/organ/internal/brain/slime)

/obj/item/organ/internal/brain/slime
	name = "core"
	desc = "The center core of a slimeperson, technically their 'extract.' Where the cytoplasm, membrane, and organelles come from; perhaps this is also a mitochondria?"
	zone = BODY_ZONE_CHEST
	icon = 'icons/obj/medical/organs/oozeling.dmi'
	icon_state = "slime_core"
	resistance_flags = FIRE_PROOF

	actions_types = list(
		/datum/action/innate/core_signal,
		/datum/action/innate/regenerate_limbs,
		/datum/action/innate/retract_limb,
	)

	/// UI to see amount of wetness stacks
	var/atom/movable/screen/slime_stacks/slime_wetness_display

	var/death_melt_type = /obj/effect/temp_visual/wizard/out
	var/core_color = COLOR_WHITE

	var/core_ejected = FALSE
	var/gps_active = TRUE

	var/datum/dna/stored_dna
	/// The mind of the oozeling that became this core.
	/// This MUST be named `mind`, in order to allow IS_[antag] macros to work on cores.
	var/datum/mind/mind
	/// The original language holder of the oozeling who died.
	var/datum/language_holder/stored_language_holder

	// dna doesn't have this for some reason
	var/stored_physique

	var/list/stored_quirks = list()
	var/list/stored_items = list()
	var/alist/items_per_slot = alist()

	///Item types that should never be stored in core and will drop on death. Takes priority over allowed lists.
	var/static/list/bannedcore = typecacheof(list(/obj/item/disk/nuclear))
	//Allowed implants usually given by cases and injectors
	var/static/list/allowed_implants = typecacheof(list(
		/obj/item/implant/exile,
		/obj/item/implant/tracking,
		/obj/item/implant/teleport_blocker,
		/obj/item/implant/chem
	))
	//Extraneous organs not of oozeling origin. Usually cyber implants.
	var/static/list/allowed_organ_types = typecacheof(list(
		/obj/item/organ/external/antennae,
		/obj/item/organ/external/frills,
		/obj/item/organ/external/horns,
		/obj/item/organ/external/plumage,
		/obj/item/organ/external/snout,
		/obj/item/organ/external/spines,
		/obj/item/organ/external/tail,
		/obj/item/organ/external/wings,
		/obj/item/organ/internal/alien,
		/obj/item/organ/internal/cyberimp,
		/obj/item/organ/internal/ears/cat/super,
		/obj/item/organ/internal/eyes/robotic/glow,
		/obj/item/organ/internal/heart/cursed,
		/obj/item/organ/internal/tongue/polyglot_voicebox,
		/obj/item/organ/internal/vocal_cords,
	))

	var/rebuilt = TRUE
	var/coredeath = TRUE

	var/datum/action/cooldown/membrane_murmur/membrane_mur

/obj/item/organ/internal/brain/slime/Initialize(mapload, mob/living/carbon/organ_owner, list/examine_list)
	. = ..()
	membrane_mur = new /datum/action/cooldown/membrane_murmur()
	colorize()
	transform.Scale(2, 2)

/obj/item/organ/internal/brain/slime/Destroy(force)
	GLOB.dead_oozeling_cores -= src
	QDEL_NULL(membrane_mur)
	QDEL_NULL(stored_dna)
	QDEL_LIST(stored_quirks)
	QDEL_NULL(stored_language_holder)

	mind = null

	if(length(stored_items))
		var/drop_loc = drop_location()
		if(drop_loc)
			drop_items_to_ground(drop_loc, explode = TRUE)
		else
			QDEL_LIST(stored_items)

	items_per_slot = null

	return ..()
