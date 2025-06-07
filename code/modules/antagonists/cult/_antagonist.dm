/datum/antagonist/cult
	name = "Cultist"
	roundend_category = "cultists"
	antagpanel_category = "Cult"
	antag_moodlet = /datum/mood_event/cult
	suicide_cry = "FOR NAR'SIE!!"
	preview_outfit = /datum/outfit/cultist
	job_rank = ROLE_CULTIST
	antag_hud_name = "cult"
	var/ignore_implant = FALSE
	var/give_equipment = FALSE
	var/datum/team/cult/cult_team

	///NEW VARS HERE
	var/list/tattoos = list()
	var/holywarning_cooldown = 0
	var/list/conversion = list()
	var/second_chance = 1
	var/datum/deconversion_ritual/deconversion = null

	//writing runes
	var/rune_blood_cost = 1	// How much blood spent per rune word written
	var/verbose = FALSE	// Used by the rune writing UI to avoid message spam

	var/cultist_role = CULTIST_ROLE_NONE // Because the role might change on the fly and we don't want to set everything again each time, better not start dealing with subtypes
	var/arch_cultist = FALSE	// same as above

	var/time_role_changed_last = 0

	var/datum/antagonist/cult/mentor = null
	var/list/acolytes = list()

	var/devotion = 0
	var/rank = DEVOTION_TIER_0

	var/blood_pool = FALSE

	var/initial_rituals = FALSE
	var/list/possible_rituals = list()
	var/list/rituals = list(RITUAL_CULTIST_1, RITUAL_CULTIST_2)
	var/logo_state = "cult-logo"

/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/cult/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.cult_team)
				cult_team = H.cult_team
				return
		cult_team = new /datum/team/cult
		cult_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	cult_team = new_team

/datum/antagonist/cult/proc/add_objectives()
	objectives |= cult_team.objectives

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(. && !ignore_implant)
		. = is_convertable_to_cult(new_owner.current, cult_team)

/datum/antagonist/cult/greet()
	. = ..()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult/bloodcult_gain.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/cult/on_gain()
	add_objectives()
	START_PROCESSING(SSobj, src)
	owner.current.DisplayUI("Cultist")
	for (var/ritual_type in GLOB.bloodcult_personal_rituals)
		possible_rituals += new ritual_type()
	. = ..()
	var/mob/living/current = owner.current
	if(give_equipment)
		equip_cultist(TRUE)
	current.log_message("has been converted to the cult of Nar'Sie!", LOG_ATTACK, color = "#960000")

	if(cult_team.blood_target && cult_team.blood_target_image && current.client)
		current.client.images += cult_team.blood_target_image

	ADD_TRAIT(current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)

/datum/antagonist/cult/on_removal()
	REMOVE_TRAIT(owner.current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)
	owner.current.HideUI("Cultist")
	STOP_PROCESSING(SSobj, src)
	if(!silent)
		owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!"), ignored_mobs = owner.current)
		to_chat(owner.current, span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of the Geometer and all your memories as her servant."))
		owner.current.log_message("has renounced the cult of Nar'Sie!", LOG_ATTACK, color = "#960000")
	if(cult_team.blood_target && cult_team.blood_target_image && owner.current.client)
		owner.current.client.images -= cult_team.blood_target_image
	cult_team.check_destroy()
	return ..()

/datum/antagonist/cult/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)

	// The longsword is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/cultblade/longsword = new
	icon.Blend(icon(longsword.lefthand_file, longsword.inhand_icon_state), ICON_OVERLAY)
	qdel(longsword)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/antagonist/cult/proc/equip_cultist(metal = TRUE)
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += cult_give_item(/obj/item/melee/cultblade/dagger, H)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H)
	to_chat(owner, "These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")

