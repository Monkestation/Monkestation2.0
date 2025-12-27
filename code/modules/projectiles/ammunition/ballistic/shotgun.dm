// Shotgun

#define AMMO_MATS_SHOTGUN list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4) // not quite as thick as a half-sheet

#define AMMO_MATS_SHOTGUN_FLECH list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
									/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2)

#define AMMO_MATS_SHOTGUN_HIVE list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
									/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 1,\
									/datum/material/silver = SMALL_MATERIAL_AMOUNT * 1)

#define AMMO_MATS_SHOTGUN_TIDE list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
									/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 1,\
									/datum/material/gold = SMALL_MATERIAL_AMOUNT * 1)

#define AMMO_MATS_SHOTGUN_PLASMA list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
									/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 2)

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "blshell"
	worn_icon_state = "shell"
	caliber = CALIBER_SHOTGUN
	custom_materials = AMMO_MATS_SHOTGUN
	projectile_type = /obj/projectile/bullet/shotgun_slug

/obj/item/ammo_casing/shotgun/executioner
	name = "executioner slug"
	desc = "A 12 gauge lead slug purpose built to annihilate flesh on impact."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/executioner
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/pulverizer
	name = "pulverizer slug"
	desc = "A 12 gauge lead slug purpose built to annihilate bones on impact."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/pulverizer
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "bshell"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2.5)
	projectile_type = /obj/projectile/bullet/shotgun_beanbag

/obj/item/ammo_casing/shotgun/beanbag/blank
	name = "blank shell"
	desc = "A blank shell usually used for training drills."
	projectile_type = null

/obj/item/ammo_casing/shotgun/apds
	name = "armor-piercing slug"
	desc = "A 12-gauge shotgun slug, reloaded with a sabot tungsten penetrator. Armor? What armor!"
	icon_state = "apshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/apds
	can_be_printed = TRUE
	advanced_print_req = TRUE
	custom_materials = AMMO_MATS_SHOTGUN_PLASMA //plastanium -> tungsten approximation

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "A 12 gauge magnesium slug meant for \"setting shit on fire and looking cool while you do it\".\
	<br><br>\
	<i>INCENDIARY: Leaves a trail of fire when shot, sets targets aflame.</i>"
	icon_state = "ishell"
	projectile_type = /obj/projectile/bullet/incendiary/shotgun
	advanced_print_req = TRUE
	custom_materials = AMMO_MATS_SHOTGUN_PLASMA

/obj/item/ammo_casing/shotgun/incendiary/no_trail
	name = "precision incendiary slug"
	desc = "An incendiary-coated shotgun slug, specially treated to only ignite on impact."
	projectile_type = /obj/projectile/bullet/incendiary/shotgun/no_trail


/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot
	pellets = 6 //back to 6
	variance = 25

/obj/item/ammo_casing/shotgun/magnum
	name = "magnum blockshot shell"
	desc = "A 12 gauge shell that fires fewer, larger pellets than buckshot. A favorite of SolFed anti-piracy enforcers, \
		especially against the likes of vox."
	icon_state = "magshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/magnum
	pellets = 4 // Half as many pellets for twice the damage each pellet, same overall damage as buckshot
	variance = 20
	advanced_print_req = TRUE

/obj/item/ammo_casing/shotgun/express
	name = "express pelletshot shell"
	desc = "A 12 gauge shell that fires more and smaller projectiles than buckshot. Considered taboo to speak about \
		openly near teshari, for reasons you would be personally blessed to not know at least some of."
	icon_state = "expshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/express
	pellets = 12 // 1.3x The pellets for 0.6x the damage, same overall damage as buckshot
	variance = 30 // Slightly wider spread than buckshot

/obj/item/ammo_casing/shotgun/flechette
	name = "flechette shell"
	desc = "A 12 gauge flechette shell that specializes in ripping unarmored targets apart."
	icon_state = "fshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/flechette
	pellets = 6 //6 x 6 = 36 Damage Potential
	variance = 25
	custom_materials = AMMO_MATS_SHOTGUN_FLECH
	advanced_print_req = TRUE

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "rshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_rubbershot
	pellets = 6 //monkestation edit
	variance = 25 // 6 pellets for 10 stam and 2 damage each
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2)


