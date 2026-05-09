/// Renders you unable to see people who were heretics at the time that this organ is gained
/obj/item/organ/internal/eyes/corrupt
	name = "corrupt orbs"
	desc = "These eyes have seen something they shouldn't have."
	// icon_state = "eyes_voidwalker"
	// iris_overlay = null
	eye_color_left = COLOR_VOID_PURPLE
	eye_color_right = COLOR_VOID_PURPLE
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	// pupils_name = span_hypnophrase("pierced realities") //teeny tiny mansus portals, IN YOUR EYEBALLS (known to cause cancer in the state of california)
	// penlight_message = "ARE THE LOCK, THE LIGHT IS THE KEY! THE HIGHER I RISE, THE MORE I-"
	/// The override images we are applying
	var/list/hallucinations

/obj/item/organ/internal/eyes/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ/* , FALSE */)
	AddElement(/datum/element/noticable_organ, "eyes have wide dilated pupils, and no iris. Something is moving in the darkness.", BODY_ZONE_PRECISE_EYES)

// /obj/item/organ/internal/eyes/corrupt/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
/obj/item/organ/internal/eyes/corrupt/Insert(mob/living/carbon/eye_recipient, special, drop_if_replaced)
	. = ..()
	if (!eye_recipient.client)
		return

	var/list/human_mobs = GLOB.human_list.Copy()
	human_mobs -= eye_recipient
	for (var/mob/living/carbon/human/check_human as anything in human_mobs)
		if (!IS_HERETIC(check_human) && !prob(5)) // Throw in some false positives
			continue
		var/image/invisible_man = image('icons/blanks/32x32.dmi', check_human, "nothing")
		invisible_man.override = TRUE
		LAZYADD(hallucinations, invisible_man)

	if (LAZYLEN(hallucinations))
		eye_recipient.client.images |= hallucinations

// /obj/item/organ/internal/eyes/corrupt/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
/obj/item/organ/internal/eyes/corrupt/Remove(mob/living/carbon/eye_owner, special)
	. = ..()
	if (!LAZYLEN(hallucinations))
		return
	eye_owner.client?.images -= hallucinations
	LAZYNULL(hallucinations)

/* /obj/item/organ/internal/eyes/corrupt/penlight_examine(mob/living/viewer, obj/item/examtool)
	viewer.playsound_local(src, 'sound/magic/magic_block_mind.ogg', 75, FALSE)
	if(!viewer.is_blind() && !IS_HERETIC_OR_MONSTER(viewer))
		to_chat(viewer, span_danger("Your eyes sizzle in their sockets as eldritch energies assault them!"))
		viewer.emote("scream")
		viewer.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
		viewer.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/speech/slurring/heretic)
		viewer.adjust_timed_status_effect(5 SECONDS, /datum/status_effect/temporary_blindness) //debounce basically.
		var/obj/item/organ/internal/eyes/parboiled = viewer.get_organ_slot(ORGAN_SLOT_EYES)
		parboiled?.apply_organ_damage(40) //enough to blind, but not enough to blind *permanently*
	return "[owner.p_Their()] eyes [span_hypnophrase(penlight_message)]"
 */
/// Sometimes speak in incomprehensible tongues
/obj/item/organ/internal/tongue/corrupt
	name = "corrupt tongue"
	desc = "This one tells only lies."
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS

/obj/item/organ/internal/tongue/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "mouth is full of stars.", BODY_ZONE_PRECISE_MOUTH)

// /obj/item/organ/internal/tongue/corrupt/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
/obj/item/organ/internal/tongue/corrupt/Insert(mob/living/carbon/tongue_owner, special, drop_if_replaced)
	. = ..()
	RegisterSignal(tongue_owner, COMSIG_MOB_SAY, PROC_REF(on_spoken))

// /obj/item/organ/internal/tongue/corrupt/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
/obj/item/organ/internal/tongue/corrupt/Remove(mob/living/carbon/tongue_owner, special)
	. = ..()
	UnregisterSignal(tongue_owner, COMSIG_MOB_SAY)

/// When the mob speaks, sometimes put it in a different language
/obj/item/organ/internal/tongue/corrupt/proc/on_spoken(mob/living/organ_owner, list/speech_args)
	SIGNAL_HANDLER
	if (organ_owner.has_reagent(/datum/reagent/water/holywater) || prob(60))
		return
	speech_args[SPEECH_LANGUAGE] = /datum/language/shadowtongue