///Attempts to make a new item and put it in a potential inventory slot in the provided mob.
/datum/antagonist/cult/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/item = new item_path(mob)
	var/where = mob.equip_conspicuous_item(item)
	if(!where)
		to_chat(mob, span_userdanger("Unfortunately, you weren't able to get [item]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE
	else
		to_chat(mob, span_danger("You have [item] in your [where]."))
		if(where == "backpack")
			mob.back.atom_storage?.show_contents(mob)
		return TRUE

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	current.faction |= FACTION_CULT
	current.grant_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	if(cult_team.cult_risen)
		current.AddElement(/datum/element/cult_eyes, initial_delay = 0 SECONDS)
	if(cult_team.cult_ascendent)
		current.AddElement(/datum/element/cult_halo, initial_delay = 0 SECONDS)

	add_team_hud(current)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, removing = FALSE)
	current.faction -= FACTION_CULT
	current.remove_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	current.clear_alert("bloodsense")
	if (HAS_TRAIT(current, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		current.RemoveElement(/datum/element/cult_eyes)
	if (HAS_TRAIT(current, TRAIT_CULT_HALO))
		current.RemoveElement(/datum/element/cult_halo)

/datum/antagonist/cult/on_mindshield(mob/implanter)
	if(!silent)
		to_chat(owner.current, span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
	return

/datum/antagonist/cult/admin_add(datum/mind/new_owner, mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has cult-ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has cult-ed [key_name(new_owner)].")

/datum/antagonist/cult/admin_remove(mob/user)
	silent = TRUE
	return ..()

/datum/antagonist/cult/get_admin_commands()
	. = ..()
	.["Dagger"] = CALLBACK(src, PROC_REF(admin_give_dagger))
	.["Dagger and Metal"] = CALLBACK(src, PROC_REF(admin_give_metal))
	.["Remove Dagger and Metal"] = CALLBACK(src, PROC_REF(admin_take_all))

/datum/antagonist/cult/proc/admin_give_dagger(mob/admin)
	if(!equip_cultist(metal = FALSE))
		to_chat(admin, span_danger("Spawning dagger failed!"))

/datum/antagonist/cult/proc/admin_give_metal(mob/admin)
	if (!equip_cultist(metal = TRUE))
		to_chat(admin, span_danger("Spawning runed metal failed!"))

/datum/antagonist/cult/proc/admin_take_all(mob/admin)
	var/mob/living/current = owner.current
	for(var/o in current.get_all_contents())
		if(istype(o, /obj/item/melee/cultblade/dagger) || istype(o, /obj/item/stack/sheet/runed_metal))
			qdel(o)

/datum/antagonist/cult/proc/erase_rune()
	var/mob/living/user = owner.current
	if (!istype(user))
		return

	if (user.incapacitated())
		return

	var/turf/T = get_turf(user)
	var/obj/effect/rune/rune = locate() in T

	if (rune && rune.invisibility == INVISIBILITY_OBSERVER)
		to_chat(user, span_warning("You can feel the presence of a concealed rune here, you have to reveal it before you can erase words from it.") )
		return

	var/removed_word = erase_rune_word(get_turf(user))
	if (removed_word)
		to_chat(user, span_notice("You retrace your steps, carefully undoing the lines of the [removed_word] rune.") )
	else
		to_chat(user, span_warning("There aren't any rune words left to erase.") )

/datum/antagonist/cult/proc/gain_devotion(acquired_devotion = 0, tier = DEVOTION_TIER_0, key, extra)
	if (cult_team)
		switch(cult_team.stage)
			if (BLOODCULT_STAGE_DEFEATED)//no more devotion gains if the bloodstone has been destroyed
				return
			if (BLOODCULT_STAGE_NARSIE)//or narsie has risen
				return

	if (key && (!cult_team || (cult_team.stage != BLOODCULT_STAGE_ECLIPSE)))
		for (var/ritual_slot in rituals)
			if (rituals[ritual_slot])
				var/datum/bloodcult_ritual/my_ritual = rituals[ritual_slot]
				if (key in my_ritual.keys)
					if (my_ritual.key_found(extra))
						my_ritual.complete()
						if (!my_ritual.only_once)
							possible_rituals += my_ritual
						rituals[ritual_slot] = null
						var/mob/M = owner.current
						if (M)
							to_chat(M, span_cult("You have completed a ritual and been reward for your devotion...soon another ritual will take its place.") )
						spawn(5 MINUTES)
							if (!rituals[ritual_slot])
								replace_rituals(ritual_slot)
	if (cult_team && (cult_team.stage != BLOODCULT_STAGE_ECLIPSE))
		var/datum/team/cult/cult = cult_team
		for (var/ritual_slot in cult.rituals)
			if (cult.rituals[ritual_slot])
				var/datum/bloodcult_ritual/faction_ritual = cult.rituals[ritual_slot]
				if (key in faction_ritual.keys)
					if (faction_ritual.key_found(extra))
						faction_ritual.complete()
						if (!faction_ritual.only_once)
							cult.possible_rituals += faction_ritual
						cult.rituals[ritual_slot] = null
						for (var/datum/mind/mind in cult.members)
							var/mob/M = mind.current
							if (M)
								if (M == owner.current)
									to_chat(M, span_cult("You have completed a ritual, and rewarded the entire cult...soon another ritual will take its place.") )
								else
									to_chat(M, span_cult("Someone has completed a ritual, rewarding the entire cult...soon another ritual will take its place.") )
						spawn(10 MINUTES)
							if (!cult.rituals[ritual_slot])
								cult.replace_rituals(ritual_slot)

	//The more devotion the cultist has acquired, the less devotion they obtain from lesser rituals
	switch (get_devotion_rank() - tier)
		if (3 to INFINITY)
			return//until they just don't get any devotion anymore
		if (2)
			acquired_devotion /= 10
		if (1)
			acquired_devotion /= 2
	devotion += acquired_devotion
	check_rank_upgrade()

	if (cult_team)
		var/datum/team/cult/cult = cult_team
		cult.total_devotion += acquired_devotion

/datum/antagonist/cult/proc/check_rank_upgrade()
	var/new_rank = get_devotion_rank()
	while (new_rank > rank)
		rank++
		if (iscarbon(owner.current))//constructs and shades cannot make use of those powers so no point informing them.
			to_chat(owner.current, span_cultlarge("As your devotion to the cult increases, a new power awakens inside you.") )
			switch(rank)
				if (DEVOTION_TIER_1)
					to_chat(owner.current, span_danger("Blood Pooling") )
					to_chat(owner.current, "<b>Any blood cost required by a cult rune or ritual will now be reduced and split with other cult members that have attained this power. You can toggle blood pooling as needed.</b>")
					GiveTattoo(/datum/cult_tattoo/bloodpool)
				if (DEVOTION_TIER_2)
					to_chat(owner.current, span_danger("Blood Dagger") )
					to_chat(owner.current, "<b>You can now form a dagger using your own blood (or pooled blood, any blood that you can get your hands on). Hitting someone will let the dagger steal some of their blood, while sheathing the dagger will let you recover all the stolen blood. Throwing the dagger deals damage based on how much blood it carries, and nails the victim down, forcing them to pull the dagger out to move away.</b>")
					GiveTattoo(/datum/cult_tattoo/dagger)
				if (DEVOTION_TIER_3)
					to_chat(owner.current, span_danger("Runic Skin") )
					to_chat(owner.current, "<b>You can now fuse a talisman that has a rune imbued or attuned to it with your skin, granting you the ability to cast this talisman hands free, as long as you are conscious and not under the effects of Holy Water.</b>")
					GiveTattoo(/datum/cult_tattoo/rune_store)
				if (DEVOTION_TIER_4)
					to_chat(owner.current, span_danger("Shortcut Sigil") )
					to_chat(owner.current, "<b>Apply your palms on a wall to draw a sigil on it that lets you and any ally pass through it.</b>")
					GiveTattoo(/datum/cult_tattoo/shortcut)

/datum/antagonist/cult/proc/get_devotion_rank()
	switch(devotion)
		if (2000 to INFINITY)
			return DEVOTION_TIER_4
		if (1000 to 2000)
			return DEVOTION_TIER_3
		if (500 to 1000)
			return DEVOTION_TIER_2
		if (100 to 500)
			return DEVOTION_TIER_1
		if (0 to 100)
			return DEVOTION_TIER_0

/datum/antagonist/cult/proc/FindMentor()
	var/datum/team/cult/cult = cult_team
	if (!cult || !cult.mentor_count)
		return
	var/datum/antagonist/cult/potential_mentor
	var/min_acolytes = 10000
	for (var/datum/mind/mind in cult.members)
		var/datum/antagonist/cult/cult_datum = mind.has_antag_datum(/datum/antagonist/cult)
		if (!mind.current || mind.current.stat == DEAD)
			continue
		if (cult_datum.cultist_role == CULTIST_ROLE_MENTOR)
			if (cult_datum.acolytes.len < min_acolytes || (cult_datum.acolytes.len == min_acolytes && prob(50)))
				min_acolytes = cult_datum.acolytes.len
				potential_mentor = cult_datum

	if (potential_mentor)
		mentor = potential_mentor
		potential_mentor.acolytes |= src
		to_chat(owner.current, span_cult("You are now in a mentorship under <span class = 'danger'>[mentor.owner.name], the [mentor.owner.assigned_role == "MODE" ? (mentor.owner.special_role) : (mentor.owner.assigned_role)]</span>. Seek their help to learn the ways of our cult.") )
		to_chat(mentor.owner.current, span_cult("You are now mentoring <span class = 'danger'>[owner.name], the [owner.assigned_role == "MODE" ? (owner.special_role) : (owner.assigned_role)]</span>. ") )
		message_admins("[mentor.owner.key]/([mentor.owner.name]) is now mentoring [owner.name]")
		log_admin("[mentor.owner.key]/([mentor.owner.name]) is now mentoring [owner.name]")

/datum/antagonist/cult/proc/GiveTattoo(type)
	if(locate(type) in tattoos)
		return
	var/datum/cult_tattoo/T = new type
	tattoos[T.name] = T
	update_cult_hud()
	T.getTattoo(owner.current)
	//anim(target = owner.current, a_icon = 'icons/effects/32x96.dmi', flick_anim = "tattoo_receive", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	sleep(1)
	//a bit too visible now that those may be unlocked at any time and no longer just in front of a spire
	//var/atom/movable/overlay/tattoo_markings = anim(target = owner.current, a_icon = 'icons/mob/cult_tattoos.dmi', flick_anim = "[T.icon_state]_mark", sleeptime = 30, lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	//animate(tattoo_markings, alpha = 0, time = 30)

/datum/antagonist/cult/proc/update_cult_hud()
	var/mob/M = owner?.current
	if(M)
		if (M.client && M.hud_used)
			if (isshade(M))
				if (istype(M.loc, /obj/item/melee/soulblade))
					M.DisplayUI("Soulblade")
			else
				M.DisplayUI("Cultist")

/datum/antagonist/cult/proc/replace_rituals(slot)
	if (!slot)
		return

	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions(src))
			valid_rituals += R

	if (valid_rituals.len < 1)
		return

	var/datum/bloodcult_ritual/BR = pick(valid_rituals)
	rituals[slot] = BR
	possible_rituals -= BR
	BR.init_ritual()

	var/mob/O = owner.current
	if (O)
		to_chat(O, span_cult("A new ritual is available...") )
	var/datum/mind/M = owner
	if ("Cult Panel" in M.active_uis)
		var/datum/mind_ui/m_ui = M.active_uis["Cult Panel"]
		if (m_ui.active)
			m_ui.Display()

/datum/antagonist/cult/proc/ChangeCultistRole(new_role)
	if (!new_role)
		return
	var/datum/team/cult/cult = cult_team
	if ((cultist_role == CULTIST_ROLE_MENTOR) && cult)
		cult.mentor_count--

	cultist_role = new_role

	DropMentorship()

	switch(cultist_role)
		if (CULTIST_ROLE_ACOLYTE)
			message_admins("BLOODCULT: [owner.key]/([owner.name]) has become a cultist acolyte.")
			log_admin("BLOODCULT: [owner.key]/([owner.name]) has become a cultist acolyte.")
			logo_state = "cult-apprentice-logo"
			FindMentor()
			if (!mentor)
				message_admins("BLOODCULT: [owner.key]/([owner.name]) couldn't find a mentor.")
				log_admin("BLOODCULT: [owner.key]/([owner.name]) couldn't find a mentor.")
		if (CULTIST_ROLE_HERALD)
			message_admins("BLOODCULT: [owner.key]/([owner.name]) has become a cultist herald.")
			log_admin("BLOODCULT: [owner.key]/([owner.name]) has become a cultist herald.")
			logo_state = "cult-logo"
		if (CULTIST_ROLE_MENTOR)
			message_admins("BLOODCULT: [owner.key]/([owner.name]) has become a cultist mentor.")
			log_admin("BLOODCULT: [owner.key]/([owner.name]) has become a cultist mentor.")
			logo_state = "cult-master-logo"
			if (cult)
				cult.mentor_count++
		else
			logo_state = "cult-logo"
			cultist_role = CULTIST_ROLE_NONE
	if (owner.current)//refreshing the UI so the current role icon appears on the cult panel button and role change button.
		owner.current.DisplayUI("Cultist Left Panel")
		owner.current.DisplayUI("Cult Panel")
	time_role_changed_last = world.time

/datum/antagonist/cult/proc/DropMentorship()
	if (mentor)
		to_chat(owner.current, span_warning("You have ended your mentorship under [mentor.owner.name].") )
		to_chat(mentor.owner.current, span_warning("[owner.name] has ended their mentorship under you.") )
		message_admins("[owner.key]/([owner.name]) has ended their mentorship under [mentor.owner.name]")
		log_admin("[owner.key]/([owner.name]) has ended their mentorship under [mentor.owner.name]")
		mentor.acolytes -= src
		mentor = null
	if (acolytes.len > 0)
		for (var/datum/antagonist/cult/acolyte in acolytes)
			to_chat(owner.current, span_warning("You have ended your mentorship of [acolyte.owner.name].") )
			to_chat(acolyte.owner.current, span_warning("[owner.name] has ended their mentorship.") )
			message_admins("[owner.key]/([owner.name]) has ended their mentorship of [acolyte.owner.name]")
			log_admin("[owner.key]/([owner.name]) has ended their mentorship of [acolyte.owner.name]")
			acolyte.mentor = null
		acolytes = list()

/datum/antagonist/cult/proc/write_rune(word_to_draw)
	var/mob/living/user = owner.current

	if (user.incapacitated())
		return

	var/muted = user.occult_muted()
	if (muted)
		to_chat(user, span_danger("You find yourself unable to focus your mind on the words of Nar-Sie.") )
		return

	if(!istype(user.loc, /turf))
		to_chat(user, span_warning("You do not have enough space to write a proper rune.") )
		return

	if(istype(user.loc, /turf/open/space))
		to_chat(user, span_warning("Get over a solid surface first!") )
		return

	var/turf/T = get_turf(user)
	var/obj/effect/new_rune/rune = locate() in T

	if(rune)
		if (rune.invisibility == INVISIBILITY_OBSERVER)
			to_chat(user, span_warning("You can feel the presence of a concealed rune here. You have to reveal it before you can add more words to it.") )
			return
		else if (rune.word1 && rune.word2 && rune.word3)
			to_chat(user, span_warning("You cannot add more than 3 words to a rune.") )
			return

	var/datum/rune_word/word = GLOB.rune_words[word_to_draw]
	var/list/rune_blood_data = use_available_blood(user, rune_blood_cost, feedback = verbose)
	if (rune_blood_data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		return

	if (verbose)
		if(rune)
			user.visible_message(span_warning("\The [user] chants and paints more symbols on the floor.") , \
					span_warning("You add another word to the rune.") , \
					span_warning("You hear chanting.") )
		else
			user.visible_message(span_warning("\The [user] begins to chant and paint symbols on the floor.") , \
					span_warning("You begin drawing a rune on the floor.") , \
					span_warning("You hear some chanting.") )

	if(!user.checkTattoo(TATTOO_SILENT))
		user.whisper("...[word.rune]...")

	if(rune)
		if(rune.word1 && rune.word2 && rune.word3)
			to_chat(user, span_warning("You cannot add more than 3 words to a rune.") )
			return
	gain_devotion(10, DEVOTION_TIER_0, "write_rune", word.english)
	write_rune_word(get_turf(user), word, rune_blood_data["blood"], caster = user)
	verbose = FALSE


/datum/antagonist/cult/proc/assign_rituals()
	initial_rituals = TRUE
	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions(src))
			valid_rituals += R

	if (valid_rituals.len < 2)
		return

	var/datum/bloodcult_ritual/previous_ritual
	for (var/ritual_slot in rituals)
		var/datum/bloodcult_ritual/BR = pick(valid_rituals)
		if ((previous_ritual) && (previous_ritual.ritual_type == BR.ritual_type))
			BR = pick(valid_rituals)//slightly reducing chances of having several rituals of the same type
		else
			previous_ritual = BR
		rituals[ritual_slot] = BR
		possible_rituals -= BR
		valid_rituals -= BR
		BR.init_ritual()

	var/datum/mind/M = owner

	if ("Cult Panel" in M.active_uis)
		var/datum/mind_ui/m_ui = M.active_uis["Cult Panel"]
		if (m_ui.active)
			m_ui.Display()

/datum/antagonist/cult/process()
	..()
	if (holywarning_cooldown > 0)
		holywarning_cooldown--
	if ((cultist_role == CULTIST_ROLE_ACOLYTE) && !mentor)
		FindMentor()

	if (cult_team)
		var/datum/team/cult/cult = cult_team
		if (!initial_rituals && cult.countdown_to_first_rituals <= 0)
			assign_rituals()
			var/mob/M = owner.current
			if (M)
				to_chat(M, span_cult("Although you can generate devotion by performing most cult activities, a couple rituals for you to perform are now available. Check the cult panel.") )
		if (!owner.current)
			return
		switch(cult.stage)
			if (BLOODCULT_STAGE_READY)
				owner.current.add_particles(PS_CULT_SMOKE)
				owner.current.add_particles(PS_CULT_SMOKE2)
				if (cult.tear_ritual && cult.tear_ritual.dance_count)
					var/count = clamp(cult.tear_ritual.dance_count / 400, 0.01, 0.6)
					owner.current.adjust_particles(PVAR_SPAWNING, count, PS_CULT_SMOKE)
					owner.current.adjust_particles(PVAR_SPAWNING, count, PS_CULT_SMOKE2)
				else
					if (prob(1))
						owner.current.adjust_particles(PVAR_SPAWNING, 0.05, PS_CULT_SMOKE)
						owner.current.adjust_particles(PVAR_SPAWNING, 0.05, PS_CULT_SMOKE2)
					else
						owner.current.adjust_particles(PVAR_SPAWNING, 0, PS_CULT_SMOKE)
						owner.current.adjust_particles(PVAR_SPAWNING, 0, PS_CULT_SMOKE2)
			if (BLOODCULT_STAGE_MISSED)
				owner.current.remove_particles(PS_CULT_SMOKE)
				owner.current.remove_particles(PS_CULT_SMOKE2)
			if (BLOODCULT_STAGE_ECLIPSE)
				if(!HasElement(owner.current, /datum/element/cult_eyes)) // look into moving this into a single run stage check like teams
					owner.current.AddElement(/datum/element/cult_eyes)
				owner.current.add_particles(PS_CULT_SMOKE)
				owner.current.add_particles(PS_CULT_SMOKE2)
				owner.current.adjust_particles(PVAR_SPAWNING, 0.6, PS_CULT_SMOKE)
				owner.current.adjust_particles(PVAR_SPAWNING, 0.6, PS_CULT_SMOKE2)
				owner.current.add_particles(PS_CULT_HALO)
				owner.current.adjust_particles(PVAR_ICON_STATE, "cult_halo[get_devotion_rank()]", PS_CULT_HALO)
			if (BLOODCULT_STAGE_DEFEATED)
				owner.current.add_particles(PS_CULT_SMOKE)
				owner.current.add_particles(PS_CULT_SMOKE2)
				owner.current.adjust_particles(PVAR_SPAWNING, 0.19, PS_CULT_SMOKE)
				owner.current.adjust_particles(PVAR_SPAWNING, 0.21, PS_CULT_SMOKE2)
				owner.current.add_particles(PS_CULT_HALO)
				owner.current.adjust_particles(PVAR_COLOR, "#00000066", PS_CULT_HALO)
				owner.current.adjust_particles(PVAR_ICON_STATE, "cult_halo[get_devotion_rank()]", PS_CULT_HALO)
			if (BLOODCULT_STAGE_NARSIE)
				owner.current.add_particles(PS_CULT_SMOKE)
				owner.current.add_particles(PS_CULT_SMOKE2)
				owner.current.adjust_particles(PVAR_SPAWNING, 0.6, PS_CULT_SMOKE)
				owner.current.adjust_particles(PVAR_SPAWNING, 0.6, PS_CULT_SMOKE2)
				owner.current.add_particles(PS_CULT_HALO)
				owner.current.adjust_particles(PVAR_ICON_STATE, "cult_halo[get_devotion_rank()]", PS_CULT_HALO)

/datum/antagonist/cult/proc/get_eclipse_increment()
	if(isshade(owner.current) || isobserver(owner.current))
		return -0.05
	switch(get_devotion_rank())
		if (DEVOTION_TIER_0)
			return 0.10
		if (DEVOTION_TIER_1)
			return 0.10 + (devotion-100)*0.000375
		if (DEVOTION_TIER_2)
			return 0.25 + (devotion-500)*0.0003
		if (DEVOTION_TIER_3)
			return 0.40 + (devotion-1000)*0.0001
		if (DEVOTION_TIER_4)
			return 0.50 + (devotion-2000)*0.00005
