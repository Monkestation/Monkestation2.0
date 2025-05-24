/obj/item/clothing/head/wizard/magus
	name = "magus helm"
	icon_state = "magus"
	inhand_icon_state = null
	desc = "A helm worn by the followers of Nar'Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor_type = /datum/armor/wizard_magus
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/datum/armor/wizard_magus
	melee = 50
	bullet = 30
	laser = 50
	energy = 50
	bomb = 25
	bio = 10
	fire = 10
	acid = 10

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar'Sie."
	icon_state = "magusred"
	icon = 'icons/obj/clothing/suits/wizard.dmi'
	worn_icon = 'icons/mob/clothing/suits/wizard.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/suit_magusred
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/datum/armor/suit_magusred
	melee = 50
	bullet = 30
	laser = 50
	energy = 50
	bomb = 25
	bio = 10
	fire = 10
	acid = 10

/obj/item/sharpener/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon_state = "cult_sharpener"
	uses = 1
	increment = 5
	max = 40
	prefix = "darkened"

/obj/item/sharpener/cult/update_icon_state()
	icon_state = "cult_sharpener[(uses == 0) ? "_used" : ""]"
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "Empowered armor which creates a powerful shield around the user."
	icon_state = "cult_armor"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	armor_type = /datum/armor/cultrobes_cult_shield
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/cult_shield

/datum/armor/cultrobes_cult_shield
	melee = 50
	bullet = 40
	laser = 50
	energy = 50
	bomb = 50
	bio = 30
	fire = 50
	acid = 60

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/setup_shielding()
	AddComponent(/datum/component/shielded, recharge_start_delay = 0 SECONDS, shield_icon_file = 'icons/effects/cult/effects.dmi', shield_icon = "shield-cult", run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)))

/// A proc for callback when the shield breaks, since cult robes are stupid and have different effects
/obj/item/clothing/suit/hooded/cultrobes/cult_shield/proc/shield_damaged(mob/living/wearer, attack_text, new_current_charges)
	wearer.visible_message(span_danger("[wearer]'s robes neutralize [attack_text] in a burst of blood-red sparks!"))
	new /obj/effect/temp_visual/cult/sparks(get_turf(wearer))
	if(new_current_charges == 0)
		wearer.visible_message(span_danger("The runed shield around [wearer] suddenly disappears!"))

/obj/item/clothing/head/hooded/cult_hoodie/cult_shield
	name = "empowered cultist helmet"
	desc = "Empowered helmet which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor_type = /datum/armor/cult_hoodie_cult_shield

/datum/armor/cult_hoodie_cult_shield
	melee = 50
	bullet = 40
	laser = 50
	energy = 50
	bomb = 50
	bio = 30
	fire = 50
	acid = 60

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage. Provides an even greater speed boost if its hood is worn."
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/cultrobes_berserker
	slowdown = -0.3 //the hood gives an additional -0.3 if you have it flipped up, for a total of -0.6
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/berserkerhood

/datum/armor/cultrobes_berserker
	melee = -45
	bullet = -45
	laser = -45
	energy = -55
	bomb = -45

/obj/item/clothing/head/hooded/cult_hoodie/berserkerhood
	name = "flagellant's hood"
	desc = "A blood-soaked hood infused with dark magic."
	armor_type = /datum/armor/cult_hoodie_berserkerhood
	slowdown = -0.3

/datum/armor/cult_hoodie_berserkerhood
	melee = -45
	bullet = -45
	laser = -45
	energy = -55
	bomb = -45

/obj/item/clothing/suit/hooded/cultrobes/berserker/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "May Nar'Sie guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	inhand_icon_state = "blindfold"
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(user.stat != DEAD && !IS_CULTIST(user) && (slot & ITEM_SLOT_EYES))
		to_chat(user, span_cultlarge("\"You want to be blind, do you?\""))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)
		user.adjust_temp_blindness(60 SECONDS)

/obj/item/reagent_containers/cup/beaker/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; reinvigorating to the faithful - this flask may be sipped or thrown."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "holyflask"
	inhand_icon_state = "holyflask"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	color = "#333333"
	list_reagents = list(/datum/reagent/fuel/unholywater = 50)

