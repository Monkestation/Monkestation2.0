/datum/outfit/slasher/slasher
	name = "Slasher Outfit"
	suit = /obj/item/clothing/suit/apron/slasher
	uniform = /obj/item/clothing/under/slasher
	shoes = /obj/item/clothing/shoes/admiral
	mask = /obj/item/clothing/mask/gas/slasher
	belt = /obj/item/storage/belt/slasher
	gloves = /obj/item/clothing/gloves/admiral
	back = /obj/item/storage/backpack/cursed

/datum/antagonist/slasher
	name = "\improper Slasher"
	show_in_antagpanel = TRUE
	roundend_category = "slashers"
	antagpanel_category = "Slasher"
	job_rank = ROLE_SLASHER
	antag_hud_name = "slasher"
	show_name_in_check_antagonists = TRUE
	hud_icon = 'monkestation/icons/mob/slasher.dmi'
	preview_outfit = /datum/outfit/slasher/slasher
	show_to_ghosts = TRUE
	var/give_objectives = TRUE
	var/datum/action/cooldown/slasher/active_action = null
	///the linked machette that the slasher can summon even if destroyed and is unique to them
	var/obj/item/slasher_machette/linked_machette
	/// the linked apron for increasing his armor values on soul succ
	var/obj/item/clothing/suit/apron/slasher/linked_apron
	///rallys the amount of souls effects are based on this
	var/souls_sucked = 0
	///our cached brute_mod
	var/cached_brute_mod = 0
	/// the mob we are stalking
	var/mob/living/carbon/human/stalked_human
	/// how close we are in % to finishing stalking
	var/stalk_precent = 0
	///ALL Powers currently owned
	var/list/datum/action/cooldown/slasher/powers = list()

	///this is our team monitor
	var/datum/component/team_monitor/slasher_monitor
	///this is our tracker component
	var/datum/component/tracking_beacon
	var/monitor_key = "slasher_key"

	///weakref list of mobs and their fear
	var/list/fears = list()
	///weakref list of mobs and last fear attempt to stop fear maxxing
	var/list/fear_cooldowns = list()
	///weakref list of mobs and last fear stages
	var/list/fear_stages = list()
	///this is a list of all heartbeaters
	var/list/heartbeats = list()
	//this is a list of all statics
	var/list/mobs_with_fullscreens = list()
	///this is our list of refs over 100 fear
	var/list/total_fear = list()
	///this is our list of tracked people
	var/list/tracked = list()
	///this is our list of seers
	var/list/seers = list()

	//aggrograb for slasher
	var/datum/martial_art/slasher_grab/grabart

/datum/antagonist/slasher/on_gain()
	. = ..() // Call parent first

	if(give_objectives)
		forge_objectives()
		if(owner?.current)
			for(var/datum/objective/objective in objectives)
				owner.announce_objectives()

/datum/antagonist/slasher/forge_objectives()
	if(!owner)
		return

	// Clear any existing objectives
	objectives.Cut()

	// Add all slasher objective subtypes
	for(var/objective_type in subtypesof(/datum/objective/slasher))
		var/datum/objective/new_objective = new objective_type
		new_objective.owner = owner
		objectives += new_objective

	// Make sure these objectives are also in the mind's objectives list
	if(owner)
		for(var/datum/objective/O in objectives)
			owner.objectives += O

