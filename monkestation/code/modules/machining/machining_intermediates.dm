//parent
/obj/item/machining_intermediates
	desc = "you shouldn't see this, yell at the fucking coders"
	icon = 'monkestation/icons/obj/machining_intermediates.dmi'

/obj/item/stack/machining_intermediates
	name = "root parent" // fuck off linters
	singular_name = "parent"
	desc = "you shouldn't see this, yell at the fucking coders"
	icon = 'monkestation/icons/obj/machining_intermediates.dmi'
	novariants = FALSE
	merge_type = /obj/item/stack/machining_intermediates

//basic items
/obj/item/machining_intermediates/axehead
	name = "axehead"
	desc = "A sharp axehead, used for cutting and chopping."
	icon_state = "axehead"
	force = 10
	attack_verb_continuous = list("attacks", "tears", "lacerates", "cuts")
	attack_verb_simple = list("attack", "tear", "lacerate", "cut")

/obj/item/machining_intermediates/firearm_bolt
	name = "firearm bolt"
	desc = "A bolt for a firearm, used to chamber rounds onto the firing mechanism."
	icon_state = "firearm_bolt"

/obj/item/machining_intermediates/dye
	name = "dye"
	desc = "bottles of dye, used for coloring various items."
	icon_state = "dye"

/obj/item/machining_intermediates/firearm_hammer
	name = "firearm hammer"
	desc = "A hammer for a firearm, used to strike the firing pin."
	icon_state = "firearmhammer"

/obj/item/machining_intermediates/hardarmor
	name = "hard armor plate"
	desc = "A hard armor plate, used for reinforcing armor."
	icon_state = "hardarmor"

/obj/item/machining_intermediates/softarmor
	name = "soft armor plate"
	desc = "A soft armor plate, used for reinforcing armor."
	icon_state = "softarmor"

/obj/item/machining_intermediates/insulation
	name = "insulation"
	desc = "Insulation material, used for insulating various items."
	icon_state = "insulation"

/obj/item/machining_intermediates/bullet_large
	name = "large bullet"
	desc = "A large bullet, used for heavy firearms."
	icon_state = "bullet_large"

/obj/item/machining_intermediates/bullet_large_ap
	name = "large armor-piercing bullet"
	desc = "A large armor-piercing bullet, designed to penetrate heavy armor."
	icon_state = "bullet_large_ap"

/obj/item/machining_intermediates/bullet_large_casing
	name = "large bullet casing"
	desc = "A large bullet casing, used for heavy firearms."
	icon_state = "bullet_large_casing"

/obj/item/machining_intermediates/bullet_small
	name = "small bullet"
	desc = "A small bullet, used for light firearms."
	icon_state = "bullet_small"

/obj/item/machining_intermediates/bullet_small_ap
	name = "small armor-piercing bullet"
	desc = "A small armor-piercing bullet, designed to penetrate light armor."
	icon_state = "bullet_small_ap"

/obj/item/machining_intermediates/bullet_small_casing
	name = "small bullet casing"
	desc = "A small bullet casing, used for light firearms."
	icon_state = "bullet_small_casing"

/obj/item/machining_intermediates/lasercavity
	name = "laser cavity"
	desc = "the components inside of a laser, used for focusing and amplifying laser beams."
	icon_state = "lasercavity"

/obj/item/machining_intermediates/lens
	name = "lens"
	desc = "A lens, used for focusing and directing light."
	icon_state = "lens"

/obj/item/machining_intermediates/moltenplastic
	name = "molten plastic"
	desc = "Molten plastic, used for molding and shaping into various items."
	icon_state = "moltenplastic"

/obj/item/machining_intermediates/gunbarrel_pistol
	name = "gun barrel pistol"
	desc = "A gun barrel, used for directing the bullet towards the target."
	icon_state = "gunbarrel_pistol"

/obj/item/machining_intermediates/gunbarrel_rifle
	name = "gun barrel rifle"
	desc = "A gun barrel, used for directing the bullet towards the target."
	icon_state = "gunbarrel_rifle"

/obj/item/machining_intermediates/gunbarrel_smootbore
	name = "gun barrel smoothbore"
	desc = "A smoothbore gun barrel, used for directing the bullet towards the target."
	icon_state = "gunbarrel_smoothbore"

