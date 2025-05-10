GLOBAL_LIST_INIT(converted_minds, list())

/datum/rune_spell/conversion
	name = "Conversion"
	desc = "The unenlightened will bask before Nar-Sie's glory and given the chance to join the cult, or they will be made your prisoner."
	desc_talisman = "Use to remotely trigger the rune and incapacitate someone on top."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/blood
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_ATTUNE
	page = "By touching this rune while a non-cultist stands above it, you will knock them down and keep them unable to move or speak as Nar-Sie's words reach out to them. \
		The ritual will take longer on trained security personnel and some Nanotrasen official, but can also be sped up by wearing cult robes or armor.\
		<br><br>If the target is willing and there are few enough cult members, they will be converted and become an honorary cultist.\
		<br><br>However if the target has a loyalty implants or the cult already has 9 human members, they will instead be restrained by ghastly bindings. \
		More than one construct of each time will also reduce the maximum amount of permitted human cultists.\
		<br><br>Do not seek to convert everyone, instead use the Seer or Astral Journey runes first to locate the most interesting candidates.\
		<br><br>Touching the rune again during the early part of the ritual lets you toggle it between \"conversion\" and \"entrapment\", should you just want to restrain someone.\
		<br><br>By attuning a talisman to this rune, you can trigger it remotely, but you will have to move closer afterwards or the ritual will stop.\
		<br><br>This rune persists upon use, allowing repeated usage."
	var/remaining = 100
	var/mob/living/carbon/victim = null
	var/flavor_text = 0
	var/success = CONVERSION_NOCHOICE
	var/list/impede_medium = list(
		"Security Officer",
		"Warden",
		"Detective",
		"Head of Security",
		"Internal Affairs Agent",
		"Head of Personnel",
		)
	var/list/impede_hard = list(
		"Chaplain",
		"Captain",
		)
	var/obj/effect/cult_ritual/conversion/conversion = null

	var/phase = 1
	var/entrapment = FALSE


/datum/rune_spell/conversion/Destroy()
	if(conversion)
		conversion.Die()
	..()

/datum/rune_spell/conversion/update_progbar()//progbar tracks conversion progress instead of paid blood
	if (!progbar)
		progbar = image("icon" = 'monkestation/code/modules/bloody_cult/icons/doafter_icon.dmi', "loc" = spell_holder, "icon_state" = "prog_bar_0")
		progbar.pixel_z = 32
		progbar.plane = HUD_PLANE
		progbar.appearance_flags = RESET_COLOR
	progbar.icon_state = "prog_bar_[min(100, round((100-remaining), 10))]"
	return

