/obj/item/gun/ballistic/automatic
	w_class = WEIGHT_CLASS_NORMAL
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
	semi_auto = TRUE
	fire_sound = 'sound/weapons/gun/smg/shot.ogg'
	fire_sound_volume = 90
	rack_sound = 'sound/weapons/gun/smg/smgrack.ogg'
	suppressed_sound = 'sound/weapons/gun/smg/shot_suppressed.ogg'
	var/select = 1 ///fire selector position. 1 = semi, 2 = burst. anything past that can vary between guns.
	var/selector_switch_icon = FALSE ///if it has an icon for a selector switch indicating current firemode.
	gun_flags = GUN_SMOKE_PARTICLES

/obj/item/gun/ballistic/automatic/update_overlays()
	. = ..()
	if(!selector_switch_icon)
		return

	switch(select)
		if(0)
			. += "[initial(icon_state)]_semi"
		if(1)
			. += "[initial(icon_state)]_burst"

/obj/item/gun/ballistic/automatic/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_firemode))
		burst_select()
	else
		..()

/obj/item/gun/ballistic/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		balloon_alert(user, "switched to semi-automatic")
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		balloon_alert(user, "switched to [burst_size]-round burst")

	playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
	update_appearance()
	update_item_action_buttons()


///SMGs

/obj/item/gun/ballistic/automatic/proto
	name = "\improper Nanotrasen Saber SMG"
	desc = "A prototype full-auto 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	burst_size = 1
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/smgm9mm
	pin = null
	bolt_type = BOLT_TYPE_LOCKING
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/automatic/proto/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/proto/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A bullpup three-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	inhand_icon_state = "c20r"
	selector_switch_icon = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/smgm45
	fire_delay = 2
	burst_size = 3
	pin = /obj/item/firing_pin/implant/pindicate
	can_bayonet = TRUE
	knife_x_offset = 26
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE

/obj/item/gun/ballistic/automatic/c20r/update_overlays()
	. = ..()
	if(!chambered && empty_indicator) //this is duplicated due to a layering issue with the select fire icon.
		. += "[icon_state]_empty"

/obj/item/gun/ballistic/automatic/c20r/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/c20r/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/gun/ballistic/automatic/wt550
	name = "\improper WT-550 Autorifle"
	desc = "Recalled by Nanotrasen due to public backlash around heat distribution resulting in unintended discombobulation. \
		This outcry was fabricated through various Syndicate-backed misinformation operations to force Nanotrasen to abandon \
		its ballistics weapon program, cornering them into the energy weapons market. Most often found today in the hands of pirates, \
		underfunded security personnel, cargo technicians, theoritical physicists and gang bangers out on the rim. \
		Light-weight and fully automatic. Uses 4.6x30mm rounds."
	icon_state = "wt550"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "arg"
	accepted_magazine_type = /obj/item/ammo_box/magazine/wt550m9
	fire_delay = 2
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE

/obj/item/gun/ballistic/automatic/wt550/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.3 SECONDS)

/obj/item/gun/ballistic/automatic/wt550/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/wt550/fss //Slightly worse printable WT-550
	name = "\improper FSS-550"
	desc = "A modified printable version of the WT-550 autorifle, in order to be printed by an autolathe, some sacrifices had to be made. Not only does this gun have less stopping power, the magazine doesn't entirely fit, and it takes a bit of force to jam it in or rip it out. Used by Syndicate agents and rebels in more than 50 systems."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "fss550"
	inhand_icon_state = "fss"
	spread = 2
	projectile_damage_multiplier = 0.9
	///How long does it take to add or remove a magazine from this gun.
	var/magazine_time = 4 SECONDS

///Modify proc so it takes time to add or remove the magazine.
/obj/item/gun/ballistic/automatic/wt550/fss/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message = TRUE)
	if(!istype(AM, accepted_magazine_type))
		balloon_alert(user, "[AM.name] doesn't fit!")
		return FALSE
	if(!do_after(user, magazine_time, target = src))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(user.transferItemToLoc(AM, src))
		magazine = AM
		if (display_message)
			balloon_alert(user, "[magazine_wording] loaded")
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
		if (bolt_type == BOLT_TYPE_OPEN && !bolt_locked)
			chamber_round(TRUE)
		update_appearance()
		return TRUE
	else
		to_chat(user, span_warning("You cannot seem to get [src] out of your hands!"))
		return FALSE

