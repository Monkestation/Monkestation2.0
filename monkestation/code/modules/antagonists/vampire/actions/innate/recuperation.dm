/datum/action/cooldown/vampire/recuperation
	name = "Recuperation"
	desc = "Greatly increase your recovery rate beyond that of any mortal. The process drains lifeforce and doesn't work in masquerade."
	button_icon_state = "power_recup"
	check_flags = NONE
	toggleable = TRUE
	starts_active = TRUE
	works_in_masquerade = TRUE // on_life still prevents it from working, but you can toggle it if you want
	has_custom_life_cost = TRUE

	/// To avoid situations where a vampire has to wait 2 years to regrow stuff because of RNG, it uses slightly randomized accumulation instead. If this reaches 1, something regrows.
	var/regrow_accumulation = 0

	/// Increments while when we're dead and able to revive, resets otherwise. If this reaches 1, we revive.
	var/revival_progress = 0

	/// Accumulation var for brain traumas, when this reaches 1, we heal a brain trauma.
	var/trauma_heal_progress = 0

/datum/action/cooldown/vampire/recuperation/New(Target)
	. = ..()
	RegisterSignal(vampire, COMSIG_VAMPIRE_STAT_CHANGED_MOD, PROC_REF(on_stat_changed))
	update_recovery_scaling(vampire.get_stat_modified(VAMPIRE_STAT_RECOVERY))

/datum/action/cooldown/vampire/recuperation/Destroy()
	. = ..()
	UnregisterSignal(vampire, COMSIG_VAMPIRE_STAT_CHANGED_MOD)

/datum/action/cooldown/vampire/recuperation/on_toggle_on()
	RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/action/cooldown/vampire/recuperation/on_toggle_off()
	UnregisterSignal(owner, COMSIG_LIVING_LIFE)
	regrow_accumulation = 0
	revival_progress = 0

