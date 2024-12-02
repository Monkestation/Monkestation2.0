////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune. Available from the beginning. Trigger progress to ACT I
//      CULT ALTAR       //Allows communication with Nar-Sie for advice and info on the Cult's current objective.
//                       //ACT II : Allows Soulstone crafting, Used to sacrifice the target on the Station
///////////////////////////ACT III : Can plant an empty Soul Blade in it to prompt observers to become the blade's shade
#define ALTARTASK_NONE	0
#define ALTARTASK_GEM	1
#define ALTARTASK_SACRIFICE_HUMAN	2
#define ALTARTASK_SACRIFICE_ANIMAL  3

/obj/structure/cult/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "altar"
	max_integrity = 100
	layer = TABLE_LAYER
	pass_flags_self = PASSTABLE
	can_buckle = TRUE
	map_id = HOLOMAP_MARKER_CULT_ALTAR
	marker_icon_state = "altar"
	var/obj/item/weapon/melee/soulblade/blade = null
	var/altar_task = ALTARTASK_NONE
	var/gem_delay = 30 SECONDS
	var/narsie_message_cooldown = 0

	var/mob/sacrificer  // who started the sacrifice ritual
	var/mutable_appearance/build

	var/list/watching_mobs = list()

	var/list/can_plant = list(
		/obj/item/knife/ritual,
		/obj/item/weapon/melee/soulblade,
		/obj/item/weapon/melee/cultblade,
		/obj/item/weapon/melee/cultblade/nocult,
		)

	var/trapped = FALSE

/obj/structure/cult/altar/New()
	..()
	flick("[icon_state]-spawn", src)
	var/image/I = image(icon, "altar_overlay")
	SET_PLANE_EXPLICIT(I, GAME_PLANE, src)

/obj/structure/cult/altar/Initialize()
	. = ..()
	//mostly for mappers
	for (var/obj/item/I in loc)
		if (is_type_in_list(I, can_plant))
			I.forceMove(src)
			blade = I
			update_appearance()

/obj/structure/cult/altar/Destroy()

	for(var/mob/mob as anything in watching_mobs)
		SSholomaps.hide_cult_map(mob)
	if (blade)
		if (loc)
			blade.forceMove(loc)
		else
			qdel(blade)
	blade = null
	flick("[icon_state]-break", src)
	..()

