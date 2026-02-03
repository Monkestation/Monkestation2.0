///Revolver rounds

/obj/item/ammo_box/a357
	name = "speed loader (.357)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	caliber = CALIBER_357
	multiple_sprites = AMMO_BOX_PER_BULLET
	item_flags = NO_MAT_REDEMPTION
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/a357/match
	name = "speed loader (.357 Match)"
	desc = "Designed to quickly reload revolvers. These rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/a357/match


/obj/item/ammo_box/c38
	name = "speed loader (.38)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	caliber = CALIBER_38
	multiple_sprites = AMMO_BOX_PER_BULLET
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*10)
	w_class = WEIGHT_CLASS_SMALL
//	ammo_band_icon = "+38_ammo_band" //monkestation temp removal, needs a PR
//	ammo_band_color = null //temp

/obj/item/ammo_box/a500
	name = "speed loader (.500)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a500
	max_ammo = 6
	caliber = CALIBER_500
	multiple_sprites = AMMO_BOX_PER_BULLET
	item_flags = NO_MAT_REDEMPTION
	w_class = WEIGHT_CLASS_SMALL


/obj/item/ammo_box/c38/trac
	name = "speed loader (.38 TRAC)"
	desc = "Designed to quickly reload revolvers. TRAC bullets embed a short-lived tracking implant within the target's body."
	ammo_type = /obj/item/ammo_casing/c38/trac

/obj/item/ammo_box/c38/match
	name = "speed loader (.38 Match)"
	desc = "Designed to quickly reload revolvers. These rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match

/obj/item/ammo_box/c38/match/bouncy
	name = "speed loader (.38 Rubber)"
	desc = "Designed to quickly reload revolvers. These rounds are incredibly bouncy and MOSTLY nonlethal, making them great to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy

/obj/item/ammo_box/c38/dumdum
	name = "speed loader (.38 DumDum)"
	desc = "Designed to quickly reload revolvers. These rounds expand on impact, allowing them to shred the target and cause massive bleeding. Very weak against armor and distant targets."
	ammo_type = /obj/item/ammo_casing/c38/dumdum

/obj/item/ammo_box/c38/hotshot
	name = "speed loader (.38 Hot Shot)"
	desc = "Designed to quickly reload revolvers. Hot Shot bullets contain an incendiary payload."
	ammo_type = /obj/item/ammo_casing/c38/hotshot

/obj/item/ammo_box/c38/iceblox
	name = "speed loader (.38 Iceblox)"
	desc = "Designed to quickly reload revolvers. Iceblox bullets contain a cryogenic payload."
	ammo_type = /obj/item/ammo_casing/c38/iceblox


/obj/item/ammo_box/govmining
	name = "speed loader (.45-70 Kinetic)"
	desc = "A six round speedloader carrying an absolute beast of a round for the 'Duster' Revolver."
	icon_state = "4570loader"
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /obj/item/ammo_casing/govmining
	max_ammo = 6
	caliber = CALIBER_GOV_MINING
	multiple_sprites = AMMO_BOX_PER_BULLET


/obj/item/ammo_box/g45l
	name = "ammo box (.45 Long Lethal)"
	desc = "This box contains .45 Long lethal cartridges."
	ammo_type = /obj/item/ammo_casing/g45l
	icon_state = "45box"
	max_ammo = 24

/obj/item/ammo_box/g45l/rubber
	name = "ammo box (.45 Long Rubber)"
	desc = "Brought to you at great expense,this box contains .45 Long rubber cartridges."
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/g45l/rubber
	max_ammo = 24


///Pistol rounds

/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/c9mm/ap
	name = "ammo box (9mm AP)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/c9mm/hp
	name = "ammo box (9mm HP)"
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/c9mm/fire
	name = "ammo box (9mm incendiary)"
	ammo_type = /obj/item/ammo_casing/c9mm/fire


/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 20

/obj/item/ammo_box/c10mm/ap
	name = "ammo box (10mm AP)"
	ammo_type = /obj/item/ammo_casing/c10mm/ap
	max_ammo = 20

/obj/item/ammo_box/c10mm/hp
	name = "ammo box (10mm HP)"
	ammo_type = /obj/item/ammo_casing/c10mm/hp
	max_ammo = 20

/obj/item/ammo_box/c10mm/fire
	name = "ammo box (10mm incendiary)"
	ammo_type = /obj/item/ammo_casing/c10mm/fire
	max_ammo = 20


