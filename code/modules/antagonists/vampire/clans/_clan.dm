/**
 * Vampire clans
 *
 * Handles everything related to clans.
 * The entire idea of datumizing this came to me in a dream.
 */
/datum/vampire_clan
	/// The name of the clan we're in.
	var/name = "Caitiff"
	/// Description of what the clan is, given when joining and through your antag UI.
	var/description = "Vile thinblooded mongrel. Choose a clan or die like the freak you are."
	/// Description shown when trying to join the clan.
	var/join_description

	/// The vampire datum that owns this clan. Use this over 'source', because while it's the same thing, this is more consistent (and used for deletion).
	var/datum/antagonist/vampire/vampiredatum

	/// The icon of this clan on the selection radial menu.
	var/join_icon = 'icons/ui/antags/vampire_clans.dmi'
	var/join_icon_state = "base"

	/// Whether the clan can be joined by players. FALSE for flavortext-only clans.
	var/joinable_clan = FALSE

	/// How we will drink blood using Feed.
	var/blood_drink_type = VAMPIRE_DRINK_NORMAL

	/// Unique antag HUD icon of this clan, if any.
	var/antag_hud_icon

/**
 * Starting Humanity score, some clans are closer to the beast, some closer to humanity.
 * We start out at null and set it in new because we want a fall back to the global default if none is set.
 * 10 	Saintly			Toreador
 * 9 	Compassionate	Ventrue
 * 8 	Caring			Malkavian, Brujah
 * 7 	Normal			Tremere
 * 6 	Distant
 * 5 	Removed
 * 4 	Unfeeling
 * 3 	Cold
 * 2 	Bestial
 * 1 	Horrific
 * 0 	Wight
 */
	var/default_humanity

