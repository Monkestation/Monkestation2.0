/obj/item/gun/ballistic/automatic/pistol
	name = "\improper Makarov pistol"
	desc = "A small, easily concealable 9mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m9mm
	can_suppress = TRUE
	burst_size = 1
	fire_delay = 0
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = 'sound/weapons/gun/pistol/shot.ogg'
	dry_fire_sound = 'sound/weapons/gun/pistol/dry_fire.ogg'
	suppressed_sound = 'sound/weapons/gun/pistol/shot_suppressed.ogg'
	load_sound = 'sound/weapons/gun/pistol/mag_insert.ogg'
	load_empty_sound = 'sound/weapons/gun/pistol/mag_insert.ogg'
	eject_sound = 'sound/weapons/gun/pistol/mag_release.ogg'
	eject_empty_sound = 'sound/weapons/gun/pistol/mag_release.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack_small.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/lock_small.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/drop_small.ogg'
	fire_sound_volume = 90
	bolt_wording = "slide"
	suppressor_x_offset = 10
	suppressor_y_offset = -1
	gun_flags = GUN_SMOKE_PARTICLES

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/fire_mag
	accepted_magazine_type = /obj/item/ammo_box/magazine/m9mm/fire

/obj/item/gun/ballistic/automatic/pistol/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/pistol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/automatic/pistol/clandestine
	name = "\improper Ansem pistol"
	desc = "The spiritual successor of the Makarov, or maybe someone just dropped their gun in a bucket of paint. The gun is chambered in 10mm."
	icon_state = "pistol_evil"
	accepted_magazine_type = /obj/item/ammo_box/magazine/m10mm
	empty_indicator = TRUE
	suppressor_x_offset = 12

/obj/item/gun/ballistic/automatic/pistol/clandestine/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE
	fire_sound = 'sound/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
	accepted_magazine_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE
	fire_sound = 'sound/weapons/gun/rifle/shot.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'

/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	desc = "A gold plated Desert Eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	inhand_icon_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	inhand_icon_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/regal
	name = "\improper Regal Condor"
	desc = "Unlike the Desert Eagle, this weapon seems to utilize some kind of advance internal stabilization system to significantly \
		reduce felt recoil and substantially increases overall accuracy, though at the cost of using a smaller caliber. This modification does \
		allow it to fire in a 2-round burst. Uses 10mm ammo."
	icon_state = "reagle"
	inhand_icon_state = "deagleg"
	burst_size = 2
	fire_delay = 1
	spread = 10
	projectile_damage_multiplier = 1.25
	accepted_magazine_type = /obj/item/ammo_box/magazine/r10mm
	actions_types = list(/datum/action/item_action/toggle_firemode)
	obj_flags = UNIQUE_RENAME // if you did the sidequest, you get the customization

/obj/item/gun/ballistic/automatic/pistol/deagle/regal/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/aps
	name = "\improper Stechkin APS machine pistol"
	desc = "An old Soviet machine pistol. It fires quickly, but kicks like a mule. Uses 9mm ammo. Has a threaded barrel for suppressors."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m9mm_aps
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 1
	spread = 10
	actions_types = list(/datum/action/item_action/toggle_firemode)
	suppressor_x_offset = 6

/obj/item/gun/ballistic/automatic/pistol/aps/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/automatic/pistol/stickman
	name = "flat gun"
	desc = "A 2 dimensional gun.. what?"
	icon_state = "flatgun"
	mag_display = FALSE
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/automatic/pistol/stickman/equipped(mob/user, slot)
	..()
	to_chat(user, span_notice("As you try to manipulate [src], it slips out of your possession.."))
	if(prob(50))
		to_chat(user, span_notice("..and vanishes from your vision! Where the hell did it go?"))
		qdel(src)
		user.update_icons()
	else
		to_chat(user, span_notice("..and falls into view. Whew, that was a close one."))
		user.dropItemToGround(src)

/**
 * Weak 1911 for syndicate chimps. It comes in a 4 TC kit.
 * 15 damage every.. second? 7 shots to kill. Not fast.
 */
/obj/item/gun/ballistic/automatic/pistol/m1911/chimpgun
	name = "\improper CH1M911"
	desc = "For the monkey mafioso on-the-go. Uses .45 rounds and has the distinct smell of bananas."
	projectile_damage_multiplier = 0.5
	projectile_wound_bonus = -12
	pin = /obj/item/firing_pin/monkey

///Blueshift guns

// .35 Sol pistol