/obj/item/ammo_box/c35sol
	name = "ammo box (.35 Sol Short lethal)"
	desc = "A box of .35 Sol Short pistol rounds, holds twenty-four rounds."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "35box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_SOL35SHORT
	ammo_type = /obj/item/ammo_casing/c35sol
	max_ammo = 24

/obj/item/ammo_box/c35sol/incapacitator
	name = "ammo box (.35 Sol Short incapacitator)"
	desc = "A box of .35 Sol Short pistol rounds, holds twenty-four rounds. The blue stripe indicates this should hold less-lethal ammunition."
	icon_state = "35box_disabler"
	ammo_type = /obj/item/ammo_casing/c35sol/incapacitator

/obj/item/ammo_box/c35sol/ripper
	name = "ammo box (.35 Sol Short ripper)"
	desc = "A box of .35 Sol Short pistol rounds, holds twenty-four rounds. The purple stripe indicates this should hold hollowpoint-like ammunition."
	icon_state = "35box_shrapnel"
	ammo_type = /obj/item/ammo_casing/c35sol/ripper

/obj/item/ammo_box/c35sol/pierce
	name = "ammo box (.35 Sol Short armor piercing)"
	desc = "A box of .35 Sol Short pistol rounds, holds twenty-four rounds."
	ammo_type = /obj/item/ammo_casing/c35sol/pierce


/obj/item/ammo_box/c585trappiste
	name = "ammo box (.585 Trappiste lethal)"
	desc = "A box of .585 Trappiste pistol rounds, holds thirty-two cartridges."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/ammo.dmi'
	icon_state = "585box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_585TRAPPISTE
	ammo_type = /obj/item/ammo_casing/c585trappiste
	max_ammo = 32

/obj/item/ammo_box/c585trappiste/incapacitator
	name = "ammo box (.585 Trappiste flathead)"
	desc = "A box of .585 Trappiste pistol rounds, holds thirty-two cartridges. The blue stripe indicates that it should hold less lethal rounds."
	icon_state = "585box_disabler"
	ammo_type = /obj/item/ammo_casing/c585trappiste/incapacitator

/obj/item/ammo_box/c585trappiste/hollowpoint
	name = "ammo box (.585 Trappiste hollowhead)"
	desc = "A box of .585 Trappiste pistol rounds, holds 32 cartridges. The purple stripe indicates that it should hold hollowpoint-like rounds."
	icon_state = "585box_shrapnel"
	ammo_type = /obj/item/ammo_casing/c585trappiste/hollowpoint


/obj/item/ammo_box/c35
	name = "ammunition packet (.35 Auto)"
	desc = "A shiny box containing .35 Auto ammo for the \"Paco\" handgun."
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "35_ammobox"
	ammo_type = /obj/item/ammo_casing/c35
	max_ammo = 40
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/c35/rubber
	name = "ammunition packet (.35 Auto Rubber)"
	desc = "A shiny box containing .35 Auto rubber ammo for the \"Paco\" handgun."
	icon_state = "35r_ammobox"
	ammo_type = /obj/item/ammo_casing/c35/rubber
	max_ammo = 40


///SMG rounds

/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/c45/rubber
	name = "ammo box (.45 rubber"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20


/obj/item/ammo_box/c46x30mm
	name = "ammo box (4.6x30mm)"
	icon = 'monkestation/code/modules/blueshift/icons/ammo.dmi'
	icon_state = "ammo_46"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 20

/obj/item/ammo_box/c46x30mm/ap
	name = "ammo box (4.6x30mm AP)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap


/obj/item/ammo_box/c27_54cesarzowa
	name = "ammo box (.27-54 Cesarzowa piercing)"
	desc = "A box of .27-54 Cesarzowa piercing pistol rounds, holds eighteen cartridges."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "27-54cesarzowa_box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_CESARZOWA
	ammo_type = /obj/item/ammo_casing/c27_54cesarzowa
	max_ammo = 18

/obj/item/ammo_box/c27_54cesarzowa/rubber
	name = "ammo box (.27-54 Cesarzowa rubber)"
	desc = "A box of .27-54 Cesarzowa rubber pistol rounds, holds eighteen cartridges."
	icon_state = "27-54cesarzowa_box_rubber"
	ammo_type = /obj/item/ammo_casing/c27_54cesarzowa/rubber


///Grenades

/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/a40mm/rubber
	name = "ammo box (40mm rubber slug)"
	ammo_type = /obj/item/ammo_casing/a40mm/rubber


