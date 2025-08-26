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
	pbk_gentle = TRUE

// Automatic Shotguns//

/obj/item/gun/ballistic/shotgun/automatic
	pbk_gentle = TRUE

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
	pbk_gentle = FALSE
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

// Proto Kinetic Double Barrel, used by miners for "Gun Mining"

/// Caliber used by Ballistic Kinetic weapons for miners (More specifically the proto shotgun)
#define MINER_SHOTGUN "kinetic shotgun"

/obj/item/gun/ballistic/shotgun/doublebarrel/kinetic
	name = "Kinetic 'Slayer' Boomstick"
	desc = "An advanced re-design of the old Proto-Kinetic Shotgun, this model utilizes the same partial ballistic and kinetic acceleration technology in the Proto-Kinetic 'Rapier' SMG but to a much more devestating degree. \
	While it still has the same problems as the PKSMG (No mod capacity, limited ammo) the 'Slayer' Shotgun features devestating firepower, and offers no compromise to any fauna that stands in its way. Rumor has it the \
	Mining Research Director designed this to execute a dissident researcher at a pizza party. <b> Does NOT fit standard 12 gauge shells! Shells tend to get jammed when fired, so you must eject both shells before reloading.</b>"
	icon_state = "protokshotgun"
	inhand_icon_state = "protokshotgun"
	worn_icon_state = "protokshotgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	recoil = 3
	force = 20
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	armour_penetration = 0
	pin = /obj/item/firing_pin/wastes //yes this is required, do NOT remove it
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'monkestation/code/modules/blueshift/sounds/shotgun_heavy.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/dual/kinetic
	unique_reskin = list()
	can_be_sawn_off = FALSE
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("slashes", "cuts", "cleaves", "chops", "swipes")
	attack_verb_simple = list("cleave", "chop", "cut", "swipe", "slash")
	pb_knockback = 0 //you may have your point blank, but you dont get a fling

/obj/item/ammo_box/magazine/internal/shot/dual/kinetic
	name = "kinetic double barrel shotgun internal magazine"
	desc = "how did you break my gun like this, please report whatever you did then feel bad!!!"
	ammo_type = /obj/item/ammo_casing/shotgun/kinetic
	caliber = MINER_SHOTGUN
	max_ammo = 2

//You cant just pry these shells out with your fingers, youll have to eject them by breaking open the shotgun
/obj/item/ammo_box/magazine/internal/shot/dual/kinetic/give_round(obj/item/ammo_casing/R)
	if(!R || !(caliber ? (caliber == R.caliber) : (ammo_type == R.type)))
		return FALSE

	else if (stored_ammo.len < max_ammo)
		stored_ammo += R
		R.forceMove(src)
		return TRUE
	return FALSE

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

/obj/projectile/plasma/kineticshotgun //subtype of plasma instead of kinetic so it can punch through mineable turf. Cant be used off of lavaland or off the wastes of icemoon anyways so...
	name = "magnum kinetic projectile"
	icon_state = "cryoshot"
	damage_type = BRUTE
	damage = 35  //totals 175 damage letting them reach the breakpoint for watcher HP so it one shots them
	range = 7
	dismemberment = 0
	projectile_piercing = PASSMOB
	impact_effect_type = /obj/effect/temp_visual/kinetic_blast
	mine_range = 1
	tracer_type = ""
	muzzle_type = ""
	impact_type = ""

/obj/projectile/plasma/kineticshotgun/sniperslug // long range but cant hit the oneshot breakpoint of a watcher and does not penetrate targets
	name = ".50 BMG kinetic"
	speed = 0.4
	damage = 150
	range = 10
	icon_state = "gaussstrong"
	projectile_piercing = NONE

/obj/projectile/plasma/kineticshotgun/rockbreaker // for breaking rocks
	name = "kinetic rockbreaker"
	speed = 1 //slower than average
	damage = 2
	range = 13
	icon_state = "guardian"
	projectile_piercing = NONE

/obj/item/storage/box/kinetic/shotgun //box
	name = "box of kinetic shells"
	desc = "A box that can hold up to ten shells of Magnum Kinetic Buckshot for the PKShotgun. Fits inside of explorer webbings."
	icon_state = "protoshell_box"
	illustration = "protoshell_box"

/obj/item/storage/box/kinetic/shotgun/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic,
	))

/obj/item/storage/box/kinetic/shotgun/PopulateContents() //populate
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/kinetic(src)

/obj/item/storage/box/kinetic/shotgun/sniperslug //box
	name = "box of .50 BMG Kinetic"
	desc = "A box designed to hold up to ten shells of 50 BMG Slugs for the PKShotgun. Fits inside of explorer webbings."
	icon_state = "bmgshell_box"
	illustration = "bmgshell_box"

/obj/item/storage/box/kinetic/shotgun/sniperslug/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic/sniperslug,
	))

/obj/item/storage/box/kinetic/shotgun/sniperslug/PopulateContents() //populate
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/kinetic/sniperslug(src)

/obj/item/storage/box/kinetic/shotgun/rockbreaker //box
	name = "box of kinetic rock breaker"
	desc = "A box for holding up to twenty shells of Rockbreaker for the PKShotgun. Surprisingly fits inside of explorer webbings."
	icon = 'icons/obj/storage/toolbox.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "ammobox"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/shotgun/rockbreaker/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 20
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic/rockbreaker,
	))

/obj/item/storage/box/kinetic/shotgun/rockbreaker/PopulateContents() //populate
	for(var/i in 1 to 20)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)

/obj/item/storage/box/kinetic/shotgun/bigcase //box
	name = "Kinetic 'Slayer' Shotgun Case"
	desc = "A special and totally original gun case that contains a 'Slayer' Shotgun, eight shells of Rockbreaker, and four shells of Magnum Kinetic Buckshot. Beware, they dont fit back inside once taken out for some reason."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "miner_case"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/shotgun/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 13
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 13
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/shotgun/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/shotgun/doublebarrel/kinetic(src) //the shotgun
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src) //fuck it we do a little bit of bad code :)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src) //8 shells of rockbreaker
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src) //4 shells of kinetic buckshot
		new /obj/item/ammo_casing/shotgun/kinetic(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src)
