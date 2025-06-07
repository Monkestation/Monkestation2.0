/obj/item/melee/soulblade
	name = "soul blade"
	desc = "An obsidian blade fitted with a soul gem, giving it soul catching properties."
	icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi'
	lefthand_file = 'monkestation/code/modules/bloody_cult/icons/in_hands/swords_axes_l.dmi'
	righthand_file = 'monkestation/code/modules/bloody_cult/icons/in_hands/swords_axes_r.dmi'
	inhand_icon_state = "soulblade"
	SET_BASE_PIXEL(-16, -16)
	icon_state = "soulblade"
	w_class = WEIGHT_CLASS_BULKY
	force = 30//30 brute, plus 5 burn
	throwforce = 20
	sharpness = SHARP_EDGED
	var/mob/living/basic/shade/shade = null
	var/blood = 0
	var/passivebloodregen = 0//increments every Life() proc of the Shade inside, and increases blood by 1 once it reaches the current blood count/3
	var/maxblood = 100
	var/movespeed = 2//smaller = faster
	max_integrity = 60
	var/reflector = FALSE
	var/mob/living/linked_cultist = null

/obj/item/melee/soulblade/Destroy()
	var/turf/T = get_turf(src)
	if (istype(loc, /obj/projectile))
		qdel(loc)

	if (shade)
		shade.remove_blade_powers()
		if (T)
			shade.soulblade_ritual = FALSE
			shade.forceMove(T)
			REMOVE_TRAIT(src, TRAIT_GODMODE, type)
			//shade.canmove = 1
			shade.cancel_camera()
			var/datum/control/C = shade.control_object
			if(C)
				C.break_control()
				qdel(C)
		else
			qdel(shade)


	if (T)
		var/obj/item/melee/cultblade/nocult/B = new (T)
		B.Move(get_step_rand(T))
		new /obj/item/soulstone(T)
	shade = null
	linked_cultist = null
	..()

/obj/item/melee/soulblade/attack_hand(mob/living/user)
	if (shade)
		if (IS_CULTIST(user) && (linked_cultist != user))
			linked_cultist = user
			to_chat(shade, "<spawn class = 'notice'>You have made contact with [user]. As long as you remain within 5 tiles of them, you can move by yourself without losing blood, and regenerate blood passively at a faster rate.</span>")
	..()

/obj/item/melee/soulblade/salt_act()
	qdel(src)


/obj/item/melee/soulblade/examine(mob/user)
	. = ..()
	if (areYouWorthy(user))
		. += span_info("blade blood: [blood]%")
		. += span_info("blade health: [round((atom_integrity/max_integrity)*100)]%")


/obj/item/melee/soulblade/narsie_act()
	return