/datum/antagonist/slasher/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.overlay_fullscreen("slasher_prox", /atom/movable/screen/fullscreen/nearby, 1)
	if(ishuman(current_mob))
		grabart = new(null)
		var/mob/living/carbon/human/slashmob = current_mob
		grabart.teach(slashmob)
	monitor_key = "slasher_monitor_[current_mob.ckey]"
	tracking_beacon = current_mob.AddComponent(/datum/component/tracking_beacon, monitor_key, null, null, TRUE, "#f3d594")
	slasher_monitor = current_mob.AddComponent(/datum/component/team_monitor, monitor_key, null, tracking_beacon)
	slasher_monitor.show_hud(owner.current)

	ADD_TRAIT(current_mob, TRAIT_BATON_RESISTANCE, "slasher")
	ADD_TRAIT(current_mob, TRAIT_CLUMSY, "slasher")
	ADD_TRAIT(current_mob, TRAIT_DUMB, "slasher")
	ADD_TRAIT(current_mob, TRAIT_LIMBATTACHMENT, "slasher")
	ADD_TRAIT(current_mob, TRAIT_SLASHER, "slasher")
	ADD_TRAIT(current_mob, TRAIT_NO_PAIN_EFFECTS, "slasher")
	ADD_TRAIT(current_mob, TRAIT_VIRUSIMMUNE, "slasher")
	ADD_TRAIT(current_mob, TRAIT_RESISTHEAT, "slasher")
	ADD_TRAIT(current_mob, TRAIT_RESISTCOLD, "slasher")
	ADD_TRAIT(current_mob, TRAIT_RESISTLOWPRESSURE, "slasher")
	ADD_TRAIT(current_mob, TRAIT_RESISTHIGHPRESSURE, "slasher")

	var/mob/living/carbon/carbon = current_mob
	var/obj/item/organ/internal/eyes/shadow/shadow = new
	shadow.Insert(carbon, drop_if_replaced = FALSE)

	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))
	RegisterSignal(current_mob, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(item_pickup))
	RegisterSignal(current_mob, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(item_unequipped))
	RegisterSignal(current_mob, COMSIG_MOB_ITEM_ATTACK, PROC_REF(check_attack))
	RegisterSignal(current_mob, COMSIG_LIVING_DEATH, PROC_REF(on_death))

	for(var/datum/quirk/quirk as anything in current_mob.quirks)
		current_mob.remove_quirk(quirk)
	///abilities galore
	for(var/datum/action/cooldown/slasher/listed_slasher as anything in subtypesof(/datum/action/cooldown/slasher))
		var/datum/action/cooldown/slasher/new_ability = new listed_slasher
		new_ability.Grant(current_mob)
		powers |= new_ability

	var/mob/living/carbon/human/human = current_mob
	if(istype(human))
		human.equipOutfit(/datum/outfit/slasher/slasher)
		linked_apron = human.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	cached_brute_mod = human.dna.species.brutemod
	current_mob.alpha = 200
	current_mob.playsound_local(current_mob, 'monkestation/sound/effects/tape_start.ogg', vol = 100, vary = FALSE, pressure_affected = FALSE)

/datum/antagonist/slasher/proc/on_death(mob/living/source)
	SIGNAL_HANDLER
	source.mind.remove_antag_datum(/datum/antagonist/slasher)
	playsound(source, 'monkestation/sound/effects/tape_end.ogg', vol = 100, vary = FALSE, pressure_affected = FALSE)
	var/mob/living/carbon/human/source_human = source
	source_human.delete_equipment()

/datum/antagonist/slasher/on_removal()
	if(!QDELETED(owner.current))
		owner.current.clear_fullscreen("slasher_prox", 15)
		REMOVE_TRAITS_IN(owner.current, "slasher")
		for(var/datum/action/cooldown/slasher/listed_slasher as anything in powers)
			listed_slasher.Remove(owner.current)

	for(var/datum/weakref/held_ref as anything in heartbeats | mobs_with_fullscreens)
		var/mob/living/carbon/human/human = held_ref?.resolve()
		if(isnull(human))
			continue
		human.stop_sound_channel(CHANNEL_HEARTBEAT)
		human.clear_fullscreen("slasher_prox", 15)
		human.regenerate_icons()
		reset_fear(human)

	heartbeats.Cut()
	mobs_with_fullscreens.Cut()
	return ..()

