// Plushies
/obj/item/toy/plush/admin
	name = "admin plushie"
	desc = "if you're seeing this there's an issue."
	icon = 'icons/obj/admin_plushies.dmi'
	icon_state = ""
	/// A string of text that is optionaly added to the objects desc, it SHOULD be the admin's CKEY.
	var/adminCKey = null
	// Whether or not to append (A member of our beloved admin team) to the end of the description
	var/append_note = TRUE

/obj/item/toy/plush/admin/Initialize(mapload)
	. = ..()
	if(append_note)
		if(adminCKey)
			desc = "[desc]" + " " + "(A member of our beloved admin team- ''[adminCKey]'')"
		else
			desc = "[desc]" + " " + "(A member of our beloved admin team)"

/obj/item/toy/plush/admin/wolfy
	name = "Wolfy"
	desc = "It's Wolfy! You feel like she's staring at you."
	icon_state = "wolfy"
	gender = FEMALE

/datum/loadout_item/plushies/wolfy
	name = "Wolfy Plush"
	item_path = /obj/item/toy/plush/admin/wolfy

/datum/store_item/plushies/wolfy
	name = "Wolfy Plush"
	item_path = /obj/item/toy/plush/admin/wolfy
	item_cost = 7500

/obj/item/toy/plush/admin/tendsthefire
	name = "tends-the-fire"
	desc = "It's Tends-The-Fire!, what a lovable little lizard!"
	icon_state = "tendsthefire"
	gender = MALE

/datum/loadout_item/plushies/tendsthefire
	name = "Tends-The-Fire Plush"
	item_path = /obj/item/toy/plush/admin/tendsthefire

/datum/store_item/plushies/tendsthefire
	name = "Tends-The-Fire Plush"
	item_path = /obj/item/toy/plush/admin/tendsthefire
	item_cost = 7500