/obj/structure/cult/altar/attackby(var/obj/item/I, var/mob/user, params)
	if (altar_task)
		return ..()
	if(is_type_in_list(I, can_plant))
		if (blade)
			to_chat(user, span_warning("You must remove \the [blade] planted into \the [src] first.") )
			return 1
		var/turf/T = get_turf(user)
		playsound(T, 'monkestation/code/modules/bloody_cult/sound/bloodyslice.ogg', 50, 1)
		user.dropItemToGround(I)
		I.forceMove(src)
		blade = I
		update_appearance()
		var/mob/living/carbon/C = locate() in loc
		var/mob/living/basic/S = locate() in loc
		if (C && C.body_position == LYING_DOWN)
			C.buckled.unbuckle_mob(C)
			buckle_mob(C)
			C.apply_damage(blade.force, BRUTE, BODY_ZONE_CHEST)
			var/datum/antagonist/cult/cul = user.mind?.has_antag_datum(/datum/antagonist/cult)
			if (cul)
				cul.gain_devotion(0, DEVOTION_TIER_0, "altar_plant", src)
			if (C == user)
				user.visible_message(span_danger("\The [user] holds \the [I] above their stomach and impales themselves on \the [src]!") , span_danger("You hold \the [I] above your stomach and impale yourself on \the [src]!") )
			else
				user.visible_message(span_danger("\The [user] holds \the [I] above \the [C]'s stomach and impales them on \the [src]!") , span_danger("You hold \the [I] above \the [C]'s stomach and impale them on \the [src]!") )
		else if(S)
			S.buckled.unbuckle_mob(S)
			S.pixel_y = 6
			buckle_mob(S)
			if(S.stat != DEAD)
				S.death()
			var/datum/antagonist/cult/cul = user.mind?.has_antag_datum(/datum/antagonist/cult)
			if (cul)
				cul.gain_devotion(0, DEVOTION_TIER_0, "altar_plant", src)
			user.visible_message(span_danger("\The [user] holds \the [I] above \the [S] and impales it on \the [src]!") , span_danger("You hold \the [I] above \the [S] and impale it on \the [src]!") )
		else
			to_chat(user, "You plant \the [blade] on top of \the [src]</span>")
			START_PROCESSING(SSobj, src)
			var/datum/antagonist/cult/cul = user.mind?.has_antag_datum(/datum/antagonist/cult)
			if (cul)
				cul.gain_devotion(0, DEVOTION_TIER_0, "altar_plant", src)
			if (istype(blade) && !blade.shade)
				for(var/mob/dead/observer/M in GLOB.player_list)
					if(!M.client || is_banned_from(M.key, ROLE_CULTIST) || M.client.is_afk())
						continue
					if (IS_CULTIST(M))
						var/datum/antagonist/cult/cultist = M.mind?.has_antag_datum(/datum/antagonist/cult)
						if (cultist.second_chance)
							to_chat(M, span_bolddanger("\The [user] has planted a Soul Blade on an altar, opening a small crack in the veil that allows you to become the blade's resident shade. (<a href = '?src = \ref[src];signup = \ref[M]'>Possess now!</a>)") )
		return 1
	if (user.pulling)
		if (blade)
			to_chat(user, span_warning("You must remove \the [blade] planted on \the [src] first.") )
			return 1
		if(iscarbon(pulling))
			if (blade)
				to_chat(user, span_warning("You must remove \the [blade] planted on \the [src] first.") )
				return 1
			var/mob/living/carbon/C = user.pulling
			C.buckled.unbuckle_mob(C)
			if (!do_after(user, 1.5 SECONDS, C))
				return
			if (ishuman(C))
				C.resting = 1
			C.forceMove(loc)
			to_chat(user, span_warning("You move \the [C] on top of \the [src]") )
			return 1
	if(!(user.istate & ISTATE_HARM))
		if(user.dropItemToGround(I, loc))
			return TRUE
	..()

/obj/structure/cult/altar/update_icon_state()
	. = ..()
	icon_state = "altar"

/obj/structure/cult/altar/update_overlays()
	. = ..()
	if (blade)
		var/image/I
		if(istype(blade, /obj/item/knife/ritual))
			I = image(icon, "altar-ritualknife")
		else if (!istype(blade))
			I = image(icon, "altar-cultblade")
		else if (blade.shade)
			I = image(icon, "altar-soulblade-full")
		else
			I = image(icon, "altar-soulblade")
		SET_PLANE_EXPLICIT(I, GAME_PLANE_UPPER, src)
		I.pixel_y = 3
		. += I
	var/image/I = image(icon, "altar_overlay")
	SET_PLANE_EXPLICIT(I, GAME_PLANE, src)
	. += I

	if (atom_integrity < max_integrity/3)
		. += "altar_damage2"
	else if (atom_integrity < 2*max_integrity/3)
		. += "altar_damage1"

//We want people on top of the altar to appear slightly higher
/obj/structure/cult/altar/Entered(var/atom/movable/mover)
	if (iscarbon(mover))
		mover.pixel_y += 7 * 1

/obj/structure/cult/altar/Exited(var/atom/movable/mover)
	if (iscarbon(mover))
		mover.pixel_y -= 7 * 1

//They're basically the height of regular tables
/obj/structure/cult/altar/Cross(var/atom/movable/mover, var/turf/target, var/height = 1.5, var/air_group = 0)
	if(air_group || (height == 0))
		return 1

	if(ismob(mover))
		var/mob/M = mover
		if(M.movement_type & FLYING)
			return TRUE

	if(istype(mover) && CanPass(mover))
		return 1
	else
		return 0

