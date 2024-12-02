/obj/item/book/bible/attack(mob/living/target_mob, mob/living/carbon/human/user, params, heal_mode)
	. = ..()
	//they have holy water in them? deconversion mode activate! anyone can do it. 'cept cultists O B V I O U S L Y
	if (!IS_CULTIST(user) && target_mob.reagents?.has_reagent(/datum/reagent/water/holywater) && !(user.istate & ISTATE_HARM))
		playsound(src, "punch", 25, 1, -1)
		if (target_mob.stat == DEAD)
			to_chat(user, span_warning("You cannot deconvert the dead!") )
			return 1
		if (target_mob.health < 20)
			to_chat(user, span_warning("\The [target_mob] is too weak to handle the deconversion ritual, patch them up a bit first.") )
			return 1
		var/datum/antagonist/cult/cultist
		if(IS_CULTIST(target_mob))
			cultist = target_mob.mind?.has_antag_datum(/datum/antagonist/cult)
			if (cultist.deconversion)
				to_chat(user, span_warning("There is already a deconversion attempt undergoing!") )
				return 1
			else
				to_chat(target_mob, span_userdanger("They are trying to deconvert you!") )
				cultist.deconversion = 1//arbitrary non-null value to prevent deconversion-shade spam, will get replaced with a /datum/deconversion_ritual 5 seconds later

		if (do_after(user, 5 SECONDS, target_mob))
			if(cultist)
				to_chat(user, span_warning("In the name of [deity_name], Nar-Sie forsake this body and soul!") )
				user.visible_message(span_warning("\The [target_mob] begins to radiate with light.") )
				new /datum/deconversion_ritual(user, target_mob, src)
			else
				to_chat(user, span_warning("In the name of [deity_name], Nar-Sie forsake this body and soul!") )
				user.visible_message(span_warning("...but nothing unusual happens.") )
		else
			cultist.deconversion = null//deconversion attempt got interrupted, you can now try again
		return 1

/datum/deconversion_ritual
	var/datum/antagonist/cult/cultist = null
	var/cult_chaplain = FALSE
	var/last_cultist = FALSE
	var/success = DECONVERSION_ACCEPT

/datum/deconversion_ritual/New(mob/living/deconverter, mob/living/deconvertee, obj/item/book/bible/bible)
	..()
	if (!bible || !bible.deity_name || !deconverter || !deconvertee || !IS_CULTIST(deconvertee))
		qdel(src)
		return
	var/mob/target
	deconvertee.overlays += image('monkestation/code/modules/bloody_cult/icons/effects.dmi', src, "deconversion")
	playsound(deconvertee, 'monkestation/code/modules/bloody_cult/sound/deconversion_start.ogg', 50, 0, -4)
	cultist = IS_CULTIST(deconvertee)
	cultist.deconversion = src

	deconvertee.adjust_dizzy(30)
	deconvertee.adjust_stutter(10)
	deconvertee.adjust_jitter(30)
	deconvertee.Paralyze(10 SECONDS)

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	var/living_cultists = 0
	for(var/datum/mind/mind in cult.members)
		if (mind.current.stat != DEAD)
			living_cultists++
	if (living_cultists <= 1)
		last_cultist = TRUE

	spawn()
		spawn()
			if (alert(deconvertee, "You are being compelled by the powers of [bible.deity_name][cult_chaplain ? " (wait what?)" : ""] to give up on serving the Cult of Nar-Sie[cult_chaplain ? " (huh!?)" : ""]", "You have 10 seconds to decide", "[!cult_chaplain ? "Abandon the Cult" : "I am so confused right now, ok I guess?"]", "[!cult_chaplain ? "Resist!" : "This is obviously a trick! Resist!"]") == "[!cult_chaplain ? "Abandon the Cult" : "I am so confused right now, ok I guess?"]")
				success = DECONVERSION_ACCEPT
				if (!target && !last_cultist)//no threats if nobody remains to carry them out.
					to_chat(deconvertee, span_cult("[cult_chaplain ? "WERE YOU DECEIVED THAT EASILY? SO BE IT THEN." : "THERE WILL BE A PRICE."]") )
			else
				success = DECONVERSION_REFUSE
				if (!target)
					to_chat(deconvertee, span_warning("You block the sweet promises of forgiveness from your mind.") )
		new /obj/effect/bible_spin(get_turf(deconvertee), deconverter ,bible)
		sleep(10 SECONDS)
		if (!deconvertee || !IS_CULTIST(deconvertee))
			qdel(src)
			return
		deconvertee.take_overall_damage(10)//it's a painful process no matter what.
		var/turf/T = get_turf(deconvertee)
		anim(target = deconvertee, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "cult_jaunt_land", plane = GAME_PLANE_UPPER)

		switch(success)
			if (DECONVERSION_ACCEPT)
				var/mob/living/basic/shade/redshade_A = new(T)
				var/mob/living/basic/shade/redshade_B = new(T)
				var/list/adjacent_turfs = list()
				for (var/turf/U in orange(1, T))
					adjacent_turfs += U
				playsound(deconvertee, 'monkestation/code/modules/bloody_cult/sound/deconversion_complete.ogg', 50, 0, -4)
				deconvertee.visible_message(span_notice("You see [deconvertee]'s eyes become clear. Through the blessing of [cult_chaplain ? "some fanfic headcanon version of [bible.deity_name]" : "[bible.deity_name]"] they have renounced Nar-Sie.") , span_notice("You were forgiven by [bible.deity_name]</span><span class = 'sinister'>[cult_chaplain ? " (YEAH RIGHT...)" : ""]</span><span class = 'notice'>. You no longer share the cult's goals.") )
				deconvertee.visible_message(span_userdanger("A pair of shades manifests from the occult energies that left them and start attacking them.") )
				cultist.owner.current.add_particles(PS_CULT_HALO)
				cultist.owner.current.adjust_particles(PVAR_COLOR, "#00000066", PS_CULT_HALO)
				cultist.owner.current.adjust_particles(PVAR_ICON_STATE, "cult_halo[cultist.get_devotion_rank()]", PS_CULT_HALO)
				cultist.owner.remove_antag_datum(/datum/antagonist/cult)
				var/list/speak = list("...you shall give back the blood we gave you [deconvertee]...", "...one does not simply turn their back on our gift...", "...if you won't dedicate your heart to Nar-Sie, you don't need it anymore...")
				redshade_A.say(pick(speak))
				redshade_B.say(pick(speak))
				target = deconvertee
				spawn(1)
					redshade_A.forceMove(get_turf(pick(adjacent_turfs)))
					redshade_B.forceMove(get_turf(pick(adjacent_turfs)))
					redshade_A.melee_attack(deconvertee)
					redshade_B.melee_attack(deconvertee)
					animate(redshade_A, alpha = 0, time = 2.5 SECONDS)
					animate(redshade_B, alpha = 0, time = 2.5 SECONDS)
					QDEL_IN(redshade_A, 3 SECONDS)
					QDEL_IN(redshade_B, 3 SECONDS)
					deconvertee.blood_volume -= 100 // ouch

			if (DECONVERSION_REFUSE)
				playsound(deconvertee, 'monkestation/code/modules/bloody_cult/sound/deconversion_failed.ogg', 50, 0, -4)
				to_chat(deconvertee, span_notice("You manage to block out the exorcism.") )
				deconvertee.visible_message(span_userdanger("The ritual was resisted!") , span_warning("The energies you mustered take their toll on your body...") )
		deconvertee.overlays -= image('monkestation/code/modules/bloody_cult/icons/effects.dmi', src, "deconversion")
		qdel(src)