/obj/item/ammo_box/c980grenade
	name = "ammo box (.980 Tydhouer practice)"
	desc = "A box of four .980 Tydhouer practice grenades. Instructions on the box indicate these are dummy practice rounds that will disintegrate into sparks on detonation. Neat!"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "980box_solid"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_980TYDHOUER
	ammo_type = /obj/item/ammo_casing/c980grenade
	max_ammo = 4

/obj/item/ammo_box/c980grenade/smoke
	name = "ammo box (.980 Tydhouer smoke)"
	desc = "A box of four .980 Tydhouer smoke grenades. Instructions on the box indicate these are smoke rounds that will make a small cloud of laser-dampening smoke on detonation."
	icon_state = "980box_smoke"
	ammo_type = /obj/item/ammo_casing/c980grenade/smoke

/obj/item/ammo_box/c980grenade/shrapnel
	name = "ammo box (.980 Tydhouer shrapnel)"
	desc = "A box of four .980 Tydhouer shrapnel grenades. Instructions on the box indicate these are shrapnel rounds. Its also covered in hazard signs, odd."
	icon_state = "980box_explosive"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel

/obj/item/ammo_box/c980grenade/shrapnel/phosphor
	name = "ammo box (.980 Tydhouer phosphor)"
	desc = "A box of four .980 Tydhouer phosphor grenades. Instructions on the box indicate these are incendiary explosive rounds. Its also covered in hazard signs, odd."
	icon_state = "980box_gas_alternate"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor

/obj/item/ammo_box/c980grenade/riot
	name = "ammo box (.980 Tydhouer tear gas)"
	desc = "A box of four .980 Tydhouer tear gas grenades. Instructions on the box indicate these are smoke rounds that will make a small cloud of laser-dampening smoke on detonation."
	icon_state = "980box_gas"
	ammo_type = /obj/item/ammo_casing/c980grenade/riot


///LMG rounds

/obj/item/ammo_box/a762/kinetic
	name = "stripper clip (Kinetic 7.62mm)"
	desc = "A stripper clip with Kinetic 7.62mm rounds."
	icon_state = "762kinetic"
	ammo_type = /obj/item/ammo_casing/a762/kinetic
	caliber = CALIBER_A762_KINETIC

/obj/item/ammo_box/a762/kinetic/big
	name = "rapid reloader (Kinetic 7.62mm)"
	desc = "A hefty reloader for 'Hellhound' LMG that can load up to fifty rounds at once, and even be refilled. Might be better to hang onto this once its empty.."
	icon_state = "a762"
	max_ammo = 50
	ammo_type = /obj/item/ammo_casing/a762/kinetic
	multiple_sprites = AMMO_BOX_ONE_SPRITE



///Rifle rounds

/obj/item/ammo_box/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip."
	icon_state = "762"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	caliber = CALIBER_A762
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/a762/surplus
	name = "stripper clip (7.62mm Surplus)"
	ammo_type = /obj/item/ammo_casing/a762/surplus

/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mmR)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14


/obj/item/ammo_box/c40sol
	name = "ammo box (.40 Sol Long lethal)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "40box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_SOL40LONG
	ammo_type = /obj/item/ammo_casing/c40sol
	max_ammo = 30

/obj/item/ammo_box/c40sol/fragmentation
	name = "ammo box (.40 Sol Long fragmentation)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets. The blue stripe indicates this should hold less lethal ammunition."
	icon_state = "40box_disabler"
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation

/obj/item/ammo_box/c40sol/pierce
	name = "ammo box (.40 Sol Long match)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets. The yellow stripe indicates this should hold high performance ammuniton."
	icon_state = "40box_pierce"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce

/obj/item/ammo_box/c40sol/incendiary
	name = "ammo box (.40 Sol Long incendiary)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets. The orange stripe indicates this should hold incendiary ammunition."
	icon_state = "40box_flame"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary


/obj/item/ammo_box/c310_cargo_box
	name = "ammo box (.310 Strilka lethal)"
	desc = "A box of .310 Strilka lethal rifle rounds, holds ten cartridges."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "310_box"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_STRILKA310
	ammo_type = /obj/item/ammo_casing/strilka310
	max_ammo = 10

/obj/item/ammo_box/c310_cargo_box/rubber
	name = "ammo box (.310 Strilka rubber)"
	desc = "A box of .310 Strilka rubber rifle rounds, holds ten cartridges."
	icon_state = "310_box_rubber"
	ammo_type = /obj/item/ammo_casing/strilka310/rubber

