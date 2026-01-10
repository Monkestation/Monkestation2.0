#define DEVIL_REVIVAL_TIME (10 MINUTES)
#define INNATE_DEVIL_TRAITS list(\
	TRAIT_NO_SOUL, \
	TRAIT_NOFIRE, \
	TRAIT_NOBREATH, \
	TRAIT_RESISTCOLD, \
	TRAIT_RESISTLOWPRESSURE, \
	TRAIT_RESISTHIGHPRESSURE, \
)

/**
 * The devil, an agent of hell that listens only to himself and upper devils
 *
 * Basic gameplay: Go up to people with custom-made contracts and scam them out of their soul
 *
 * Do note contracts the devil makes are "sticky", in a way that most abilities will transfer bodies.
 * If you make a deal with the devil, better expect that blindness to still affect you whilst in a borg body.
 **/
/datum/antagonist/devil
	name = "\improper Devil"
	job_rank = ROLE_DEVIL
	antag_hud_name = "devil"
	suicide_cry = "SEE YOU IN HELL!!"
	antagpanel_category = ANTAG_GROUP_DEVILS
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	stinger_sound = 'sound/ambience/antag/heretic/heretic_gain.ogg'
	ui_name = "AntagInfoDevil"
	/// The timer ID for reviving devils
	var/revival_timer_id = null
	/// The amount of times the devil can revive from a full-body removal
	var/lifes_left = 2
	/// Every single ability the devil has should be here.
	var/list/current_abilities = list()

	/// A list of all possible devil clauses when the antag is created
	/// Keep in mind these are shared between the people who took them
	var/list/clauses = list()
	/// A list of clauses that will be automatically applied when making a new contract
	var/list/default_clauses = list()
	/// The list of people we've made contracts with linked with the clauses they took
	/// Mind = list(/datum/devil_clause/immortality)
	var/list/contracted = list()
	/// The UI used to edit contract clauses
	var/datum/contract_ui/contract_ui = null

	/// The true name of the devil, speaking it outloud will stun the devil
	var/true_name = ""
	/// The regex of the true name, so we don't have to create it every single time someone speaks
	var/regex/name_regex = null
	/// Cooldown for the name stun, so it isn't quite instant victory
	COOLDOWN_DECLARE(true_name_cooldown)

/datum/antagonist/devil/proc/create_objectives()
	var/datum/objective/collect_souls/soul_objective = new
	objectives += soul_objective

/datum/antagonist/devil/on_gain()
	create_objectives()
	create_true_name()
	var/list/default_abilities = list(
		/datum/action/cooldown/spell/devil/revival/greater,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/demon,
		/datum/action/cooldown/spell/devil/contract,
	)
	for(var/datum/action/ability as anything in default_abilities)
		current_abilities += new ability(src)
	. = ..()

	var/list/clauses_to_take = subtypesof(/datum/devil_clause)
	clauses_to_take -= list(/datum/devil_clause/trait_giver, /datum/devil_clause/ability_giver)
	for(var/datum/devil_clause/clause as anything in clauses_to_take)
		new clause(src)

	if(isnull(contract_ui))
		contract_ui = new(src)
	RegisterSignal(owner, COMSIG_MIND_TRANSFERRED, PROC_REF(on_devil_transferred))
	RegisterSignal(owner.current, COMSIG_QDELETING, PROC_REF(on_devil_deleted))

/datum/antagonist/devil/on_removal()
	for(var/datum/mind/mind as anything in contracted)
		on_mind_deleted(mind)

	if(revival_timer_id)
		deltimer(revival_timer_id)
	if(lifes_left)
		UnregisterSignal(owner, COMSIG_MIND_TRANSFERRED)
		if(owner.current && !isbrain(owner.current))
			UnregisterSignal(owner.current, COMSIG_QDELETING)
	default_clauses = null
	QDEL_LIST(clauses)
	QDEL_LIST(current_abilities)
	QDEL_NULL(contract_ui)
	QDEL_NULL(name_regex)
	return ..()

/datum/antagonist/devil/apply_innate_effects(mob/living/target = owner.current)
	RegisterSignal(target, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))
	target.add_traits(INNATE_DEVIL_TRAITS, DEVIL_TRAIT)
	for(var/datum/action/ability as anything in current_abilities)
		ability.Grant(target)

/datum/antagonist/devil/remove_innate_effects(mob/living/target = owner.current)
	if(QDELETED(target))
		return
	UnregisterSignal(target, COMSIG_MOVABLE_HEAR)
	target.remove_traits(INNATE_DEVIL_TRAITS, DEVIL_TRAIT)
	for(var/datum/action/ability as anything in current_abilities)
		ability.Remove(target)

/datum/antagonist/devil/ui_static_data()
	var/list/data = ..()
	data["true_name"] = true_name
	return data

/datum/antagonist/devil/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, true_name))
		if(name_regex)
			QDEL_NULL(name_regex)
		name_regex = regex(true_name, "i")