/obj/item/gun/ballistic/automatic/pistol/sol
	name = "\improper Wespe Pistol"
	desc = "The standard issue service pistol of SolFed's various military branches. Uses .35 Sol and comes with an attached light."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "wespe"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/pistol_light.ogg'

	w_class = WEIGHT_CLASS_NORMAL

	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	special_mags = TRUE

	suppressor_x_offset = 7
	suppressor_y_offset = 0

	fire_delay = 0.3 SECONDS

/obj/item/gun/ballistic/automatic/pistol/sol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/automatic/pistol/sol/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		starting_light = new /obj/item/flashlight/seclite(src), \
		is_light_removable = FALSE, \
		)

/obj/item/gun/ballistic/automatic/pistol/sol/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/pistol/sol/examine_more(mob/user)
	. = ..()

	. += "The Wespe is a pistol that was made entirely for military use. \
		Required to use a standard round, standard magazines, and be able \
		to function in all of the environments that SolFed operated in \
		commonly. These qualities just so happened to make the weapon \
		popular in frontier space and is likely why you are looking at \
		one now."

	return .

/obj/item/gun/ballistic/automatic/pistol/sol/no_mag
	spawnwithmagazine = FALSE

// Sol pistol evil gun

/obj/item/gun/ballistic/automatic/pistol/sol/evil
	desc = "The standard issue service pistol of SolFed's various military branches. Comes with attached light. This one is painted tacticool black."

	icon_state = "wespe_evil"
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/automatic/pistol/sol/evil/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/sol/evil/unrestricted
	pin = /obj/item/firing_pin

// Trappiste high caliber pistol in .585

/obj/item/gun/ballistic/automatic/pistol/trappiste
	name = "\improper Skild Pistol"
	desc = "A somewhat rare to see Trappiste pistol firing the high caliber .585 developed by the same company. \
		Sees rare use mainly due to its tendency to cause severe wrist discomfort."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "skild"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/pistol_heavy.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_heavy.ogg'

	w_class = WEIGHT_CLASS_NORMAL

	accepted_magazine_type = /obj/item/ammo_box/magazine/c585trappiste_pistol

	suppressor_x_offset = 8
	suppressor_y_offset = 0

	fire_delay = 1 SECONDS

	recoil = 3
	wield_recoil = 1

/obj/item/gun/ballistic/automatic/pistol/trappiste/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/automatic/pistol/sol/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/pistol/trappiste/examine_more(mob/user)
	. = ..()

	. += "The Skild only exists due to a widely known event that SolFed's military \
		would prefer wasn't anywhere near as popular. A general, name unknown as of now, \
		was recorded complaining about the lack of capability the Wespe provided to the \
		military, alongside several statements comparing the Wespe's lack of masculinity \
		to the, quote, 'unique lack of testosterone those NRI mongrels field'. While the \
		identities of both the general and people responsible for the leaking of the recording \
		are still classified, many high ranking SolFed military staff suspiciously have stopped \
		appearing in public, unlike the Skild. A lot of several thousand pistols, the first \
		of the weapons to ever exist, were not so silently shipped to SolFed's Plutonian \
		shipping hub from TRAPPIST. SolFed military command refuses to answer any \
		further questions about the incident to this day."

	return .

/obj/item/gun/ballistic/automatic/pistol/trappiste/no_mag
	spawnwithmagazine = FALSE

// Plasma spewing pistol. Yes these have chargeable packs, but they are basically ballistics....
// Sprays a wall of plasma that sucks against armor but fucks against unarmored targets

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower
	name = "\improper Słońce Plasma Projector"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. \
		Uses plasma power packs. \
		Spews an inaccurate stream of searing plasma out the magnetic barrel so long as it has power and the trigger is pulled."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_32.dmi'
	icon_state = "slonce"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/incinerate.ogg'
	fire_sound_volume = 40 // This thing is comically loud otherwise

	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/plasma_battery
	can_suppress = FALSE
	show_bolt_icon = FALSE
	casing_ejector = FALSE
	empty_indicator = FALSE
	bolt_type = BOLT_TYPE_OPEN
	fire_delay = 0.1 SECONDS
	spread = 15

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/automatic_fire, autofire_shot_delay = fire_delay)

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/pistol/plasma_thrower/examine_more(mob/user)
	. = ..()

	. += "The 'Słońce' started life as an experiment in advancing the field of accelerated \
		plasma weaponry. Despite the design's obvious shortcomings in terms of accuracy and \
		range, the CIN combined military command (which we'll call the CMC from now on) took \
		interest in the weapon as a means to counter Sol's more advanced armor technology. \
		As it would turn out, the plasma globules created by the weapon were really not \
		as effective against armor as the CMC had hoped, quite the opposite actually. \
		What the plasma did do well however was inflict grevious burns upon anyone unfortunate \
		enough to get hit by it unprotected. For this reason, the 'Słońce' saw frequent use by \
		army officers and ship crews who needed a backup weapon to incinerate the odd space \
		pirate or prisoner of war."

	return .

