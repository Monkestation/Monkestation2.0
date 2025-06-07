
/datum/rune_spell/bloodmagnetism
	name = "Blood Magnetism"
	desc = "Bring forth one of your fellow believers, no matter how far they are, as long as their heart beats."
	desc_talisman = "Use to begin the Blood Magnetism ritual where you stand."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/self
	page = "This rune actually has two different rituals built into it:\
		<br><br>The first one, Summon Cultist, lets you summon a cultist from anywhere in the world whether they're alive or dead, for a cost of 50u of blood, which can be split by having other cultists participate in the ritual. \
		The ritual will fail however should the target cultist be anchored to their location, or have a holy implant.\
		<br><br>The second ritual, Rejoin Cultist, lets you summon yourself next to the target cultist instead for a cost of 15u of blood. \
		Other cultists can participate in the second ritual to accompany you, but the cost will remain 15u for every participating cultist. \
		Again, the ritual will fail if the target has a holy implant (or has been made to drink\
		<br><br>This rune persists upon use, allowing repeated usage."
	remaining_cost = 10
	cost_upkeep = 1
	var/rejoin = 0
	var/mob/target = null
	var/list/feet_portals = list()
	var/cost_summon = 50//you probably don't want to pay that up alone
	var/cost_rejoin = 15//static cost for every contributor

/datum/rune_spell/bloodmagnetism/Destroy()
	target = null
	for (var/guy in feet_portals)
		var/obj/object = feet_portals[guy]
		qdel(object)
		feet_portals -= guy
	feet_portals = list()
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "runetrigger-build")
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/effects.dmi', "rune_summon")
	..()


/datum/rune_spell/bloodmagnetism/abort()
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "runetrigger-build")
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/effects.dmi', "rune_summon")
	for (var/guy in feet_portals)
		var/obj/object = feet_portals[guy]
		qdel(object)
	..()

/datum/rune_spell/bloodmagnetism/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	rejoin = alert(activator, "Will you pull them toward you, or pull yourself toward them?", "Blood Magnetism", "Summon Cultist", "Rejoin Cultist") == "Rejoin Cultist"

	var/list/possible_targets = list()
	var/list/prisoners = list()
	var/datum/antagonist/cult/cultist = activator.mind?.has_antag_datum(/datum/antagonist/cult)
	var/datum/team/cult/bloodcult = cultist.cult_team
	for (var/datum/mind/mind in bloodcult.members)
		if (mind.current)
			if (mind.current.occult_muted())
				continue
			possible_targets.Add(mind.current)

	//Prisoners are valid Blood Magnetism targets!
	for(var/obj/item/restraints/handcuffs/cult/cuffs in bloodcult.bindings)
		if (iscarbon(cuffs.loc))
			var/mob/living/carbon/carbon = cuffs.loc
			if (carbon.handcuffed == cuffs)
				prisoners.Add(carbon)

	var/list/annotated_targets = list()
	var/list/visible_mobs = viewers(activator)
	var/i = 1
	for(var/mob/mob in possible_targets)
		var/status = ""
		if(mob == activator)
			status = " (You)"
		else if(mob in visible_mobs)
			status = " (Visible)"
		else if(mob.stat == DEAD)
			status = " (Dead)"
		annotated_targets["\Roman[i]-[mob.real_name][status]"] = mob
		i++

	for(var/mob/prisoner in prisoners)
		annotated_targets["\Roman[i]-[prisoner.real_name] (Prisoner)"] = prisoner
		i++

	var/choice = input(activator, "Choose who you wish to [rejoin ? "rejoin" : "summon"]", "Blood Magnetism") as null|anything in annotated_targets
	if (!choice)
		qdel(src)
		return
	target = annotated_targets[choice]
	if (!target)
		qdel(src)
		return

	contributors.Add(activator)
	update_progbar()
	if (activator.client)
		activator.client.images |= progbar
	spell_holder.overlays += image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "runetrigger-build")
	if (!rejoin)
		spell_holder.overlays += image('monkestation/code/modules/bloody_cult/icons/effects.dmi', "rune_summon")
	else
		feet_portals.Add(activator)
		var/obj/effect/cult_ritual/feet_portal/P = new (activator.loc, activator, src)
		feet_portals[activator] = P
	to_chat(activator, span_rose("This ritual's blood toll can be substantially reduced by having multiple cultists partake in it.") )
	spawn()
		payment()

/datum/rune_spell/bloodmagnetism/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator, R)
	qdel(src)

