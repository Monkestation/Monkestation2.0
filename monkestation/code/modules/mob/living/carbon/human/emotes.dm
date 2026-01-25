/datum/emote/living/carbon/human/assinhale
	key = "assinhale"
	key_third_person = "inhales through their ass"

	var/sounds = list(
		'monkestation/sound/effects/fart_reverse1.ogg',
		'monkestation/sound/effects/fart_reverse2.ogg',
		'monkestation/sound/effects/fart_reverse3.ogg',
		'monkestation/sound/effects/fart_reverse4.ogg'
	)
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/assinhale/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if (!.)
		return

	if(!user.get_organ_slot(ORGAN_SLOT_BUTT) || !ishuman(user))
		to_chat(user, "<span class='warning'>You don't have a butt!</span>")
		return
	var/mob/living/carbon/human/ass_holder = user
	var/obj/item/organ/internal/butt/booty = user.get_organ_slot(ORGAN_SLOT_BUTT)

	if (booty.superfart_armed)
		to_chat(user, "<span class='warning'>Your ass is already armed!</span>")
		return

	var/volume = 50
	if(ass_holder.has_quirk(/datum/quirk/loud_ass))
		volume = volume * 2

	user.visible_message(span_warning("[ass_holder] inhales through their ass. What the fuck?"), span_warning("You inhale through your ass, ready to super fart at any moment!"))
	playsound(ass_holder, pick(sounds), volume, TRUE, pressure_affected = FALSE, mixer_channel = CHANNEL_PRUDE)
	booty.superfart_armed = TRUE
	ass_holder.add_mood_event("superfart_armed", /datum/mood_event/superfart_armed)

/datum/emote/living/carbon/human/superfart
	key = "superfart"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/human/superfart/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(user.stat > SOFT_CRIT) //Only superfart in softcrit or less.
		return
	if(!user.get_organ_slot(ORGAN_SLOT_BUTT) || !ishuman(user))
		to_chat(user, "<span class='warning'>You don't have a butt!</span>")
		return
	var/mob/living/carbon/human/ass_holder = user
	var/obj/item/organ/internal/butt/booty = user.get_organ_slot(ORGAN_SLOT_BUTT)
	if(booty.cooling_down)
		return
	booty.cooling_down = TRUE
	var/turf/Location = get_turf(ass_holder)

	ass_holder.clear_mood_event("superfart_armed")

	//BIBLEFART/
	//This goes above all else because it's an instagib.
	for(var/obj/item/book/bible/Holy in Location)
		ass_holder.visible_message(span_warning("[ass_holder] attempts to fart on \the [Holy], uh oh."))
		ass_holder.dagoth_kill_smite(butt = booty, explode = TRUE)
		return

	playsound(ass_holder, "monkestation/sound/effects/superfart.ogg", 100, FALSE, pressure_affected = FALSE, mixer_channel = CHANNEL_PRUDE)
	addtimer(CALLBACK(src, PROC_REF(finish_superfart), ass_holder, booty), 0.8 SECONDS)

/datum/emote/living/carbon/human/superfart/proc/finish_superfart(mob/living/carbon/human/user, obj/item/organ/internal/butt/booty)
	var/turf/turf = get_turf(user)
	switch(rand(1000))
		if(0) //Ass Rod
			var/butt_end
			var/butt_x
			var/butt_y
			switch(user.dir)
				if(SOUTH)
					butt_y = world.maxy-(TRANSITIONEDGE+1)
					butt_x = user.x
				if(WEST)
					butt_x = world.maxx-(TRANSITIONEDGE+1)
					butt_y = user.y
				if(NORTH)
					butt_y = (TRANSITIONEDGE+1)
					butt_x = user.x
				else
					butt_x = (TRANSITIONEDGE+1)
					butt_y = user.y
			butt_end = locate(butt_x, butt_y, turf.z)
			user.visible_message(span_warning("<b>[user]</b> blows their ass off with such force, they explode!"), span_warning("Holy shit, your butt flies off into the galaxy!"))
			priority_announce("What the fuck was that?!", "General Alert", SSstation.announcer.get_rand_alert_sound())
			user.gib()
			qdel(booty)
			new /obj/effect/immovablerod/butt(turf, butt_end)
			return
		if(1 to 11) 	//explosive fart
			user.visible_message(span_warning("[user]'s ass explodes violently!"))
			dyn_explosion(turf, 5, 5)
			return
		if(12 to 1000)		//Regular superfart
			if(!turf.has_gravity())
				var/atom/target = get_edge_target_turf(user, user.dir)
				user.throw_at(target, 1, 20, spin = FALSE)
			user.visible_message(span_warning("[user]'s butt goes flying off!"))
			new /obj/effect/decal/cleanable/blood(turf)
			user.nutrition = max(user.nutrition - rand(10, 40), NUTRITION_LEVEL_STARVING)
			booty.Remove(user)
			booty.forceMove(turf)
			for(var/mob/living/Struck in turf)
				if(Struck != user)
					user.visible_message(span_danger("[Struck] is violently struck in the face by [user]'s flying ass!"))
					Struck.apply_damage(20, BRUTE, BODY_ZONE_HEAD)
	addtimer(VARSET_CALLBACK(booty, cooling_down, FALSE), 2 SECONDS)