/datum/vampire_clan/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum = owner_datum
	// Apply clan-specific default humanity; fall back to the global default only if none was set.
	if(isnull(default_humanity))
		default_humanity = VAMPIRE_DEFAULT_HUMANITY
	vampiredatum.adjust_humanity(default_humanity - VAMPIRE_DEFAULT_HUMANITY, TRUE)
	// adjust_humanity only hands out blush of life on a gain, so clans starting right at the default never got it
	if(vampiredatum.humanity >= VAMPIRE_LOW_HUMANITY && !(locate(/datum/action/cooldown/vampire/blush_of_life) in vampiredatum.powers))
		vampiredatum.grant_power(new /datum/action/cooldown/vampire/blush_of_life)

	vampiredatum.owner.current.playsound_local(get_turf(vampiredatum.owner.current), 'sound/effects/vampires/VampireAlert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(vampiredatum.owner.current, span_narsiesmall("I remember now. I belong with the [name]..."))

	vampiredatum.update_static_data_for_all_viewers()

	log_vampire_power("[key_name(vampiredatum.owner.current)] has joined the [name].")

/datum/vampire_clan/proc/on_apply()
	for(var/datum/discipline/disciple as anything in vampiredatum.owned_disciplines)
		disciple.apply_discipline_quirks(vampiredatum)

	for(var/datum/action/cooldown/vampire/clanselect/clanselect in vampiredatum.powers)
		vampiredatum.remove_power(clanselect)

	if(!QDELETED(vampiredatum.owner?.current))
		apply_effects(vampiredatum.owner.current)

/datum/vampire_clan/proc/apply_effects(mob/living/body)
	return

/datum/vampire_clan/proc/remove_effects(mob/living/body)
	return

/datum/vampire_clan/Destroy(force)
	if(!QDELETED(vampiredatum?.owner?.current))
		remove_effects(vampiredatum.owner.current)
	vampiredatum = null
	return ..()

/**
 * Called when a Vampire exits Torpor
 */
/datum/vampire_clan/proc/on_exit_torpor()
	return

/**
 * Called during Vampire's life_tick
 */
/datum/vampire_clan/proc/handle_clan_life()
	if(!(locate(/datum/action/cooldown/vampire/levelup) in vampiredatum.powers) && vampiredatum.vampire_level_unspent > 0)
		vampiredatum.grant_power(new /datum/action/cooldown/vampire/levelup)

/**
 * Called when a Vampire successfully vassalizes someone with Share Blood.
 * Do not call this on [/datum/antagonist/vampire/proc/make_vassal()] !!!
 */
/datum/vampire_clan/proc/on_vassal_made(mob/living/living_vampire, mob/living/living_vassal)
	living_vampire.playsound_local(null, 'sound/effects/singlebeat.ogg', 70, TRUE)

	living_vassal.playsound_local(null, 'sound/effects/singlebeat.ogg', 70, TRUE)
	living_vassal.set_jitter_if_lower(30 SECONDS)
	living_vassal.emote("laugh")

/**
 * Called when we level up inside a coffin.
 */

	/**
	 * For every discipline in clan_disciplines we do:
	 * if the next level returns anything but null, we add it to the options
	 * ///
	 * Then we display the radial with the options.
	 * Picking a choice will do the following:
	 * Remove all powers from the discipline's current level, by:
	 * for every power in get_abilities_with_level(current level) > remove
	 * increase discipline level
	 * for every power in get_abilities_with_level(current level) > add
	 */
/datum/vampire_clan/proc/spend_rank(mob/living/carbon/carbon_vampire)
	if(QDELETED(vampiredatum.owner?.current) || vampiredatum.vampire_level_unspent <= 0)
		return

	// Generate radial menu
	var/list/options = list()
	var/list/radial_display = list()

	for(var/datum/discipline/discipline as anything in vampiredatum.owned_disciplines)	// We do owned_disciplines, not clan_disciplines. clan_disciplines is used to populate owned_disciplines.
		if(discipline.get_abilities_with_level("next"))
			options[discipline.name] = discipline
			var/datum/radial_menu_choice/option = new
			option.image = image(icon = 'icons/mob/actions/actions_vampire_disciplines.dmi', icon_state = discipline.icon_state)
			option.info = "[span_boldnotice(discipline.name)]\n[span_cult(discipline.discipline_explanation)]"
			radial_display[initial(discipline.name)] = option

	var/mob/living/living_vampire = vampiredatum.owner.current

	// Show radial menu
	if(!length(options))
		to_chat(living_vampire, span_notice("You grow more familiar with your powers!"))
	else
		to_chat(living_vampire, span_notice("You have the opportunity to grow your expertise. Select a discipline to advance your Rank."))

		// If we're in a closet, anchor the radial menu to it. If not, anchor it to the vampire body
		var/datum/discipline/discipline_response

		if(istype(living_vampire.loc, /obj/structure/closet))
			var/obj/structure/closet/container = living_vampire.loc
			discipline_response = show_radial_menu(living_vampire, container, radial_display)
		else
			discipline_response = show_radial_menu(living_vampire, living_vampire, radial_display)

		var/datum/discipline/chosen_discipline

		for(var/datum/discipline/discipline as anything in vampiredatum.owned_disciplines)
			if(discipline.name == discipline_response)
				chosen_discipline = discipline
				break

		if(isnull(discipline_response) || QDELETED(src) || QDELETED(living_vampire))
			return FALSE

		// Remove all current powers
		var/list/saved_cooldowns = list()
		for(var/datum/action/cooldown/vampire/power_old as anything in vampiredatum.powers)
			if(is_type_in_list(power_old, chosen_discipline.get_abilities_with_level("current")))
				vampiredatum.remove_power(power_old)
				saved_cooldowns[power_old.name] = power_old.next_use_time

		// increment level
		chosen_discipline.level_up()

		// add all current powers (of the new level)
		for(var/power_type in chosen_discipline.get_abilities_with_level("current"))
			var/datum/action/cooldown/vampire/power_new = new power_type
			if(power_new.name in saved_cooldowns)
				power_new.next_use_time = saved_cooldowns[power_new.name]
			vampiredatum.grant_power(power_new)
			// a brand new disable has no old cooldown to copy, so it'd skip the lockout the others are under
			if((power_new.shared_cooldown & VAMPIRE_SHARED_COOLDOWN_MIND) && vampiredatum.mind_lockout_end > max(world.time, power_new.next_use_time))
				power_new.StartCooldownSelf(vampiredatum.mind_lockout_end - world.time)

		living_vampire.balloon_alert(living_vampire, "learned [discipline_response] level [chosen_discipline.level - 1]!")
		to_chat(living_vampire, span_notice("You have learned how to use [discipline_response]!"))

	finalize_spend_rank()

	// QoL
	if(vampiredatum.vampire_level_unspent > 0)
		spend_rank(carbon_vampire)

/datum/vampire_clan/proc/finalize_spend_rank()
	// Level up the vampire
	vampiredatum.vampire_regen_rate += 0.05
	vampiredatum.max_vitae += 100

	/* if(ishuman(vampiredatum.owner.current))
		var/mob/living/carbon/human/vampire_human = vampiredatum.owner.current
		vampire_human.dna.species.punchdamage += 0.5 */

	// We're almost done - Spend your Rank now.
	vampiredatum.vampire_level++
	vampiredatum.vampire_level_unspent--

	// Flavor
	to_chat(vampiredatum.owner.current, span_notice("You are now a rank [vampiredatum.vampire_level] Vampire. \
		Your strength, health, feed rate, regen rate, and maximum blood capacity have all increased! \n\
		* Your existing powers have all ranked up as well!"))
	vampiredatum.update_hud()
