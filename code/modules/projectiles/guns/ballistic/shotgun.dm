/obj/item/gun/ballistic/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	worn_icon_state = null
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_icon_state = "shotgun"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	fire_sound = 'sound/weapons/gun/shotgun/shot.ogg'
	fire_sound_volume = 90
	rack_sound = 'sound/weapons/gun/shotgun/rack.ogg'
	load_sound = 'sound/weapons/gun/shotgun/insert_shell.ogg'
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot
	semi_auto = FALSE
	internal_magazine = TRUE
	casing_ejector = FALSE
	bolt_wording = "pump"
	cartridge_wording = "shell"
	tac_reloads = FALSE
	weapon_weight = WEAPON_HEAVY

	pb_knockback = 2
	gun_flags = GUN_SMOKE_PARTICLES

/obj/item/gun/ballistic/shotgun/blow_up(mob/user)
	. = 0
	if(chambered?.loaded_projectile)
		process_fire(user, user, FALSE)
		. = 1

/obj/item/gun/ballistic/shotgun/lethal
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/gun/ballistic/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	inhand_icon_state = "shotgun"
	fire_delay = 8
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."
	can_be_sawn_off = TRUE

/obj/item/gun/ballistic/shotgun/riot/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

// SolFed shotgun (I.E resprited riot shotgun from blueshift)

/obj/item/gun/ballistic/shotgun/riot/sol
	name = "\improper Renoster Shotgun"
	desc = "A twelve gauge shotgun with a six shell capacity underneath. Made for and used by SolFed's various military branches."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns48x.dmi'
	icon_state = "renoster"

	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "renoster"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "renoster"

	inhand_x_dimension = 32
	inhand_y_dimension = 32

	SET_BASE_PIXEL(-8, 0)

	fire_sound = 'monkestation/code/modules/blueshift/sounds/shotgun_heavy.ogg'
	rack_sound = 'monkestation/code/modules/blueshift/sounds/shotgun_rack.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_heavy.ogg'
	can_suppress = TRUE

	suppressor_x_offset = 9

	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE

/obj/item/gun/ballistic/shotgun/riot/sol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/shotgun/riot/sol/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/shotgun/riot/sol/examine_more(mob/user)
	. = ..()

	. += "The Renoster was designed at its core as a police shotgun. \
		As consequence, it holds all the qualities a police force would want \
		in one. Large shell capacity, sturdy frame, while holding enough \
		capacity for modification to satiate even the most overfunded of \
		peacekeeper forces. Inevitably, the weapon made its way into civilian \
		markets alongside its sale to several military branches that also \
		saw value in having a heavy shotgun."

	return .

/obj/item/gun/ballistic/shotgun/riot/sol/update_appearance(updates)
	if(sawn_off)
		suppressor_x_offset = 0
		SET_BASE_PIXEL(0, 0)

	. = ..()

// Shotgun but EVIL!

/obj/item/gun/ballistic/shotgun/riot/sol/evil
	desc = "A twleve guage shotgun with an eight shell capacity underneath. This one is painted in a tacticool black."

	icon_state = "renoster_evil"
	worn_icon_state = "renoster_evil"
	inhand_icon_state = "renoster_evil"
	projectile_wound_bonus = 15
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/shotgun/riot/sol/evil/unrestricted
	pin = /obj/item/firing_pin

// Automatic Shotguns//

/obj/item/gun/ballistic/shotgun/automatic/shoot_live_shot(mob/living/user)
	..()
	rack()

/obj/item/gun/ballistic/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	inhand_icon_state = "shotgun_combat"
	fire_delay = 8
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_HUGE
	pbk_gentle = TRUE

/obj/item/gun/ballistic/shotgun/automatic/combat/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	name = "compact shotgun"
	desc = "A compact version of the semi automatic combat shotgun. For close encounters."
	icon_state = "cshotgunc"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/com/compact
	w_class = WEIGHT_CLASS_BULKY


//Dual Feed Shotgun

/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	inhand_icon_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "cshotgun"
	w_class = WEIGHT_CLASS_HUGE
	semi_auto = TRUE
	projectile_damage_multiplier = 1.2
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/tube
	/// If defined, the secondary tube is this type, if you want different shell loads
	var/alt_accepted_magazine_type
	/// If TRUE, we're drawing from the alternate_magazine
	var/toggled = FALSE
	/// The B tube
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/bounty
	name = "bounty cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes. This one shows signs of bounty hunting customization, meaning it likely has a dual rubber shot/fire slug load."
	//alt_accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/tube/fire   monkestation edit

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to pump it.")

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	alt_accepted_magazine_type = alt_accepted_magazine_type || accepted_magazine_type
	alternate_magazine = new alt_accepted_magazine_type(src)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/Destroy()
	QDEL_NULL(alternate_magazine)
	return ..()

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		rack()
	else
		toggle_tube(user)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		balloon_alert(user, "switched to tube B")
	else
		balloon_alert(user, "switched to tube A")

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS))
		return
	rack()

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

