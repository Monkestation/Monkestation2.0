/mob/living/register_init_signals()
	. = ..()

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_VIRUS_SCANNER), PROC_REF(on_virus_scanner_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_VIRUS_SCANNER), PROC_REF(on_virus_scanner_trait_loss))

/mob/living/proc/on_virus_scanner_trait_gain(datum/source)
	SIGNAL_HANDLER
	AddElement(/datum/element/virus_viewer)

/mob/living/proc/on_virus_scanner_trait_loss(datum/source)
	SIGNAL_HANDLER
	RemoveElement(/datum/element/virus_viewer)