/obj/item/machining_intermediates/slidepistol
	name = "pistol slide"
	desc = "A slide for a pistol, used for chambering rounds and cycling the action."
	icon_state = "pistolslide"

/obj/item/machining_intermediates/handle_polymer
	name = "polymer handle"
	desc = "A polymer handle, used for gripping and holding various items."
	icon_state = "handle_polymer"

/obj/item/machining_intermediates/handle_wood
	name = "wooden handle"
	desc = "A wooden handle, used for gripping and holding various items."
	icon_state = "handle_wood"

/obj/item/machining_intermediates/sewingsupplies
	name = "sewing supplies"
	desc = "A set of sewing supplies, used for stitching and repairing fabric items."
	icon_state = "sewingsupplies"

/obj/item/machining_intermediates/shapedwood
	name = "shaped wood"
	desc = "Wood that has been shaped into a specific form, used for crafting various items."
	icon_state = "shapedwood"

/obj/item/machining_intermediates/smallmotor
	name = "small motor"
	desc = "A small motor, used for powering various machines and devices. Incompatible with standardized stock parts."
	icon_state = "smallmotor"

/obj/item/machining_intermediates/suitsensors
	name = "suit sensors"
	desc = "Sensors designed for suits, used for monitoring and detecting various conditions across facilities."
	icon_state = "suitsensors"

/obj/item/machining_intermediates/trigger
	name = "trigger"
	desc = "A trigger mechanism, used for firing firearms."
	icon_state = "trigger"

/obj/item/machining_intermediates/universalcircuit
	name = "universal circuit"
	desc = "A universal circuit, used for various electronic devices."
	icon_state = "universalcircuit"

/obj/item/machining_intermediates/stock_wood
	name = "stock wood"
	desc = "A stock of wood, loved by the old."
	icon_state = "stock_wood"

/obj/item/machining_intermediates/stock_polymer
	name = "stock polymer"
	desc = "A stock of polymer, sleek and tacticool."
	icon_state = "stock_polymer"

/obj/item/machining_intermediates/crappyring
	name = "crappy ring"
	desc = "A cheap ring, not worth much."
	icon_state = "crappyring"

/obj/item/machining_intermediates/fancyring
	name = "fancy ring"
	desc = "A fancy ring, worth a bit more than a cheap one."
	icon_state = "fancyring"

/obj/item/machining_intermediates/jewelry_t1
	name = "basic Jewelry"
	desc = "Basic jewelry, the bare minimum to propose to someone with."
	icon_state = "jewelry_t1"

/obj/item/machining_intermediates/jewelry_t2
	name = "intricate jewelry"
	desc = "Intricate jewelry, a nice gift for a loved one."
	icon_state = "jewelry_t2"

/obj/item/machining_intermediates/jewelry_t3
	name = "exquisite jewelry"
	desc = "Exquisite jewelry, a perfect gift for a special occasion."
	icon_state = "jewelry_t3"

//stacks
/obj/item/stack/machining_intermediates/steel
	name = "steel"
	singular_name = "steel ingot"
	desc = "A solid block of steel, used in various construction and manufacturing processes."
	icon_state = "sheet-steel"
	merge_type = /obj/item/stack/machining_intermediates/steel

/obj/item/stack/machining_intermediates/hardsteel
	name = "hardsteel"
	singular_name = "hardsteel ingot"
	desc = "A solid block of hardsteel, used in various advanced construction and manufacturing processes."
	icon_state = "sheet-hardsteel"
	merge_type = /obj/item/stack/machining_intermediates/hardsteel

/obj/item/stack/machining_intermediates/screwbolt
	name = "screwbolt"
	singular_name = "screw bolt"
	desc = "A menagerie of screw and bolts, used in various construction and manufacturing processes."
	icon_state = "sheet-screwbolt"
	merge_type = /obj/item/stack/machining_intermediates/screwbolt

/obj/item/stack/machining_intermediates/smallwire
	name = "small wire"
	singular_name = "small wire"
	desc = "A small wire with its insulation stripped, used in various construction and manufacturing processes."
	icon_state = "sheet-smallwire"
	merge_type = /obj/item/stack/machining_intermediates/smallwire