///Modify proc so it takes time to add or remove the magazine.
/obj/item/gun/ballistic/automatic/wt550/fss/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	if(!do_after(user, magazine_time, target = src))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(bolt_type == BOLT_TYPE_OPEN)
		chambered = null
	if (magazine.ammo_count())
		playsound(src, load_sound, load_sound_volume, load_sound_vary)
	else
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	magazine.forceMove(drop_location())
	var/obj/item/ammo_box/magazine/old_mag = magazine
	if (tac_load)
		if (insert_magazine(user, tac_load, FALSE))
			balloon_alert(user, "[magazine_wording] swapped")
		else
			to_chat(user, span_warning("You dropped the old [magazine_wording], but the new one doesn't fit. How embarassing."))
			magazine = null
	else
		magazine = null
	user.put_in_hands(old_mag)
	old_mag.update_appearance()
	if (display_message)
		balloon_alert(user, "[magazine_wording] unloaded")
	update_appearance()

/obj/item/gun/ballistic/automatic/wt550/fss/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/plastikov
	name = "\improper PP-95 SMG"
	desc = "An ancient 9mm submachine gun pattern updated and simplified to lower costs, though perhaps simplified too much."
	icon_state = "plastikov"
	inhand_icon_state = "plastikov"
	accepted_magazine_type = /obj/item/ammo_box/magazine/plastikov9mm
	burst_size = 5
	spread = 25
	can_suppress = FALSE
	actions_types = list()
	projectile_damage_multiplier = 0.35 //It's like 10.5 damage per bullet, it's close enough to 10 shots
	mag_display = TRUE
	empty_indicator = TRUE
	special_mags = TRUE
	fire_sound = 'sound/weapons/gun/smg/shot_alt.ogg'

/obj/item/gun/ballistic/automatic/plastikov/refurbished //forgive me lord for i have sinned
	name = "\improper PP-96 SMG"
	desc = "An ancient 9mm submachine gun pattern updated and simplified to lower costs. This one has been refurbished for better performance."
	spread = 10
	burst_size = 3
	icon_state = "plastikov_refurbished"
	inhand_icon_state = "plastikov_refurbished"
	accepted_magazine_type = /obj/item/ammo_box/magazine/plastikov9mm
	spawn_magazine_type = /obj/item/ammo_box/magazine/plastikov9mm/red
	projectile_damage_multiplier = 0.5 //15 damage
	can_suppress = TRUE
	suppressor_x_offset = 4
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/automatic/plastikov/refurbished/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/rostokov
	name = "\improper Rostokov carbine"
	desc = "A bullpup fully automatic 9mm carbine. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "rostokov"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "rostokov"
	accepted_magazine_type = /obj/item/ammo_box/magazine/rostokov9mm
	projectile_damage_multiplier = 0.66 //20 damage
	fire_delay = 1
	spread = 5
	can_suppress = FALSE
	burst_size = 1
	slot_flags = null
	worn_icon_state = "rostokov"
	actions_types = list()
	pin = /obj/item/firing_pin/implant/pindicate
	mag_display = TRUE
	empty_indicator = TRUE
	fire_sound = 'monkestation/code/modules/blueshift/sounds/smg_heavy.ogg'

/obj/item/gun/ballistic/automatic/rostokov/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/rostokov/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/mini_uzi
	name = "\improper Type U3 Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "miniuzi"
	accepted_magazine_type = /obj/item/ammo_box/magazine/uzim9mm
	burst_size = 2
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	mag_display = TRUE
	rack_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'

/obj/item/gun/ballistic/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "Based on the classic 'Chicago Typewriter'."
	icon_state = "tommygun"
	inhand_icon_state = "shotgun"
	selector_switch_icon = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = 0
	accepted_magazine_type = /obj/item/ammo_box/magazine/tommygunm45
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()
	fire_delay = 1
	bolt_type = BOLT_TYPE_OPEN
	empty_indicator = TRUE
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/automatic/tommygun/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.1 SECONDS)

/**
 * Weak uzi for syndicate chimps. It comes in a 4 TC kit.
 * Roughly 9 damage per bullet every 0.2 seconds, equaling out to downing an opponent in a bit over a second, if they have no armor.
 */
/obj/item/gun/ballistic/automatic/mini_uzi/chimpgun
	name = "\improper MONK-10"
	desc = "Developed by Syndicate monkeys, for syndicate Monkeys. Despite the name, this weapon resembles an Uzi significantly more than a MAC-10. Uses 9mm rounds. There's a label on the other side of the gun that says \"Do what comes natural.\""
	projectile_damage_multiplier = 0.4
	projectile_wound_bonus = -25
	pin = /obj/item/firing_pin/monkey

/**
 * Weak tommygun for syndicate chimps. It comes in a 4 TC kit.
 * Roughly 9 damage per bullet every 0.2 seconds, equaling out to downing an opponent in a bit over a second, if they have no armor.
 */
/obj/item/gun/ballistic/automatic/tommygun/chimpgun
	name = "\improper Typewriter"
	desc = "It was the best of times, it was the BLURST of times!? You stupid monkeys!"
	projectile_damage_multiplier = 0.4
	projectile_wound_bonus = -25
	pin = /obj/item/firing_pin/monkey