/obj/structure/cult/altar/MouseDrop_T(var/atom/movable/O, var/mob/living/user)
	if (altar_task)
		return
	if (!istype(O))
		return
	if(user.incapacitated() || user.body_position == LYING_DOWN)
		return
	if(O.anchored || !Adjacent(user) || !user.Adjacent(O))
		return
	if (user.get_active_held_item() == O)
		if(!user.dropItemToGround(O))
			return
	else
		if(!ismob(O))
			return
		if(O.loc == user || !isturf(O.loc) || !isturf(user.loc))
			return

		var/mob/living/L = O
		if(!istype(L) || L.buckled)
			return
		if (blade)
			to_chat(user, span_warning("You must remove \the [blade] planted on \the [src] first.") )
			return 1

		if (!do_after(user, 15, L))
			return
		L.buckled?.unbuckle_mob(L)

		if (ishuman(L) && L != user)
			L.resting = TRUE

		add_fingerprint(L)

	O.forceMove(loc)
	if(O == user)
		to_chat(user, span_warning("You climb on top of \the [src].") )
		user.set_resting(TRUE)
	else
		to_chat(user, span_warning("You move \the [O] on top of \the [src].") )
	buckle_mob(O)

	return 1

/obj/structure/cult/altar/unbuckle_mob(mob/living/buckled_mob, force, can_fall)
	if(blade)
		return FALSE
	. = ..()

/obj/structure/cult/altar/conceal()
	if (blade || altar_task)
		return
	anim(location = loc, target = loc, a_icon = icon, flick_anim = "[icon_state]-conceal")
	for (var/mob/living/carbon/C in loc)
		Uncrossed(C)
	..()

/obj/structure/cult/altar/reveal()
	flick("[icon_state]-spawn", src)
	..()
	for (var/mob/living/carbon/C in loc)
		Crossed(C)