/obj/item/melee/soulblade/attack_self(mob/living/user)
	var/choices = list(
		list("Give Blood", "radial_giveblood", "Transfer some of your blood to \the [src] to repair it and refuel its blood level, or you could just slash someone."),
		list("Remove Gem", "radial_removegem", "Remove the soul gem from the blade."),
		)

	if (!areYouWorthy(user))
		choices = list(
			list("Remove Gem", "radial_removegem", "Remove the soul gem from \the [src]."),
			)

	var/list/made_choices = list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi', icon_state = choice[2])
		option.info = span_boldnotice(choice[3])
		made_choices[choice[1]] = option

	var/task = show_radial_menu(user, user, made_choices, tooltips = TRUE, radial_icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi')//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()
	var/obj/item/active_hand_item = user.get_active_held_item()
	if (active_hand_item != src)
		to_chat(user, span_warning("You must hold \the [src] in your active hand.") )
		return
	switch (task)
		if ("Give Blood")
			var/data = use_available_blood(user, 10)
			if (data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
				blood = min(maxblood, blood+35)//reminder that the blade cannot give blood back to their wielder, so this should prevent some exploits
				atom_integrity = min(atom_integrity, max_integrity+10)
				update_icon()
		if ("Remove Gem")
			if (!areYouWorthy(user) && shade && ((IS_CULTIST(shade) && !IS_CULTIST(user))))
				shade.say("Dedo ol'btoh!")
				user.take_overall_damage(25, 25)
				if (iscarbon(user))
					user.bodytemperature += 60
				playsound(user.loc, 'monkestation/code/modules/bloody_cult/sound/bloodboil.ogg', 50, 0, -1)
				to_chat(user, span_danger("You manage to pluck the gem out of \the [src], but a surge of the blade's occult energies makes your blood boil!") )
			var/turf/T = get_turf(user)
			playsound(T, 'sound/items/Deconstruct.ogg', 50, 0, -3)
			user.dropItemToGround(src)
			var/obj/item/melee/cultblade/CB = new (T)
			var/obj/item/soulstone/gem/SG = new (T)
			user.put_in_active_hand(CB)
			user.put_in_inactive_hand(SG)
			if (shade)
				shade.forceMove(SG)
				SG.contents += shade
				shade.remove_blade_powers()
				shade.soulblade_ritual = FALSE
				SG.icon_state = "soulstone2"
				SG.name = "Soul Gem: [shade.real_name]"
				shade = null
			loc = null//so we won't drop a broken blade and shard
			qdel(src)

/obj/item/melee/soulblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!areYouWorthy(user))
		user.Paralyze(5)
		to_chat(user, span_warning("An unexplicable force powerfully repels \the [src] from \the [target]!") )
		user.adjustFireLoss(5)
		return
	if (IS_CULTIST(user) && !IS_CULTIST(target) && !target.stat == DEAD)
		var/datum/antagonist/cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/cult)
		if (target.mind)
			cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_soulblade", target)
		else
			cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_soulblade_nomind", target)
	if (ishuman(target) && target.resting)
		var/obj/structure/cult/altar/altar = locate() in target.loc
		if (altar)
			altar.attackby(src, user)
			return
	..()


/obj/item/melee/soulblade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		return
	if (HAS_TRAIT(user, TRAIT_PACIFISM))
		return

	if (blood >= 5)
		blood = max(0, blood-5)
		update_icon()
		var/turf/starting = get_turf(user)
		var/obj/projectile/bloodslash/blood_slash = new (starting)
		blood_slash.preparePixelProjectile(target, user)
		if(user.zone_selected)
			blood_slash.def_zone = user.zone_selected
		else
			blood_slash.def_zone = BODY_ZONE_CHEST
		blood_slash.fire(direct_target = target)
		playsound(starting, 'monkestation/code/modules/bloody_cult/sound/forge.ogg', 100, 1)
		blood_slash.process()

/obj/item/melee/soulblade/attack(mob/living/attacked, mob/living/carbon/human/user)
	. = ..()
	if (ismob(attacked))
		var/mob/living/M = attacked
		M.adjustFireLoss(5)
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.stat != DEAD)
				C.blood_volume -= 10
				blood = min(100, blood+20)
				to_chat(user, span_warning("You steal some of their blood!") )
			else
				C.blood_volume -= 5
				blood = min(100, blood+10)
				to_chat(user, span_warning("You steal a bit of their blood, but not much.") )
			update_icon()
			if (shade)
				shade.DisplayUI("Soulblade")
		else if (M.blood_volume)
			var/mob/living/simple_animal/SA = M
			if (SA.stat != DEAD)
				blood = min(100, blood+20)
				to_chat(user, span_warning("You steal some of their blood!") )
			else
				blood = min(100, blood+10)
				to_chat(user, span_warning("You steal a bit of their blood, but not much.") )
			update_icon()
			if (shade)
				shade.DisplayUI("Soulblade")


/obj/item/melee/soulblade/pickup(mob/living/user)
	..()
	if(!areYouWorthy(user))
		to_chat(user, span_warning("An overwhelming feeling of dread comes over you as you pick up \the [src]. It would be wise to rid yourself of this, quickly.") )
		user.adjust_dizzy(120)
	else
		user.adjust_dizzy(-120)
	update_icon()

/obj/item/melee/soulblade/proc/areYouWorthy(mob/living/user)
	if (IS_CULTIST(user))
		return TRUE
	else if (!shade)
		return FALSE
	else if (user == shade)
		return TRUE
	return TRUE