/obj/item/ammo_casing/shotgun/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = /obj/projectile/bullet/incendiary/shotgun/dragonsbreath
	pellets = 4
	variance = 35
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_stunslug
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2.5)
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/meteorslug
	name = "meteor slug"
	desc = "A 12 gauge shell rigged with CMC technology which launches a heap of matter with great force when fired.\
	<br><br>\
	<i>METEOR: Fires a meteor-like projectile that knocks back movable objects like people and airlocks.</i>"
	icon_state = "mshell"
	projectile_type = /obj/projectile/bullet/cannonball/meteorslug
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/projectile/beam/pulse/shotgun
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "heshell"
	projectile_type = /obj/projectile/bullet/shotgun_frag12
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/incapacitate
	name = "hornet's nest shell"
	desc = "A 12 gauge shell filled with some kind of material that excels at incapacitating targets. Contains a lot of pellets, \
	sacrificing individual pellet strength for sheer stopping power in what's best described as \"spitting distance\".\
	<br><br>\
	<i>HORNET'S NEST: Fire an overwhelming amount of projectiles in a single shot.</i>"
	icon_state = "bountyshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_incapacitate
	pellets = 20//monkestation edit 12 to 20
	variance = 30 //monkestation edit
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2)
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal split the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/projectile/ion/weak
	pellets = 4
	variance = 35
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/laserslug
	name = "scatter laser shell"
	desc = "An advanced shotgun shell that uses a micro laser to replicate the effects of a scatter laser weapon in a ballistic package."
	icon_state = "lshell"
	projectile_type = /obj/projectile/beam/weak
	pellets = 6
	variance = 35
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "cshell"
	projectile_type = null
	can_be_printed = FALSE


/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 15 units of any chemical."
	icon_state = "cshell"
	projectile_type = /obj/projectile/bullet/dart
	var/reagent_amount = 15

/obj/item/ammo_casing/shotgun/dart/Initialize(mapload)
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "An improved shotgun dart filled with deadly toxins. Can be injected with up to 30 units of any chemical."
	reagent_amount = 30
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/dart/bioterror/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 6)
	reagents.add_reagent(/datum/reagent/toxin/spore, 6)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 6) //;HELP OPS IN MAINT
	reagents.add_reagent(/datum/reagent/toxin/coniine, 6)
	reagents.add_reagent(/datum/reagent/toxin/sodium_thiopental, 6)


/obj/item/ammo_casing/shotgun/beehive
	name = "hornet shell"
	desc = "A less-lethal 12 gauge shell that fires four pellets capable of bouncing off nearly any surface \
		and re-aiming themselves toward the nearest target. They will, however, go for <b>any target</b> nearby."
	icon_state = "cnrshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/beehive
	pellets = 4
	variance = 15
	fire_sound = 'sound/weapons/taser.ogg'
	harmful = FALSE
	custom_materials = AMMO_MATS_SHOTGUN_HIVE
	advanced_print_req = TRUE

/obj/item/ammo_casing/shotgun/antitide
	name = "stardust shell"
	desc = "A highly experimental shell filled with nanite electrodes that will embed themselves in soft targets. The electrodes are charged from kinetic movement which means moving targets will get punished more."
	icon_state = "lasershell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/antitide
	pellets = 8 // 8 * 7 for 56 stamina damage, plus whatever the embedded shells do
	variance = 50
	harmful = FALSE
	fire_sound = 'sound/weapons/taser.ogg'
	custom_materials = AMMO_MATS_SHOTGUN_TIDE
	advanced_print_req = TRUE


/obj/item/ammo_casing/shotgun/trickshot
	name = "trickshot shell"
	desc = "A 12 gauge trickshot shell. Specially made to bounce up to five times!"
	icon = 'monkestation/icons/obj/guns/ammunition.dmi'
	icon_state = "trickshell"
	projectile_type = /obj/projectile/bullet/pellet/trickshot
	can_be_printed = FALSE
	pellets = 6
	variance = 8

