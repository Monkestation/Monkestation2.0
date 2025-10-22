///The maximum level a Ventrue Bloodsucker can be, before they have to level up their vassal instead.
#define VENTRUE_MAX_LEVEL 3
///How much it costs for a Ventrue to rank up without a spare rank to spend.
#define BLOODSUCKER_BLOOD_RANKUP_COST (550)

/datum/bloodsucker_clan/ventrue
	name = CLAN_VENTRUE
	description = "The Ventrue Clan is extremely snobby with their meals, and refuse to drink blood from people without a mind. \n\
		You may only level yourself up to Level %MAX_LEVEL%, anything further will be ranks to spend on their Favorite Vassal through a Persuasion Rack. \n\
		The Favorite Vassal will slowly turn more Vampiric this way, until they finally lose their last bits of Humanity."
	clan_objective = /datum/objective/bloodsucker/embrace
	join_icon_state = "ventrue"
	join_description = "Lose the ability to drink from mindless mobs, can't level up or gain new powers, \
		instead you raise a vassal into a Bloodsucker."
	blood_drink_type = BLOODSUCKER_DRINK_SNOBBY

/datum/bloodsucker_clan/ventrue/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	description = replacetext(description, "%MAX_LEVEL%", VENTRUE_MAX_LEVEL)

/datum/bloodsucker_clan/ventrue/spend_rank(datum/antagonist/bloodsucker/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	if(!target)
		if(bloodsuckerdatum.bloodsucker_level < VENTRUE_MAX_LEVEL)
			return ..()
		return FALSE
	var/datum/antagonist/vassal/favorite/vassal_datum = target.mind.has_antag_datum(/datum/antagonist/vassal/favorite)
	var/datum/antagonist/bloodsucker/vassal_bloodsucker_datum = target.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!vassal_datum)
		return FALSE
	// Purchase Power Prompt
	var/list/options = list()
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.all_bloodsucker_powers)
		if(!(power::purchase_flags & VASSAL_CAN_BUY))
			continue
		if(locate(power) in vassal_datum.powers)
			continue
		if(vassal_bloodsucker_datum && (locate(power) in vassal_bloodsucker_datum.powers))
			continue
		options[power::name] = power

	if(length(options) < 1)
		to_chat(bloodsuckerdatum.owner.current, span_notice("You grow more ancient by the night!"))
	else
		// Give them the UI to purchase a power.
		var/choice = tgui_input_list(bloodsuckerdatum.owner.current, "You have the opportunity to level up your Favorite Vassal. Select a power you wish them to recieve.", "Your Blood Thickens...", options)
		// Prevent Bloodsuckers from closing/reopning their coffin to spam Levels.
		if(cost_rank && bloodsuckerdatum.bloodsucker_level_unspent <= 0)
			return
		// Did you choose a power?
		if(!choice || !options[choice])
			to_chat(bloodsuckerdatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return
		// Prevent Bloodsuckers from closing/reopning their coffin to spam Levels.
		if((locate(options[choice]) in vassal_datum.powers))
			to_chat(bloodsuckerdatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return

		// Good to go - Buy Power!
		var/datum/action/cooldown/bloodsucker/purchased_power = options[choice]
		vassal_datum.BuyPower(new purchased_power)
		bloodsuckerdatum.owner.current.balloon_alert(bloodsuckerdatum.owner.current, "taught [choice]!")
		to_chat(bloodsuckerdatum.owner.current, span_notice("You taught [target] how to use [choice]!"))
		target.balloon_alert(target, "learned [choice]!")
		to_chat(target, span_notice("Your master taught you how to use [choice]!"))

	vassal_datum.vassal_level++
	switch(vassal_datum.vassal_level)
		if(2)
			target.add_traits(list(TRAIT_COLD_BLOODED, TRAIT_NOBREATH, TRAIT_AGEUSIA), BLOODSUCKER_TRAIT)
			to_chat(target, span_notice("Your blood begins to feel cold, and as a mote of ash lands upon your tongue, you stop breathing..."))
		if(3)
			target.add_traits(list(TRAIT_NOCRITDAMAGE, TRAIT_NOSOFTCRIT), BLOODSUCKER_TRAIT)
			to_chat(target, span_notice("You feel your Master's blood reinforce you, strengthening you up."))
		if(4)
			target.add_traits(list(TRAIT_SLEEPIMMUNE, TRAIT_VIRUSIMMUNE), BLOODSUCKER_TRAIT)
			to_chat(target, span_notice("You feel your Master's blood begin to protect you from bacteria."))
			if(ishuman(target))
				var/mob/living/carbon/human/human_target = target
				human_target.skin_tone = "albino"
		if(5)
			target.add_traits(list(TRAIT_NOHARDCRIT, TRAIT_HARDLY_WOUNDED), BLOODSUCKER_TRAIT)
			to_chat(target, span_notice("You feel yourself able to take cuts and stabbings like it's nothing."))
		if(6 to INFINITY)
			if(!vassal_bloodsucker_datum)
				QDEL_NULL(vassal_datum.info_button_ref)
				vassal_bloodsucker_datum = target.mind.add_antag_datum(/datum/antagonist/bloodsucker)
				vassal_bloodsucker_datum.my_clan = new /datum/bloodsucker_clan/vassal(vassal_bloodsucker_datum)
				to_chat(target, span_notice("You feel your heart stop pumping for the last time as you begin to thirst for blood, you feel... dead."))
				bloodsuckerdatum.owner.current.add_mood_event("madevamp", /datum/mood_event/madevamp)
			vassal_datum.set_vassal_level(vassal_bloodsucker_datum)

	finalize_spend_rank(bloodsuckerdatum, cost_rank, blood_cost)
	vassal_datum.LevelUpPowers()

/datum/bloodsucker_clan/ventrue/interact_with_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/favorite/vassal_datum)
	. = ..()
	if(.)
		return TRUE
	if(!istype(vassal_datum))
		return FALSE
	if(!bloodsuckerdatum.bloodsucker_level_unspent <= 0)
		bloodsuckerdatum.SpendRank(vassal_datum.owner.current)
		return TRUE
	if(bloodsuckerdatum.bloodsucker_blood_volume >= BLOODSUCKER_BLOOD_RANKUP_COST)
		// We don't have any ranks to spare? Let them upgrade... with enough Blood.
		to_chat(bloodsuckerdatum.owner.current, span_warning("Do you wish to spend [BLOODSUCKER_BLOOD_RANKUP_COST] Blood to Rank [vassal_datum.owner.current] up?"))
		var/static/list/rank_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
		)
		var/rank_response = show_radial_menu(bloodsuckerdatum.owner.current, vassal_datum.owner.current, rank_options, radius = 36, require_near = TRUE)
		if(rank_response == "Yes")
			bloodsuckerdatum.SpendRank(vassal_datum.owner.current, cost_rank = FALSE, blood_cost = BLOODSUCKER_BLOOD_RANKUP_COST)
		return TRUE
	to_chat(bloodsuckerdatum.owner.current, span_danger("You don't have any levels or enough Blood to Rank [vassal_datum.owner.current] up with."))
	return TRUE

/datum/bloodsucker_clan/ventrue/on_favorite_vassal(datum/source, datum/antagonist/vassal/vassal_datum, mob/living/bloodsucker)
	to_chat(bloodsucker, span_announce("* Bloodsucker Tip: You can now upgrade your Favorite Vassal by buckling them onto a persuasion rack!"))
	vassal_datum.BuyPower(new /datum/action/cooldown/bloodsucker/distress)

#undef BLOODSUCKER_BLOOD_RANKUP_COST
#undef VENTRUE_MAX_LEVEL