/obj/item/gun/ballistic/automatic/xhihao_smg ///.585 trappiste SMG, always having balance problems
	name = "\improper Bogseo Heavy Submachine Gun"
	desc = "A weapon that could hardly be called a 'sub' machinegun, firing the hefty .585 cartridge. \
		It provides enough kick to bruise a shoulder pretty bad if used without protection."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/guns32x.dmi'
	icon_state = "bogseo"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/xhihao_light_arms/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/xhihao_light_arms/guns_righthand.dmi'
	inhand_icon_state = "bogseo"
	special_mags = FALSE
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/c585trappiste_pistol
	fire_sound = 'monkestation/code/modules/blueshift/sounds/smg_heavy.ogg'
	can_suppress = TRUE
	can_bayonet = FALSE
	suppressor_x_offset = 9
	burst_size = 2
	fire_delay = 0.5 SECONDS
	actions_types = list()
	spread = 14.5
	// Hope you didn't need to see anytime soon
	recoil = 2
	wield_recoil = 1
	projectile_wound_bonus = -5

/obj/item/gun/ballistic/automatic/xhihao_smg/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_XHIHAO)
///	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/xhihao_smg/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/xhihao_smg/examine_more(mob/user)
	. = ..()

	. += "The Bogseo submachinegun is seen in highly different lights based on \
		who you ask. Ask a Jovian, and they'll go off all day about how they \
		love the thing so. A big weapon for shooting big targets, like the \
		fuel-stat raiders in their large suits of armor. Ask a space pirate, however \
		and you'll get a different story. That is thanks to many SolFed anti-piracy \
		units picking the Bogseo as their standard boarding weapon. What better \
		to ruin a brigand's day than a bullet large enough to turn them into \
		mist at full auto, after all?"

	return .

/obj/item/gun/ballistic/automatic/xhihao_smg/no_mag
	spawnwithmagazine = FALSE


/obj/item/gun/ballistic/automatic/miecz /// Rapid firing submachinegun firing .27-54 Cesarzowa
	name = "\improper Miecz Submachine Gun"
	desc = "A short barrel, further compacted conversion of the 'Lanca' rifle to fire pistol caliber .27-54 cartridges. \
		Due to the intended purpose of the weapon, and less than optimal ranged performance of the projectile, it has \
		nothing more than basic glow-sights as opposed to the ranged scope Lanca users might be used to."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_48.dmi'
	icon_state = "miecz"
	inhand_icon_state = "c20r"
	worn_icon_state = "gun"
	SET_BASE_PIXEL(-8, 0)
	special_mags = FALSE
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_SUITSTORE
	accepted_magazine_type = /obj/item/ammo_box/magazine/miecz
	fire_sound = 'monkestation/code/modules/blueshift/sounds/smg_light.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 0
	suppressor_y_offset = 0
	can_bayonet = FALSE
	burst_size = 1
	fire_delay = 0.2 SECONDS
	actions_types = list()
	spread = 5

/obj/item/gun/ballistic/automatic/miecz/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/miecz/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/automatic/miecz/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/miecz/examine_more(mob/user)
	. = ..()

	. += "The Meicz is one of the newest weapons to come out of CIN member state hands and \
		into the wild, typically the frontier. It was built alongside the round it fires, the \
		.27-54 Cesarzawa pistol round. Based on the proven Lanca design, it seeks to bring that \
		same reliable weapon design into the factor of a submachinegun. While it is significantly \
		larger than many comparable weapons in SolFed use, it more than makes up for it with ease \
		of control and significant firerate."

	return .

/obj/item/gun/ballistic/automatic/miecz/no_mag
	spawnwithmagazine = FALSE


/obj/item/gun/ballistic/automatic/sol_smg // Base Sol SMG - Incredibly junky, needs work
	name = "\improper Sindano Submachine Gun"
	desc = "A small submachine gun firing .35 Sol. Commonly seen in the hands of PMCs and other unsavory corpos. Accepts any standard Sol pistol magazine."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns32x.dmi'
	icon_state = "sindano"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "sindano"
	special_mags = TRUE
	bolt_type = BOLT_TYPE_OPEN
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	spawn_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol/stendo
	fire_sound = 'monkestation/code/modules/blueshift/sounds/smg_light.ogg'
	can_suppress = TRUE
	can_bayonet = FALSE
	suppressor_x_offset = 11
	burst_size = 2
	fire_delay = 0.35 SECONDS
	spread = 7.5

/obj/item/gun/ballistic/automatic/sol_smg/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/automatic/sol_smg/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/sol_smg/examine_more(mob/user)
	. = ..()

	. += "The Sindano submachinegun was originally produced for military contract. \
		These guns were seen in the hands of anyone from medics, ship techs, logistics officers, \
		and shuttle pilots often had several just to show off. Due to SolFed's quest to \
		extend the lifespans of their logistics officers and quartermasters, the weapon \
		uses the same standard pistol cartridge that most other miltiary weapons of \
		small caliber use. This results in interchangeable magazines between pistols \
		and submachineguns, neat!"

	return .

