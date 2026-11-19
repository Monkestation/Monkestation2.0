// Vox organs are partially synthetic: they do not decay, but react badly to EMPs.

/obj/item/organ/internal/brain
	/// What this brain is called in MMI and brain messages ("your brain fizzles out"). Like on Yogstation.
	var/brain_name = "brain"

/obj/item/organ/internal/brain/vox
	name = "cortical stack"
	brain_name = "cortical stack"
	desc = "A peculiarly advanced bio-electronic device that seems to hold the memories and identity of a Vox."
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "cortical-stack"
	decay_factor = 0

/obj/item/organ/internal/brain/vox/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !owner)
		return
	to_chat(owner, span_warning("Your head hurts."))
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, severity == EMP_HEAVY ? 50 : 25) // Yogstation's clamp(severity * 5, 5, 50) on its 5/10 EMP scale

/obj/item/organ/internal/heart/vox
	name = "vox heart"
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "heart-vox-on"
	base_icon_state = "heart-vox"
	decay_factor = 0

/obj/item/organ/internal/liver/vox
	name = "vox liver"
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "liver-vox"
	decay_factor = 0

/obj/item/organ/internal/stomach/vox
	name = "gizzard"
	desc = "Mechanical digestion."
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "stomach-vox"
	decay_factor = 0

/obj/item/organ/internal/stomach/vox/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !owner)
		return
	owner.adjust_disgust(10)

/obj/item/organ/internal/appendix/vox
	name = "vox appendix"
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "appendix-vox"
	base_icon_state = "appendix-vox"
	decay_factor = 0

/obj/item/organ/internal/ears/vox
	name = "vox ears"
	desc = "Researchers hypothesize that the titanium reinforced tympanic membrane takes the piercing edge off their own shrieking."
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "ears-vox"
	decay_factor = 0

/obj/item/organ/internal/ears/vox/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !owner)
		return
	// Very brief, but full, deafness: 10 ticks on Yogstation. Monke's deaf counter alone only makes undamaged ears hard of hearing.
	ADD_TRAIT(owner, TRAIT_DEAF, "vox_ears_emp")
	addtimer(CALLBACK(src, PROC_REF(end_emp_deafness), owner), 20 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/organ/internal/ears/vox/proc/end_emp_deafness(mob/living/carbon/deafened)
	if(!QDELETED(deafened))
		REMOVE_TRAIT(deafened, TRAIT_DEAF, "vox_ears_emp")

/obj/item/organ/internal/ears/vox/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
	REMOVE_TRAIT(organ_owner, TRAIT_DEAF, "vox_ears_emp")

/obj/item/organ/internal/eyes/vox
	name = "vox eyes"
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "eyes-vox"
	decay_factor = 0

/obj/item/organ/internal/eyes/vox/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !owner)
		return
	owner.adjust_hallucinations(10 SECONDS)

/obj/item/organ/internal/lungs/vox
	name = "vox lungs"
	desc = "They're filled with dust... wow."
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "lungs-vox"
	decay_factor = 0
	safe_oxygen_min = 0 // We breathe nitrogen,
	safe_oxygen_max = 0.05 // and oxygen is toxic to us.
	safe_nitro_min = 16
	oxy_damage_type = TOX

/obj/item/organ/internal/lungs/vox/Initialize(mapload)
	. = ..()
	// Like Yogstation's vox breathing class: carbon dioxide counts against the nitrogen we breathe.
	add_gas_relationship(/datum/gas/carbon_dioxide, /datum/gas/nitrogen, -0.7)

/obj/item/organ/internal/lungs/vox/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !owner)
		return
	owner.emote("gasp")

/obj/item/organ/internal/tongue/vox
	name = "vox tongue"
	desc = "You almost swear you can hear it shrieking."
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "tongue-vox"
	decay_factor = 0
	taste_sensitivity = 50 // There's not much need for taste when you're a scavenger.
	modifies_speech = TRUE
	languages_native = list(/datum/language/vox)
	liked_foodtypes = MEAT | FRIED
	disliked_foodtypes = GROSS // as on Yogstation, scavengers aren't picky
	attack_verb_continuous = list("licks", "slobbers", "slaps", "frenches", "tongues", "skrees")
	attack_verb_simple = list("lick", "slobber", "slap", "french", "tongue", "skree")

/obj/item/organ/internal/tongue/vox/handle_speech(datum/source, list/speech_args)
	. = ..()
	if(owner && prob(20))
		playsound(owner, 'sound/voice/vox_species/shriek1.ogg', 25, TRUE, 1)

/obj/item/organ/internal/tongue/vox/get_scream_sound()
	return pick('sound/voice/vox_species/shriek1.ogg'/*, 'sound/voice/vox_species/ashriek.ogg'*/) // ashriek commented out, as on Yogstation