/datum/action/cooldown/vampire/recuperation/proc/on_life(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(vampire.masquerade_enabled)
		return

	var/regen_rate = vampire.regen_rate_modifier.get_value()
	var/regen_level = vampire.get_stat(VAMPIRE_STAT_RECOVERY)

	if(regen_rate <= 0) // sanity check
		return

	if(owner.stat == DEAD)
		if(regen_level < VAMPIRE_REGEN_THRESHOLD_REVIVE)
			return
		regen_rate *= 1.5 // regen faster while dead

	var/list/dmg = list(
		BRUTE = user.getBruteLoss(),
		BURN = user.getFireLoss()
	)

	if(regen_level >= VAMPIRE_REGEN_THRESHOLD_TOX)
		dmg[TOX] = user.getToxLoss()
		dmg[CLONE] = user.getCloneLoss()

	if(regen_level >= VAMPIRE_REGEN_THRESHOLD_OXY)
		dmg[OXY] = user.getOxyLoss()

	var/total_damage = 0
	for(var/dmgType as anything in dmg)
		var/amount = dmg[dmgType]
		if(!amount)
			dmg -= dmgType
			continue
		total_damage += amount

	var/total_life_cost = 0

	if(total_damage > 0)
		var/damage_regen_amount = regen_rate * seconds_per_tick
		var/list/ratios = list()
		for(var/dmgType as anything in dmg)
			ratios[dmgType] = dmg[dmgType] / total_damage
		for(var/dmgType as anything in ratios)
			user.heal_damage_type(-damage_regen_amount * ratios[dmgType], dmgType)
		total_life_cost += min(total_damage, damage_regen_amount) / 6 // 1 lifeforce per 6 damage healed

	if(regen_level >= VAMPIRE_REGEN_THRESHOLD_WOUNDS)
		var/wound_count = length(user.all_wounds)
		if(wound_count > 0) // no division by zero please
			var/wound_regen_amount = regen_rate * seconds_per_tick / 30 / wound_count // 10 seconds per severity at max if you only have one wound
			for(var/datum/wound/wound as anything in user.all_wounds)
				wound.heal(wound_regen_amount)
			total_life_cost += wound_regen_amount * wound_count * 2 // roughly 2 lifeforce per wound severity healed

	if(regen_level >= VAMPIRE_REGEN_THRESHOLD_ORGANS)
		var/organ_regen_amount = regen_rate * 0.1 * seconds_per_tick // 0.2 - 0.3 healing per second in practice (about 5 minutes to heal 100 at max recovery)
		for(var/obj/item/organ/internal/organ in user.organs)
			if(organ.damage <= 0 && !(organ.organ_flags & ORGAN_FAILING))
				continue
			if((organ.organ_flags & ORGAN_FAILING) && organ.failure_time >= 15 SECONDS / regen_rate) // takes 5 seconds to recover from organ failure at max
				if(user.stat == DEAD) // dead organs don't normally increment this, it's a bit hacky but it works
					organ.failure_time += seconds_per_tick
				continue
			total_life_cost += min(organ.damage, organ_regen_amount) * 0.05 // 1 lifeforce per 20 organ damage healed
			organ.apply_organ_damage(-organ_regen_amount)

		handle_traumas(regen_rate, regen_level, seconds_per_tick)

		var/obj/item/organ/internal/ears/ears = user.get_organ_slot(ORGAN_SLOT_EARS)
		if(istype(ears) && ears.deaf > 0)
			ears.deaf = max(0, ears.deaf - regen_rate * seconds_per_tick / 3) // 3x deafness decay at max (counting natural decay)

	if(regen_level >= VAMPIRE_REGEN_THRESHOLD_PURGE)
		var/toxin_purge_amount = regen_rate * 0.2 * seconds_per_tick // 0.43u - 0.6u per second in practice (time is entirely dependent on dosage)
		for(var/datum/reagent/toxin/toxin in user.reagents.reagent_list) // only purges toxins, purging meth would be laame
			total_life_cost += min(toxin.volume, toxin_purge_amount) * 0.2 // 1 lifeforce per 5u toxins purged
			user.reagents.remove_reagent(toxin.type, toxin_purge_amount)

	if(regen_level >= VAMPIRE_REGEN_THRESHOLD_REGROW_LIMBS)
		handle_regrow(regen_rate, regen_level, seconds_per_tick) // costs nothing because it only regrows damaged versions (which themselves cost lifeforce to heal)

	if(regen_level > VAMPIRE_REGEN_THRESHOLD_REVIVE)
		INVOKE_ASYNC(src, PROC_REF(handle_revive), regen_rate, regen_level, seconds_per_tick)

	vampire.adjust_lifeforce(-total_life_cost)

/// Handles healing brain traumas. There's no prioritization for this.
/datum/action/cooldown/vampire/recuperation/proc/handle_traumas(regen_rate, regen_level, seconds_per_tick)
	var/resilience = regen_level < VAMPIRE_REGEN_THRESHOLD_REGROW_ORGANS ? TRAUMA_RESILIENCE_BASIC : TRAUMA_RESILIENCE_SURGERY

	if(!user.has_trauma_type(resilience = resilience))
		trauma_heal_progress = 0
		return

	trauma_heal_progress += regen_rate * seconds_per_tick / 90 // 30 seconds per trauma at max
	if(trauma_heal_progress < 1)
		return
	trauma_heal_progress--

	user.cure_trauma_type(resilience = resilience)

/datum/action/cooldown/vampire/recuperation/proc/handle_revive(regen_rate, regen_level, seconds_per_tick)
	if(!can_revive())
		revival_progress = 0
		return

	if(revival_progress == 0)
		user.notify_ghost_cloning("Your eternal life is not yet over! Your body refuses its fate!", sound = 'monkestation/sound/vampires/revive_alert.ogg')
		if(HAS_TRAIT(user, TRAIT_HUSK)) // intentionally works against ling absorb and such (in line with most other revival abilities and legacy bloodsuckers)
			user.cure_husk()
			user.visible_message(
				message = span_danger("[user]'s charred outer flesh falls away, only to reveal a pristine layer underneath!"),
				self_message = span_green("Your charred outer flesh falls away, making way for a new pristine layer."),
				blind_message = span_hear("You hear a series of soft, wet thuds.") // the flesh just kind of falls off in pieces to the floor (you're likely laying down so the distance is minimal)
			)
			playsound(user, 'sound/effects/wounds/sizzle2.ogg', vol = 30, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) // and no we don't have a sound for that, and fuck no im not making it for this

	revival_progress += regen_rate * seconds_per_tick / 53 // 12 seconds to revive at max, counting death bonus (actually 11.8 to avoid tick bullshit)
	if(revival_progress < 1)
		if(SPT_PROB(50, seconds_per_tick))
			playsound(get_turf(user), SFX_BODYFALL, vol = 30, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			user.emote("twitch", status_check = FALSE)
		return
	revival_progress--

	vampire.adjust_lifeforce(-10) // if you die, you have to spend a bunch of lifeforce healing enough to revive, that's why this is so low

	user.revive()
	user.set_resting(FALSE, silent = TRUE, instant = TRUE)
	user.visible_message(
		message = span_danger("[user] snaps back to life!"),
		self_message = span_green("Ah, how good it feels to be alive again!"),
		blind_message = span_hear("You hear a thud.")
	)

/datum/action/cooldown/vampire/recuperation/proc/can_revive()
	if(user.stat != DEAD)
		return FALSE

	if(user.health <= user.crit_threshold && !HAS_TRAIT(user, TRAIT_NOSOFTCRIT))
		return FALSE

	if(user.health <= user.hardcrit_threshold && !HAS_TRAIT(user, TRAIT_NOHARDCRIT))
		return FALSE

	return TRUE

/// Handles regrowing both organs and limbs. Limbs take priority because performance and honestly they're more important anyway.
/datum/action/cooldown/vampire/recuperation/proc/handle_regrow(regen_rate, regen_level, seconds_per_tick)
	var/regrow_limb_zone = get_regrow_limb_zone()
	var/regrow_organ_type = get_regrow_organ_type(regen_level)

	if(!regrow_limb_zone && !regrow_organ_type)
		regrow_accumulation = 0 // nothing to regrow, reset accumulation (these checks arent THAT expensive)
		return

	regrow_accumulation += regen_rate * seconds_per_tick * rand(2, 3) / 150 // average of 20 seconds per regrow at max recovery
	if(regrow_accumulation < 1)
		return
	regrow_accumulation--

	if(regrow_limb_zone)
		regrow_limb(regrow_limb_zone)
	else
		regrow_organ(regrow_organ_type)

/// Gets a suitable limb zone for regrowth, if any.
/datum/action/cooldown/vampire/recuperation/proc/get_regrow_limb_zone()
	if(user.health < user.crit_threshold) // saves on having to check missing limbs
		return

	var/missing_zones = user.get_missing_limbs()
	for(var/zone as anything in missing_zones)
		var/obj/item/bodypart/limb = user.dna.species.bodypart_overrides[zone]
		if(user.health - initial(limb.max_damage) < user.crit_threshold) // don't crit/kill the vampire if they regrow a limb
			missing_zones -= zone

	if(!length(missing_zones))
		return

	return pick(missing_zones)

/// Gets a suitable organ type for regrowth, if any.
/datum/action/cooldown/vampire/recuperation/proc/get_regrow_organ_type(regen_level)
	if(regen_level < VAMPIRE_REGEN_THRESHOLD_REGROW_ORGANS)
		return

	// Unlike limb regrowth, this is in order of priority.
	var/valid_slots = list(
		ORGAN_SLOT_EYES, // seeing is the most important thing
		ORGAN_SLOT_LUNGS, // right behind breathing
		ORGAN_SLOT_EARS, // hearing you can go without for a bit
		ORGAN_SLOT_LIVER, // a liver? definitely can go without
		ORGAN_SLOT_HEART, // you can go without it entirely but fixing your tongue and ass before your heart would be fucking weird
		ORGAN_SLOT_STOMACH, // your hunger is based on your lifeforce so this is useless too
		ORGAN_SLOT_TONGUE, // next up, speaking properly
		ORGAN_SLOT_BUTT, // clearly, farting is more important than pissing
		ORGAN_SLOT_BLADDER,
	)

	for(var/slot as anything in valid_slots)
		if(user.get_organ_slot(slot))
			continue

		var/organ_type = user.dna.species.get_mutant_organ_type_for_slot(slot)
		if(!organ_type)
			continue

		return organ_type

/// Regrows a limb on the given zone.
/datum/action/cooldown/vampire/recuperation/proc/regrow_limb(zone)
	user.regenerate_limb(zone)

	var/obj/item/bodypart/new_limb = user.get_bodypart(zone)
	if(!new_limb) // i hope for the sake of this codebase that this hopefully pointless check never passes
		CRASH("Vampire Recuperate attempted regrowing a limb using regenerate_limb(zone), yet get_bodypart(zone) returned null. Something is fucked up.")

	new_limb.receive_damage(brute = new_limb.max_damage, forced = TRUE, wound_bonus = CANT_WOUND) // regrown limbs start at 0 health

	playsound(user, 'sound/magic/demon_consume.ogg', vol = 50, vary = TRUE)
	user.visible_message(
		message = span_danger("[user]'s flesh shifts nauseatingly as [user.p_their()] [new_limb.plaintext_zone] regrows!"),
		self_message = span_green("Your flesh shifts as your [new_limb.plaintext_zone] regrows!"),
		blind_message = span_hear("You hear a wet crunch!")
	)

/// Regrows an organ of the given type.
/datum/action/cooldown/vampire/recuperation/proc/regrow_organ(type)
	var/obj/item/organ/organ = new type
	organ.set_organ_damage(organ.maxHealth) // regrown organs start at 0 health
	organ.Insert(user, special = TRUE, drop_if_replaced = FALSE)

	to_chat(user, span_green("You feel an odd sensation as your [organ.name] regrow[organ.p_s()]!")) // i went out of my way to code a pronoun override for organs to avoid "your eyes regrows", what is my life
	playsound(user, 'sound/effects/wounds/splatter.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

/datum/action/cooldown/vampire/recuperation/proc/on_stat_changed(datum/source, stat, old_amount, new_amount)
	SIGNAL_HANDLER
	if(stat != VAMPIRE_STAT_RECOVERY)
		return
	update_recovery_scaling(new_amount)

/datum/action/cooldown/vampire/recuperation/proc/update_recovery_scaling(recovery)
	vampire.regen_rate_modifier.set_multiplicative(VAMPIRE_STAT_RECOVERY, 1 + recovery / VAMPIRE_SP_MAXIMUM * 2) // 3x regen rate at max recovery