///how many times can the shuttle be cursed?
#define MAX_SHUTTLE_CURSES 3
///if the max number of shuttle curses are used within this duration, the entire cult gets an achievement
#define SHUTTLE_CURSE_OMFG_TIMESPAN (10 SECONDS)

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the emergency escape shuttle. "
	icon = 'icons/obj/cult/items_and_weapons.dmi'
	icon_state = "shuttlecurse"
	///how many times has the shuttle been cursed so far?
	var/static/totalcurses = 0
	///when was the first shuttle curse?
	var/static/first_curse_time
	///curse messages that have already been used
	var/static/list/remaining_curses

/obj/item/shuttle_curse/attack_self(mob/living/user)
	if(!IS_CULTIST(user))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(100)
		to_chat(user, span_warning("A powerful force shoves you away from [src]!"))
		return
	if(totalcurses >= MAX_SHUTTLE_CURSES)
		to_chat(user, span_warning("You try to shatter the orb, but it remains as solid as a rock!"))
		to_chat(user, span_danger(span_big("It seems that the blood cult has exhausted its ability to curse the emergency escape shuttle. It would be unwise to create more cursed orbs or to continue to try to shatter this one.")))
		return
	if(locate(/obj/narsie) in SSpoints_of_interest.narsies)
		to_chat(user, span_warning("Nar'Sie is already on this plane, there is no delaying the end of all things."))
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 3 MINUTES
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		var/security_num = SSsecurity_level.get_current_level_as_number()
		var/set_coefficient = 1

		if(totalcurses == 0)
			first_curse_time = world.time

		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1
			else
				set_coefficient = 0.5
		var/surplus = timer - (SSshuttle.emergency_call_time * set_coefficient)
		SSshuttle.emergency.setTimer(timer)
		if(surplus > 0)
			SSshuttle.block_recall(surplus)
		totalcurses++
		to_chat(user, span_danger("You shatter the orb! A dark essence spirals into the air, then disappears."))
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, TRUE)

		if(!remaining_curses)
			remaining_curses = strings(CULT_SHUTTLE_CURSE, "curse_announce")

		var/curse_message = pick_n_take(remaining_curses) || "Something has gone horrendously wrong..."

		curse_message += " The shuttle will be delayed by three minutes."
		priority_announce("[curse_message]", "System Failure", 'sound/misc/notice1.ogg')
		if(MAX_SHUTTLE_CURSES-totalcurses <= 0)
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can no longer be cursed. It would be unwise to create more cursed orbs.")))
		else if(MAX_SHUTTLE_CURSES-totalcurses == 1)
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can only be cursed one more time.")))
		else
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can only be cursed [MAX_SHUTTLE_CURSES-totalcurses] more times.")))

		if(totalcurses >= MAX_SHUTTLE_CURSES && (world.time < first_curse_time + SHUTTLE_CURSE_OMFG_TIMESPAN))
			var/omfg_message = pick_list(CULT_SHUTTLE_CURSE, "omfg_announce") || "LEAVE US ALONE!"
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), omfg_message, "Priority Alert", 'sound/misc/announce_syndi.ogg', null, "Nanotrasen Department of Transportation: Central Command"), rand(2 SECONDS, 6 SECONDS))
			for(var/mob/iter_player as anything in GLOB.player_list)
				if(IS_CULTIST(iter_player))
					iter_player.client?.give_award(/datum/award/achievement/misc/cult_shuttle_omfg, iter_player)

		qdel(src)

#undef MAX_SHUTTLE_CURSES

/obj/item/cult_shift
	name = "veil shifter"
	desc = "This relic instantly teleports you, and anything you're pulling, forward by a moderate distance."
	icon = 'icons/obj/cult/items_and_weapons.dmi'
	icon_state ="shifter"
	///How many uses does the item have before becoming inert
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += span_cult("It has [uses] use\s remaining.")
	else
		. += span_cult("It seems drained.")