/// Randomly secretes alcohol or hallucinogens when you're drinking something
/obj/item/organ/internal/liver/corrupt
	name = "corrupt liver"
	desc = "After what you've seen you could really go for a drink."
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// How much extra ingredients to add?
	var/amount_added = 5
	/// What extra ingredients can we add?
	var/list/extra_ingredients = list(
		/datum/reagent/consumable/ethanol/pina_olivada,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/thirteenloko,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/superlaughter,
		/datum/reagent/drug/bath_salts,
		/datum/reagent/drug/blastoff,
		/datum/reagent/drug/happiness,
		/datum/reagent/drug/mushroomhallucinogen,
	)

/obj/item/organ/internal/liver/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

// /obj/item/organ/internal/liver/corrupt/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
/obj/item/organ/internal/liver/corrupt/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	RegisterSignal(receiver, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_drank))

// /obj/item/organ/internal/liver/corrupt/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
/obj/item/organ/internal/liver/corrupt/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_ATOM_EXPOSE_REAGENTS)

/// If we drank something, add a little extra
/obj/item/organ/internal/liver/corrupt/proc/on_drank(mob/living/carbon/human, list/reagents, datum/reagents/source_reagents, methods)
	SIGNAL_HANDLER
	if (!(methods & INGEST))
		return
	if (human.has_reagent(/datum/reagent/water/holywater) || (locate(/datum/reagent/water/holywater) in reagents))
		return
	var/datum/reagents/extra_reagents = new()
	extra_reagents.add_reagent(pick(extra_ingredients), amount_added)
	extra_reagents.trans_to(human, amount_added, transfered_by = src, methods = INJECT)
	if (prob(20))
		to_chat(human, span_warning("As you take a sip, you feel something bubbling in your stomach..."))


/// Rapidly become hungry if you are not digesting blood
/obj/item/organ/internal/stomach/corrupt
	name = "corrupt stomach"
	desc = "This parasite demands an unwholesome diet in order to be satisfied."
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// Do we have an unholy thirst?
	var/thirst_satiated = FALSE
	/// Timer for when we get thirsty again
	var/thirst_timer
	/// How long until we prompt the player to drink blood again?
	COOLDOWN_DECLARE(message_cooldown)

/obj/item/organ/internal/stomach/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "appear%PRONOUN_S to have an unhealthy pallor.")

// /obj/item/organ/internal/stomach/corrupt/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
/obj/item/organ/internal/stomach/corrupt/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	RegisterSignal(receiver, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_drank))

// /obj/item/organ/internal/stomach/corrupt/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
/obj/item/organ/internal/stomach/corrupt/Remove(mob/living/carbon/stomach_owner, special)
	. = ..()
	UnregisterSignal(stomach_owner, COMSIG_ATOM_EXPOSE_REAGENTS)

/// Check if we drank a little blood
/obj/item/organ/internal/stomach/corrupt/proc/on_drank(atom/source, list/reagents, datum/reagents/source_reagents, methods)
	SIGNAL_HANDLER
	if (!(methods & INGEST))
		return

	var/contains_blood = locate(/datum/reagent/blood) in reagents
	if (!contains_blood)
		return

	if (!thirst_satiated)
		to_chat(source, span_cult_italic("The thirst is satisfied... for now."))
	thirst_satiated = TRUE
	deltimer(thirst_timer)
	thirst_timer = addtimer(VARSET_CALLBACK(src, thirst_satiated, FALSE), 3 MINUTES, TIMER_STOPPABLE | TIMER_DELETE_ME)

/obj/item/organ/internal/stomach/corrupt/handle_hunger(mob/living/carbon/human/human, seconds_per_tick)
	if (thirst_satiated || human.has_reagent(/datum/reagent/water/holywater))
		return ..()

	human.adjust_nutrition(-1 * seconds_per_tick)

	if (!COOLDOWN_FINISHED(src, message_cooldown))
		return ..()
	COOLDOWN_START(src, message_cooldown, 30 SECONDS)

	var/static/list/blood_messages = list(
		"Blood...",
		"Everyone suddenly looks so tasty.",
		"The blood...",
		"There's an emptiness in you that only blood can fill.",
		"You could really go for some blood right now.",
		"You feel the blood rushing through your veins.",
		"You think about biting someone's throat.",
		"Your stomach growls and you feel a metallic taste in your mouth.",
	)
	to_chat(human, span_cult_italic(pick(blood_messages)))

	return ..()

/// Occasionally bombards you with spooky hands and lets everyone hear your pulse.
/obj/item/organ/internal/heart/corrupt
	name = "corrupt heart"
	desc = "What corruption is this spreading along with the blood?"
	// beat_noise = "THE THUMPTHUMPTHUMPING OF THE CHISEL ON THE GLASS. OPEN THE FUTURE SHATTER THE-"
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	// cell_line = CELL_LINE_ORGAN_HEART_CURSED
	// cells_minimum = 2 //guarantees we always get sacred heart and corrupted heart cells
	/// How long until the next heart?
	COOLDOWN_DECLARE(hand_cooldown)