/obj/item/ammo_box/c310_cargo_box/piercing
	name = "ammo box (.310 Strilka piercing)"
	desc = "A box of .310 Strilka piercing rifle rounds, holds ten cartridges."
	icon_state = "310_box_ap"
	ammo_type = /obj/item/ammo_casing/strilka310/ap


/obj/item/ammo_box/strilka310
	name = "stripper clip (.310 Strilka)"
	desc = "A stripper clip."
	icon_state = "310_strip"
	ammo_type = /obj/item/ammo_casing/strilka310
	max_ammo = 5
	caliber = CALIBER_STRILKA310
	multiple_sprites = AMMO_BOX_PER_BULLET
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/strilka310/surplus
	name = "stripper clip (.310 Surplus)"
	ammo_type = /obj/item/ammo_casing/strilka310/surplus


///MISC

/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	icon = 'icons/obj/weapons/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*25)


///SHOTGUN FANCY AMMO BOXES WITH INTEGRATED LOADER!!

/obj/item/ammo_box/advanced/s12gauge
	name = "slug ammo box"
	desc = "A box of slug shells. Large, singular shots that pack a punch."
	icon = 'monkestation/code/modules/blueshift/icons/shotbox.dmi'
	icon_state = "slug"
	ammo_type = /obj/item/ammo_casing/shotgun
	max_ammo = 16
	multitype = FALSE // if you enable this and set the box's caliber var to CALIBER_SHOTGUN (at time of writing, "shotgun"), then you can have the fabled any-ammo shellbox
	var/old_ammo_count
	//var for how long it takes to reload from this ammo box
	var/reload_delay = 1 SECONDS