// Bulldog shotgun //

/obj/item/gun/ballistic/shotgun/bulldog
	name = "\improper Bulldog Shotgun"
	desc = "A semi-auto, mag-fed shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines. Can have a secondary magazine attached to quickly swap between ammo types, or just to keep shooting."
	icon_state = "bulldog"
	inhand_icon_state = "bulldog"
	worn_icon_state = "cshotgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	weapon_weight = WEAPON_MEDIUM
	accepted_magazine_type = /obj/item/ammo_box/magazine/m12g
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0
	pin = /obj/item/firing_pin/implant/pindicate
	fire_sound = 'sound/weapons/gun/shotgun/shot_alt.ogg'
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	empty_alarm = TRUE
	special_mags = TRUE
	mag_display_ammo = TRUE
	semi_auto = TRUE
	internal_magazine = FALSE
	tac_reloads = TRUE
	projectile_damage_multiplier = 1.2
	casing_ejector = TRUE
	///the type of secondary magazine for the bulldog
	var/secondary_magazine_type
	///the secondary magazine
	var/obj/item/ammo_box/magazine/secondary_magazine

/obj/item/gun/ballistic/shotgun/bulldog/Initialize(mapload)
	. = ..()
	secondary_magazine_type = secondary_magazine_type || accepted_magazine_type
	secondary_magazine = new secondary_magazine_type(src)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/gun/ballistic/shotgun/bulldog/Destroy()
	QDEL_NULL(secondary_magazine)
	return ..()

/obj/item/gun/ballistic/shotgun/bulldog/examine(mob/user)
	. = ..()
	if(secondary_magazine)
		var/secondary_ammo_count = secondary_magazine.ammo_count()
		. += "There is a secondary magazine."
		. += "It has [secondary_ammo_count] round\s remaining."
		. += "Shoot with right-click to swap to the secondary magazine after firing."
		. += "If the magazine is empty, [src] will automatically swap to the secondary magazine."
	. += "You can load a secondary magazine by right-clicking [src] with the magazine you want to load."
	. += "You can remove a secondary magazine by alt-right-clicking [src]."
	. += "Right-click to swap the magazine to the secondary position, and vice versa."

/obj/item/gun/ballistic/shotgun/bulldog/update_overlays()
	. = ..()
	if(secondary_magazine)
		. += "[icon_state]_secondary_mag_[initial(secondary_magazine.icon_state)]"
		if(!secondary_magazine.ammo_count())
			. += "[icon_state]_secondary_mag_empty"
	else
		. += "[icon_state]_no_secondary_mag"

