/obj/structure/closet/syndicate/byos_supplies
	name = "contruction supply closet"
	desc = "A closet containing all the supplies for building a station."

/obj/structure/closet/syndicate/byos_supplies/populate_contents_immediate()
	. = ..()
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/pipe_dispenser(src)

/obj/structure/closet/syndicate/byos_supplies/PopulateContents()
	. = ..()
	new /obj/item/stack/sheet/iron/fifty(src)
	new /obj/item/stack/sheet/iron/fifty(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/rods/fifty(src)
	new /obj/item/stack/sheet/rglass/fifty(src)
	new /obj/item/storage/belt/utility/full(src)
	new /obj/item/storage/belt/utility/full/engi(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/rcd_ammo/large(src)
	new /obj/item/rcd_ammo/large(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/flashlight(src)
	new /obj/item/flashlight(src)
	new /obj/item/clothing/suit/space/hardsuit/engine(src)
	new /obj/item/mod/control/pre_equipped/engineering(src)
	new /obj/item/clothing/shoes/magboots(src)
	new /obj/item/rcl/pre_loaded(src)

/obj/structure/closet/syndicate/byos_supplies/heavy
	desc = "A closet containing all the supplies for building a station. This one seems to have more supplies then normal."

/obj/structure/closet/syndicate/byos_supplies/heavy/populate_contents_immediate()
	. = ..()
	new /obj/item/areaeditor/blueprints(src)

/obj/structure/closet/syndicate/byos_supplies/heavy/PopulateContents()
	. = ..()
	new /obj/item/mod/control/pre_equipped/advanced(src)
	new /obj/item/construction/rcd/combat(src)
	new /obj/item/storage/belt/utility/chief/full(src)
	new /obj/item/stack/sheet/plasteel/fifty(src)
	new /obj/item/stack/sheet/plasteel/twenty(src)

//the syndie supplies are better as they will have a lower crew count
/obj/structure/closet/syndicate/byos_supplies_syndicate
	name = "\improper Syndicate contruction supply closet"
	desc = "A closet containing all the supplies for building a Syndicate station."

/obj/structure/closet/syndicate/byos_supplies_syndicate/populate_contents_immediate()
	. = ..()
	new /obj/item/pipe_dispenser(src)

/obj/structure/closet/syndicate/byos_supplies_syndicate/PopulateContents()
	. = ..()
	new /obj/item/stack/sheet/plastitaniumglass/fifty(src)
	new /obj/item/stack/sheet/plastitaniumglass/fifty(src)
	new /obj/item/stack/sheet/mineral/plastitanium/fifty(src)
	new /obj/item/stack/sheet/mineral/plastitanium/fifty(src)
	new /obj/item/stack/sheet/iron/fifty(src)
	new /obj/item/stack/rods/fifty(src)
	new /obj/item/clothing/head/helmet/space/syndicate/black/engie(src)
	new /obj/item/clothing/head/helmet/space/syndicate/black/engie(src)
	new /obj/item/clothing/suit/space/syndicate/black/engie(src)
	new /obj/item/clothing/suit/space/syndicate/black/engie(src)
	new /obj/item/construction/rcd/combat(src)
	new /obj/item/construction/rcd/combat(src)
	new /obj/item/rcd_ammo/large(src)
	new /obj/item/rcd_ammo/large(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/storage/belt/utility/full/powertools(src)
	new /obj/item/storage/belt/utility/full/powertools(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/clothing/glasses/meson/night(src)
	new /obj/item/clothing/glasses/meson/night(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/clothing/shoes/magboots/syndie(src)
	new /obj/item/rcl/pre_loaded(src)