/datum/antagonist/slasher/greet()
	. = ..()
	to_chat(owner.current, span_userdanger("The time is ripe to hunt for souls."))
	to_chat(owner.current, span_announce("You are a vengeful spirit that feeds on fear. <b>Stick to maintenance, the darkness reveals us but is our greatest friend</b>."))

	to_chat(owner.current, span_announce("Claim the souls of the fallen, the more souls you have, the sharper your blade."))
	to_chat(owner.current, span_announce("Reject the light, it hides you but makes you vulnerable."))
	owner.current.playsound_local(null, 'monkestation/sound/ambience/antag/slasher.ogg', vol = 100, vary = FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/slasher/proc/LifeTick(mob/living/source, seconds_between_ticks, times_fired)
	SIGNAL_HANDLER

	var/list/currently_beating = list()
	var/list/current_statics = list()
	for(var/datum/weakref/held as anything in fear_stages)
		var/stage = fear_stages[held]
		var/mob/living/carbon/human/human = held.resolve()

		if(stage >= 1)
			currently_beating |= held
			if(!(held in heartbeats))
				heartbeats |= held
				human.playsound_local(human, 'sound/health/slowbeat.ogg', 40, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)

		if(stage >= 2)
			current_statics |= held
			if(!(held in mobs_with_fullscreens))
				human.overlay_fullscreen("slasher_prox", /atom/movable/screen/fullscreen/nearby, 1)
				mobs_with_fullscreens |= held

		else
			if(held in heartbeats)
				human.stop_sound_channel(CHANNEL_HEARTBEAT)
				heartbeats -= held
			if(held in mobs_with_fullscreens)
				human.clear_fullscreen("slasher_prox", 15)
				mobs_with_fullscreens -= held

		for(var/mob/living/carbon/human/mobs_in_view in view(7, human))
			var/datum/mind/mind_in_view = mobs_in_view.mind
			if(!mind_in_view)
				continue
			if(!mind_in_view.has_antag_datum(/datum/antagonist/slasher))
				reduce_fear(human, 2)


	for(var/datum/weakref/held_ref as anything in (heartbeats - currently_beating))
		var/mob/living/carbon/human/human = held_ref.resolve()
		human.stop_sound_channel(CHANNEL_HEARTBEAT)
		heartbeats -= held_ref
		human.regenerate_icons()

	for(var/datum/weakref/held_ref as anything in (mobs_with_fullscreens - current_statics))
		var/mob/living/carbon/human/human = held_ref.resolve()
		human.clear_fullscreen("slasher_prox", 15)
		mobs_with_fullscreens -= held_ref
		human.regenerate_icons()

/datum/status_effect/slasher
	id = "slasher"
	alert_type = null

/datum/antagonist/slasher/proc/check_attack(mob/living/attacking_person, mob/living/attacked_mob)
	SIGNAL_HANDLER
	var/obj/item/held_item = attacking_person.get_active_held_item()

	var/held_force = 3
	if(held_item)
		held_force = held_item.force

	increase_fear(attacked_mob, held_force / 3)

	for(var/i = 1 to (held_force / 3))
		attacked_mob.blood_particles(2, max_deviation = rand(-120, 120), min_pixel_z = rand(-4, 12), max_pixel_z = rand(-4, 12))

/datum/antagonist/slasher/proc/item_pickup(datum/input_source, obj/item/source)
	SIGNAL_HANDLER
	RegisterSignal(source, COMSIG_ITEM_DAMAGE_MULTIPLIER, PROC_REF(damage_multiplier))

/datum/antagonist/slasher/proc/item_unequipped(datum/input_source, obj/item/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_ITEM_DAMAGE_MULTIPLIER)

/datum/antagonist/slasher/proc/damage_multiplier(obj/item/source, damage_multiplier_ptr, mob/living/attacked, def_zone)
	//keeping this just in case we use it later, but the damage changing has been turned off
	// *damage_multiplier_ptr = 1

/datum/antagonist/slasher/proc/increase_fear(atom/movable/target, amount)
	var/datum/weakref/weak = WEAKREF(target)
	if(!(weak in fear_cooldowns))
		target.AddComponent(/datum/component/hovering_information, /datum/hover_data/slasher_fear, TRAIT_SLASHER)
		fear_cooldowns |= weak
		fear_cooldowns[weak] = 0

	if(fear_cooldowns[weak] > world.time + 10 SECONDS)
		return

	if(!(weak in fears))
		fears |= weak
	fears[weak] += amount

	fear_cooldowns[weak] = world.time
	fear_stage_check(weak)

/datum/antagonist/slasher/proc/reduce_fear_area(amount, area)
	for(var/mob/living/carbon/human/human in range(area, get_turf(owner)))
		var/datum/weakref/weak = WEAKREF(human)
		if(!(weak in fears))
			continue
		fears[weak] -= amount
		fears[weak] = max(fears[weak], 0)
		fear_stage_check(weak)

/datum/antagonist/slasher/proc/reduce_fear(atom/target, amount)
	var/datum/weakref/weak = WEAKREF(target)
	if(!(weak in fears))
		return
	fears[weak] -= amount
	fears[weak] = max(fears[weak], 0)
	fear_stage_check(weak)

/datum/antagonist/slasher/proc/reset_fear(atom/target)
	var/datum/weakref/weak = WEAKREF(target)
	if(!(weak in fears))
		return
	fears[weak] = 0
	fear_stage_check(weak)

/datum/antagonist/slasher/proc/fear_stage_check(datum/weakref/weak)
	var/fear_number = fears[weak]
	var/old_stage = fear_stages[weak]
	var/stage = 0
	switch(fear_number)
		if(0 to 25)
			stage = 0
		if(26 to 50)
			stage = 1
		if(51 to 75)
			stage = 2
		if(76 to 100)
			stage = 3
		else
			stage = 4

	if((weak in fear_stages))
		if(fear_stages[weak] == stage)
			return
	stage_change(weak, stage, old_stage)


/datum/antagonist/slasher/proc/stage_change(datum/weakref/weak, new_stage, last_stage)
	fear_stages[weak] = new_stage

	if(new_stage >= 3)
		try_add_tracker(weak)
	if(new_stage >= 4)
		try_add_seer(weak)


/datum/antagonist/slasher/proc/return_feared_people(range, value)
	var/list/mobs = list()
	for(var/datum/weakref/weak_ref as anything in fears)
		if(fears[weak_ref] < value)
			continue
		var/mob/living/mob = weak_ref.resolve()
		if(get_dist(owner.current, mob) > range)
			continue
		mobs += mob
	return mobs

/datum/antagonist/slasher/proc/try_add_tracker(datum/weakref/weak)
	if(weak in tracked)
		return
	tracked += weak

	var/mob/living/living = weak.resolve()

	var/datum/component/tracking_beacon/beacon = living.AddComponent(/datum/component/tracking_beacon, monitor_key, null, null, TRUE, "#f3d594")
	slasher_monitor.add_to_tracking_network(beacon)

	RegisterSignal(living, COMSIG_LIVING_TRACKER_REMOVED, PROC_REF(remove_tracker))

/datum/antagonist/slasher/proc/remove_tracker(mob/living/source, frequency)
	if(frequency != monitor_key)
		return

	tracked -= WEAKREF(source)
	slasher_monitor.update_all_directions()

/datum/antagonist/slasher/proc/try_add_seer(datum/weakref/weak)
	if(weak in seers)
		return
	seers += weak

	var/mob/living/living = weak.resolve()
	living.AddComponent(/datum/component/see_as_something, owner.current, "wendigo", 'icons/mob/simple/icemoon/64x64megafauna.dmi', "?????")

/datum/hover_data/slasher_fear/setup_data(atom/source, mob/enterer)
	if(!enterer.mind?.has_antag_datum(/datum/antagonist/slasher))
		return
	var/datum/antagonist/slasher/slasher = enterer.mind.has_antag_datum(/datum/antagonist/slasher)

	var/datum/weakref/weak = WEAKREF(source)
	if(!(weak in slasher.fear_stages))
		return
	var/fear_stage = slasher.fear_stages[weak]

	var/image/new_image = new
	new_image.icon = 'monkestation/code/modules/blood_for_the_blood_gods/icons/slasher_ui.dmi'
	new_image.pixel_x = 10
	new_image.plane = GAME_PLANE_UPPER
	switch(fear_stage)
		if(2)
			new_image.icon_state = "they_fear"
		if(3)
			new_image.icon_state = "they_see_no_evil"
		if(4)
			new_image.icon_state = "they_see"
		else
			new_image.icon_state = null

	if(!isturf(source.loc))
		new_image.loc = source.loc
	else
		new_image.loc = source
	add_client_image(new_image, enterer.client)

/datum/objective/slasher/harvest_souls
	name = "Harvest Souls"
	explanation_text = "Harvest souls from the dead to increase your power."
	admin_grantable = TRUE

/datum/objective/slasher/soulsteal
	name = "Soulsteal"
	explanation_text = "Use soulsteal to harvest souls."
	admin_grantable = TRUE

/datum/objective/slasher/trappem
	name = "Trapping"
	explanation_text = "Use your traps to slow down your victims."
	admin_grantable = TRUE


/datum/antagonist/slasher/antag_token(datum/mind/hosts_mind, mob/spender)
	var/spender_key = spender.key
	if(!spender_key)
		CRASH("wtf, spender had no key")
	var/turf/spawn_loc = find_safe_turf_in_maintenance()//Used for the Drop Pod type of spawn for maints only
	if(isnull(spawn_loc))
		message_admins("Failed to find valid spawn location for [ADMIN_LOOKUPFLW(spender)], who spent a slasher antag token")
		CRASH("Failed to find valid spawn location for slasher antag token")
	if(isliving(spender) && hosts_mind)
		hosts_mind.current.unequip_everything()
		new /obj/effect/holy(hosts_mind.current.loc)
		QDEL_IN(hosts_mind.current, 1 SECOND)
	var/mob/living/carbon/human/slasher = new (spawn_loc)
	slasher.PossessByPlayer(spender_key)
	slasher.mind.add_antag_datum(/datum/antagonist/slasher)
	if(isobserver(spender))
		qdel(spender)
	message_admins("[ADMIN_LOOKUPFLW(slasher)] has been made into a slasher by using an antag token.")