///Handles teleporting the atom we're pulling along with us when using the shifter
/obj/item/cult_shift/proc/handle_teleport_grab(turf/target_turf, mob/user)
	var/mob/living/carbon/pulling_user = user
	if(pulling_user.pulling)
		var/atom/movable/pulled = pulling_user.pulling
		do_teleport(pulled, target_turf, channel = TELEPORT_CHANNEL_CULT)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, span_warning("\The [src] is dull and unmoving in your hands."))
		return
	if(!IS_CULTIST(user))
		user.dropItemToGround(src, TRUE)
		step(src, pick(GLOB.alldirs))
		to_chat(user, span_warning("\The [src] flickers out of your hands, your connection to this dimension is too strong!"))
		return

	//The user of the shifter
	var/mob/living/carbon/user_cultist = user
	//Initial teleport location
	var/turf/mobloc = get_turf(user_cultist)
	//Teleport target turf, with some error to spice it up
	var/turf/destination = get_teleport_loc(location = mobloc, target = user_cultist, distance = 9, density_check = TRUE, errorx = 3, errory = 1, eoffsety = 1)
	//The atom the user was pulling when using the shifter; we handle it here before teleporting the user as to not lose their 'pulling' var
	var/atom/movable/pulled = handle_teleport_grab(destination, user_cultist)

	if(!destination || !do_teleport(user_cultist, destination, channel = TELEPORT_CHANNEL_CULT))
		playsound(src, 'sound/items/haunted/ghostitemattack.ogg', 100, TRUE)
		balloon_alert(user, "teleport failed!")
		return

	uses--
	if(uses <= 0)
		icon_state = "shifter_drained"

	if(pulled)
		user_cultist.start_pulling(pulled) //forcemove (teleporting) resets pulls, so we need to re-pull

	new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, user_cultist.dir)
	new /obj/effect/temp_visual/dir_setting/cult/phase(destination, user_cultist.dir)

	playsound(mobloc, 'sound/effects/portal_travel.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, 'sound/effects/phasein.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, 'sound/effects/portal_travel.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/flashlight/flare/culttorch
	name = "void torch"
	desc = "Used by veteran cultists to instantly transport items to their needful brethren."
	w_class = WEIGHT_CLASS_SMALL
	light_outer_range = 1
	icon_state = "torch"
	inhand_icon_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	color = "#ff0000"
	on_damage = 15
	slot_flags = null
	on = TRUE
	var/charges = 5

/obj/item/flashlight/flare/culttorch/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return
	if(!IS_CULTIST(user))
		to_chat(user, "That doesn't seem to do anything useful.")
		return

	if(!isitem(A))
		..()
		to_chat(user, span_warning("\The [src] can only transport items!"))
		return

	. |= AFTERATTACK_PROCESSED_ITEM

	var/list/cultists = list()
	for(var/datum/mind/M as anything in get_antag_minds(/datum/antagonist/cult))
		if(M.current && M.current.stat != DEAD)
			cultists |= M.current
	var/mob/living/cultist_to_receive = tgui_input_list(user, "Who do you wish to call to [src]?", "Followers of the Geometer", (cultists - user))
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(isnull(cultist_to_receive))
		to_chat(user, "<span class='cult italic'>You require a destination!</span>")
		log_game("[key_name(user)]'s Void torch failed - no target.")
		return
	if(cultist_to_receive.stat == DEAD)
		to_chat(user, "<span class='cult italic'>[cultist_to_receive] has died!</span>")
		log_game("[key_name(user)]'s Void torch failed - target died.")
		return
	if(!IS_CULTIST(cultist_to_receive))
		to_chat(user, "<span class='cult italic'>[cultist_to_receive] is not a follower of the Geometer!</span>")
		log_game("[key_name(user)]'s Void torch failed - target was deconverted.")
		return
	if(A in user.get_all_contents())
		to_chat(user, "<span class='cult italic'>[A] must be on a surface in order to teleport it!</span>")
		return
	to_chat(user, "<span class='cult italic'>You ignite [A] with \the [src], turning it to ash, but through the torch's flames you see that [A] has reached [cultist_to_receive]!</span>")
	user.log_message("teleported [A] to [cultist_to_receive] with \the [src].", LOG_GAME)
	cultist_to_receive.put_in_hands(A)
	charges--
	to_chat(user, "\The [src] now has [charges] charge\s.")
	if(charges == 0)
		qdel(src)


/obj/item/gun/ballistic/rifle/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	color = "#ff0000"
	guns_left = 24
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'

/obj/item/gun/ballistic/rifle/enchanted/arcane_barrage/blood/can_trigger_gun(mob/living/user, akimbo_usage)
	if(akimbo_usage)
		return FALSE //no akimbo wielding magic lol.
	. = ..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"Did you truly think that you could channel MY blood without my approval? Amusing, but futile.\""))
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(C.active_hand_index == 1)
				C.apply_damage(20, BRUTE, BODY_ZONE_L_ARM, wound_bonus = 20, sharpness = SHARP_EDGED) //oof ouch
			else
				C.apply_damage(20, BRUTE, BODY_ZONE_R_ARM, wound_bonus = 20, sharpness = SHARP_EDGED)
		qdel(src)
		return FALSE

