
/obj/item/disk/tech_disk
	name = "technology disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk0"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass=SMALL_MATERIAL_AMOUNT)
	var/datum/techweb/stored_research

/obj/item/disk/tech_disk/Initialize(mapload)
	. = ..()
	if(!stored_research)
		stored_research = new /datum/techweb/disk
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/item/disk/tech_disk/debug
	name = "\improper CentCom technology disk"
	desc = "A debug item for research"
	custom_materials = null

/obj/item/disk/tech_disk/debug/Initialize(mapload)
	stored_research = SSresearch.admin_tech
	return ..()



/obj/item/disk/design_disk/fss  ///Apparently we don't have a place to collect these, so here will do
	name = "FSS-550 Design Disk"
	desc = "A disk that allows an autolathe to print the FSS-550 and associated ammo."
	icon_state = "datadisk1"

/obj/item/disk/design_disk/fss/Initialize(mapload)
	. = ..()
	blueprints += new /datum/design/fss
	blueprints += new /datum/design/mag_autorifle_fss
	blueprints += new /datum/design/mag_autorifle_fss/ap_mag
	blueprints += new /datum/design/mag_autorifle_fss/ic_mag
	blueprints += new /datum/design/mag_autorifle_fss/rub_mag
	blueprints += new /datum/design/mag_autorifle_fss/salt_mag

