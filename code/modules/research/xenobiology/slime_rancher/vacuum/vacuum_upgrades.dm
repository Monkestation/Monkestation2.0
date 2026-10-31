/// Installed behavior and stat changes owned by one vacuum pack.
/datum/vacuum_upgrade
	/// Pack that owns this upgrade.
	var/obj/item/vacuum_pack/pack
	/// Display name used by pack examination.
	var/name = "vacuum"
	/// Added storage slots.
	var/capacity_bonus = 0
	/// Added suction range.
	var/range_bonus = 0
	/// Reduction to suction wind-up.
	var/capture_delay_reduction = 0
	/// Capability bitflag granted to the pack.
	var/capability = NONE

/datum/vacuum_upgrade/New(obj/item/vacuum_pack/pack)
	. = ..()
	src.pack = pack
	on_install()

/datum/vacuum_upgrade/Destroy()
	pack = null
	return ..()

/// Runs right after the upgrade is installed, for ones that need a bit of setup.
/datum/vacuum_upgrade/proc/on_install()
	return

/datum/vacuum_upgrade/capacity
	name = "capacity"
	capacity_bonus = 5

/datum/vacuum_upgrade/range
	name = "range"
	range_bonus = 2

/datum/vacuum_upgrade/speed
	name = "speed"
	capture_delay_reduction = 0.5 SECONDS

/datum/vacuum_upgrade/pacify
	name = "pacify"
	capability = VACUUM_CAN_PACIFY

/datum/vacuum_upgrade/printer
	name = "printer"
	capability = VACUUM_CAN_PRINT

/// Uses its own trait source so other stasis effects survive release.
/datum/vacuum_upgrade/stasis
	name = "stasis"

/datum/vacuum_upgrade/stasis/on_install()
	RegisterSignal(pack, COMSIG_VACUUM_STORED, PROC_REF(on_stored))
	RegisterSignal(pack, COMSIG_VACUUM_RELEASED, PROC_REF(on_released))
	for(var/mob/living/occupant as anything in pack.occupants())
		apply_stasis(occupant)

/datum/vacuum_upgrade/stasis/Destroy()
	if(pack)
		UnregisterSignal(pack, list(COMSIG_VACUUM_STORED, COMSIG_VACUUM_RELEASED))
		for(var/mob/living/occupant as anything in pack.occupants())
			remove_stasis(occupant)
	return ..()

/datum/vacuum_upgrade/stasis/proc/on_stored(datum/source, mob/living/occupant)
	SIGNAL_HANDLER
	apply_stasis(occupant)

/datum/vacuum_upgrade/stasis/proc/on_released(datum/source, mob/living/occupant)
	SIGNAL_HANDLER
	remove_stasis(occupant)

/datum/vacuum_upgrade/stasis/proc/apply_stasis(mob/living/occupant)
	if(!QDELETED(occupant))
		ADD_TRAIT(occupant, TRAIT_STASIS, REF(src))

/datum/vacuum_upgrade/stasis/proc/remove_stasis(mob/living/occupant)
	if(!QDELETED(occupant))
		REMOVE_TRAIT(occupant, TRAIT_STASIS, REF(src))

/// Heals living occupants over elapsed time without reviving them.
/datum/vacuum_upgrade/healing
	name = "healing"

/datum/vacuum_upgrade/healing/on_install()
	START_PROCESSING(SSobj, src)

/datum/vacuum_upgrade/healing/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/vacuum_upgrade/healing/process(seconds_per_tick)
	for(var/mob/living/occupant as anything in pack?.occupants())
		if(occupant.stat != DEAD)
			occupant.heal_overall_damage(brute = 1 * seconds_per_tick, burn = 1 * seconds_per_tick)

/// Use it on a pack to install an upgrade. Eats the disk.
/obj/item/disk/vacuum_upgrade
	name = "vacuum upgrade disk"
	desc = "A one-use upgrade disk for a slime vacuum pack."
	icon_state = "rndmajordisk"
	/// Upgrade datum installed by this disk.
	var/upgrade_type

/obj/item/disk/vacuum_upgrade/capacity
	name = "vacuum capacity upgrade disk"
	upgrade_type = /datum/vacuum_upgrade/capacity
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2)

/obj/item/disk/vacuum_upgrade/range
	name = "vacuum range upgrade disk"
	upgrade_type = /datum/vacuum_upgrade/range
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 2)