/obj/item/ammo_box/magazine/internal/blood
	caliber = CALIBER_A762
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/projectile/magic/arcane_barrage/blood
	firing_effect_type = /obj/effect/temp_visual/cult/sparks

/obj/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "mini_leaper"
	nondirectional_sprite = TRUE
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter

/obj/projectile/magic/arcane_barrage/blood/Bump(atom/target)
	var/turf/T = get_turf(target)
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
	var/mob/mob_target = target

	if(ismob(mob_target) && IS_CULTIST(mob_target))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != DEAD)
				H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 4)
		if(isshade(target) || isconstruct(target))
			var/mob/living/simple_animal/M = target
			if(M.health+5 < M.maxHealth)
				M.adjustHealth(-5)
		new /obj/effect/temp_visual/cult/sparks(T)
		qdel(src)
	else
		..()

/obj/item/blood_beam
	name = "\improper magical aura"
	desc = "Sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/weapons/hand.dmi'
	lefthand_file = 'icons/mob/inhands/items/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charging = FALSE
	var/firing = FALSE
	var/angle

/obj/item/blood_beam/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/blood_beam/afterattack(atom/A, mob/living/user, proximity_flag, clickparams)
	. = ..()
	if(firing || charging)
		return
	if(ishuman(user))
		angle = get_angle(user, A)
	else
		qdel(src)
		return . | AFTERATTACK_PROCESSED_ITEM
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user)
	if(do_after(user, 9 SECONDS, target = user))
		firing = TRUE
		ADD_TRAIT(user, TRAIT_IMMOBILIZED, CULT_TRAIT)
		INVOKE_ASYNC(src, PROC_REF(pewpew), user, clickparams)
		var/obj/structure/emergency_shield/cult/weak/N = new(user.loc)
		if(do_after(user, 9 SECONDS, target = user))
			user.Paralyze(40)
			to_chat(user, "<span class='cult italic'>You have exhausted the power of this spell!</span>")
		REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, CULT_TRAIT)
		firing = FALSE
		if(N)
			qdel(N)
		qdel(src)
	charging = FALSE

/obj/item/blood_beam/proc/charge(mob/user)
	var/obj/O
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, TRUE)
	for(var/i in 1 to 12)
		if(!charging)
			break
		if(i > 1)
			sleep(1.5 SECONDS)
		if(i < 4)
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune1/inner(user.loc, 30, "#ff0000")
		else
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune5(user.loc, 30, "#ff0000")
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(user.loc, user.dir)
	if(O)
		qdel(O)

/obj/item/blood_beam/proc/pewpew(mob/user, proximity_flag)
	var/turf/targets_from = get_turf(src)
	var/spread = 40
	var/second = FALSE
	var/set_angle = angle
	for(var/i in 1 to 12)
		if(second)
			set_angle = angle - spread
			spread -= 8
		else
			sleep(1.5 SECONDS)
			set_angle = angle + spread
		second = !second //Handles beam firing in pairs
		if(!firing)
			break
		playsound(src, 'sound/magic/exit_blood.ogg', 75, TRUE)
		new /obj/effect/temp_visual/dir_setting/cult/phase(user.loc, user.dir)
		var/turf/temp_target = get_turf_in_angle(set_angle, targets_from, 40)
		for(var/turf/T in get_line(targets_from,temp_target))
			if (locate(/obj/effect/blessing, T))
				temp_target = T
				playsound(T, 'sound/effects/parry.ogg', 50, TRUE)
				new /obj/effect/temp_visual/at_shield(T, T)
				break
			T.narsie_act(TRUE, TRUE)
			for(var/mob/living/target in T.contents)
				if(IS_CULTIST(target))
					new /obj/effect/temp_visual/cult/sparks(T)
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						if(H.stat != DEAD)
							H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 7)
					if(isshade(target) || isconstruct(target))
						var/mob/living/simple_animal/M = target
						if(M.health+15 < M.maxHealth)
							M.adjustHealth(-15)
						else
							M.health = M.maxHealth
				else
					var/mob/living/L = target
					if(L.density)
						L.Paralyze(20)
						L.adjustBruteLoss(45)
						playsound(L, 'sound/hallucinations/wail.ogg', 50, TRUE)
						L.emote("scream")
		user.Beam(temp_target, icon_state="blood_beam", time = 7, beam_type = /obj/effect/ebeam/blood)


