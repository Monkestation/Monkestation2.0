/obj/item/gun/ballistic/revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon_state = "revolver"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder
	fire_sound = 'sound/weapons/gun/revolver/shot_alt.ogg'
	load_sound = 'sound/weapons/gun/revolver/load_bullet.ogg'
	eject_sound = 'sound/weapons/gun/revolver/empty.ogg'
	fire_sound_volume = 90
	dry_fire_sound = 'sound/weapons/gun/revolver/dry_fire.ogg'
	casing_ejector = FALSE
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	tac_reloads = FALSE
	var/spin_delay = 10
	var/recent_spin = 0
	var/last_fire = 0
	gun_flags = GUN_SMOKE_PARTICLES
	box_reload_delay = CLICK_CD_RAPID // honestly this is negligible because of the inherent delay of having to switch hands

/obj/item/gun/ballistic/revolver/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	..()
	last_fire = world.time


/obj/item/gun/ballistic/revolver/chamber_round(keep_bullet, spin_cylinder = TRUE, replace_new_round)
	if(!magazine) //if it mag was qdel'd somehow.
		CRASH("revolver tried to chamber a round without a magazine!")
	if(spin_cylinder)
		chambered = magazine.get_round(TRUE)
	else
		chambered = magazine.stored_ammo[1]

/obj/item/gun/ballistic/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	..()
	chamber_round()

/obj/item/gun/ballistic/revolver/click_alt(mob/user)
	spin()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/revolver/fire_sounds()
	var/frequency_to_use = sin((90/magazine?.max_ammo) * get_ammo(TRUE, FALSE)) // fucking REVOLVERS
	var/click_frequency_to_use = 1 - frequency_to_use * 0.75
	var/play_click = sqrt(magazine?.max_ammo) > get_ammo(TRUE, FALSE)
	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
		if(play_click)
			playsound(src, 'sound/weapons/gun/general/ballistic_click.ogg', suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = click_frequency_to_use)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound)
		if(play_click)
			playsound(src, 'sound/weapons/gun/general/ballistic_click.ogg', fire_sound_volume, vary_fire_sound, frequency = click_frequency_to_use)


/obj/item/gun/ballistic/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	var/mob/M = usr

	if(M.stat || !in_range(M,src))
		return

	if (recent_spin > world.time)
		return
	recent_spin = world.time + spin_delay

	if(do_spin())
		playsound(usr, SFX_REVOLVER_SPIN, 30, FALSE)
		usr.visible_message(span_notice("[usr] spins [src]'s chamber."), span_notice("You spin [src]'s chamber."))
	else
		verbs -= /obj/item/gun/ballistic/revolver/verb/spin

/obj/item/gun/ballistic/revolver/proc/do_spin()
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	. = istype(C)
	if(.)
		C.spin()
		chamber_round(spin_cylinder = FALSE)

/obj/item/gun/ballistic/revolver/get_ammo(countchambered = FALSE, countempties = TRUE)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/gun/ballistic/revolver/examine(mob/user)
	. = ..()
	var/live_ammo = get_ammo(FALSE, FALSE)
	. += "[live_ammo ? live_ammo : "None"] of those are live rounds."
	if (current_skin)
		. += "It can be spun with <b>alt+click</b>"

/obj/item/gun/ballistic/revolver/ignition_effect(atom/A, mob/user)
	if(last_fire && last_fire + 15 SECONDS > world.time)
		. = span_notice("[user] touches the end of [src] to \the [A], using the residual heat to ignite it in a puff of smoke. What a badass.")

/obj/item/gun/ballistic/revolver/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/revolver/c38
	name = "\improper .38 revolver"
	desc = "A classic, if not outdated, lethal firearm. Uses .38 Special rounds."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	icon_state = "c38"
	fire_sound = 'sound/weapons/gun/revolver/shot.ogg'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gun/ballistic/revolver/c38/detective
	name = "\improper Colt Detective Special"
	desc = "A classic, if not outdated, law enforcement firearm. Uses .38 Special rounds. \nSome spread rumors that if you loosen the barrel with a wrench, you can \"improve\" it."

	can_modify_ammo = TRUE
	initial_caliber = CALIBER_38
	initial_fire_sound = 'sound/weapons/gun/revolver/shot.ogg'
	alternative_caliber = CALIBER_357
	alternative_fire_sound = 'sound/weapons/gun/revolver/shot_alt.ogg'
	alternative_ammo_misfires = TRUE
	misfire_probability = 0
	misfire_percentage_increment = 25 //about 1 in 4 rounds, which increases rapidly every shot

	obj_flags = UNIQUE_RENAME
	unique_reskin = list(
		"Default" = "c38",
		"Fitz Special" = "c38_fitz",
		"Police Positive Special" = "c38_police",
		"Blued Steel" = "c38_blued",
		"Stainless Steel" = "c38_stainless",
		"Gold Trim" = "c38_trim",
		"Golden" = "c38_gold",
		"The Peacemaker" = "c38_peacemaker",
		"Black Panther" = "c38_panther"
	)

