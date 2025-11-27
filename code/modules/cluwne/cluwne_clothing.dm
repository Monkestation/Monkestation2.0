/obj/item/clothing/mask/gas/cluwne
	name = "cluwne mask"
	desc = "May the forces at be have mercy upon this wretched form."
	clothing_flags = MASKINTERNALS | GAS_FILTERING
	max_filters = 0
	icon_state = "cluwne"
	inhand_icon_state = "sexyclown_hat"
	lefthand_file = 'icons/mob/inhands/clothing/hats_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/hats_righthand.dmi'
	flags_cover = MASKCOVERSEYES
	appearance_flags = KEEP_TOGETHER
	resistance_flags = ACID_PROOF | FIRE_PROOF | INDESTRUCTIBLE | LAVA_PROOF | UNACIDABLE
	species_exception = list(/datum/species/golem/bananium)
	alternative_deathgasps = list('sound/voice/cluwne/cluwne_deathgasp1.ogg', 'sound/voice/cluwne/cluwne_deathgasp2.ogg')
	alternative_laughs = list(
		'sound/voice/cluwne/laugh/cluwne_laugh1.ogg',
		'sound/voice/cluwne/laugh/cluwne_laugh2.ogg',
		'sound/voice/cluwne/laugh/cluwne_laugh3.ogg',
		'sound/voice/cluwne/laugh/cluwne_laugh4.ogg',
		'sound/voice/cluwne/laugh/cluwne_laugh5.ogg',
		'sound/voice/cluwne/laugh/cluwne_laugh6.ogg',
	)
	alternative_screams =  list(
		'sound/voice/cluwne/scream/cluwne_scream1.ogg',
		'sound/voice/cluwne/scream/cluwne_scream2.ogg',
		'sound/voice/cluwne/scream/cluwne_scream3.ogg',
		'sound/voice/cluwne/scream/cluwne_scream4.ogg',
		'sound/voice/cluwne/scream/cluwne_scream5.ogg',
		'sound/voice/cluwne/scream/cluwne_scream6.ogg',
	)
	/// Do we delete on drop.
	var/drop_delete = TRUE
	COOLDOWN_DECLARE(spamcheck)

/obj/item/clothing/mask/gas/cluwne/Initialize(mapload)
	. = ..()
	if(drop_delete)
		AddElement(/datum/element/delete_on_drop)

/obj/item/clothing/mask/gas/cluwne/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if (slot & ITEM_SLOT_MASK)
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(user, COMSIG_MOB_SAY)

/obj/item/clothing/mask/gas/cluwne/dropped(mob/living/carbon/human/user)
	..()
	UnregisterSignal(user, COMSIG_MOB_SAY)

/obj/item/clothing/mask/gas/cluwne/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(prob(75)) //spared
		return
	var/original_message = replacetext(speech_args[SPEECH_MESSAGE], regex(@"(\s+)", "g"), " ")
	var/list/old_words = splittext(original_message, " ")
	var/list/new_words = list()
	for(var/words in old_words)
		new_words += "HONK!"
	var/new_message = new_words.Join(" ")
	new_message = capitalize(new_message)
	speech_args[SPEECH_MESSAGE] = new_message
	if(COOLDOWN_FINISHED(src, spamcheck))
		var/chuckle = pick(
			'sound/voice/cluwne/chuckle/cluwne_chuckle1.ogg',
			'sound/voice/cluwne/chuckle/cluwne_chuckle2.ogg',
			'sound/voice/cluwne/chuckle/cluwne_chuckle3.ogg',
			'sound/voice/cluwne/chuckle/cluwne_chuckle4.ogg',
	)
		playsound(src, chuckle, 35, FALSE, SHORT_RANGE_SOUND_EXTRARANGE-2, falloff_exponent = 0, ignore_walls = FALSE, use_reverb = FALSE)
		COOLDOWN_START(src, spamcheck, 3 SECONDS)

/obj/item/clothing/under/rank/civilian/clown/cluwne
	name = "cluwne suit"
	desc = "<i>'HENK!'</i>"
	icon_state = "cluwne"
	inhand_icon_state = "greenclown"
	squeak_sounds = list('sound/items/bikehorn.ogg'= 4, 'sound/misc/scary_horn.ogg' = 1)

/obj/item/clothing/under/rank/civilian/clown/cluwne/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/clothing/gloves/color/white/cluwne
	name = "clammy white gloves"
	desc = "Sticky, cold, and wet."

/obj/item/clothing/gloves/color/white/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/clothing/shoes/clown_shoes/cluwne/cursed
	desc = "The insides seem awfully wet with grease and smells of something foul. Which maniac would wear this?!"
	name = "cluwne shoes"
	icon_state = "cluwne"
	slowdown = SHOES_SLOWDOWN+1
	has_storage = FALSE
	sound_dampener = FALSE

/obj/item/clothing/shoes/clown_shoes/cluwne/cursed/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)
