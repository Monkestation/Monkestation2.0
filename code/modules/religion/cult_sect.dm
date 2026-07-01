/datum/religion_sect/cult
	name = "Cult"
	quote = "We must devote ourselves."
	desc = "Your God requires absolute devotion from you and the acolytes you convert. \
	Rather than favor, offer your loyalty to perform rituals."
	tgui_icon = "cross"
	altar_icon_state = "cult_sect"
	alignment = ALIGNMENT_EVIL
	rites_list = list(/datum/religion_rites/conversion,
	/datum/religion_rites/cult/robes,
	/datum/religion_rites/cult/summon_spirit,
	/datum/religion_rites/cult/summon_god,)
	///people who have agreed to serve, and can be deaconized
	var/list/possible_acolytes = list()
	///people who have been offered an invitation, they haven't finished the alert though.
	var/list/datum/weakref/currently_asking = list()
	desired_items = list("Devoted Followers")


/datum/religion_sect/cult/on_conversion(mob/living/chap)
	. = ..()
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/leader/cult_leader(get_turf(chap))

/**
 * Called by conversion rite, this async'd proc waits for a response on joining the sect.
 * If yes, the conversion rite can now recruit them instead of just offering invites
 */
/datum/religion_sect/cult/proc/invite_acolyte(mob/living/carbon/human/invited, mob/living/inviter)
	inviter.balloon_alert(inviter, "offer has been made")
	currently_asking += invited
	var/ask = tgui_alert(invited, "Serve [GLOB.deity]?", "Initiation", list("Yes", "No"), 60 SECONDS)
	currently_asking -= invited
	if(ask == "Yes")
		possible_acolytes += invited
		inviter.balloon_alert(inviter, "accepts serving [GLOB.deity]!")
	else
		inviter.balloon_alert(inviter, "refuses to serve [GLOB.deity]!")

/datum/religion_rites/conversion
	name = "Initiation"
	desc = "Converts someone to your sect. They must be willing, so the first invocation will instead prompt them to join. \
	Once they accept and are converted, they will become a acolyte, counting as a member for rituals. The sect gains 100 favor per conversion."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"dv'n lrd `bve",
		"l`t th's vssl b` wrthy",
		"l`t it srv y in `yr nm",
	)
	invoke_msg = "nd sr`v y fr ' rst f its pth'tc lf`"
	///the invited acolyte
	var/mob/living/carbon/human/new_acolytes

/datum/religion_rites/conversion/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/cult/sect = GLOB.religious_sect
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/mob/living/carbon/human/possible_acolytes in movable_reltool.buckled_mobs)
		if(possible_acolytes.stat != CONSCIOUS)
			to_chat(user, span_warning("[possible_acolytes] needs to be alive and conscious to join the cult!"))
			return FALSE
		if(TRAIT_GENELESS in possible_acolytes.dna.species.inherent_traits)
			to_chat(user, span_warning("This species disgusts [GLOB.deity]! They would never be allowed to join the cult!"))
			return FALSE
		if(possible_acolytes in sect.currently_asking)
			to_chat(user, span_warning("Wait for them to decide on whether to join or not!"))
			return FALSE
		if(!(possible_acolytes in sect.possible_acolytes))
			INVOKE_ASYNC(sect, TYPE_PROC_REF(/datum/religion_sect/cult, invite_acolyte), possible_acolytes, user)
			to_chat(user, span_notice("They have been given the option to serving your God. Wait for them to decide and try again."))
			return FALSE
		new_acolytes = possible_acolytes
		return ..()