// Plasma sharpshooter pistol
// Shoots single, strong plasma blasts at a slow rate

/obj/item/gun/ballistic/automatic/pistol/plasma_marksman
	name = "\improper Gwiazda Plasma Sharpshooter"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. \
		Uses plasma power packs. \
		Fires relatively accurate globs of searing plasma."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_32.dmi'
	icon_state = "gwiazda"

	fire_sound = 'monkestation/code/modules/blueshift/sounds/burn.ogg'
	fire_sound_volume = 40 // This thing is comically loud otherwise

	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/plasma_battery
	can_suppress = FALSE
	show_bolt_icon = FALSE
	casing_ejector = FALSE
	empty_indicator = FALSE
	bolt_type = BOLT_TYPE_OPEN
	fire_delay = 0.6 SECONDS
	spread = 2.5

	projectile_damage_multiplier = 3 // 30 damage a shot
	projectile_wound_bonus = 10 // +55 of the base projectile, burn baby burn

/obj/item/gun/ballistic/automatic/pistol/plasma_marksman/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/automatic/pistol/plasma_marksman/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/pistol/plasma_marksman/examine_more(mob/user)
	. = ..()

	. += "The 'Gwiazda' is a further refinement of the 'Słońce' design. with improved \
		energy cycling, magnetic launchers built to higher precision, and an overall more \
		ergonomic design. While it still fails to perform against armor, the weapon is \
		significantly more accurate and higher power, at expense of a much lower firerate. \
		Opinions on this weapon within military service were highly mixed, with many preferring \
		the sheer stopping power a spray of plasma could produce, with others loving the new ability \
		to hit something in front of you for once."

	return .


/obj/item/gun/ballistic/automatic/pistol/whispering_jester_45
	name = "\improper Whispering-Jester .45"
	desc = "A .45 handgun that is designed by Rayne Corp for various people such as jesters, insurgents, and even stealth operatives. The handgun has a built in holosight, suppressor, and laser sight."
	icon = 'monkestation/icons/obj/weapons/guns/whispering_jester_45/item.dmi'
	icon_state = "jester"
	lefthand_file = 'monkestation/icons/obj/weapons/guns/whispering_jester_45/lefthand.dmi'
	righthand_file = 'monkestation/icons/obj/weapons/guns/whispering_jester_45/righthand.dmi'
	inhand_icon_state = "jester"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/whispering_jester_45_magazine
	can_bayonet = FALSE
	can_suppress = FALSE
	can_unsuppress = FALSE
	suppressed = TRUE
	bolt_type = BOLT_TYPE_OPEN
	bolt_wording = "firearm"
	fire_delay = 1
	fire_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_fire.ogg' //Unused, just in case it some how gets un-suppressed.
	suppressed_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_fire.ogg'
	suppressed_volume = 60
	dry_fire_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_clicky.ogg'
	rack_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_clicky.ogg'
	lock_back_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_clicky.ogg'
	bolt_drop_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_clicky.ogg'
	load_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_mag_in.ogg'
	load_empty_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_mag_in.ogg'
	eject_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_mag_out.ogg'
	eject_empty_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_mag_out.ogg'

//april fools edition
/obj/item/gun/ballistic/automatic/pistol/whispering_jester_45/toyota
	name = "\improper Screaming-Hilux .45"
	desc = "A three-way weapon design project by Rayne Corp, Toyota, and Johnson & Co Architecture, sold under the Toyne Group. Designed as a fully-automatic alternative to the Whispering Jester, it trades all forms of stealth for delivering a lethal punch to hearing first, targets second. Do not trust the onboard suppressor. Wear hearing protection."
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/whispering_jester_45_magazine/big_lmao
	can_bayonet = FALSE
	can_suppress = FALSE
	can_unsuppress = TRUE
	suppressed = FALSE
	bolt_type = BOLT_TYPE_OPEN
	bolt_wording = "firearm"
	fire_delay = 0.1
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	fire_sound_volume = 150 //abraxis this is a bad idea
	recoil = 5 //it's a pistol firing full-auto, fuck your wrist lmao
	wield_recoil = 0.75
	spread = 12.5

/obj/item/gun/ballistic/automatic/pistol/whispering_jester_45/toyota/Initialize(mapload)
	. = ..()

	give_autofire()