/datum/rune_spell/conversion/cast()
	var/obj/effect/new_rune/R = spell_holder
	var/mob/converter = activator//trying to fix logs showing the converter as *null*

	R.one_pulse()
	var/turf/T = R.loc
	var/list/targets = list()


	for (var/mob/living/carbon/carbon in T)//all carbons can be converted...but only carbons. no cult silicons. (unless it's April 1st)
		if (!IS_CULTIST(carbon) && carbon.stat != DEAD)//no more corpse conversions!
			targets.Add(carbon)
	if (targets.len > 0)
		victim = pick(targets)
	else
		to_chat(activator, span_warning("There needs to be a potential convert standing or lying on top of the rune.") )
		qdel(src)
		return

	var/mob/convertee = victim//trying to fix logs showing the victim as *null*

	var/datum/team/cult/cult = locate_team(/datum/team/cult)

	update_progbar()
	if (activator.client)
		activator.client.images |= progbar

	//secondly, let's stun our victim and begin the ritual
	to_chat(victim, span_danger("Occult energies surge from below your [issilicon(victim) ? "actuators" : "feet"] and seep into your [issilicon(victim) ? "chassis" : "body"].") )
	victim.Knockdown(5 SECONDS)
	victim.Stun(5 SECONDS)
	if (isalien(victim))
		victim.Paralyze(5 SECONDS)
	victim.overlay_fullscreen("conversionborder", /atom/movable/screen/fullscreen/conversion_border)
	victim.update_fullscreen_alpha("conversionborder", 255, 5)
	conversion = new(T)
	flick("rune_convert_start", conversion)
	for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
		if (M.client)
			M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_start.ogg', 50, 0, -4)


	if (!cult.CanConvert())
		to_chat(activator, span_warning("There are already too many cultists. \The [victim] will be made a prisoner.") )

	if (victim.mind)
		if (victim.mind.assigned_role in impede_medium)
			to_chat(victim, span_warning("Your devotion to Nanotrasen slows down the ritual.") )
			to_chat(activator, span_warning("Their devotion to Nanotrasen is strong, the ritual will take longer.") )

		if (victim.mind.assigned_role in impede_hard)
			var/higher_cause = "Space Jesus"
			switch(victim.mind.assigned_role)
				if ("Captain")
					higher_cause = "Nanotrasen"
				if ("Chaplain")
					higher_cause = "a higher God"
			to_chat(victim, span_warning("Your devotion to [higher_cause] slows down the ritual.") )
			to_chat(activator, span_warning("Their devotion to [higher_cause] is amazing, the ritual will be lengthy.") )

	spawn()
		while (remaining > 0)
			if (destroying_self || !spell_holder || !activator || !victim)
				return
			//first let's make sure they're on the rune
			if (victim.loc != T)//Removed() should take care of it, but just in case
				victim.clear_fullscreen("conversionborder", 10)
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_abort.ogg', 50, 0, -4)
				conversion.icon_state = ""
				flick("rune_convert_abort", conversion)
				abort(RITUALABORT_REMOVED)
				return

			//and that we're next to them
			if (!spell_holder.Adjacent(activator))
				cancelling--
				if (cancelling <= 0)
					victim.clear_fullscreen("conversionborder", 10)
					for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
						if (M.client)
							M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_abort.ogg', 50, 0, -4)
					conversion.icon_state = ""
					flick("rune_convert_abort", conversion)
					abort(RITUALABORT_GONE)
					return

			else
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_process.ogg', 10, 0, -4)
				//then progress through the ritual
				victim.Knockdown(5 SECONDS)
				victim.Stun(5 SECONDS)
				if (isalien(victim))
					victim.Paralyze(5 SECONDS)
				var/progress = 10//10 seconds to reach second phase for a naked cultist
				progress += activator.get_cult_power()//down to 1-2 seconds when wearing cult gear
				var/delay = 0
				if (victim.mind)
					if (victim.mind.assigned_role in impede_medium)
						delay = 1
						progress = progress/2

					if (victim.mind.assigned_role in impede_hard)
						delay = 1
						progress = progress/4

				if (delay)
					progress = clamp(progress, 1, 10)
				remaining -= progress
				update_progbar()

				//spawning some messages
				var/threshold = min(100, round((100-remaining), 10))
				if (flavor_text < 3)
					if (flavor_text == 0 && threshold > 10)//it's ugly but gotta account for the possibility of several messages appearing at once
						to_chat(victim, span_cult("WE ARE THE BLOOD PUMPING THROUGH THE FABRIC OF SPACE") )
						flavor_text++
					if (flavor_text == 1 && threshold > 40)
						to_chat(victim, span_cult("THE GEOMETER CALLS FOR YET ANOTHER FEAST") )
						flavor_text++
					if (flavor_text == 2 && threshold > 70)
						to_chat(victim, span_cult("FRIEND OR FOE, YOU TOO SHALL JOIN THE FESTIVITIES") )
						flavor_text++
			sleep(10)

		if (activator && activator.client)
			activator.client.images -= progbar

		//alright, now the second phase, which always lasts an additional 10 seconds, but no longer requires the proximity of the activator.
		phase = 2
		var/acceptance = "Yes"
		victim.Knockdown(15 SECONDS)
		victim.Stun(15 SECONDS)
		if (isalien(victim))
			victim.Paralyze(15 SECONDS)

		if (victim.client)
			if(victim.mind.assigned_role == "Chaplain")
				acceptance = "Chaplain"

			for(var/obj/item/implant/mindshield/I in victim.implants)
				acceptance = "Implanted"

		else if (!victim.mind)
			acceptance = "Mindless"

		if (is_banned_from(victim.ckey, ROLE_CULTIST))
			acceptance = "Banned"


		if (!cult.CanConvert())
			acceptance = "Overcrowded"

		if (entrapment)
			acceptance = "Overcrowded"

		//Players with cult enabled in their preferences will always get converted. TBAfor
		//Others get a choice, unless they're cult-banned or have their preferences set to Never (or disconnected), in which case they always die.
		var/conversion_delay = 100
		switch (acceptance)
			if ("Always", "Yes")
				conversion.icon_state = "rune_convert_good"
				to_chat(activator, span_cult("The ritual immediately stabilizes, \the [victim] appears eager help prepare the festivities.") )
				cult.send_flavour_text_accept(victim, activator)
				success = CONVERSION_ACCEPT
				conversion_delay = 30
			if ("No", "???", "Never")
				if (victim.client)
					to_chat(activator, span_cult("The ritual arrives in its final phase. How it ends depends now of \the [victim]. You do not have to remain adjacent for the remainder of the ritual.") )
					spawn()
						if (alert(victim, "The Cult of Nar-Sie has much in store for you, but what specifically?", "You have 10 seconds to decide", "Join the Cult", "Become Prisoner") == "Join the Cult")
							conversion.icon_state = "rune_convert_good"
							success = CONVERSION_ACCEPT
							to_chat(victim, span_cult("THAT IS GOOD. COME CLOSER. THERE IS MUCH TO TEACH YOU") )
						else
							to_chat(victim, span_danger("THAT IS ALSO GOOD, FOR YOU WILL ENTERTAIN US") )
							success = CONVERSION_REFUSE
				else//converting a braindead carbon will always lead to them being captured
					to_chat(activator, span_cult("\The [victim] doesn't really seem to have all their wits about them. Letting the ritual conclude will let you restrain them.") )
			if ("Implanted")
				if (victim.client)
					to_chat(activator, span_cult("A loyalty implant interferes with the ritual. They will not be able to accept the conversion.") )
					to_chat(victim, span_danger("Your loyalty implant prevents you from hearing any more of what they have to say.") )
					success = CONVERSION_REFUSE
				else//converting a braindead carbon will always lead to them being captured
					to_chat(activator, span_cult("\The [victim] doesn't really seem to have all their wits about them. Letting the ritual conclude will let you restrain them.") )
			if ("Chaplain")//Chaplains can never be converted
				if (victim.client)
					to_chat(activator, span_cult("Chaplains won't ever let themselves be converted. They will be restrained.") )
					to_chat(victim, span_danger("Your devotion to Space Jesus shields you from Nar-Sie's temptations.") )
					success = CONVERSION_REFUSE
				else//converting a braindead carbon will always lead to them being captured
					to_chat(activator, span_cult("\The [victim] doesn't really seem to have all their wits about them. Letting the ritual conclude will let you restrain them.") )
			if ("Banned")
				conversion.icon_state = "rune_convert_bad"
				to_chat(activator, span_cult("Given how unstable the ritual is becoming, \The [victim] will surely be consumed entirely by it. They weren't meant to become one of us.") )
				to_chat(victim, span_danger("Except your past actions have displeased us. You will be our snack before the feast begins. \[You are banned from this role\]") )
				success = CONVERSION_BANNED
			if ("Mindless")
				conversion.icon_state = "rune_convert_bad"
				to_chat(activator, span_cult("This mindless creature will be sacrificed.") )
				success = CONVERSION_MINDLESS
			if ("Overcrowded")
				to_chat(victim, span_cult("EXCEPT...THERE ARE NO VACANT SEATS LEFT!") )
				success = CONVERSION_OVERCROWDED
				conversion_delay = 30

		//since we're no longer checking for the cultist's adjacency, let's finish this ritual without a loop
		sleep(conversion_delay)

		if (destroying_self || !spell_holder || !activator || !victim)
			return

		if (victim.loc != T)//Removed() should take care of it, but just in case
			victim.clear_fullscreen("conversionborder", 10)
			for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
				if (M.client)
					M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_abort.ogg', 50, 0, -4)
			conversion.icon_state = ""
			flick("rune_convert_abort", conversion)
			abort(RITUALABORT_REMOVED)
			return

		if (victim.mind && !(victim.mind in GLOB.converted_minds))
			GLOB.converted_minds += victim.mind
			if (!cult)
				message_admins("Blood Cult: A conversion ritual occured...but we cannot find the cult faction...")//failsafe in case of admin varedit fuckery
			var/datum/antagonist/streamer/streamer_role = activator?.mind?.has_antag_datum(/datum/antagonist/streamer)
			if(streamer_role && streamer_role.team == "Cult")
				streamer_role.conversions +=  1
				streamer_role.update_streamer_hud()

		switch (success)
			if (CONVERSION_ACCEPT)
				conversion.layer = BELOW_OBJ_LAYER
				conversion.plane = GAME_PLANE_UPPER
				victim.clear_fullscreen("conversionborder", 10)
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_success.ogg', 75, 0, -4)
				//new cultists get purged of the debuffs
				victim.SetKnockdown(0)
				victim.SetStun(0)
				if (isalien(victim))
					victim.SetParalyzed(0)
				//let's also remove cult cuffs if they have them
				if (istype(victim.handcuffed, /obj/item/restraints/handcuffs/cult))
					victim.dropItemToGround(victim.handcuffed)

				convert(convertee, converter)
				conversion.icon_state = ""

				flick("rune_convert_success", conversion)
				message_admins("BLOODCULT: [key_name(convertee)] has been converted by [key_name(converter)].")
				log_admin("BLOODCULT: [key_name(convertee)] has been converted by [key_name(converter)].")
				abort(RITUALABORT_CONVERT)
				return
			if (CONVERSION_NOCHOICE, CONVERSION_REFUSE, CONVERSION_OVERCROWDED)
				conversion.icon_state = ""
				flick("rune_convert_refused", conversion)
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/convert_abort.ogg', 75, 0, -4)

				victim.Knockdown(7)
				victim.Stun(6)
				if (isalien(victim))
					victim.Paralyze(8)

				if (cult && victim.mind)
					if (!(victim.mind in cult.previously_made_prisoner))
						cult.previously_made_prisoner |= victim.mind
						var/datum/antagonist/cult/cult_datum = activator.mind.has_antag_datum(/datum/antagonist/cult)
						cult_datum.gain_devotion(250, DEVOTION_TIER_3, "made_prisoner", victim)

				//let's start by removing any cuffs they might already have
				if (victim.handcuffed)
					var/obj/item/restraints/handcuffs/cuffs = victim.handcuffed
					victim.dropItemToGround(cuffs)

				var/obj/item/restraints/handcuffs/cult/restraints = new(victim)
				victim.set_handcuffed(restraints)
				restraints.gaoler = IS_CULTIST(converter)
				victim.update_handcuffed()

				if (success == CONVERSION_NOCHOICE)
					if (convertee.mind)//no need to generate logs when capturing mindless monkeys
						to_chat(victim, span_danger("Because you didn't give your answer in time, you were automatically made prisoner.") )
						message_admins("BLOODCULT: [key_name(convertee)] has timed-out during conversion by [key_name(converter)].")
						log_admin("BLOODCULT: [key_name(convertee)] has timed-out during conversion by [key_name(converter)].")

					abort(RITUALABORT_NOCHOICE)
				else if (success == CONVERSION_REFUSE)
					message_admins("BLOODCULT: [key_name(convertee)] has refused conversion by [key_name(converter)].")
					log_admin("BLOODCULT: [key_name(convertee)] has refused conversion by [key_name(converter)].")

					abort(RITUALABORT_REFUSED)
				else
					message_admins("BLOODCULT: [key_name(convertee)] was made prisoner by [key_name(converter)] because the cult is overcrowded.")
					log_admin("BLOODCULT: [key_name(convertee)] was made prisoner by [key_name(converter)] because the cult is overcrowded.")

					abort(RITUALABORT_REFUSED)

			if (CONVERSION_BANNED)

				message_admins("BLOODCULT: [key_name(convertee)] died because they were converted by [key_name(converter)] while cult-banned.")
				log_admin("BLOODCULT: [key_name(convertee)] died because they were converted by [key_name(converter)] while cult-banned.")
				conversion.icon_state = ""
				flick("rune_convert_failure", conversion)

				//sacrificed victims have all their stuff stored in a coffer that also contains their skull and a cup of their blood, should they have either
				victim.boxify(TRUE, FALSE, "cult")
				abort(RITUALABORT_SACRIFICE)

			if (CONVERSION_MINDLESS)

				conversion.icon_state = ""
				flick("rune_convert_failure", conversion)

				victim.boxify(TRUE, FALSE, "cult")
				abort(RITUALABORT_SACRIFICE)
		victim.clear_fullscreen("conversionborder", 10)

