/obj/structure/blob/normal
	name = "normal blob"
	icon_state = "blob"
	light_outer_range = 0
	max_integrity = BLOB_REGULAR_MAX_HP
	var/initial_integrity = BLOB_REGULAR_HP_INIT
	health_regen = BLOB_REGULAR_HP_REGEN
	brute_resist = BLOB_BRUTE_RESIST * 0.5

/obj/structure/blob/normal/Initialize(mapload, owner_overmind)
	. = ..()
	update_integrity(initial_integrity)

/obj/structure/blob/normal/scannerreport()
	if(atom_integrity <= 15)
		return "Currently weak to brute damage."
	return "N/A"

/obj/structure/blob/normal/update_name()
	. = ..()
	name = "[(atom_integrity <= 15) ? "fragile " : (blob_team ? null : "dead ")][initial(name)]"

/obj/structure/blob/normal/update_desc()
	. = ..()
	if(atom_integrity <= 15)
		desc = "A thin lattice of slightly twitching tendrils."
	else if(blob_team)
		desc = "A thick wall of writhing tendrils."
	else
		desc = "A thick wall of lifeless tendrils."

/obj/structure/blob/normal/update_icon_state()
	icon_state = "blob[(atom_integrity <= 15) ? "_damaged" : null]"

	/// - [] TODO: Move this elsewhere
	if(atom_integrity <= 15)
		brute_resist = BLOB_BRUTE_RESIST
	else if (blob_team)
		brute_resist = BLOB_BRUTE_RESIST * 0.5
	else
		brute_resist = BLOB_BRUTE_RESIST * 0.5
	return ..()