/obj/item/melee/soulblade/dropped(mob/user)
	..()
	update_icon()

/obj/item/melee/soulblade/update_icon()
	. = ..()
	overlays.len = 0
	animate(src, pixel_y = -16 * 1, time = 3, easing = SINE_EASING)
	shade = locate() in src
	if (shade)
		plane = HUD_PLANE//let's keep going and see where this takes us
		icon_state = "soulblade-full"
		animate(src, pixel_y = -8 * 1 , time = 7, loop = -1, easing = SINE_EASING)
		animate(pixel_y = -12 * 1, time = 7, loop = -1, easing = SINE_EASING)
	else
		if (!ismob(loc))
			plane = initial(plane)
			layer = initial(layer)
		icon_state = "soulblade"

	if (istype(loc, /mob/living/carbon))
		var/mob/living/carbon/C = loc
		if (areYouWorthy(C))
			var/image/I = image('monkestation/code/modules/bloody_cult/icons/hud.dmi', src, "consthealth[10*round((blood/maxblood)*10)]")
			I.pixel_x = 16
			I.pixel_y = 16
			overlays += I


/obj/item/melee/soulblade/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE, quickstart = TRUE)
	var/turf/starting = get_turf(src)
	var/turf/second_target = target
	var/obj/projectile/soulbullet/soul_bullet = new (starting)
	soul_bullet.firer = thrower
	soul_bullet.def_zone = ran_zone(thrower.zone_selected)
	soul_bullet.preparePixelProjectile(target, starting)
	soul_bullet.secondary_target = second_target
	soul_bullet.shade = shade
	soul_bullet.blade = src
	src.forceMove(soul_bullet)
	soul_bullet.fire()
	soul_bullet.process()

/obj/item/melee/soulblade/ex_act(severity)
	switch(severity)
		if (1)
			takeDamage(100)
		if (2)
			takeDamage(40)
		if (3)
			takeDamage(20)

/obj/item/melee/soulblade/proc/takeDamage(damage)
	if (!damage)
		return
	atom_integrity -= damage
	if (atom_integrity <= 0)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		qdel(src)
	else
		playsound(loc, "trayhit", 70, 1)

/obj/item/melee/soulblade/attackby(obj/item/I, mob/user)
	if (HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	if(I.force)
		var/damage = I.force
		takeDamage(damage)
		user.visible_message(span_danger("\The [src] has been attacked with \the [I] by \the [user]. ") )

/obj/item/melee/soulblade/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(.)
		return

	visible_message(span_warning("\The [src] was hit by \the [hitting_atom].") , 1)
	if (isobj(hitting_atom))
		var/obj/O = hitting_atom
		takeDamage(O.throwforce)

/obj/item/melee/soulblade/proc/capture_shade(mob/living/basic/shade/target, mob/user)

	if(shade)
		to_chat(user, "<span class = 'danger'>Capture failed!: </span>\The [src] already has a shade! Remove its soul gem if you wish to harm this shade nonetheless.")
	else
		target.forceMove(src) //put shade in blade
		ADD_TRAIT(src, TRAIT_GODMODE, type)
		target.health = target.maxHealth//full heal
		target.give_blade_powers()
		shade = target
		dir = NORTH
		update_icon()
		to_chat(target, "Your soul has been captured by the soul blade, its arcane energies are reknitting your ethereal form, healing you.")
		to_chat(user, "<span class = 'notice'><b>Capture successful!</b>: </span>[target.real_name]'s has been captured and stored within the gem on your blade.")
		target.master = user

		//Is our user a cultist? Then you're a cultist too now!
		if (IS_CULTIST(user) && !IS_CULTIST(target))
			var/datum/team/cult/cult = locate_team(/datum/team/cult)
			if (cult && !cult.CanConvert())
				to_chat(user, span_danger("The cult has too many members already. But this shade will obey you nonetheless.") )
				return
			var/datum/antagonist/cult/newCultist = new(target.mind)
			cult.HandleRecruitedRole(newCultist)
			//newCultist.Greet(GREET_SOULSTONE)
			newCultist.conversion["soulstone"] = user