/obj/item/gun/ballistic/automatic/sol_smg/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/sol_smg/evil
	desc = "A small submachinegun, this one is painted in tacticool black. Accepts any standard Sol pistol magazine."
	icon_state = "sindano_evil"
	inhand_icon_state = "sindano_evil"
	spread = 5
	projectile_wound_bonus = 5
	projectile_damage_multiplier = 1.25
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/automatic/sol_smg/evil/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/sol_smg/evil/unrestricted
	pin = /obj/item/firing_pin



///Rifles

/obj/item/gun/ballistic/automatic/m90
	name = "\improper M-90gl Carbine"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90gl'. Has an attached underbarrel grenade launcher." //monkestation edit: reverted back from .223 to original 556 as ported from nova
	desc_controls = "Right-click to use grenade launcher."
	icon_state = "m90"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "m90"
	selector_switch_icon = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/m556 //monkestation edit: reverted back from .223 to original 556 as ported from nova
	can_suppress = FALSE
	var/obj/item/gun/ballistic/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2
	spread = 5
	pin = /obj/item/firing_pin/implant/pindicate
	mag_display = TRUE
	empty_indicator = TRUE
	fire_sound = 'sound/weapons/gun/smg/shot_alt.ogg'

/obj/item/gun/ballistic/automatic/m90/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher(src)
	update_appearance()

/obj/item/gun/ballistic/automatic/m90/Destroy()
	QDEL_NULL(underbarrel)
	return ..()

/obj/item/gun/ballistic/automatic/m90/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/m90/unrestricted/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted(src)
	update_appearance()

///obj/item/gun/ballistic/automatic/m90/try_fire_gun(atom/target, mob/living/user, params)
	//if(LAZYACCESS(params2list(params), RIGHT_CLICK))
	//	return underbarrel.try_fire_gun(target, user, params)
	//return ..()

/obj/item/gun/ballistic/automatic/m90/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return underbarrel.try_fire_gun(interacting_with, user, list2params(modifiers))

/obj/item/gun/ballistic/automatic/m90/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(isammocasing(tool))
		if(istype(tool, underbarrel.magazine.ammo_type))
			underbarrel.attack_self(user)
			underbarrel.attackby(tool, user, list2params(modifiers))
		return ITEM_INTERACT_BLOCKING
	return ..()