/datum/religion_rites/conversion/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	. = ..()
	var/mob/living/carbon/human/joining_now = new_acolytes
	new_acolytes = null
	if(!(joining_now in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, span_warning("The new member is no longer on the altar!"))
		return FALSE
	if(joining_now.stat != CONSCIOUS)
		to_chat(user, span_warning("The new member has to stay alive for the rite to work!"))
		return FALSE
	if(!joining_now.mind)
		to_chat(user, span_warning("The new member has no mind!"))
		return FALSE
	if(joining_now.mind.has_antag_datum(/datum/antagonist/cult))//one cult at a time buddy
		to_chat(user, span_warning("[GLOB.deity] has seen a true, dark evil in [joining_now]'s heart, and they have been smitten!"))
		playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
		joining_now.gib(TRUE)
		return FALSE
	to_chat(user, span_notice("[joining_now] has submitted to [GLOB.deity]! They are now a holy role! (albeit the lowest level of such)"))
	joining_now.mind.holy_role = HOLY_ROLE_DEACON
	GLOB.religious_sect.adjust_favor(100, user)
	playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
	return TRUE


/datum/religion_rites/cult/proc/can_invoke(mob/living/user, atom/religious_tool)
	if(!required_acolytes)
		return user ? list(user) : list()

	var/list/invokers = list() //people eligible to invoke the rune
	if(user)
		invokers += user

	for(var/mob/living/acolytes in view(3, religious_tool))
		if(!IS_HOLY(acolytes))
			continue
		if(acolytes == user)
			continue
		if(acolytes.stat != CONSCIOUS)
			continue
		invokers += acolytes

	if(length(invokers) < required_acolytes)
		return FALSE

	return TRUE


/datum/religion_rites/cult // cult rites parent used to make all cult rites require a certain number of people and have cooldowns
	name = "Create Robes"
	desc = "Create a pair of robes for the initiated, these robes will hide their name and voice when worn, however it won't hide their ID."
	ritual_length = 5 SECONDS
	invoke_msg = "g`v us rbs, s w my bt`tr drss i`n yr' img`"
	favor_cost = 0
	var/required_acolytes = 1

/datum/religion_rites/cult/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_invoke())
		to_chat(user, span_warning("You need at least [required_acolytes] acolytes around to perform this ritual!"))
		return FALSE
	return ..()

/datum/religion_rites/cult/robes
	name = "Create Robes"
	desc = "Create a pair of robes for the initiated, these robes will hide their name and voice when worn, however it won't hide their ID."
	ritual_length = 10 SECONDS
	invoke_msg = "g`v us rbs, s w my bt`tr drss i`n yr' img`"
	favor_cost = 15
	required_acolytes = 1

/datum/religion_rites/cult/robes/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/cult(altar_turf)
	return TRUE

/datum/religion_rites/cult/summon_spirit // cult rites parent used to make all cult rites require a certain number of people
	name = "Summon Spirit"
	desc = "Summon a spirit from beyond the veil. This ritual requires 3 acolytes."
	ritual_length = 30 SECONDS
	favor_cost = 100 // 1 member = 1 spirit, these guys are pretty weak anyways
	ritual_invocations = list(
		"wc`llp'",
		"spr'tsf th's rlm",
	)
	invoke_msg = "gv th'm frm nd mk th'm whl`"
	required_acolytes = 3