/datum/deconversion_ritual/Destroy()
	if (cultist)
		cultist.deconversion = null
	cultist = null
	..()

// Belmont Bible Spin

/obj/effect/bible_spin
	var/mob/living/owner
	var/obj/item/book/bible/source
	var/image/bible_image
	var/current_spin = 0
	var/lifetime = 10 SECONDS
	var/lifetime_max = 10 SECONDS
	var/distance = 0
	var/distance_min = 8
	var/distance_amplitude = 24
	var/spin_speed = 30

/obj/effect/bible_spin/New(var/turf/loc, var/_owner, var/_source)
	..()
	if (!_owner || !_source)
		qdel(src)
		return
	playsound(src, 'monkestation/code/modules/bloody_cult/sound/bible_throw.ogg', 70, 0)
	owner = _owner
	source = _source
	source.forceMove(src)
	//owner.lock_atom(src)
	current_spin = dir2angle(owner.dir)
	bible_image = image(source.icon, source, source.icon_state)
	bible_image.plane = ABOVE_LIGHTING_PLANE
	overlays += bible_image
	spawn()
		process_spin()

/obj/effect/bible_spin/proc/process_spin()
	set waitfor = 0

	while(owner && !QDELETED(owner)&& source && !QDELETED(source) && (source.loc == src) && lifetime > 0)
		update_spin()
		var/obj/effect/afterimage/A = new(loc, null, 15)
		animate(A)
		A.appearance = appearance
		A.pixel_x = pixel_x
		A.pixel_y = pixel_y
		animate(A, alpha = 0, time = 10)
		A.layer--
		A.add_particles(PS_BIBLE_PAGE)
		A.adjust_particles(PVAR_VELOCITY, list(pixel_x/2, pixel_y/2), PS_BIBLE_PAGE)
		A.adjust_particles(PVAR_SPAWNING, 2, PS_BIBLE_PAGE)
		if ((lifetime % 10) == 0)
			playsound(src, 'monkestation/code/modules/bloody_cult/sound/bible_spin.ogg', 50, 0)
			for (var/mob/living/L in range(1, src))
				source.throw_impact(L, source.throw_speed*2, owner)
		lifetime--
		spawn(1)//making sure we're only spawning one page per afterimage
			A.adjust_particles(PVAR_SPAWNING, 0, PS_BIBLE_PAGE)
		sleep(1)

	if (source && !QDELETED(source))
		source.forceMove(loc)
		if (owner)
			owner.put_in_hands(source)
	qdel(src)

/obj/effect/bible_spin/proc/update_spin()
	current_spin += spin_speed
	distance = distance_min + distance_amplitude*sin(180*(lifetime/lifetime_max))
	animate(src, pixel_x = distance*cos(current_spin), pixel_y = distance*sin(current_spin), time = 1)