#define FIRING_PIN_REMOVAL_DELAY 50
/obj/item/gun/ballistic/automatic/m90/screwdriver_act_secondary(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	else if(underbarrel.pin?.pin_removable && user.is_holding(src))
		user.visible_message(span_warning("[user] attempts to remove [underbarrel.pin] from [underbarrel] with [I]."),
		span_notice("You attempt to remove [underbarrel.pin] from [underbarrel]. (It will take [DisplayTimeText(FIRING_PIN_REMOVAL_DELAY)].)"), null, 3)
		if(I.use_tool(src, user, FIRING_PIN_REMOVAL_DELAY, volume = 50))
			if(!underbarrel.pin) //check to see if the pin is still there, or we can spam messages by clicking multiple times during the tool delay
				return
			user.visible_message(span_notice("[underbarrel.pin] is pried out of [underbarrel] by [user], destroying the pin in the process."),
								span_warning("You pry [underbarrel.pin] out with [I], destroying the pin in the process."), null, 3)
			QDEL_NULL(underbarrel.pin)
			return TRUE

/obj/item/gun/ballistic/automatic/m90/welder_act_secondary(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	else if(underbarrel.pin?.pin_removable && user.is_holding(src))
		user.visible_message(span_warning("[user] attempts to remove [underbarrel.pin] from [underbarrel] with [I]."),
		span_notice("You attempt to remove [underbarrel.pin] from [underbarrel]. (It will take [DisplayTimeText(FIRING_PIN_REMOVAL_DELAY)].)"), null, 3)
		if(I.use_tool(src, user, FIRING_PIN_REMOVAL_DELAY, 5, volume = 50))
			if(!underbarrel.pin) //check to see if the pin is still there, or we can spam messages by clicking multiple times during the tool delay
				return
			user.visible_message(span_notice("[underbarrel.pin] is spliced out of [underbarrel] by [user], melting part of the pin in the process."),
								span_warning("You splice [underbarrel.pin] out of [underbarrel] with [I], melting part of the pin in the process."), null, 3)
			QDEL_NULL(underbarrel.pin)
			return TRUE

/obj/item/gun/ballistic/automatic/m90/wirecutter_act_secondary(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	else if(underbarrel.pin?.pin_removable && user.is_holding(src))
		user.visible_message(span_warning("[user] attempts to remove [underbarrel.pin] from [underbarrel] with [I]."),
		span_notice("You attempt to remove [underbarrel.pin] from [underbarrel]. (It will take [DisplayTimeText(FIRING_PIN_REMOVAL_DELAY)].)"), null, 3)
		if(I.use_tool(src, user, FIRING_PIN_REMOVAL_DELAY, volume = 50))
			if(!underbarrel.pin) //check to see if the pin is still there, or we can spam messages by clicking multiple times during the tool delay
				return
			user.visible_message(span_notice("[underbarrel.pin] is ripped out of [underbarrel] by [user], mangling the pin in the process."),
								span_warning("You rip [underbarrel.pin] out of [underbarrel] with [I], mangling the pin in the process."), null, 3)
			QDEL_NULL(underbarrel.pin)
			return TRUE

/obj/item/firing_pin/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isgun(interacting_with))
		return NONE
	if(!(("underbarrel") in (interacting_with.vars)))
		return NONE
	var/obj/item/gun/ballistic/automatic/m90/targeted_gun = interacting_with
	var/obj/item/firing_pin/old_pin = targeted_gun.underbarrel.pin
	if(old_pin?.pin_removable && (force_replace || old_pin.pin_hot_swappable))
		if(Adjacent(user))
			user.put_in_hands(old_pin)
		else
			old_pin.forceMove(targeted_gun.drop_location())
		old_pin.gun_remove(user)

	if(!targeted_gun.underbarrel.pin)
		if(!user.temporarilyRemoveItemFromInventory(src))
			return .
		if(gun_insert(user, targeted_gun.underbarrel))
			if(old_pin)
				balloon_alert(user, "swapped firing pin")
			else
				balloon_alert(user, "inserted firing pin")
	else
		to_chat(user, span_notice("This firearm already has a firing pin installed."))

	return ITEM_INTERACT_SUCCESS

#undef FIRING_PIN_REMOVAL_DELAY

/obj/item/gun/ballistic/automatic/m90/update_overlays()
	. = ..()
	switch(select)
		if(0)
			. += "[initial(icon_state)]_semi"
		if(1)
			. += "[initial(icon_state)]_burst"

/obj/item/gun/ballistic/automatic/ar
	name = "\improper NT-ARG 'Boarder'"
	desc = "A robust assault rifle used by Nanotrasen fighting forces."
	icon_state = "arg"
	inhand_icon_state = "arg"
	slot_flags = 0
	accepted_magazine_type = /obj/item/ammo_box/magazine/m556
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 1

/obj/item/gun/ballistic/automatic/sol_rifle ///The standard rifle rifle, it just works
	name = "\improper Carwo-Cawil Battle Rifle"
	desc = "A heavy battle rifle firing .40 Sol. Commonly seen in the hands of SolFed military types. Accepts any standard SolFed rifle magazine."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns48x.dmi'
	icon_state = "infanterie"
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "infanterie"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "infanterie"
	SET_BASE_PIXEL(-8, 0)
	special_mags = TRUE
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	accepted_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle
	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle/standard
	fire_sound = 'monkestation/code/modules/blueshift/sounds/rifle_heavy.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_rifle.ogg'
	can_suppress = TRUE
	can_bayonet = FALSE
	suppressor_x_offset = 12
	burst_size = 1
	fire_delay = 0.4 SECONDS
	actions_types = list()
	spread = 7.5
	projectile_wound_bonus = -10

/obj/item/gun/ballistic/automatic/sol_rifle/Initialize(mapload)
	. = ..()

	give_autofire()

/// Separate proc for handling auto fire just because one of these subtypes isn't otomatica
/obj/item/gun/ballistic/automatic/sol_rifle/proc/give_autofire()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/sol_rifle/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/automatic/sol_rifle/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/sol_rifle/examine_more(mob/user)
	. = ..()

	. += "The Carwo-Cawil rifles are built by Carwo for \
		use by SolFed's various infantry branches. Following the rather reasonable \
		military requirements of using the same few cartridges and magazines, \
		the lifespans of logistics coordinators and quartermasters everywhere \
		were lengthened by several years. While typically only for military sale \
		in the past, the recent collapse of certain unnamed weapons manufacturers \
		has caused Carwo to open many of its military weapons to civilian sale, \
		which includes this one."

	return .

/obj/item/gun/ballistic/automatic/sol_rifle/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/sol_rifle/evil
	desc = "A heavy battle rifle, this one seems to be painted tacticool black. Accepts any standard SolFed rifle magazine."

	icon_state = "infanterie_evil"
	worn_icon_state = "infanterie_evil"
	inhand_icon_state = "infanterie_evil"
	projectile_wound_bonus = 5
	projectile_damage_multiplier = 1.25
	fire_delay = 0.3 SECONDS
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/automatic/sol_rifle/evil/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/sol_rifle/evil/unrestricted
	pin = /obj/item/firing_pin



///Machine Guns

/obj/item/gun/ballistic/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 7.12x82mm light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6"
	inhand_icon_state = "l6closedmag"
	base_icon_state = "l6"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	accepted_magazine_type = /obj/item/ammo_box/magazine/mm712x82
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	actions_types = list()
	can_suppress = FALSE
	spread = 7
	pin = /obj/item/firing_pin/implant/pindicate
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	mag_display = TRUE
	mag_display_ammo = TRUE
	tac_reloads = FALSE
	fire_sound = 'sound/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	var/cover_open = FALSE

/obj/item/gun/ballistic/automatic/l6_saw/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/l6_saw/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/l6_saw/examine(mob/user)
	. = ..()
	. += "<b>alt + click</b> to [cover_open ? "close" : "open"] the dust cover."
	if(cover_open && magazine)
		. += span_notice("It seems like you could use an <b>empty hand</b> to remove the magazine.")


/obj/item/gun/ballistic/automatic/l6_saw/click_alt(mob/user)
	cover_open = !cover_open
	balloon_alert(user, "cover [cover_open ? "opened" : "closed"]")
	playsound(src, 'sound/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/automatic/l6_saw/update_icon_state()
	. = ..()
	inhand_icon_state = "[base_icon_state][cover_open ? "open" : "closed"][magazine ? "mag":"nomag"]"

/obj/item/gun/ballistic/automatic/l6_saw/update_overlays()
	. = ..()
	. += "l6_door_[cover_open ? "open" : "closed"]"


/obj/item/gun/ballistic/automatic/l6_saw/try_fire_gun(atom/target, mob/living/user, params)
	if(cover_open)
		balloon_alert(user, "close the cover!")
		return FALSE

	. = ..()
	if(.)
		update_appearance()
	return .

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/automatic/l6_saw/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		..()
		return
	if (!cover_open)
		balloon_alert(user, "open the cover!")
		return
	..()

/obj/item/gun/ballistic/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, accepted_magazine_type))
		balloon_alert(user, "open the cover!")
		return
	..()


/obj/item/gun/ballistic/automatic/quarad_lmg /// Light Machine Gun, lives in the heavy armaments locker
	name = "\improper Qarad Light Machinegun"
	desc = "A spotless, if outdated machinegun. The same model was used to great effect against xenomorph incursions in the past, hopefully this one doesn't have any manufacturing defects...."
	icon = 'monkestation/icons/obj/weapons/guns/guns48x.dmi'
	icon_state = "outomaties"
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "outomaties"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "outomaties"
	bolt_type = BOLT_TYPE_OPEN
	accepted_magazine_type = /obj/item/ammo_box/magazine/c65xeno_drum
	spawn_magazine_type = /obj/item/ammo_box/magazine/c65xeno_drum
	SET_BASE_PIXEL(-8, 0)
	special_mags = TRUE
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	fire_sound = 'monkestation/code/modules/blueshift/sounds/rifle_heavy.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_rifle.ogg'
	can_suppress = TRUE
	can_bayonet = FALSE
	suppressor_x_offset = 12
	actions_types = list()
	burst_size = 1
	fire_delay = 0.2 SECONDS
	recoil = 3
	wield_recoil = 0.75
	spread = 12.5

/obj/item/gun/ballistic/automatic/quarad_lmg/Initialize(mapload)
	. = ..()

	give_autofire()

/obj/item/gun/ballistic/automatic/quarad_lmg/proc/give_autofire()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/quarad_lmg/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/quarad_lmg/examine_more(mob/user)
	. = ..()

	. += "The Qarad light machinegun is an old weapon, dating back to the largest of the \
		xenomorph containment efforts. It's specially-tooled 6.5mm cartridges have \
		poor effect on humans, being designed for much more durable targets.  \
		Despite it's age and suboptimal design, it will still spit bullets down-range \
		like nothing else. After a string of expensive xenomorph breaches on research stations,\
		NT pulled these machine guns out of deep storage, many still in their original packaging."

/obj/item/gun/ballistic/automatic/quarad_lmg/evil ///Nukie version
	name = "\improper Suspicious Qarad Light Machinegun"
	desc = "A heavily modified machinegun, complete with bluespace barrel extender! More bullet per bullet, more barrel per inch!"
	icon_state = "outomaties_evil"
	worn_icon = 'monkestation/icons/mob/inhands/gunsx48_worn.dmi'
	worn_icon_state = "outomaties_evil"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthandx48.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthandx48.dmi'
	inhand_icon_state = "outomaties_evil"
	spawn_magazine_type = /obj/item/ammo_box/magazine/c65xeno_drum/evil
	fire_delay = 0.1 SECONDS
	recoil = 2
	wield_recoil = 0.25
	spread = 8
	projectile_wound_bonus = 10
	projectile_damage_multiplier = 1.3

/obj/item/gun/ballistic/automatic/minigun22
	name = "\improper Miniaturized Minigun"
	desc = "A Miniaturized Multibarrel rotary gun that fires .22 LR \"peashooter\" ammunition"
	icon = 'icons/obj/weapons/guns/minigun.dmi'
	icon_state = "minigun_spin"
	inhand_icon_state = "minigun"
	slowdown = 0.4
	fire_sound = 'sound/weapons/gun/minigun10burst.ogg'
	fire_sound_volume = 50
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/minigun22
	fire_delay = 0.5
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()
	item_flags = SLOWS_WHILE_IN_HAND
	recoil = 1.2
	spread = 20

/obj/item/gun/ballistic/automatic/minigun22/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.1 SECONDS)



