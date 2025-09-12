// Fluff objects relating to CraterStation

/obj/item/paper/crumpled/craterstation

/obj/item/paper/crumpled/craterstation/workers_camp
	default_raw_text = "Alright, if you stop by for supplies after the main base is set up; it's southwest. I left a spare set of winter gear in the locker. Make sure to go on the surface, we're not sure what's underground."

/obj/item/paper/crumpled/craterstation/mulebot_lost
	default_raw_text = "One of the whiteouts knocked out the Mulebot sent to keep the worker's camp supplied. We were planning to move them to the bunkhouse inside the base anyway, and they have enough food to last until then, but someone should go and retrieve the bot before it breaks down for good."

/obj/item/paper/crumpled/craterstation/medbay_stasis
	default_raw_text = "Sorry we couldn't finish the stasis unit during fitting-out. We don't have all the boards yet."

/obj/item/paper/crumpled/craterstation/remember_us
	default_raw_text = "Everything's ready. Finally. Command crews, if you read this, remember our labours well. We fought to build this place against the cold, and we won."

/obj/item/paper/crumpled/craterstation/generator_blowout
	default_raw_text = "John noticed some pressure irregularities in the generator's main burn chamber, so we're preparing to reduce power in order to do a maintenance check. Hopefully we'll- *The writing past here is practically unreadable, seemingly affected by some sort of seismic event - or an explosion.*"

/obj/item/paper/crumpled/craterstation/genetics_stew
	default_raw_text = "Make sure the stew stays warm, and when it runs out, replace it. It is best that people who have been freshly-cloned are comfortably accomodated - they're probably having a REALLY bad day, and just going 'get back to work' and throwing their gear at them is a pretty unfriendly experience."

/obj/item/paper/crumpled/craterstation/gorlex_evac
	default_raw_text = "<b>INCOMING ORDER FROM JCSS LONDON:</b><BR><BR>All Gorlex Securities staff assigned to Crater outpost security detail are to relocate to the new security building. The temporary outpost will be demolished shortly."


//custom corpse - Constructor

/obj/effect/mob_spawn/corpse/human/crater_constructor
	name = "Construction Worker"
	outfit = /datum/outfit/constructor

/datum/outfit/constructor
	name = "Frozen Construction Worker (Empty Internals)"
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/rank/engineering/engineer/hazard
	suit = /obj/item/clothing/suit/hooded/wintercoat
	shoes = /obj/item/clothing/shoes/workboots
	neck = /obj/item/flashlight/lantern/rayne //haha frostpunk go brrrrrrrrrrrrrrrr
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/crater_engi
	back = /obj/item/storage/backpack/industrial/frontier_colonist
	l_pocket = /obj/item/pocket_heater/loaded
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double/empty //why do you think they're dead, doofus
	belt = /obj/item/storage/belt/utility/full
	head = /obj/item/clothing/head/hooded/winterhood
	box = /obj/item/storage/box/survival
	mask = /obj/item/clothing/mask/gas/explorer
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/constructor/internals_full
	name = "Craterstation Construction Worker"
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double //for events and testing

/datum/id_trim/crater_engi
	access = list(ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS)
	assignment = "Construction Worker"
	trim_state = "trim_stationengineer"
	department_color = CIRCUIT_COLOR_SUPPLY

/obj/structure/sign/plaques/kiddie/crater_memorial
	name = "Memorial Plaque"
	desc = "A plaque listing the names of those who died building Crater outpost. May their sacrifice forever be rememebered by those who tread its paths."


// dirt but COLD

/turf/open/misc/dirt/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	baseturfs = /turf/open/misc/asteroid/snow/icemoon //sometimes under a roof, other times outside

// terminals and other whatnot

/obj/machinery/computer/terminal/craterstation
	name = "control terminal"
	desc = "A terminal used to monitor certain pieces of equipment."
	tguitheme = "nanotrasen"
	content = list("No connection.")
	upperinfo = "Property of Nanotrasen."

/obj/machinery/computer/terminal/craterstation/ptl_reflector
	name = "PTL reflector control terminal"
	desc = "A terminal used to control the power transmission laser's reflector. Needs to be unlocked by Central Command; and that isn't happening while you're down here."
	tguitheme = "nanotrasen"
	content = list("<center><b>PTL CONTROL SYSTEM</b></center> <BR> Control systems are locked. Please contact Central Command if alteration is required. <BR> <BR> Laser reflector tracking relay node Eta-8, holding 33 degrees L/R and 29 degrees F/B offset.")
	upperinfo = "LASER REFLECTOR MK. 8 REMOTE CONTROL UNIT - RESTRICTED ACCESS"