/datum/rune_spell/bloodmagnetism/midcast(mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar
	if (rejoin)
		feet_portals.Add(add_cultist)
		var/obj/effect/cult_ritual/feet_portal/P = new (add_cultist.loc, add_cultist, src)
		feet_portals[add_cultist] = P

/datum/rune_spell/bloodmagnetism/proc/payment()//an extra payment is spent at the end of the channeling, and shared between contributors
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		//are our payers still here and about?
		for(var/mob/living/contributor in contributors)
			if (!IS_CULTIST(contributor) || !(contributor in range(spell_holder, 1)) || (contributor.stat != CONSCIOUS))
				if (contributor.client)
					contributor.client.images -= progbar
				var/obj/effect/cult_ritual/feet_portal/P = feet_portals[contributor]
				qdel(P)
				feet_portals.Remove(contributor)
				contributors.Remove(contributor)
		//alright then, time to pay in blood
		var/amount_paid = 0
		for(var/mob/living/contributor in contributors)
			var/data = use_available_blood(contributor, cost_upkeep/contributors.len, contributors[contributor])//always 1u total per payment
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(contributor)
				var/obj/effect/cult_ritual/feet_portal/P = feet_portals[contributor]
				qdel(P)
				feet_portals.Remove(contributor)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[contributor] = data[BLOODCOST_RESULT]
				make_tracker_effects(contributor.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		//if there's no blood for over 3 seconds, the channeling fails
		if (amount_paid)
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				if(accumulated_blood && !(locate(/obj/effect/decal/cleanable/blood/splatter) in spell_holder.loc))
					var/obj/effect/decal/cleanable/blood/splatter/splatter = new(spell_holder.loc)//splash
					splatter.count = 2
				abort(RITUALABORT_BLOOD)
				return

		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/bloodmagnetism/proc/success()
	if (target.occult_muted())
		for(var/mob/living/contributor in contributors)
			to_chat(activator, span_warning("The ritual failed, the target seems to be under a curse that prevents us from reaching them through the veil.") )
	else
		if (rejoin)
			var/list/valid_turfs = list()
			for(var/turf/T in orange(target, 1))
				if(!T.is_blocked_turf(TRUE))
					valid_turfs.Add(T)
			if (valid_turfs.len)
				for(var/mob/living/contributor in contributors)
					use_available_blood(contributor, cost_rejoin, contributors[contributor])
					var/datum/antagonist/cult/cult_datum = contributor.mind.has_antag_datum(/datum/antagonist/cult)
					cult_datum.gain_devotion(100, DEVOTION_TIER_2, "bloodmagnetism_rejoin", contributor)
					make_tracker_effects(contributor.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 3)
					var/obj/effect/abstract/landing_animation = anim(target = contributor, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "cult_jaunt_prepare", plane = GAME_PLANE_UPPER)
					playsound(contributor, 'monkestation/code/modules/bloody_cult/sound/cultjaunt_prepare.ogg', 75, 0, -3)
					spawn(10)
						playsound(contributor, 'monkestation/code/modules/bloody_cult/sound/cultjaunt_land.ogg', 30, 0, -3)
						new /obj/effect/bloodcult_jaunt(get_turf(contributor), contributor, pick(valid_turfs))
						flick("cult_jaunt_land", landing_animation)
		else
			if(target.buckled || !isturf(target.loc))
				to_chat(target, span_warning("You feel that some force wants to pull you through the veil, but cannot proceed while you are buckled or inside something.") )
				for(var/mob/living/contributor in contributors)
					to_chat(activator, span_warning("The ritual failed, the target seems to be anchored to where they are.") )
			else
				for(var/mob/living/contributor in contributors)
					use_available_blood(contributor, cost_summon/contributors.len, contributors[contributor])
					make_tracker_effects(contributor.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 3)
					var/datum/antagonist/cult/cult_datum = contributor.mind.has_antag_datum(/datum/antagonist/cult)
					cult_datum.gain_devotion(100, DEVOTION_TIER_2, "bloodmagnetism_summon", contributor)
				var/obj/effect/abstract/landing_animation = anim(target = src.target, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "cult_jaunt_prepare", lay = CULT_OVERLAY_LAYER, plane = GAME_PLANE_UPPER)
				var/mob/mob_target = target//so we keep track of them after the datum is ded until we jaunt
				var/turf/T = get_turf(spell_holder)
				playsound(mob_target, 'monkestation/code/modules/bloody_cult/sound/cultjaunt_prepare.ogg', 75, 0, -3)
				spawn(10)
					playsound(mob_target, 'monkestation/code/modules/bloody_cult/sound/cultjaunt_land.ogg', 30, 0, -3)
					new /obj/effect/bloodcult_jaunt(get_turf(mob_target), mob_target, T)
					flick("cult_jaunt_land", landing_animation)

	for(var/mob/living/contributor in contributors)
		if (contributor.client)
			contributor.client.images -= progbar
		contributors.Remove(contributor)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/obj/effect/cult_ritual/feet_portal
	anchored = 1
	icon_state = "rune_rejoin"
	pixel_y = -10
	layer = ABOVE_OBJ_LAYER
	plane = GAME_PLANE
	var/mob/living/caster = null
	var/turf/source = null

/obj/effect/cult_ritual/feet_portal/New(turf/loc, mob/living/user, datum/rune_spell/seer/runespell)
	..()
	caster = user
	source = get_turf(runespell?.spell_holder)
	if (!caster)
		qdel(src)
		return

/obj/effect/cult_ritual/feet_portal/Destroy()
	caster = null
	source = null
	..()

/obj/effect/cult_ritual/feet_portal/HasProximity(atom/movable/AM)
	if (caster && caster.loc != loc)
		forceMove(get_turf(caster))