/datum/rune_spell/conversion/proc/convert(var/mob/M, var/mob/converter)
	var/datum/antagonist/cult/newCultist = new(M.mind)
	M.mind.add_antag_datum(newCultist)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	cult.HandleRecruitedRole(newCultist)
	if (!(victim.mind in cult.previously_converted))
		cult.previously_made_prisoner |= M.mind
		var/datum/antagonist/cult/cult_datum = converter.mind.has_antag_datum(/datum/antagonist/cult)
		if (victim.mind in cult.previously_made_prisoner)
			cult_datum.gain_devotion(250, DEVOTION_TIER_4, "converted_prisoner", victim)//making someone prisoner already grants 250 devotion on top.
		else
			cult_datum.gain_devotion(500, DEVOTION_TIER_4, "conversion", victim)
	//newCultist.OnPostSetup()
	//newCultist.Greet(GREET_CONVERTED)
	newCultist.conversion["converted"] = activator
	newCultist.update_cult_hud()

/datum/rune_spell/conversion/midcast(mob/add_cultist)
	if (add_cultist != activator)
		return
	if (phase == 1)
		if (entrapment)
			to_chat(add_cultist, span_notice("You perform the conversion sign, allowing the victim to become a cultist if they qualify.") )
			entrapment = FALSE
		else
			to_chat(add_cultist, span_warning("You perform the entrapment sign, ensuring that the victim will be restrained.") )
			entrapment = TRUE

/datum/rune_spell/conversion/Removed(var/mob/M)
	if (victim == M)
		for(var/mob/living/L in dview(world.view, spell_holder.loc, INVISIBILITY_MAXIMUM))
			if (L.client)
				L.playsound_local(spell_holder.loc, 'monkestation/code/modules/bloody_cult/sound/convert_abort.ogg', 50, 0, -4)
		conversion.icon_state = ""
		flick("rune_convert_abort", conversion)
		abort(RITUALABORT_REMOVED)

/datum/rune_spell/conversion/cast_talisman()//handled by /obj/item/talisman/proc/trigger instead
	return

/datum/rune_spell/conversion/abort(var/cause)
	if (victim)
		victim.clear_fullscreen("conversionborder", 10)
		victim = null
	..()

/obj/effect/cult_ritual/conversion
	anchored = 1
	icon = 'monkestation/code/modules/bloody_cult/icons/64x64.dmi'
	icon_state = "rune_convert_process"
	pixel_x = -32/2
	pixel_y = -32/2
	plane = ABOVE_LIGHTING_PLANE
	mouse_opacity = 0

/obj/effect/cult_ritual/conversion/proc/Die()
	spawn(10)
		qdel(src)