//why did i steal code from the qarad for this fucking thing
/obj/item/gun/ballistic/automatic/pistol/whispering_jester_45/toyota/proc/give_autofire()
	AddComponent(/datum/component/automatic_fire, fire_delay)


//.35 Auto PACO, I.E standard security carry
/obj/item/gun/ballistic/automatic/pistol/paco //Sec pistol, Paco from CEV Eris.
	name = "\improper FS HG .35 Auto \"Paco\""
	desc = "A modern and reliable sidearm for the soldier in the field. Commonly issued as a sidearm to Security Officers. Uses standard and rubber .35 Auto and high capacity magazines."
	icon = 'monkestation/code/modules/security/icons/paco.dmi'
	icon_state = "paco"
	inhand_icon_state = "paco"
	lefthand_file = 'monkestation/code/modules/security/icons/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/security/icons/guns_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m35
	can_suppress = FALSE
	fire_sound = 'monkestation/code/modules/security/sound/paco/paco_shot.ogg'
	rack_sound = 'monkestation/code/modules/security/sound/paco/paco_rack.ogg'
	lock_back_sound = 'monkestation/code/modules/security/sound/paco/paco_lock.ogg'
	bolt_drop_sound = 'monkestation/code/modules/security/sound/paco/paco_drop.ogg'
	load_sound = 'monkestation/code/modules/security/sound/paco/paco_magin.ogg'
	load_empty_sound = 'monkestation/code/modules/security/sound/paco/paco_magin.ogg'
	eject_sound = 'monkestation/code/modules/security/sound/paco/paco_magout.ogg'
	eject_empty_sound = 'monkestation/code/modules/security/sound/paco/paco_magout.ogg'
	var/has_stripe = TRUE
	var/COOLDOWN_STRIPE

/obj/item/gun/ballistic/automatic/pistol/paco/Initialize(mapload) //Sec pistol, Paco(renamed to TACO... Atleast 10 percent of the time)
	. = ..()
	if(prob(10))
		name = "\improper FS HG .35 Auto \"Taco\" LE"
		desc += " <font color=#FFE733>You notice a small difference on the side of the pistol... An engraving depicting a taco! It's a Limited Run model!</font>"

/obj/item/gun/ballistic/automatic/pistol/paco/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/paco/update_icon_state()
	. = ..()
	if(!has_stripe) //Definitely turn this into a switch case statement if someone (or I) decide to add more variants, but this works for now
		icon_state = "spaco"
		inhand_icon_state = "spaco"

/obj/item/gun/ballistic/automatic/pistol/paco/add_seclight_point() //Seclite functionality
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'monkestation/icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "pacoflight", \
		overlay_x = 15, \
		overlay_y = 13)

/obj/item/gun/ballistic/automatic/pistol/paco/click_alt(mob/user) //Some people like the stripe, some people don't. Gives you the option to do the unthinkable.
	if(!has_stripe || !TIMER_COOLDOWN_FINISHED(src, COOLDOWN_STRIPE)) //Checks if the gun has a stripe to rip and is not on cooldown
		return CLICK_ACTION_BLOCKING
	TIMER_COOLDOWN_START(src, COOLDOWN_STRIPE, 6 SECONDS)
	playsound(src, 'sound/items/duct_tape_snap.ogg', 50, TRUE)
	balloon_alert_to_viewers("[user] starts picking at the Paco's stripe!")
	if(!do_after(user, 6 SECONDS))
		return CLICK_ACTION_BLOCKING
	has_stripe = FALSE
	obj_flags = UNIQUE_RENAME
	desc += " You figure there's ample room to engrave something nice on it, but know that it'd offer no tactical advantage whatsoever."
	playsound(src, 'sound/items/duct_tape_rip.ogg', 50, TRUE)
	playsound(src, rack_sound, 50, TRUE) //Increases satisfaction
	balloon_alert_to_viewers("[user] rips the stripe right off the Paco!") //The implication that the stripe is just a piece of red tape is very funny
	update_icon_state()
	update_appearance() //So you don't have to rack the slide to update the sprite
	update_inhand_icon(user) //So you don't have to switch the gun inhand to update the inhand sprite
	return CLICK_ACTION_SUCCESS

//Busted blueshield pistol
/obj/item/gun/ballistic/automatic/pistol/tech_9
	name = "\improper Glock-O"
	desc = "The standard issue service pistol of blueshield agents."
	burst_size = 4
	fire_delay = 1
	icon = 'monkestation/icons/obj/weapons/guns/tech9.dmi'
	icon_state = "tech9"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/pistol_light.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/m35

/obj/item/gun/ballistic/automatic/pistol/tech_9/no_mag
	spawnwithmagazine = FALSE