/obj/effect/ebeam/blood
	name = "blood beam"

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "An infamous shield used by Nar'Sien sects to confuse and disorient their enemies. Its edges are weighted for use as a throwing weapon - capable of disabling multiple foes with preternatural accuracy."
	icon_state = "mirror_shield" // eshield1 for expanded
	inhand_icon_state = "mirror_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bumps", "prods")
	attack_verb_simple = list("bump", "prod")
	hitsound = 'sound/weapons/smash.ogg'
	block_sound = 'sound/weapons/effects/ric5.ogg'
	var/illusions = 2

/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(IS_CULTIST(owner))
		if(isprojectile(hitby))
			var/obj/projectile/P = hitby
			if(P.damage_type == BRUTE || P.damage_type == BURN)
				if(P.damage >= 30)
					var/turf/T = get_turf(owner)
					T.visible_message(span_warning("The sheer force from [P] shatters the mirror shield!"))
					new /obj/effect/temp_visual/cult/sparks(T)
					playsound(T, 'sound/effects/glassbr3.ogg', 100)
					owner.Paralyze(25)
					qdel(src)
					return FALSE
			if(P.reflectable & REFLECT_NORMAL)
				return FALSE //To avoid reflection chance double-dipping with block chance
		. = ..()
		if(.)
			if(illusions > 0)
				illusions--
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/shield/mirror, readd)), 450)
				if(prob(60))
					var/mob/living/simple_animal/hostile/illusion/M = new(owner.loc)
					M.faction = list(FACTION_CULT)
					M.Copy_Parent(owner, 70, 10, 5)
					M.move_to_delay = owner.cached_multiplicative_slowdown
				else
					var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
					E.Copy_Parent(owner, 70, 10)
					E.GiveTarget(owner)
					E.Goto(owner, owner.cached_multiplicative_slowdown, E.minimum_distance)
			return TRUE
	else
		if(prob(50))
			var/mob/living/simple_animal/hostile/illusion/H = new(owner.loc)
			H.Copy_Parent(owner, 100, 20, 5)
			H.faction = list(FACTION_CULT)
			H.GiveTarget(owner)
			H.move_to_delay = owner.cached_multiplicative_slowdown
			to_chat(owner, span_danger("<b>[src] betrays you!</b>"))
		return FALSE

/obj/item/shield/mirror/proc/readd()
	illusions++
	if(illusions == initial(illusions) && isliving(loc))
		var/mob/living/holder = loc
		to_chat(holder, "<span class='cult italic'>The shield's illusions are back at full strength!</span>")

/obj/item/shield/mirror/IsReflect()
	if(prob(block_chance))
		return TRUE
	return FALSE

/obj/item/shield/mirror/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	var/datum/thrownthing/D = throwingdatum
	if(isliving(hit_atom))
		var/mob/living/target = hit_atom

		if(target.can_block_magic() || IS_CULTIST(target))
			target.visible_message(span_warning("[src] bounces off of [target], as if repelled by an unseen force!"))
			return
		if(IS_CULTIST(target) && target.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			target.visible_message(span_warning("[target] catches [src] out of the air!"))
			return
		if(!..())
			target.Paralyze(30)
			if(D?.thrower)
				for(var/mob/living/Next in orange(2, T))
					if(!Next.density || IS_CULTIST(Next))
						continue
					throw_at(Next, 3, 1, D.thrower)
					return
				throw_at(D.thrower, 7, 1, null)
	else
		..()

#undef SHUTTLE_CURSE_OMFG_TIMESPAN