///Semi-Auto rifles

/obj/item/gun/ballistic/automatic/surplus
	name = "Surplus Rifle"
	desc = "One of countless obsolete ballistic rifles that still sees use as a cheap deterrent. Uses 10mm ammo and its bulky frame prevents one-hand firing."
	icon_state = "surplus"
	inhand_icon_state = "moistnugget"
	worn_icon_state = null
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/m10mm/rifle
	fire_delay = 30
	burst_size = 1
	can_unsuppress = TRUE
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	mag_display = TRUE

/obj/item/gun/ballistic/automatic/sol_rifle/marksman /// Sol marksman rifle, mildly useless but highly accurate
	name = "\improper Cawil Marksman Rifle"
	desc = "A heavy marksman rifle commonly seen in the hands of SolFed military types. Accepts any standard SolFed rifle magazine."
	icon_state = "elite"
	worn_icon_state = "elite"
	inhand_icon_state = "elite"
	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle
	fire_delay = 0.8 SECONDS
	spread = 0
	projectile_damage_multiplier = 1.75
	projectile_wound_bonus = 0

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/scope, range_modifier = 2)

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/give_autofire() ///I.E not actually automatic fire, just semi
	return

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/examine_more(mob/user)
	. = ..()

	. += "This particlar variant is a marksman rifle. \
		Automatic fire was forsaken for a semi-automatic setup, a more fitting \
		stock, and more often than not a scope. Typically also seen with smaller \
		magazines for convenience for the shooter, but as with any other Sol \
		rifle, all standard magazine types will work."

	return .