/datum/religion_rites/cult/summon_spirit/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you wish to become a Holy Shade?",
		check_jobban = ROLE_HOLY_SUMMONED,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_SHADE,
		alert_pic = /mob/living/basic/shade/holy,
		jump_target = religious_tool,
		role_name_text = "a shade",
		chat_text_border_icon = /mob/living/basic/shade/holy,
	)
	var/mob/dead/observer/candidate = pick(candidates)
	if(!candidate)
		to_chat(user, span_warning("The soul pool is empty..."))
		user.visible_message(span_warning("The soul pool was not strong enough to bring forth the shade."))
		return NOT_ENOUGH_PLAYERS
	var/datum/mind/mind = new(candidate.key)
	var/mob/living/carbon/human/species/shade = new /mob/living/basic/shade/holy(altar_turf)
	shade.real_name = "Holy Shade ([rand(1,999)])"
	mind.active = TRUE
	mind.transfer_to(shade)
	if(is_special_character(user))
		to_chat(shade, span_userdanger("You are grateful to have been summoned into this word by [user]. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost."))
	else
		to_chat(shade, span_boldnotice("You are grateful to have been summoned into this world. You are now a member of this station's crew, Try not to cause any trouble."))
	playsound(altar_turf, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg',), 50, TRUE)
	return ..()

/datum/religion_rites/cult/summon_god // cult rites parent used to make all cult rites require a certain number of people
	name = "Summon Deity"
	desc = "Summon fix using a provided animal vessel, if no vessel if provided fix will take a random form. \
	This ritual can only be performed once. This ritual requires 7 acolytes."
	ritual_length = 5 SECONDS // 5 seconds for testing, planned 30-60
	ritual_invocations = list(
		"w s'k `fr yr bdy",
		"nd yr evr`lst'ng pr'snc",
	)
	invoke_msg = "y shll b whl g'n"
	favor_cost = 700
	required_acolytes = 7

/datum/religion_rites/cult/summon_god/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you wish to become [GLOB.deity]?",
		check_jobban = ROLE_HOLY_SUMMONED,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_SHADE,
		alert_pic = /mob/living/basic/shade/holy,
		jump_target = religious_tool,
		role_name_text = "[GLOB.deity]",
		chat_text_border_icon = /mob/living/basic/shade/holy,
	)
	var/mob/dead/observer/candidate = pick(candidates)
	if(!candidate)
		to_chat(user, span_warning("The soul pool is empty..."))
		user.visible_message(span_warning("The soul pool was not strong enough to bring forth the shade."))
		return NOT_ENOUGH_PLAYERS
	var/datum/mind/Mind = new /datum/mind(candidate.key)
	var/datum/action/cooldown/spell/voice_of_god/voice_of_god = new(src)
	var/atom/movable/movable_reltool = religious_tool
	var/datum/religion_sect/cult/sect = GLOB.religious_sect
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs)) //If a mob is buckled to the altar, we will check if it meets conditions to be used as a vessel
		for(var/mob/living/vessel in movable_reltool.buckled_mobs)
			if(vessel.ckey) //only works on animals that aren't player controlled
				to_chat(user, span_boldnotice("this vessel is already filled!"))
				return FALSE
			if(vessel.stat)
				to_chat(user, span_boldnotice("it's dead!"))
				return FALSE
			if(!vessel.compare_sentience_type(SENTIENCE_ORGANIC)) // Will also return false if not a basic or simple mob, which are the only two we want anyway
				to_chat(user, span_boldnotice("invalid vessel!"))
				return FALSE
			vessel.real_name = "[GLOB.deity]"
			vessel.name = "[GLOB.deity]"
			vessel.maxHealth = 125 // shouldn't be to hard or easy to kill, yes purposely nerfs higher HP mobs
			vessel.health = 125
			Mind.active = 1
			Mind.transfer_to(vessel)
			voice_of_god.Grant(vessel)
			to_chat(vessel, span_userdanger("You are [GLOB.deity], a great deity, and have been summoned into this word by your head acolyte [user] and their underlings, show them grace and listen to what they have to say."))
			sect.rites_list -= /datum/religion_rites/cult/summon_god
			return ..()
	var/mob/living/spawned_mob = create_random_mob(altar_turf, FRIENDLY_SPAWN)
	spawned_mob.faction |= FACTION_NEUTRAL
	Mind.active = 1
	Mind.transfer_to(spawned_mob)
	spawned_mob.real_name = "[GLOB.deity]"
	spawned_mob.name = "[GLOB.deity]"
	spawned_mob.maxHealth = 125 // shouldn't be to hard or easy to kill, yes purposely nerfs higher HP mobs
	spawned_mob.health = 125
	voice_of_god.Grant(spawned_mob)
	to_chat(spawned_mob, span_userdanger("You are [GLOB.deity], a great deity, and have been summoned into this word by your head acolyte [user] and their underlings, show them grace and listen to what they have to say."))
	sect.rites_list -= /datum/religion_rites/cult/summon_god
	return ..()
