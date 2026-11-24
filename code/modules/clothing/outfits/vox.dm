/// What a vox needs to not choke on the station's air.
/// No mask here: equipOutfit() calls post_equip_species_outfit(), which puts the vox mask on.
/// A mask in this outfit would make the loadout send every loadout mask to the backpack, even ones vox can breathe through.
/datum/outfit/vox
	name = "Vox Internals"
	r_hand = /obj/item/tank/internals/emergency_oxygen/vox
	internals_slot = ITEM_SLOT_HANDS