/obj/structure/cult/altar/cultist_act(var/mob/user, var/menu = "default")
	. = ..()
	if (!.)
		return
	if (altar_task)
		switch (altar_task)
			if (ALTARTASK_GEM)
				to_chat(user, span_warning("You must wait before the Altar's current task is over.") )
			if (ALTARTASK_SACRIFICE_HUMAN to ALTARTASK_SACRIFICE_ANIMAL)
				if (user in contributors)
					return
				if (!user.checkTattoo(TATTOO_SILENT))
					if (prob(5))
						user.say("Let me show you the dance of my people!", "C")
					else
						user.say("Barhah hra zar'garis!", "C")
				contributors.Add(user)
				if (user.client)
					user.client.images |= progbar
		return
	if(length(buckled_mobs) || blade)
		var/mob/M
		if(length(buckled_mobs))
			M = buckled_mobs[1]
		if(M && M != user)
			var/list/choices = list()

			var/datum/radial_menu_choice/option = new
			option.image = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi', icon_state = "radial_altar_remove")
			option.info = span_boldnotice("Pull the blade off, freeing the victim.")
			choices["Remove Blade"] = option

			var/datum/radial_menu_choice/option2 = new
			option2.image = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi', icon_state = "radial_altar_sacrifice")
			option2.info = span_boldnotice("Initiate the sacrifice ritual. The ritual can only proceed if the proper victim has been nailed to the altar.")
			choices["Sacrifice"] = option2

			var/task = show_radial_menu(user, src, choices, tooltips = TRUE, radial_icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi')
			if (!Adjacent(user) || !task)
				return
			switch (task)
				if ("Remove Blade")
					if (do_after(user, 2 SECONDS, src))
						M.visible_message(span_notice("\The [M] was freed from \the [src] by \the [user]!") , "You were freed from \the [src] by \the [user].")
						unbuckle_mob(M)
						if(istype(M, /mob/living/simple_animal))
							M.pixel_y = 0
						if (blade)
							blade.forceMove(loc)
							blade.attack_hand(user)
							to_chat(user, span_warning("You remove \the [blade] from \the [src]") )
							STOP_PROCESSING(SSobj, src)
							blade = null
							playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
							update_appearance()
				if ("Sacrifice")
					// First we'll check for any blockers around it since we'll dance using forceMove to allow up to 8 dancers without them bumping into each others
					// Of course this means that walls and objects placed AFTER the start of the dance can be crossed by dancing but that's good enough.
					for (var/turf/T in orange(1, src))
						if (T.density)
							to_chat(user, span_warning("\The [T] would hinder the ritual. Either dismantle it or use an altar located in a more spacious area.") )
							return
						var/atom/A = T.check_blocking_content(TRUE)
						if (A && (A != src) && !ismob(A)) // mobs get a free pass
							to_chat(user, span_warning("\The [A] would hinder the ritual. Either move it or use an altar located in a more spacious area.") )
							return
					if(ishuman(M))
						altar_task = ALTARTASK_SACRIFICE_HUMAN
					else
						altar_task = ALTARTASK_SACRIFICE_ANIMAL
					StartSacrifice(user)
					return
		else if (blade)
			if(length(buckled_mobs))
				if (do_after(user, 2 SECONDS, src))
					unbuckle_all_mobs()
					blade.forceMove(loc)
					blade.attack_hand(user)
					to_chat(user, span_notice("You remove \the [blade] from \the [src]") )
					STOP_PROCESSING(SSobj, src)
					blade = null
					playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
					update_appearance()
			else
				blade.forceMove(loc)
				blade.attack_hand(user)
				to_chat(user, span_notice("You remove \the [blade] from \the [src]") )
				STOP_PROCESSING(SSobj, src)
				blade = null
				playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
				update_appearance()
			return
	else
		var/list/choices = list(
			list("Consult Roster", "radial_altar_roster", "Check the names and status of all of the cult's members."),
			list("Commune with Nar-Sie", "radial_altar_commune", "Make contact with Nar-Sie."),
			list("Look through Veil", "radial_altar_map", "Check the veil for tears to locate other occult constructions."),
			list("Conjure Soul Gem", "radial_altar_gem", "Order the altar to sculpt you a Soul Gem, to capture the soul of your enemies."),
			)
		var/list/made_choices = list()
		for(var/list/choice in choices)
			var/datum/radial_menu_choice/option = new
			option.image = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi', icon_state = choice[2])
			option.info = span_boldnotice(choice[3])
			made_choices[choice[1]] = option

		var/task = show_radial_menu(user, src, made_choices, tooltips = TRUE, radial_icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi')
		if (buckled_mobs || !Adjacent(user) || !task)
			return
		switch (task)
			if ("Consult Roster")
				var/datum/team/cult/cult = locate_team(/datum/team/cult)
				if (!cult)
					return
				var/dat = {"<body style = "color:#FFFFFF" bgcolor = "#110000">"}
				dat += "<b>Our cult can currently grow up to [cult.cultist_cap] members.</b>"
				dat += "<ul>"
				for (var/datum/mind/mind in cult.members)
					var/datum/antagonist/cult/cult_datum = mind.has_antag_datum(/datum/antagonist/cult)
					var/conversion = ""
					var/cult_role = ""
					switch (cult_datum.cultist_role)
						if (CULTIST_ROLE_ACOLYTE)
							cult_role = "Acolyte"
						if (CULTIST_ROLE_MENTOR)
							cult_role = "Mentor"
						else
							cult_role = "Herald"
					if (cult_datum.conversion.len > 0)
						conversion = pick(cult_datum.conversion)
					var/origin_text = ""
					switch (conversion)
						if ("converted")
							origin_text = "Converted by [cult_datum.conversion[conversion]]"
						if ("resurrected")
							origin_text = "Resurrected by [cult_datum.conversion[conversion]]"
						if ("soulstone")
							origin_text = "Soul captured by [cult_datum.conversion[conversion]]"
						if ("altar")
							origin_text = "Volunteer shade"
						if ("sacrifice")
							origin_text = "Sacrifice"
						else
							origin_text = "Founder"
					var/mob/living/carbon/H = mind.current
					var/extra = ""
					if (H && istype(H))
						if (H.stat == DEAD)
							extra = " - <span style='color:#FF0000'>DEAD</span>"
					dat += "<li><b>[H.name] ([cult_role])</b></li> - [origin_text][extra]"
				for(var/obj/item/restraints/handcuffs/cult/cuffs in cult.bindings)
					if (iscarbon(cuffs.loc))
						var/mob/living/carbon/C = cuffs.loc
						if (C.handcuffed == cuffs && cuffs.gaoler && cuffs.gaoler.owner)
							var/datum/mind/gaoler = cuffs.gaoler.owner
							var/extra = ""
							if (C && istype(C))
								if (C.stat == DEAD)
									extra = " - <span style='color:#FF0000'>DEAD</span>"
							dat += "<li><span style='color:#FFFF00'><b>[C.real_name]</b></span></li> - Prisoner of [gaoler.name][extra]"
				dat += {"</ul></body>"}
				user << browse("<TITLE>Cult Roster</TITLE>[dat]", "window=cultroster;size=600x400")
				onclose(user, "cultroster")
			if ("Commune with Nar-Sie")
				if(narsie_message_cooldown)
					to_chat(user, span_warning("This altar has already sent a message in the past 30 seconds, wait a moment.") )
					return
				var/input = stripped_input(user, "Please choose a message to transmit to Nar-Sie through the veil. Know that he can be fickle, and abuse of this ritual will leave your body asunder. Communion does not guarantee a response. There is a 30 second delay before you may commune again, be clear, full and concise.", "To abort, send an empty message.", "")
				if(!input || !Adjacent(user))
					return
				usr.pray(input)
				to_chat(usr, span_notice("Your communion has been received.") )
				var/turf/T = get_turf(usr)
				log_say("[key_name(usr)] (@[T.x], [T.y], [T.z]) has communed with Nar-Sie: [input]")
				narsie_message_cooldown = 1
				spawn(30 SECONDS)
					narsie_message_cooldown = 0
			if ("Conjure Soul Gem")
				altar_task = ALTARTASK_GEM
				update_appearance()
				overlays += "altar-soulstone1"
				spawn (gem_delay/3)
					update_appearance()
					overlays += "altar-soulstone2"
					sleep (gem_delay/3)
					update_appearance()
					overlays += "altar-soulstone3"
					sleep (gem_delay/3)
					altar_task = ALTARTASK_NONE
					update_appearance()
					var/obj/item/soulstone/gem/gem = new (loc)
					gem.pixel_y = 4
			if ("Look through Veil")
				SSholomaps.show_cult_map(user, src)
				watching_mobs |= user
				RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(remove_watching))

/obj/structure/cult/altar/proc/remove_watching(mob/user)
	watching_mobs -= user

/obj/structure/cult/altar/proc/StartSacrifice(var/mob/user)
	var/mob/M = buckled_mobs[1]
	switch(altar_task)
		if(ALTARTASK_SACRIFICE_HUMAN)
			if((!istype(blade, /obj/item/weapon/melee/cultblade) && !istype(blade, /obj/item/weapon/melee/soulblade)) || istype(blade, /obj/item/weapon/melee/cultblade/nocult))
				to_chat(user, span_warning("\The [blade] is too weak to perform such a sacrifice. Forge a stronger blade.") )
				altar_task = ALTARTASK_NONE
				return
			timeleft = 30
			timetotal = timeleft
			min_contributors = 1//monkey, or other carbon lifeforms
			if (ishuman(M))
				if (M.mind)
					min_contributors = 3
					to_chat(user, span_cult("You need <span class = 'danger'>3</span> cultists to partake in the ritual for the sacrifice to proceed.") )
		if(ALTARTASK_SACRIFICE_ANIMAL)
			timeleft = 15
			timetotal = timeleft
			min_contributors = 1
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (cult)
		if (buckled_mobs)
			sacrificer = user
			update_appearance()
			contributors.Add(user)
			update_progbar()
			if (user.client)
				user.client.images |= progbar

			if(!build)
				build = mutable_appearance('monkestation/code/modules/bloody_cult/icons/cult.dmi', "build", layer = MOB_SHIELD_LAYER)
				build.pixel_y = 8

			add_overlay(build)
			if (!user.checkTattoo(TATTOO_SILENT))
				if (prob(5))
					user.say("Let me show you the dance of my people!", "C")
				else
					user.say("Barhah hra zar'garis!", "C")
			if (user.client)
				user.client.images |= progbar
			spawn()
				dance_start()

/obj/structure/cult/altar/noncultist_act(var/mob/user)//Non-cultists can still remove blades planted on altars.
	if(buckled_mobs)
		var/mob/M = buckled_mobs[1]
		if(M != user)
			if (do_after(user, 2 SECONDS, src))
				M.visible_message(span_notice("\The [M] was freed from \the [src] by \the [user]!") , "You were freed from \the [src] by \the [user].")
				unbuckle_mob(M)
				if (blade)
					blade.forceMove(loc)
					blade.attack_hand(user)
					to_chat(user, "You remove \the [blade] from \the [src]</span>")
					STOP_PROCESSING(SSobj, src)
					blade = null
					playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
					update_appearance()
	else if (blade)
		blade.forceMove(loc)
		blade.attack_hand(user)
		to_chat(user, "You remove \the [blade] from \the [src]</span>")
		STOP_PROCESSING(SSobj, src)
		blade = null
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		update_appearance()
		if (trapped) //soulblade sanctum trapped altar
			trapped = FALSE
			var/list/possible_floors = list()
			for (var/turf/open/floor/F in orange(1, get_turf(src)))
				possible_floors.Add(F)
			for (var/i = 1 to 4)
				if (possible_floors.len <= 0)
					break
				var/turf/T = pick(possible_floors)
				if (T)
					possible_floors.Remove(T)
					new /obj/effect/cult_ritual/backup_spawn(T)
		return
	else
		to_chat(user, span_cult("You feel madness taking its toll, trying to figure out \the [name]'s purpose.") )
	return 1

/obj/structure/cult/altar/process()
	if (istype(blade))
		blade.blood = min(blade.maxblood, blade.blood+10)
		if (blade.blood == blade.maxblood)
			STOP_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/structure/cult/altar/Topic(href, href_list)
	if(href_list["signup"])
		var/mob/M = usr
		if(!isobserver(M) || !IS_CULTIST(M))
			return
		var/mob/dead/observer/O = M
		var/obj/item/weapon/melee/soulblade/blade = locate() in src
		if (!istype(blade))
			to_chat(usr, span_warning("The blade was removed from \the [src].") )
			return
		if (blade.shade)
			to_chat(usr, span_warning("Another shade was faster, and is currently possessing \the [blade].") )
			return
		var/mob/living/basic/shade/shadeMob = new(blade)
		blade.shade = shadeMob
		shadeMob.status_flags |= GODMODE
		ADD_TRAIT(shadeMob, TRAIT_IMMOBILIZED, REF(src))
		var/datum/antagonist/cult/cultist = IS_CULTIST(M)
		cultist.second_chance = 0
		shadeMob.real_name = M.mind.name
		shadeMob.name = "[shadeMob.real_name] the Shade"
		M.mind.transfer_to(shadeMob)
		O.can_reenter_corpse = 1
		O.reenter_corpse()

		/* Only cultists get brought back this way now, so let's assume they kept their identity.
		spawn()
			var/list/shade_names = list("Orenmir", "Felthorn", "Sparda", "Vengeance", "Klinge")
			shadeMob.real_name = pick(shade_names)
			shadeMob.real_name = copytext(sanitize(input(shadeMob, "You have no memories of your previous life, if you even had one. What name will you give yourself?", "Give yourself a new name", "[shadeMob.real_name]") as null|text), 1, MAX_NAME_LEN)
			shadeMob.name = "[shadeMob.real_name] the Shade"
			if (shadeMob.mind)
				shadeMob.mind.name = shadeMob.real_name
		*/
		shadeMob.cancel_camera()
		//shadeMob.give_blade_powers()
		blade.dir = NORTH
		blade.update_appearance()
		update_appearance()
		//Automatically makes them cultists
		var/datum/antagonist/cult/newCultist = new/datum/antagonist/cult(shadeMob.mind)
		newCultist.conversion.Add("altar")


/obj/structure/cult/altar/dance_start()//This is executed at the end of the sacrifice ritual
	. = ..()//true if the ritual was successful
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	overlays -= build
	min_contributors = initial(min_contributors)
	if(!.)
		altar_task = ALTARTASK_NONE
		return
	if(!buckled_mobs)
		return
	switch(altar_task)
		if(ALTARTASK_SACRIFICE_HUMAN)
			altar_task = ALTARTASK_NONE
			update_appearance()
			var/mob/M = buckled_mobs[1]
			if (istype(blade) && !blade.shade && M.mind)//If an empty soul blade was the tool used for the ritual, let's make them its shade.
				var/mob/living/basic/shade/new_shade = M.change_mob_type( /mob/living/basic/shade , null, null, 1 )
				blade.forceMove(loc)
				blade.blood = blade.maxblood
				new_shade.forceMove(blade)
				blade.shade = new_shade
				blade.update_appearance()
				blade = null
				for(var/mob/living/L in dview(world.view, loc, INVISIBILITY_MAXIMUM))
					if (L.client)
						L.playsound_local(loc, 'monkestation/code/modules/bloody_cult/sound/convert_failure.ogg', 75, 0, -4)
				playsound(loc, get_sfx("soulstone"), 50, 1)
				var/obj/effect/cult_ritual/conversion/anim = new(loc)
				anim.icon_state = ""
				flick("rune_convert_refused", anim)
				anim.Die()

				if (!IS_CULTIST(new_shade))
					var/datum/antagonist/cult/newCultist = new(new_shade.mind)
					cult.HandleRecruitedRole(newCultist)
					newCultist.conversion.Add("sacrifice")

				new_shade.soulblade_ritual = TRUE
				new_shade.name = "[M.real_name] the Shade"
				new_shade.real_name = "[M.real_name]"
				new_shade.give_blade_powers()
				playsound(src, get_sfx("soulstone"), 50, 1)
			else
				anim(target = src, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "rune_sac", plane = ABOVE_GAME_PLANE)

		if(ALTARTASK_SACRIFICE_ANIMAL)
			altar_task = ALTARTASK_NONE
			var/mob/living/M = buckled_mobs[1]
			anim(target = src, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "rune_sac", plane = ABOVE_GAME_PLANE)
			var/turf/TU = get_turf(src)
			spawn(5)
				var/obj/item/reagent_containers/R = locate(/obj/item/reagent_containers) in TU.contents
				if(R)
					var/remaining = R.volume - R.reagents.total_volume
					if(R && R.is_open_container())
						if(istype(M, /mob/living/basic/mouse))
							M.transfer_blood_to(R, min(remaining, 30))
						else
							M.transfer_blood_to(R, min(remaining, 60))
						R.on_reagent_change()
				qdel(M)
				//bloodmess_splatter(TU)
				playsound(src, "gib", 30, 0, -3)

/obj/structure/cult/altar/ritual_reward(var/mob/M)
	var/datum/antagonist/cult/cult_datum = M.mind.has_antag_datum(/datum/antagonist/cult)
	if (cult_datum)
		switch(altar_task)
			if(ALTARTASK_SACRIFICE_HUMAN)
				var/mob/O = buckled_mobs[1]
				if (O.mind)
					cult_datum.gain_devotion(500, DEVOTION_TIER_4, "altar_sacrifice_human", O)
				else//monkey-human
					cult_datum.gain_devotion(200, DEVOTION_TIER_4, "altar_sacrifice_human_nomind", O)
			if(ALTARTASK_SACRIFICE_ANIMAL)
				var/mob/O = buckled_mobs[1]
				if (ismonkey(O))
					cult_datum.gain_devotion(200, DEVOTION_TIER_3, "altar_sacrifice_monkey", O)
				else
					cult_datum.gain_devotion(200, DEVOTION_TIER_3, "altar_sacrifice_animal", O)

#undef ALTARTASK_NONE
#undef ALTARTASK_GEM
#undef ALTARTASK_SACRIFICE_HUMAN
#undef ALTARTASK_SACRIFICE_ANIMAL