/obj/item/ammo_casing/shotgun/uraniumpen
	name = "uranium penetrator"
	desc = "A uranium penetrator. Not radioactive, but capable of punching through walls and objects."
	icon = 'monkestation/icons/obj/guns/ammunition.dmi'
	icon_state = "uraniumpenetrator"
	projectile_type = /obj/projectile/bullet/uraniumpen
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/beeshot
	name = "beeshot"
	desc = "A strange buzzing shell. It sort of resembles a bee."
	icon = 'monkestation/icons/obj/guns/ammunition.dmi'
	icon_state = "beeshot"
	projectile_type = /obj/projectile/bullet/pellet/beeshot
	can_be_printed = FALSE
	pellets = 3
	variance = 5


/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "improvshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_improvised
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2.5)
	pellets = 10
	variance = 25
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/honkshot
	name = "confetti shell"
	desc = "A 12 gauge buckshot shell thats been filled to the brim with confetti, yippie!"
	icon_state = "honkshell"
	projectile_type = /obj/projectile/bullet/honkshot
	pellets = 12
	variance = 35
	fire_sound = 'sound/items/bikehorn.ogg'
	harmful = FALSE


/obj/item/ammo_casing/shotgun/hunter
	name = "hunter slug shell"
	desc = "A 12 gauge slug shell that fires specially designed slugs that deal extra damage to the local planetary fauna"
	icon_state = "huntershell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/hunter


/obj/item/ammo_casing/shotgun/breacher
	name = "breaching slug"
	desc = "A 12 gauge anti-material slug. Great for breaching airlocks and windows, quickly and efficiently."
	icon_state = "breacher"
	projectile_type = /obj/projectile/bullet/shotgun_breaching
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2)


/obj/item/ammo_casing/shotgun/buckshot/spent
	name = "spent buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = null


/obj/item/ammo_casing/shotgun/buckshot/six
	pellets = 36
	variance = 25
	projectile_type = /obj/projectile/bullet/pellet/shotgun_death

/obj/item/ammo_casing/shotgun/buckshot/hundred
	pellets = 600
	variance = 25


// for the mining autoshotgun
/obj/item/ammo_casing/shotgun/hydrakinetic
	name = "Kinetic Hydra Shell"
	desc = "A 20 gauge shell loaded with five pellets, dubbed the Kinetic Hydra Shell! <b> Does NOT fit in any standard shotgun! </b>"
	icon_state = "20gshell"
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	caliber = KINETIC_20G
	pellets = 5
	variance = 7 //very tight spread
	projectile_type = /obj/projectile/bullet/hydrakinetic


// for the mining breakaction

/obj/item/ammo_casing/shotgun/kinetic //for slaying, works on crowds
	name = "Kinetic Magnum Buckshot Shell"
	desc = "A 12 gauge Shell loaded with magnum kinetic projectiles. Penetrates rocky walls and creatures! <b> Does NOT fit in any standard 12 gauge shotgun! </b>"
	icon_state = "shellproto"
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	caliber = MINER_SHOTGUN
	pellets = 5
	variance = 30
	projectile_type = /obj/projectile/plasma/kineticshotgun

/obj/item/ammo_casing/shotgun/kinetic/sniperslug //slugs essentially
	name = "Kinetic .50 BMG"
	desc = "If god did not want us to put 50 BMG in a 12 gauge, he would not have given them similar diameter! A incredibly large 50 BMG round adapted into a kinetic slug. Does not penetrate targets like Magnum Kinetic Buckshot, but still penetrates rock walls. <b> Does NOT fit in any standard 12 gauge shotgun! </b>"
	icon_state = "slugbmg"
	pellets = 1
	variance = 5
	projectile_type = /obj/projectile/plasma/kineticshotgun/sniperslug


/obj/item/ammo_casing/shotgun/kinetic/rockbreaker //for digging!
	name = "Kinetic Rockbreaker Shell"
	desc = "A 12 gauge Shell loaded with dozens of special tiny kinetic rockbreaker pellets, perfect for clearing masses of rocks but no good for killing fauna. <b> Does NOT fit in any standard 12 gauge shotgun! </b>"
	icon_state = "bountyshell"
	caliber = MINER_SHOTGUN
	pellets = 10
	variance = 120
	projectile_type = /obj/projectile/plasma/kineticshotgun/rockbreaker

