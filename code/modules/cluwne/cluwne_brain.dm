//--------------------------
// Cluwne's Fucked Up Brain
//--------------------------
/obj/item/organ/internal/brain/cluwne
	name = "bananium encrusted mass"
	desc = "A chunk of bananium covering an unknown mass underneath. Smells faintly of bananas and oozes a foul smelling green liquid."
	icon_state = "brain_cluwne"
	organ_traits = list(TRAIT_ILLITERATE, TRAIT_CHUNKYFINGERS, TRAIT_DUMB, TRAIT_CLUMSY, TRAIT_DISFIGURED, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_NO_TRANSFORMATION_STING, TRAIT_NO_MINDSWAP, TRAIT_EASILY_WOUNDED)
	var/datum/component/omen/misfortune

/obj/item/organ/internal/brain/cluwne/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 40)
	gain_trauma(/datum/brain_trauma/special/banana_tumor, TRAUMA_RESILIENCE_ABSOLUTE)

/obj/item/organ/internal/brain/cluwne/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	misfortune = organ_owner.AddComponent(/datum/component/omen)

/obj/item/organ/internal/brain/cluwne/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	cure_trauma_type(/datum/brain_trauma/special/banana_tumor, TRAUMA_RESILIENCE_ABSOLUTE)
	QDEL_NULL(misfortune)

//---------------------------------
// Cluwne's Fucked Up Brain Trauma
//---------------------------------
/datum/brain_trauma/special/banana_tumor
	name = "Banana Brain Tumors"
	desc = "Patient has several bananas stuck in their brain causing unnatural movement and impulses."
	scan_desc = "banana brain tumors"
	gain_text = span_notice("You feel several spikes of pain inside your head digging in deep...")
	lose_text = span_warning("The spikes of pain leave your head and your mind clears.")
	can_gain = TRUE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	trauma_flags = TRAUMA_NOT_RANDOM | TRAUMA_SPECIAL_CURE_PROOF

/datum/brain_trauma/special/banana_tumor/on_life(seconds_per_tick, times_fired)
	..()
	if(prob(75))
		return
	if((owner.IsStun() || owner.IsParalyzed() || owner.IsUnconscious()))
		return
	var/emote_to_do = (pick_weight(list("laugh" = 40, "scream" = 15, "chuckle" = 15, "screech" = 15, "twitch" = 30)))

	owner.emote(emote_to_do)

	if(prob(10))
		honkerblast(owner, light_range = 5, medium_range = 3, heavy_range = 0)