/obj/item/gun/ballistic/revolver/c38/detective/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/revolver/syndicate
	name = "\improper Syndicate Revolver"
	desc = "A modernized 7 round revolver manufactured by Waffle Co. Uses .357 ammo."
	icon_state = "revolversyndie"

/obj/item/gun/ballistic/revolver/syndicate/cowboy
	desc = "A classic revolver, refurbished for modern use. Uses .357 ammo."
	//There's already a cowboy sprite in there!
	icon_state = "lucky"

/obj/item/gun/ballistic/revolver/syndicate/nuclear
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/revolver/mateba
	name = "\improper Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."
	icon_state = "mateba"

/obj/item/gun/ballistic/revolver/mateba/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/revolver/golden
	name = "\improper Golden revolver"
	desc = "This ain't no game, ain't never been no show, And I'll gladly gun down the oldest lady you know. Uses .357 ammo."
	icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	recoil = 8
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/revolver/nagant
	name = "\improper Nagant revolver"
	desc = "An old model of revolver that originated in Russia. Able to be suppressed. Uses 7.62x38mmR ammo."
	icon_state = "nagant"
	can_suppress = TRUE

	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/gun/ballistic/revolver/russian
	name = "\improper Russian revolver"
	desc = "A Russian-made revolver for drinking games. Uses .357 ammo, and has a mechanism requiring you to spin the chamber before each trigger pull."
	icon_state = "russianrevolver"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rus357
	var/spun = FALSE
	hidden_chambered = TRUE //Cheater.
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/ballistic/revolver/russian/do_spin()
	. = ..()
	if(.)
		spun = TRUE

/obj/item/gun/ballistic/revolver/russian/attackby(obj/item/A, mob/user, params)
	..()
	if(get_ammo() > 0)
		spin()
	update_appearance()
	A.update_appearance()
	return

/obj/item/gun/ballistic/revolver/russian/can_trigger_gun(mob/living/user, akimbo_usage)
	if(akimbo_usage)
		return FALSE
	return ..()

/obj/item/gun/ballistic/revolver/russian/attack_self(mob/user)
	if(!spun)
		spin()
		spun = TRUE
		return
	..()

/obj/item/gun/ballistic/revolver/russian/fire_gun(atom/target, mob/living/user, flag, params)
	. = ..(null, user, flag, params)

	if(flag)
		if(!(target in user.contents) && ismob(target))
			if((user.istate & ISTATE_HARM)) // Flogging action
				return

	if(isliving(user))
		if(!can_trigger_gun(user))
			return
	if(target != user)
		playsound(src, dry_fire_sound, 30, TRUE)
		user.visible_message(
			span_danger("[user.name] tries to fire \the [src] at the same time, but only succeeds at looking like an idiot."), \
			span_danger("\The [src]'s anti-combat mechanism prevents you from firing it at anyone but yourself!"))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!spun)
			to_chat(user, span_warning("You need to spin \the [src]'s chamber first!"))
			return

		spun = FALSE

		var/zone = check_zone(user.zone_selected)
		var/obj/item/bodypart/affecting = H.get_bodypart(zone)
		var/is_target_face = zone == BODY_ZONE_HEAD || zone == BODY_ZONE_PRECISE_EYES || zone == BODY_ZONE_PRECISE_MOUTH
		var/loaded_rounds = get_ammo(FALSE, FALSE) // check before it is fired

		if(loaded_rounds && is_target_face)
			add_memory_in_range(user, 7, /datum/memory/witnessed_russian_roulette, \
				protagonist = user, \
				antagonist = src, \
				rounds_loaded = loaded_rounds, \
				aimed_at =  affecting.name, \
				result = (chambered ? "lost" : "won"))

		if(chambered)
			if(HAS_TRAIT(user, TRAIT_CURSED)) // I cannot live, I cannot die, trapped in myself, body my holding cell.
				to_chat(user, span_warning("What a horrible night... To have a curse!"))
				return
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire_casing(user, user, params, distro = 0, quiet = 0, zone_override = null, spread = 0, fired_from = src))
				playsound(user, fire_sound, fire_sound_volume, vary_fire_sound)
				if(is_target_face)
					shoot_self(user, affecting)
				else
					user.visible_message(span_danger("[user.name] cowardly fires [src] at [user.p_their()] [affecting.name]!"), span_userdanger("You cowardly fire [src] at your [affecting.name]!"), span_hear("You hear a gunshot!"))
				chambered = null
				user.add_mood_event("russian_roulette_lose", /datum/mood_event/russian_roulette_lose)
				return

		if(loaded_rounds && is_target_face)
			user.add_mood_event("russian_roulette_win", /datum/mood_event/russian_roulette_win, loaded_rounds)

		user.visible_message(span_danger("*click*"))
		playsound(src, dry_fire_sound, 30, TRUE)