/obj/item/gun/ballistic/automatic/sol_rifle/marksman/no_mag
	spawnwithmagazine = FALSE


/obj/item/gun/ballistic/automatic/lanca // Semi-automatic rifle firing .310, I.E weaker damage mosin with slower fire rate but semi and magazines and accurate
	name = "\improper Lanca Battle Rifle"
	desc = "A relatively compact, long barreled bullpup battle rifle chambered for .310 Strilka. Has an integrated sight with \
		a surprisingly functional amount of magnification, given its place of origin."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_48.dmi'
	icon_state = "lanca"
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/guns_worn.dmi'
	worn_icon_state = "lanca"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/guns_righthand.dmi'
	inhand_icon_state = "lanca"
	SET_BASE_PIXEL(-8, 0)
	special_mags = FALSE
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	accepted_magazine_type = /obj/item/ammo_box/magazine/lanca
	fire_sound = 'monkestation/code/modules/blueshift/sounds/battle_rifle.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_heavy.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 0
	suppressor_y_offset = 0
	can_bayonet = FALSE
	burst_size = 1
	fire_delay = 1.2 SECONDS
	actions_types = list()
	recoil = 1.5
	wield_recoil = 0.5
	spread = 2.5

/obj/item/gun/ballistic/automatic/lanca/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/automatic/lanca/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/automatic/lanca/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/lanca/examine_more(mob/user)
	. = ..()

	. += "The Lanca is a now relatively dated replacement for Kalashnikov pattern rifles \
		adopted by states now combining to form the CIN. While the rifle that came before them \
		had its benefits, leadership of many armies started to realize that the Kalashnikov-based \
		rifles were really showing their age once the variants began reaching the thousands in serial. \
		The solution was presented by a then new company, Szot Dynamica. This new rifle, not too \
		unlike the one you are seeing now, adopted all of the latest technology of the time. Lightweight \
		caseless ammunition, well known for its use in Sakhno rifles, as well as various electronics and \
		other incredible technological advancements. These advancements may have already been around since \
		before the creation of even the Sakhno, but the fact you're seeing this now fifty year old design \
		must mean something, right?"

	return .

/obj/item/gun/ballistic/automatic/lanca/no_mag
	spawnwithmagazine = FALSE

