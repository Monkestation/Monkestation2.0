/// The fabled paper plane crossbow and its hardlight paper planes.
/obj/item/paperplane/syndicate/hardlight
	name = "hardlight paper plane"
	desc = "Hard enough to hurt, fickle enough to be impossible to pick up."
	impact_eye_damage_lower = 10
	impact_eye_damage_higher = 10
	delete_on_impact = TRUE
	/// Which color is the paper plane?
	var/list/paper_colors = list(COLOR_CYAN, COLOR_BLUE_LIGHT, COLOR_BLUE)
	alpha = 150 // It's hardlight, it's gotta be see-through.

/obj/item/paperplane/syndicate/hardlight/Initialize(mapload)
	. = ..()
	color = color_hex2color_matrix(pick(paper_colors))
	alpha = initial(alpha) // It's hardlight, it's gotta be see-through.

/obj/item/paperplane/syndicate/hardlight/attack_self(mob/user)
	return

/// Some override that didn't belong anywhere else.

/obj/item/delivery/big
	/// Does this wrapped package contain at least one mob?
	var/contains_mobs = FALSE

// I did this out of sanity, I didn't want to make the clamp code more complex than necessary, and honestly I'm considering taking this upstream, it just feels awkward to PR just that.
/obj/item/bounty_cube
	w_class = WEIGHT_CLASS_SMALL