/obj/item/gun/ballistic/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = BODY_ZONE_HEAD)
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message(span_danger("[user.name] fires [src] at [user.p_their()] head!"), span_userdanger("You fire [src] at your head!"), span_hear("You hear a gunshot!"))

/obj/item/gun/ballistic/revolver/russian/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/revolver/russian/soul
	name = "cursed Russian revolver"
	desc = "To play with this revolver requires wagering your very soul."

/obj/item/gun/ballistic/revolver/russian/soul/shoot_self(mob/living/user)
	. = ..()
	var/obj/item/soulstone/anybody/revolver/stone = new /obj/item/soulstone/anybody/revolver(get_turf(src))
	if(!stone.capture_soul(user, forced = TRUE)) //Something went wrong
		qdel(stone)
		return
	user.visible_message(span_danger("[user.name]'s soul is captured by \the [src]!"), span_userdanger("You've lost the gamble! Your soul is forfeit!"))

/obj/item/gun/ballistic/revolver/reverse //Fires directly at its user... unless the user is a clown, of course.
	name = "\improper Syndicate Revolver"
	clumsy_check = FALSE
	icon_state = "revolversyndie"

/obj/item/gun/ballistic/revolver/reverse/can_trigger_gun(mob/living/user, akimbo_usage)
	if(akimbo_usage)
		return FALSE
	if(HAS_TRAIT(user, TRAIT_CLUMSY) || is_clown_job(user.mind?.assigned_role))
		return ..()
	if(process_fire(user, user, FALSE, null, BODY_ZONE_HEAD))
		user.visible_message(span_warning("[user] somehow manages to shoot [user.p_them()]self in the face!"), span_userdanger("You somehow shoot yourself in the face! How the hell?!"))
		user.emote("scream")
		user.drop_all_held_items()
		user.Paralyze(80)

///Blueshift guns

// .35 Sol mini revolver

/obj/item/gun/ballistic/revolver/sol
	name = "\improper Eland Revolver"
	desc = "A small revolver with a comically short barrel and cylinder space for eight .35 Sol Short rounds."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "eland"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/c35sol
	suppressor_x_offset = 3
	w_class = WEIGHT_CLASS_SMALL
	can_suppress = TRUE

/obj/item/gun/ballistic/revolver/sol/evil
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/revolver/sol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/revolver/sol/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/revolver/sol/examine_more(mob/user)
	. = ..()

	. += "The Eland is one of the few Trappiste weapons not made for military contract. \
		Instead, the Eland started life as a police weapon, offered as a gun to finally \
		outmatch all others in the cheap police weapons market. Unfortunately, this \
		coincided with nearly every SolFed police force realising they are actually \
		comically overfunded. With military weapons bought for police forces taking \
		over the market, the Eland instead found home in the civilian personal defense \
		market. That is likely the reason you are looking at this one now."

	return .


// .585 super revolver. INSANELY slow fire rate for the damage

/obj/item/gun/ballistic/revolver/takbok
	name = "\improper Takbok Revolver"
	desc = "A hefty revolver with an equally large cylinder capable of holding five .585 Trappiste rounds."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "takbok"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/revolver_heavy.ogg'
	suppressed_sound = 'monkestation/code/modules/blueshift/sounds/suppressed_heavy.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/c585trappiste
	suppressor_x_offset = 5
	can_suppress = TRUE
	fire_delay = 1 SECONDS
	recoil = 3
	wield_recoil = 1