// The AMR
// This sounds a lot scarier than it actually is, you'll just have to trust me here
/obj/item/gun/ballistic/automatic/wylom
	name = "\improper Wyłom Anti-Materiel Rifle"
	desc = "A massive, outdated beast of an anti materiel rifle that was once in use by CIN military forces. Fires the devastating .60 Strela caseless round, \
		the massively overperforming penetration of which being the reason this weapon was discontinued."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_64.dmi'
	base_pixel_x = -16 // This baby is 64 pixels wide
	pixel_x = -16
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/inhands_64_left.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/inhands_64_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/szot_dynamica/guns_worn.dmi'
	icon_state = "wylom"
	inhand_icon_state = "wylom"
	worn_icon_state = "wylom"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/wylom
	can_suppress = FALSE
	can_bayonet = FALSE
	fire_sound = 'monkestation/code/modules/blueshift/sounds/amr_fire.ogg'
	fire_sound_volume = 100 // BOOM BABY
	recoil = 4
	wield_recoil = 2
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	fire_delay = 2 SECONDS
	actions_types = list()
	force = 15 // I mean if you're gonna beat someone with the thing you might as well get damage appropriate for how big the fukken thing is

/obj/item/gun/ballistic/automatic/wylom/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)
	AddElement(/datum/element/gun_launches_little_guys, throwing_force = 3, throwing_range = 5)

/obj/item/gun/ballistic/automatic/wylom/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/wylom/examine_more(mob/user)
	. = ..()

	. += "The 'Wyłom' AMR was a weapon not originally made for unaided human hands. \
		The original rifle had mounting points for a specialized suit attachment system, \
		not too much unlike heavy smartguns that can be seen across the galaxy. CIN military \
		command, however, deemed that expensive exoskeletons and rigs for carrying an organic \
		anti material system were simply not needed, and that soldiers should simply 'deal with it'. \
		Unsurprisingly, soldiers assigned this weapon tend to not be a massive fan of that fact, \
		and smekalka within CIN ranks is common with troops finding novel ways to carry and use \
		their large rifles with as little effort as possible. Most of these novel methods, of course, \
		tend to shatter when the rifle is actually fired."

	return .



// Laser rifle (rechargeable magazine) //

/obj/item/gun/ballistic/automatic/laser
	name = "laser rifle"
	desc = "Though sometimes mocked for the relatively weak firepower of their energy weapons, the logistic miracle of rechargeable ammunition has given Nanotrasen a decisive edge over many a foe."
	icon_state = "oldrifle"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "arg"
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge
	empty_indicator = TRUE
	fire_delay = 2
	can_suppress = FALSE
	burst_size = 0
	actions_types = list()
	fire_sound = 'monkestation/sound/weapons/gun/energy/Laser1.ogg'
	casing_ejector = FALSE



//Proto Kinetic SMG, used by miners as part of what ill call "Gun Mining"
//Not actually a PKA, but styled to be like one

/obj/item/gun/ballistic/automatic/proto/pksmg
	name = "proto-kinetic 'Rapier' smg"
	desc = "Using partial ballistic technology and kinetic acceleration, the Mining Research department has managed to make the kinetic accelerator full auto. \
	While the technology is promising, it is held back by certain factors, specifically limited ammo and no mod capacity, but that shouldn't be an issue with its performance."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "pksmg"
	burst_size = 2
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/pksmgmag
	pin = /obj/item/firing_pin/wastes
	bolt_type = BOLT_TYPE_LOCKING
	show_bolt_icon = FALSE
	fire_sound = 'sound/weapons/kenetic_accel.ogg'

//FLASHLIGHTTTTTT
/obj/item/gun/ballistic/automatic/proto/pksmg/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 16)


// KINETIC L6 SAW (LMG dubbed the 'Hellhound')
/obj/item/gun/ballistic/automatic/proto/pksmg/kineticlmg
	name = "Kinetic 'Hellhound' LMG"
	desc = "Using parts from confiscated weapons, the Mining Research team has thrown together \
	A beast of a weapon. Using Proto Kinetic Acceleration technology as per usual, the 'Hellhound' \
	is a LMG chambered in kinetic 7.62 with a incredibly high fire rate, for when you need a beast \
	to kill a beast. Has a fixed unremovable 100 round magazine with a special loading port on the outside, allowing you to \
	to kill a beast. Has a fixed unremovable 150 round magazine with a special loading port on the outside, forcing you to \
	top off and reload using stripper clips."
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	icon_state = "kineticlmg"
	inhand_icon_state = "kineticlmg"
	base_icon_state = "kineticlmg"
	worn_icon_state = "kineticlmg"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	burst_size = 3
	mag_display = FALSE
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/kineticlmg
	weapon_weight = WEAPON_HEAVY
	internal_magazine = TRUE
	spread = 3
	fire_delay = 1
	pin = /obj/item/firing_pin/wastes
	fire_sound = 'sound/weapons/gun/hmg/hmg.ogg'