/obj/item/gun/ballistic/shotgun/bulldog/handle_chamber(mob/living/user, empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	if(!secondary_magazine)
		return ..()
	var/secondary_shells_left = LAZYLEN(secondary_magazine.stored_ammo)
	if(magazine)
		var/shells_left = LAZYLEN(magazine.stored_ammo)
		if(shells_left <= 0 && secondary_shells_left >= 1)
			toggle_magazine()
	else
		toggle_magazine()
	return ..()

/obj/item/gun/ballistic/shotgun/bulldog/attack_self_secondary(mob/user, modifiers)
	toggle_magazine()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/ballistic/shotgun/bulldog/afterattack_secondary(mob/living/victim, mob/living/user, params)
	if(secondary_magazine)
		toggle_magazine()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CALL_NORMAL

/obj/item/gun/ballistic/shotgun/bulldog/attackby_secondary(obj/item/weapon, mob/user, params)
	if(!istype(weapon, secondary_magazine_type))
		balloon_alert(user, "[weapon.name] doesn't fit!")
		return SECONDARY_ATTACK_CALL_NORMAL
	if(!user.transferItemToLoc(weapon, src))
		to_chat(user, span_warning("You cannot seem to get [src] out of your hands!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/item/ammo_box/magazine/old_mag = secondary_magazine
	secondary_magazine = weapon
	if(old_mag)
		user.put_in_hands(old_mag)
		old_mag.update_appearance()
	balloon_alert(user, "secondary [magazine_wording] loaded")
	playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	update_appearance(UPDATE_OVERLAYS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/ballistic/shotgun/bulldog/alt_click_secondary(mob/user)
	if(secondary_magazine)
		var/obj/item/ammo_box/magazine/old_mag = secondary_magazine
		secondary_magazine = null
		user.put_in_hands(old_mag)
		old_mag.update_appearance()
		update_appearance(UPDATE_OVERLAYS)
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/ballistic/shotgun/bulldog/proc/toggle_magazine()
	var/rechamber = FALSE
	if(magazine && chambered)
		if(chambered.loaded_projectile && magazine.stored_ammo.len < magazine.max_ammo)
			magazine.give_round(chambered, 0)
			chambered = null
			rechamber = TRUE

	var/primary_magazine = magazine
	var/alternative_magazine = secondary_magazine

	magazine = alternative_magazine
	secondary_magazine = primary_magazine
	playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	if(rechamber && magazine)
		chamber_round()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/shotgun/bulldog/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/gun/ballistic/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	inhand_icon_state = "shotgun_db"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	force = 10
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/dual
	sawn_desc = "Omar's coming!"
	obj_flags = UNIQUE_RENAME
	rack_sound_volume = 0
	unique_reskin = list("Default" = "dshotgun",
						"Dark Red Finish" = "dshotgun_d",
						"Ash" = "dshotgun_f",
						"Faded Grey" = "dshotgun_g",
						"Maple" = "dshotgun_l",
						"Rosewood" = "dshotgun_p"
						)
	semi_auto = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	can_be_sawn_off = TRUE
	pb_knockback = 3 // it's a super shotgun!

/obj/item/gun/ballistic/shotgun/doublebarrel/AltClick(mob/user)
	. = ..()
	if(unique_reskin && !current_skin && user.can_perform_action(src, NEED_DEXTERITY))
		reskin_obj(user)

/obj/item/gun/ballistic/shotgun/doublebarrel/sawoff(mob/user)
	. = ..()
	if(.)
		weapon_weight = WEAPON_MEDIUM

/obj/item/gun/ballistic/shotgun/doublebarrel/slugs
	name = "hunting shotgun"
	desc = "A hunting shotgun used by the wealthy to hunt \"game\"."
	sawn_desc = "A sawn-off hunting shotgun. In its new state, it's remarkably less effective at hunting... anything."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/dual/slugs

/obj/item/gun/ballistic/shotgun/doublebarrel/breacherslug
	name = "breaching shotgun"
	desc = "A normal double-barrel shotgun that has been rechambered to fit breaching shells. Useful in breaching airlocks and windows, not much else."
	sawn_desc = "A sawn-off breaching shotgun, making for a more compact configuration while still having the same capability as before."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/dual/breacherslug

/obj/item/gun/ballistic/shotgun/hook
	name = "hook modified sawn-off shotgun"
	desc = "Range isn't an issue when you can bring your victim to you."
	icon_state = "hookshotgun"
	inhand_icon_state = "hookshotgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/bounty
	weapon_weight = WEAPON_MEDIUM
	semi_auto = TRUE
	flags_1 = CONDUCT_1
	force = 18 //it has a hook on it
	sharpness = SHARP_POINTY //it does in fact, have a hook on it
	attack_verb_continuous = list("slashes", "hooks", "stabs")
	attack_verb_simple = list("slash", "hook", "stab")
	hitsound = 'sound/weapons/bladeslice.ogg'
	//our hook gun!
	var/obj/item/gun/magic/hook/bounty/hook

/obj/item/gun/ballistic/shotgun/hook/Initialize(mapload)
	. = ..()
	hook = new /obj/item/gun/magic/hook/bounty(src)

/obj/item/gun/ballistic/shotgun/hook/Destroy()
	QDEL_NULL(hook)
	return ..()

/obj/item/gun/ballistic/shotgun/hook/examine(mob/user)
	. = ..()
	. += span_notice("Right-click to shoot the hook.")

/obj/item/gun/ballistic/shotgun/hook/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	hook.afterattack(target, user, proximity_flag, click_parameters)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// A shotgun, but tis a revolver (Blueshift again)
// Woe, buckshot be upon ye

/obj/item/gun/ballistic/revolver/shotgun_revolver
	name = "\improper Bóbr 12 GA revolver"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. A revolver type design with a four shell cylinder. That's right, shell, this one shoots twelve guage."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev12ga
	recoil = SAWN_OFF_RECOIL
	wield_recoil = SAWN_OFF_RECOIL * 0.5
	weapon_weight = WEAPON_MEDIUM
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/guns_32.dmi'
	icon_state = "bobr"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/revolver_fire.ogg'
	spread = SAWN_OFF_ACC_PENALTY
	projectile_damage_multiplier = 0.75 /// No way in hell a handgun with a 3 inch barrel should fire the same cartridge with the same force as a full-length barrel
	projectile_wound_bonus = -5  /// In addition, this should help with the balance issues around the Bobr, it being a concealable shotgun with near-instant reload

/obj/item/gun/ballistic/revolver/shotgun_revolver/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SZOT)

/obj/item/gun/ballistic/revolver/shotgun_revolver/examine_more(mob/user)
	. = ..()

	. += "The 'Bóbr' started development as a limited run sporting weapon before \
		the military took interest. The market quickly changed from sport shooting \
		targets, to sport shooting SolFed strike teams once the conflict broke out. \
		This pattern is different from the original civilian version, with a military \
		standard pistol grip and weather resistant finish. While the 'Bóbr' was not \
		a weapon standard issued to every CIN soldier, it was available for relatively \
		cheap, and thus became rather popular among the ranks."

	return .