/obj/item/gun/ballistic/revolver/takbok/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/revolver/takbok/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/revolver/takbok/examine_more(mob/user)
	. = ..()

	. += "The Takbok is a unique design for Trappiste for the sole reason that it \
		was made at first to be a one-off. Founder of partner company Carwo Defense, \
		Darmaan Khaali Carwo herself, requested a sporting revolver from Trappiste. \
		What was delivered wasn't a target revolver, it was a target crusher. The \
		weapon became popular as Carwo crushed many shooting competitions using \
		the Takbok, with the design going on several production runs up until \
		2523 when the popularity of the gun fell off. Due to the number of revolvers \
		made, they are still easy enough to find if you look despite production \
		having already ceased many years ago."

	return .

// Blueshields custom takbok revolver.
/obj/item/gun/ballistic/revolver/takbok/blueshield
	name = "unmarked takbok revolver" //Give it a unique prefix compared hellfire's 'modified' to stand out
	icon_state = "takbok_blueshield"
	desc = "A modified revolver resembling that of Trappiste's signature Takbok, notably lacking any of the company's orginal markings or traceable identifaction. The custom modifactions allows it to shoot the five .585 Trappiste rounds in its cylinder quicker and with more consistancy."

	//In comparasion to the orginal's fire_delay = 1 second, recoil = 3, wield_recoil = 1
	fire_delay = 0.6 SECONDS
	recoil = 2
	wield_recoil = 0.8
	projectile_damage_multiplier = 1.3

/obj/item/gun/ballistic/revolver/takbok/blueshield/give_manufacturer_examine()
	RemoveElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)
	AddElement(/datum/element/manufacturer_examine, COMPANY_REMOVED)

/obj/item/gun/ballistic/revolver/takbok/blueshield/examine_more(mob/user)
	. = ..()
	//Basically, it is a short continuation story of the original takbok about fans continuing their passion for an idea or project. Still, the original company stopped them despite the innovations they brought. And the ‘C’ is a callback to their inspirational figure ‘Cawgo’
	. += ""
	. += "After the production run of the original Takbok \
		ended in 2523 alongside its popularity, enthusiasts of the sidearm continued \
		to tinker with the make of the weapon to keep it with modern standards for \
		firearms, despite Trappiste's license on the design. This unusual passion \
		for the weapon led to variations with few to no identifying marks besides \
		the occasional 'C' carved into the hilt of the gun. As a consequence of its \
		production methods, it is unable to be distributed through conventional means \
		despite the typical assessment of most being an improved model."
	return .


///.45 Long revolver, cargo cowboy gun

/obj/item/gun/ballistic/revolver/r45l
	name = "\improper .45 Long Revolver"
	desc = "A cheap .45 Long Revolver. Pray the timing keeps."
	icon_state = "45revolver"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45l
	obj_flags = UNIQUE_RENAME

	unique_reskin = list("Default" = "45revolver",
						"Cowboy" = "357colt",
						"Lucky" = "lucky" //Well do ya?
						)


// 45-70 GOV "MINING" REVOLVER

/obj/item/gun/ballistic/revolver/govmining
	name = "45-70 GOV 'Duster' Revolver"
	desc = "A .45-70 cartridge adapted to Proto Kinetic Acceleration technology has proven \
	very effective for taking down the heavy hitting local fauna, making this a rather useful \
	option to carry out into the wilds. Comes with a spin nanochip in the grip that grants \
	the wielder the dexterity to spin the revolver to eject the casings. Why it was designed to \
	only eject the casings when spun, we cant be sure, but the Mining Research Director said \
	that 'it will be really cool trust me'."
	icon_state = "miningbigiron"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/govmining
	fire_sound = 'monkestation/code/modules/blueshift/sounds/revolver_heavy.ogg'
	load_sound = 'sound/weapons/gun/revolver/load_bullet.ogg'
	eject_sound = 'sound/weapons/gun/revolver/empty.ogg'
	fire_sound_volume = 100
	dry_fire_sound = 'sound/weapons/gun/revolver/dry_fire.ogg'
	pin = /obj/item/firing_pin/wastes

/obj/item/gun/ballistic/revolver/govmining/give_manufacturer_examine()
	RemoveElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH) //So this gun was made in house by nanotrasen's mining research team, it was NOT made by Scarborough


/obj/item/gun/ballistic/revolver/govmining/attack_self(mob/living/user) //you do a sick flip when you empty the rounds
	SpinAnimation(4,2)
	if(flip_cooldown <= world.time)
		flip_cooldown = (world.time + 30)
		user.visible_message(span_notice("[user] spins [src] around [user.p_their()] finger by the trigger, ejecting any loaded cartridges!"))
		playsound(src, 'sound/items/handling/ammobox_pickup.ogg', 20, FALSE)
	. = ..()