/obj/item/ammo_box/advanced/s12gauge/pre_attack(atom/target, mob/living/user)
	if(DOING_INTERACTION(user, "doafter_reloading"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(length(stored_ammo) == 0 && !istype(target, /obj/item/ammo_casing))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(istype(target, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/gun = target
		if(!(istype(target, /obj/item/gun/ballistic/revolver)))
			if(length(gun.magazine.stored_ammo) >= gun.magazine.max_ammo)
				return COMPONENT_CANCEL_ATTACK_CHAIN
		else
			var/live_ammo = gun.magazine.ammo_count(FALSE)
			if(live_ammo >= length(gun.magazine.stored_ammo))
				return COMPONENT_CANCEL_ATTACK_CHAIN
		to_chat(user, span_notice("You start unloading a shell from the [src]..."))
		old_ammo_count = length(stored_ammo)
		if(!do_after(user, reload_delay, src, timed_action_flags = IGNORE_USER_LOC_CHANGE, interaction_key = "doafter_reloading"))
			return COMPONENT_CANCEL_ATTACK_CHAIN
		to_chat(user, span_notice("You load a shell into the [gun]."))

/obj/item/ammo_box/advanced/s12gauge/afterattack(atom/target, mob/user, proximity_flag, click_parameters) //why did i do this, i guess it's funny?
	. = ..()
	if(istype(target, /obj/item/gun/ballistic))
		if(old_ammo_count == length(stored_ammo))
			to_chat(user, span_notice("You pause for a moment, something isn't right..."))


/obj/item/ammo_box/advanced/s12gauge/buckshot
	name = "buckshot ammo box"
	desc = "A box of buckshot shells. These have a modest spread of weaker projectiles."
	icon_state = "buckshot"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/rubber
	name = "rubbershot ammo box"
	desc = "A box of rubbershot shells. These have a modest spread of weaker, less-lethal projectiles."
	icon_state = "rubber"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/bean
	name = "beanbag Slug ammo box"
	desc = "A box of beanbag slug shells. These are large, singular beanbags that pack a less-lethal punch."
	icon_state = "bean"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/magnum
	name = "magnum blockshot ammo box"
	desc = "A box of magnum blockshot shells. The size of the pellet is larger in diameter than the typical shot, but there are less of them inside each shell."
	icon_state = "magnum"
	ammo_type = /obj/item/ammo_casing/shotgun/magnum
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/express
	name = "express pelletshot ammo box"
	desc = "A box of express pelletshot shells. The size of the pellet is smaller in diameter than the typical shot, but there are more of them inside each shell."
	icon_state = "express"
	ammo_type = /obj/item/ammo_casing/shotgun/express
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/hunter
	name = "hunter slug ammo box"
	desc = "A box of hunter slug shells. These shotgun slugs excel at damaging the local fauna."
	icon_state = "hunter"
	ammo_type = /obj/item/ammo_casing/shotgun/hunter
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/apds
	name = "AP sabot-slug ammo box"
	desc = "A box of tungsten sabot-slugs. A vastly higher velocity combined with greater sectional density renders most armor irrelevant."
	icon_state = "apshell"
	ammo_type = /obj/item/ammo_casing/shotgun/apds
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/flechette
	name = "flechette ammo box"
	desc = "A box of flechette shells. Each shell contains a small group of tumbling blades that excel at causing terrible wounds."
	icon_state = "flechette"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/beehive
	name = "hornet's nest ammo box"
	desc = "A box of hornet's nest shells. These are less-lethal shells that will bounce off walls and direct themselves toward nearby targets."
	icon_state = "beehive"
	ammo_type = /obj/item/ammo_casing/shotgun/beehive
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/antitide
	name = "stardust ammo box"
	desc = "A box of express pelletshot shells. These are less-lethal and will embed in targets, causing pain on movement."
	icon_state = "antitide"
	ammo_type = /obj/item/ammo_casing/shotgun/antitide
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/incendiary
	name = "incendiary Slug ammo box"
	desc = "A box of incendiary slug shells. These will ignite targets and leave a trail of fire behind them."
	icon_state = "incendiary"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary
	max_ammo = 16

/obj/item/ammo_box/advanced/s12gauge/honkshot
	name = "confetti Honkshot ammo box"
	desc = "A box of 35 Honkshot TM shells."
	icon_state = "honk"
	ammo_type = /obj/item/ammo_casing/shotgun/honkshot
	max_ammo = 40
	reload_delay = 0.1 SECONDS


// GRENADE BOXES!
#define A40MM_GRENADE_INBOX_SPRITE_WIDTH 3

/obj/item/storage/fancy/a40mm_box
	name = "40mm grenade box"
	desc = "A metal box designed to hold 40mm grenades."
	icon =  'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_box"
	base_icon_state = "40mm_box"
	spawn_type = /obj/item/ammo_casing/a40mm
	spawn_count = 4
	open_status = FALSE
	appearance_flags = KEEP_TOGETHER|LONG_GLIDE
	contents_tag = "grenade"
	foldable_result = null
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5)
	flags_1 = CONDUCT_1
	force = 8
	throwforce = 12
	throw_speed = 2
	throw_range = 7
	resistance_flags = null

	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'

/obj/item/storage/fancy/a40mm_box/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/ammo_casing/a40mm))

/obj/item/storage/fancy/a40mm_box/attack_self(mob/user)
	..()
	if(open_status == FANCY_CONTAINER_OPEN)
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/storage/fancy/a40mm_box/PopulateContents()
	. = ..()
	update_appearance()

/obj/item/storage/fancy/a40mm_box/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][open_status ? "_open" : null]"

/obj/item/storage/fancy/a40mm_box/update_overlays()
	. = ..()
	if(!open_status)
		return

	var/grenades = 0
	for(var/_grenade in contents)
		var/obj/item/ammo_casing/a40mm/grenade = _grenade
		if (!istype(grenade))
			continue
		. += image(icon = initial(icon), icon_state = (initial(grenade.icon_state) + "_inbox"), pixel_x = grenades * A40MM_GRENADE_INBOX_SPRITE_WIDTH)
		grenades += 1

#undef A40MM_GRENADE_INBOX_SPRITE_WIDTH

/obj/item/storage/fancy/a40mm_box/rubber
	spawn_type = /obj/item/ammo_casing/a40mm/rubber

/obj/item/storage/fancy/a40mm_box/weak
	spawn_type = /obj/item/ammo_casing/a40mm/weak

/obj/item/storage/fancy/a40mm_box/incendiary
	spawn_type = /obj/item/ammo_casing/a40mm/incendiary

/obj/item/storage/fancy/a40mm_box/smoke
	spawn_type = /obj/item/ammo_casing/a40mm/smoke

/obj/item/storage/fancy/a40mm_box/stun
	spawn_type = /obj/item/ammo_casing/a40mm/stun

/obj/item/storage/fancy/a40mm_box/hedp
	spawn_type = /obj/item/ammo_casing/a40mm/hedp

/obj/item/storage/fancy/a40mm_box/frag
	spawn_type = /obj/item/ammo_casing/a40mm/frag