/obj/item/organ/internal/heart/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/internal/heart/corrupt/on_life(seconds_per_tick)
	. = ..()
	if (!COOLDOWN_FINISHED(src, hand_cooldown) || IS_IN_MANSUS(owner) || !owner.needs_heart() || !beating || owner.has_reagent(/datum/reagent/water/holywater))
		return
	fire_curse_hand(owner)
	COOLDOWN_START(src, hand_cooldown, rand(6 SECONDS, 45 SECONDS)) // Wide variance to put you off guard

/*
/obj/item/organ/internal/heart/corrupt/hear_beat_noise(mob/living/hearer)
	hearer.playsound_local(src, 'sound/magic/hereticknock.ogg', 75, FALSE)
	if(!IS_HERETIC_OR_MONSTER(hearer))
		hearer.emote("scream")
		hearer.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
		hearer.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/speech/slurring/heretic)
		var/obj/item/bodypart/head/regret = hearer.get_bodypart(BODY_ZONE_HEAD)
		regret?.force_wound_upwards(/datum/wound/pierce/bleed/severe/magicalearpain, wound_source = "stethoscoped a corrupted heart")
	return "[owner.p_Their()] heart produces [span_hypnophrase(beat_noise)]"
 */

/// Sometimes cough out some kind of dangerous gas
/obj/item/organ/internal/lungs/corrupt
	name = "corrupt lungs"
	desc = "Some things SHOULD be drowned in tar."
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/* breath_noise = "SECRET SONGS OF THE BREAKING OF THE MAKING OF THE WAKING FROM THE-" */
	/// How likely are we not to cough every time we take a breath?
	var/cough_chance = 15
	/// How much gas to emit?
	var/gas_amount = 30
	/// What can we cough up?
	var/list/gas_types = list(
		/datum/gas/bz = 30,
		/datum/gas/miasma = 50,
		/datum/gas/plasma = 20,
	)
	/// Cooldown between corrupted effects.
	COOLDOWN_DECLARE(effect_cooldown)

/obj/item/organ/internal/lungs/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/internal/lungs/corrupt/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather)
	. = ..()
	if (!. || IS_IN_MANSUS(owner) || breather.has_reagent(/datum/reagent/water/holywater) || !prob(cough_chance) || !COOLDOWN_FINISHED(src, effect_cooldown))
		return
	COOLDOWN_START(src, effect_cooldown, rand(25 SECONDS, 90 SECONDS))
	breather.emote("cough");
	var/chosen_gas = pick_weight(gas_types)
	var/datum/gas_mixture/mix_to_spawn = new()
	mix_to_spawn.add_gas(pick(chosen_gas))
	mix_to_spawn.gases[chosen_gas][MOLES] = gas_amount
	mix_to_spawn.temperature = breather.bodytemperature
	log_atmos("[owner] coughed some gas into the air due to their corrupted lungs.", mix_to_spawn)
	var/turf/open/our_turf = get_turf(breather)
	our_turf.assume_air(mix_to_spawn)

/*
/obj/item/organ/internal/lungs/corrupt/hear_breath_noise(mob/living/hearer)
	hearer.playsound_local(src, 'sound/magic/voidblink.ogg', 75, FALSE)
	if(!IS_HERETIC_OR_MONSTER(hearer))
		hearer.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/speech/slurring/heretic)
		hearer.emote("scream")
		hearer.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
		hearer.sound_damage(10, 40 SECONDS)
	return "[owner.p_Their()] lungs emit [span_hypnophrase(breath_noise)]"
 */

/// It's full of worms
/obj/item/organ/internal/appendix/corrupt
	name = "corrupt appendix"
	desc = "What kind of dark, cosmic force is even going to bother to corrupt an appendix?"
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// How likely are we to spawn worms?
	var/worm_chance = 2

/obj/item/organ/internal/appendix/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "abdomen is distended... and wiggling.", BODY_ZONE_PRECISE_GROIN)

/obj/item/organ/internal/appendix/corrupt/on_life(seconds_per_tick)
	. = ..()
	if (owner.stat != CONSCIOUS || owner.has_reagent(/datum/reagent/water/holywater) || IS_IN_MANSUS(owner) || !SPT_PROB(worm_chance, seconds_per_tick))
		return
	owner.vomit(/* MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM, */ vomit_type = VOMIT_NEBULA_WORMS, distance = 0, stun = FALSE, harm = TRUE, message = TRUE)
	owner.Knockdown(0.5 SECONDS)