/obj/item/disk/vacuum_upgrade/speed
	name = "vacuum speed upgrade disk"
	upgrade_type = /datum/vacuum_upgrade/speed
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 3)

/obj/item/disk/vacuum_upgrade/stasis
	name = "vacuum stasis upgrade disk"
	upgrade_type = /datum/vacuum_upgrade/stasis
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 3, /datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 2)

/obj/item/disk/vacuum_upgrade/healing
	name = "vacuum healing upgrade disk"
	upgrade_type = /datum/vacuum_upgrade/healing
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 3, /datum/material/plasma = SMALL_MATERIAL_AMOUNT * 3)

/obj/item/disk/vacuum_upgrade/pacify
	name = "vacuum pacify upgrade disk"
	upgrade_type = /datum/vacuum_upgrade/pacify
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 3)

/obj/item/disk/vacuum_upgrade/printer
	name = "vacuum printer upgrade disk"
	upgrade_type = /datum/vacuum_upgrade/printer
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 4, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 3, /datum/material/diamond = SMALL_MATERIAL_AMOUNT * 2)

/datum/design/vacuum_pack_upgrade
	name = "Vacuum Upgrade Disk"
	desc = "A one-use upgrade disk for a slime vacuum pack."
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_XENOBIOLOGY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/vacuum_pack_upgrade/capacity
	name = "Vacuum Capacity Upgrade Disk"
	id = "vacuum_upgrade_capacity"
	desc = "Adds five storage slots to a slime vacuum pack."
	build_path = /obj/item/disk/vacuum_upgrade/capacity
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2)

/datum/design/vacuum_pack_upgrade/range
	name = "Vacuum Range Upgrade Disk"
	id = "vacuum_upgrade_range"
	desc = "Adds two tiles of suction range to a slime vacuum pack."
	build_path = /obj/item/disk/vacuum_upgrade/range
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 2)

/datum/design/vacuum_pack_upgrade/speed
	name = "Vacuum Speed Upgrade Disk"
	id = "vacuum_upgrade_speed"
	desc = "Cuts down the suction wind-up on a slime vacuum pack."
	build_path = /obj/item/disk/vacuum_upgrade/speed
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 3)

/datum/design/vacuum_pack_upgrade/pacify
	name = "Vacuum Pacify Upgrade Disk"
	id = "vacuum_upgrade_pacify"
	desc = "Lets a slime vacuum pack capture rabid slimes safely."
	build_path = /obj/item/disk/vacuum_upgrade/pacify
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 3)

/datum/design/vacuum_pack_upgrade/stasis
	name = "Vacuum Stasis Upgrade Disk"
	id = "vacuum_upgrade_stasis"
	desc = "Keeps creatures stored in a slime vacuum pack in stasis."
	build_path = /obj/item/disk/vacuum_upgrade/stasis
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 3, /datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 2)

/datum/design/vacuum_pack_upgrade/healing
	name = "Vacuum Healing Upgrade Disk"
	id = "vacuum_upgrade_healing"
	desc = "Slowly heals creatures stored in a slime vacuum pack."
	build_path = /obj/item/disk/vacuum_upgrade/healing
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 3, /datum/material/plasma = SMALL_MATERIAL_AMOUNT * 3)

/datum/design/vacuum_pack_upgrade/printer
	name = "Vacuum Printer Upgrade Disk"
	id = "vacuum_upgrade_printer"
	desc = "Lets a slime vacuum pack print and launch stored creature species from a linked biomass recycler."
	build_path = /obj/item/disk/vacuum_upgrade/printer
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 4, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 3, /datum/material/diamond = SMALL_MATERIAL_AMOUNT * 2)

/datum/techweb_node/slime_vacuum_upgrades
	id = "slime_vacuum_upgrades"
	display_name = "Slime Vacuum Modules"
	description = "Upgrade modules for the slime vacuum pack: more capacity, more range, faster capture, pacifying, stasis, and passive healing for stored creatures."
	prereq_ids = list("bio_process")
	design_ids = list(
		"vacuum_upgrade_capacity",
		"vacuum_upgrade_range",
		"vacuum_upgrade_speed",
		"vacuum_upgrade_pacify",
		"vacuum_upgrade_stasis",
		"vacuum_upgrade_healing",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
