#define MIMIC_SPOOF_RESIST_MASK ( \
	LAVA_PROOF | \
	FIRE_PROOF | \
	UNACIDABLE | \
	ACID_PROOF | \
	INDESTRUCTIBLE \
)
/datum/component/mimic_disguise
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/spoofed_flags = 0

/datum/component/mimic_disguise/Initialize()
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/disguise_item = parent
	var/to_spoof = disguise_item.resistance_flags & MIMIC_SPOOF_RESIST_MASK

	if(to_spoof)
		spoofed_flags = to_spoof
		disguise_item.resistance_flags &= ~to_spoof

	if(!(disguise_item.obj_flags & CAN_BE_HIT)) // Mimics are attackable.
		disguise_item.obj_flags |= CAN_BE_HIT

/datum/component/mimic_disguise/Destroy(force)
	if(QDELETED(parent))
		return ..()
	var/obj/item/disguise_item = parent
	if(spoofed_flags)
		disguise_item.resistance_flags |= spoofed_flags
	if(!(initial(disguise_item.obj_flags) & CAN_BE_HIT))
		disguise_item.obj_flags &= ~CAN_BE_HIT
	return ..()
#undef MIMIC_SPOOF_RESIST_MASK