/datum/antagonist/devil/proc/create_true_name()
	if(name_regex)
		QDEL_NULL(name_regex)
	var/constructed_name = ""
	var/list/syllables = list("hal", "ve", "odr", "neit", "ci", "quon", "mya", "folth", "wren", "geyr", "hil", "niet", "twou", "phi", "coa")
	for(var/index in 1 to rand(3, 5))
		constructed_name += pick(syllables)
		if(prob(40))
			constructed_name += "'"
	true_name = constructed_name
	name_regex = regex(true_name, "i")

/datum/antagonist/devil/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	message_admins(hearing_args[HEARING_RAW_MESSAGE])
	var/mob/speaker = hearing_args[HEARING_SPEAKER]
	if(speaker == owner.current || !COOLDOWN_FINISHED(src, true_name_cooldown))
		return

	if(name_regex.Find(hearing_args[HEARING_RAW_MESSAGE]) != 0)
		COOLDOWN_START(src, true_name_cooldown, 1 MINUTES)
		var/holy_multiplier = (speaker?.mind?.holy_role ? 2 : 1)
		owner.current.adjustFireLoss(15 * holy_multiplier)
		owner.current.Stun(3 SECONDS * holy_multiplier, ignore_canstun = TRUE)

/datum/antagonist/devil/proc/on_devil_transferred(datum/mind/mind, mob/living/old_current)
	SIGNAL_HANDLER
	if(old_current && !isbrain(old_current))
		UnregisterSignal(old_current, COMSIG_QDELETING)
	if(isbrain(mind.current))
		if(isnull(revival_timer_id))
			revival_timer_id = addtimer(CALLBACK(src, PROC_REF(revive_devil)), DEVIL_REVIVAL_TIME, TIMER_STOPPABLE)
		return
	if(revival_timer_id)
		deltimer(revival_timer_id)
	RegisterSignal(mind.current, COMSIG_QDELETING, PROC_REF(on_devil_deleted))

/datum/antagonist/devil/proc/on_devil_deleted(mob/living/devil_body)
	SIGNAL_HANDLER
	UnregisterSignal(devil_body, COMSIG_QDELETING)
	revival_timer_id = addtimer(CALLBACK(src, PROC_REF(revive_devil)), DEVIL_REVIVAL_TIME, TIMER_STOPPABLE)

/// The proc that gets called if the body had its original body destroyed, and not restored within 10 minutes.
/datum/antagonist/devil/proc/revive_devil()
	revival_timer_id = null
	if(owner.current && !isbrain(owner.current)) // Borged or otherwise they somehow got a new body. Leave them be.
		RegisterSignal(owner.current, COMSIG_QDELETING, PROC_REF(on_devil_deleted))
		return

	var/mob/living/carbon/human/new_body = new(find_safe_turf(dense_atoms = TRUE))
	var/datum/color_palette/generic_colors/located = new_body.dna.color_palettes[/datum/color_palette/generic_colors]
	located.mutant_color = "#A02720"
	located.mutant_color_secondary = "#A02720"
	new_body.dna.features = list(
		"tail_lizard" = "Dark Tiger",
		"tail_human" = "None",
		"snout" = "Sharp",
		"horns" = "Curled",
		"ears" = "None",
		"wings" = "None",
		"frills" = "None",
		"spines" = "Long",
		"body_markings" = "Dark Tiger Body",
		"legs" = DIGITIGRADE_LEGS,
	)
	new_body.hairstyle = "Bald"
	new_body.undershirt = "Nude"
	new_body.underwear = "Nude"
	new_body.socks = "Nude"
	new_body.eye_color_left = "#FEE5A3"
	new_body.eye_color_right = "#FEE5A3"
	new_body.set_species(/datum/species/lizard)
	new_body.fully_replace_character_name(newname = owner.name)
	new_body.equipOutfit(/datum/outfit/devil)
	owner.transfer_to(new_body)
	new_body.revive(NONE, revival_policy = POLICY_ANTAGONISTIC_REVIVAL) // Gotta drag the ghost to their new body, and give a message
	lifes_left--
	if(lifes_left)
		to_chat(new_body, span_danger("You can revive [lifes_left] more times from full-body removal. You should remain carefull."))
	else
		to_chat(new_body, span_userdanger("You can't revive the next time you perish, this is your final life!"))
		UnregisterSignal(owner, COMSIG_MIND_TRANSFERRED)
		UnregisterSignal(owner.current, COMSIG_QDELETING)

/datum/outfit/devil
	name = "Devil"
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/red
	neck = /obj/item/clothing/neck/tie/black/tied
	shoes = /obj/item/clothing/shoes/laceup
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/headset
	l_hand = /obj/item/storage/briefcase

#undef INNATE_DEVIL_TRAITS
#undef DEVIL_REVIVAL_TIME
