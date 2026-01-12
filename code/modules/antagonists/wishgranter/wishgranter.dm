/datum/antagonist/wishgranter
	name = "\improper Wishgranter Avatar"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antagpanel_category = "Avatar of the Wish Granter"
	hijack_speed = 2 //You literally are here to do nothing else. Might as well be fast about it.
	antag_hud_name = "wishgranter"
	suicide_cry = "HAHAHAHAHA!!"
	stinger_sound = 'sound/ambience/antag/wishgranter_gain.ogg'
	antag_moodlet = /datum/mood_event/wishgranter
	antag_count_points = 15 // very loud hijacker
	/// List of traits given to the avatar's body.
	var/static/list/given_traits = list(
		TRAIT_FEARLESS,
		TRAIT_NOFLASH, // do something besides flashbang spam
		TRAIT_NO_PAIN_EFFECTS, // i'm just HER
		TRAIT_PUSHIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_STUNIMMUNE, // bc it gave hulk previously
		TRAIT_TRUE_NIGHT_VISION,
		TRAIT_XRAY_VISION,
	)
	/// List of traits given to the avatar's mind.
	var/static/list/given_mind_traits = list(
		TRAIT_UNCONVERTABLE, // The bonds of loyalty are broken, after all.
	)

/datum/antagonist/wishgranter/forge_objectives()
	var/datum/objective/hijack/hijack = new
	hijack.owner = owner
	objectives += hijack

/datum/antagonist/wishgranter/on_gain()
	owner.special_role = "Avatar of the Wish Granter"
	forge_objectives()
	owner.add_traits(given_mind_traits, REF(src))
	return ..()

/datum/antagonist/wishgranter/on_removal()
	. = ..()
	owner.remove_traits(given_mind_traits, REF(src))

/datum/antagonist/wishgranter/greet()
	. = ..()
	to_chat(owner, span_boldwarning("Your head pounds for a moment, feeling as if something incomprehensible from beyond this reality smiles at you..."), type = MESSAGE_TYPE_INFO)
	to_chat(owner, span_boldnotice("You are the [span_hypnophrase("avatar of the Wish Granter")], and your power is LIMITLESS! And it's all yours. You need to make sure no one can take it from you."), type = MESSAGE_TYPE_INFO)
	to_chat(owner, span_userdanger("Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!"), type = MESSAGE_TYPE_INFO)
	owner.announce_objectives()

/datum/antagonist/wishgranter/apply_innate_effects(mob/living/mob_override)
	var/mob/living/mob = mob_override || owner.current
	RegisterSignal(mob, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_wishgranter_overlay))
	RegisterSignal(mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	mob.update_appearance(UPDATE_OVERLAYS)
	if(ishuman(mob))
		var/mob/living/carbon/human/human_owner = mob
		human_owner.physiology?.damage_resistance += 25
		human_owner.dna?.add_mutation(/datum/mutation/telekinesis, MUTATION_SOURCE_WISHGRANTER)
	mob.add_traits(given_traits, REF(src))
	mob.update_sight()

/datum/antagonist/wishgranter/remove_innate_effects(mob/living/mob_override)
	var/mob/living/mob = mob_override || owner.current
	UnregisterSignal(mob, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ATOM_EXAMINE))
	mob.update_appearance(UPDATE_OVERLAYS)
	if(ishuman(mob))
		var/mob/living/carbon/human/human_owner = mob
		human_owner.physiology?.damage_resistance -= 25
		human_owner.dna?.remove_mutation(/datum/mutation/telekinesis, MUTATION_SOURCE_WISHGRANTER)
	mob.remove_traits(given_traits, REF(src))
	mob.update_sight()

/datum/antagonist/wishgranter/proc/add_wishgranter_overlay(mob/living/source, list/overlays)
	SIGNAL_HANDLER
	var/mutable_appearance/aura = mutable_appearance('icons/effects/effects.dmi', "wg_aura")
	var/mutable_appearance/aura_e = emissive_appearance('icons/effects/effects.dmi', "wg_aura_e", source)
	if(ishuman(source))
		var/mob/living/carbon/human/human_source = source
		human_source.apply_height_filters(aura)
		human_source.apply_height_filters(aura_e)
	overlays += aura
	overlays += aura_e

/datum/antagonist/wishgranter/proc/on_examine(mob/living/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_boldwarning("A chaotic, radiant malignancy blazes from within. You feel as though nothing is safe from [source.p_their()] all-consuming madness.")