/obj/machinery/computer/terminal/craterstation/blacklab
	name = "old terminal"
	desc = "An old, frozen up control terminal for some piece of bluespace machinery."
	icon_keyboard = "teleport_key"
	icon_screen = "teleport"
	tguitheme = "nanotrasen"
	content = list("<center><b>BLUESPACE RELOCATOR CONTROLS</b></center> <BR> Teleporter disconnected. Last input shown below: <BR> <BR> SEND OFFSET 2.5M UP 30 M WEST 30 M SOUTH")
	upperinfo = "BLUESPACE TELEPORTATION DEVICE MK. 1 CONTROL SYSTEM"

/obj/machinery/computer/terminal/craterstation/evac_dock_cargo
	name = "logistics terminal"
	desc = "A frozen-up terminal that records manifests of shipping containers."
	tguitheme = "nanotrasen"
	icon_screen = "supply"
	content = list("<center><b>CONTAINER MANIFEST: NO. 6</center></b> <BR> <BR> <b>ORIGIN:</b> JCSS LONDON MATERIALS RESERVE <BR> <b>CLASS:</b> STANDARD (20) KOSMOSLOGISTIKA <BR> <b>CONTENTS:</b> 200x STEEL SHEETS, 100x GLASS SHEETS, 50x REINFORCED GLASS, 50x PLASTEEL, 2x SERVICE STEW TANK <BR> <BR> <b>OWNER:</b> JOHNSON AND CO ARCHITECTURE <BR> <b>DESTINATION:</b> NTO. 13 'CRATER' CONSTRUCTION SITE")
	upperinfo = "Signed in as John Miller // Johnson & Co Architecture - ntOS 3.11"

/obj/machinery/computer/terminal/craterstation/tram_maint
	name = "tram maintenance terminal"
	desc = "A terminal responsible for controlling the maintenance system of the tram."
	tguitheme = "nanotrasen"
	content = list("<center><b>WARNING: SYSTEM LOCKED</b><BR>The tram maintenance system is currently locked. Reason: Tram in active service.</center>")
	upperinfo = "Tram Controller 3.11 - Property of Nanotrasen Corporation"

/obj/machinery/computer/terminal/craterstation/abadoned_warehouse_crane
	name = "cargo crane terminal"
	desc = "A frozen-up terminal that once controlled cargo cranes."
	tguitheme = "nanotrasen"
	icon_screen = "supply"
	content = list("<center><b>FATAL ERROR</center></b> <BR> <BR> <b>WARNING:</b> MOTOR INTEGRITY COMPROMISED. PLEASE CONTACT YOUR NEAREST SERVICE TEAM.")
	upperinfo = "Signed in as ADMIN // Johnson & Co Architecture - ntOS 3.11"

/obj/machinery/computer/terminal/craterstation/cargo_helm
	name = "helm terminal"
	desc = "The helm terminal of the cargo shuttle. Seems to be locked-down."
	tguitheme = "nanotrasen"
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	content = list("<center><b>SYSTEM LOCKED</center></b> <BR> <BR> Due to this vessel's nature as a high-liability automated cargo relay (CentCom direct transport), this console has been locked. Contact Central Command or your nearest Galaxywise technician for an override.")
	upperinfo = "HelmOS 3.11 - Galaxywise Fleetyards - Autopilot Mode"

//fake armour for theatre

/obj/item/clothing/suit/costume/fake_armor
	name = "fake armor vest"
	desc = "A flimsy, cheap replica of an armor vest."
	icon_state = "armoralt"
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back/armorvest
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	allowed = null
	body_parts_covered = CHEST


/obj/item/clothing/head/collectable/swat/nt
	name = "collectable nanotrasen SWAT helmet"
	desc = "A version of the collectable SWAT helmet with Nanotrasen's insignia replacing that of the Syndicate."
	icon_state = "swat"
	inhand_icon_state = "swat_helmet"

//fluff structures

/obj/structure/fluff/launch_silo_hatch
	name = "drone silo hatch"
	desc = "A hatch for the launch silo of a planetary exploration drone bay."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "turretCover"

/obj/structure/fluff/broken_drone_fab
	name = "broken drone shell dispenser"
	desc = "A drone shell dispenser that has, for one reason or another, ceased to function."
	density = TRUE
	icon = 'icons/obj/machines/droneDispenser.dmi'
	icon_state = "off"
