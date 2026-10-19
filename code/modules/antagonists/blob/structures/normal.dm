/obj/structure/blob/normal
	name = "normal blob"
	icon_state = "blob"
	light_outer_range = 0
	point_cost = BLOB_EXPAND_COST
	max_integrity = BLOB_REGULAR_MAX_HP
	health_regen = BLOB_REGULAR_HP_REGEN
	brute_resist = BLOB_BRUTE_RESIST * 0.5

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

/obj/structure/blob/normal/on_integrity_update(new_value)
	if(atom_integrity <= 15)
		brute_resist = BLOB_BRUTE_RESIST
	else
		brute_resist = BLOB_BRUTE_RESIST * 0.5

/obj/structure/blob/normal/update_icon_state()
	icon_state = "blob[(atom_integrity <= 15) ? "_damaged" : null]"
	return ..()

/obj/structure/blob/normal/handle_ctrl_click(mob/eye/blob/overmind)
	if(overmind.buy(BLOB_UPGRADE_STRONG_COST))
		var/obj/structure/blob/shield_blob = change_to(/obj/structure/blob/shield, overmind.antag_team)
		shield_blob.balloon_alert(overmind, "upgraded to [shield_blob.name]!")
