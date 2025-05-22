/mob/living/carbon/human/register_init_signals()
	. = ..()

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_HEAVY_BLEEDER), PROC_REF(on_gain_heavy_bleeder_trait))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HEAVY_BLEEDER), PROC_REF(on_lose_heavy_bleeder_trait))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNKNOWN), SIGNAL_REMOVETRAIT(TRAIT_UNKNOWN)), PROC_REF(on_unknown_trait))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_DWARF), SIGNAL_REMOVETRAIT(TRAIT_DWARF)), PROC_REF(on_dwarf_trait))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_GIANT)), PROC_REF(on_gain_giant_trait))
	RegisterSignals(src, list(SIGNAL_REMOVETRAIT(TRAIT_GIANT)), PROC_REF(on_lose_giant_trait))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_NOHUNGER), SIGNAL_REMOVETRAIT(TRAIT_NOHUNGER)), PROC_REF(on_nohunger))

/// Gaining [TRAIT_HEAVY_BLEEDER] doubles our bleed_mod.
/mob/living/carbon/human/proc/on_gain_heavy_bleeder_trait(datum/source)
	SIGNAL_HANDLER
	physiology?.bleed_mod *= 2

/// Losing [TRAIT_HEAVY_BLEEDER] halves our bleed_mod.
/mob/living/carbon/human/proc/on_lose_heavy_bleeder_trait(datum/source)
	SIGNAL_HANDLER
	physiology?.bleed_mod /= 2

/// Gaining or losing [TRAIT_UNKNOWN] updates our name and our sechud
/mob/living/carbon/human/proc/on_unknown_trait(datum/source)
	SIGNAL_HANDLER

	name = get_visible_name()
	sec_hud_set_ID()

/// Gaining or losing [TRAIT_DWARF] updates our height
/mob/living/carbon/human/proc/on_dwarf_trait(datum/source)
	SIGNAL_HANDLER

	update_mob_height()
/* //Non-Modular change - Remove passtable from dwarves.
	if(HAS_TRAIT(src, TRAIT_DWARF))
		passtable_on(src, TRAIT_DWARF)
	else
		passtable_off(src, TRAIT_DWARF)
*/

/mob/living/carbon/human/proc/on_gain_giant_trait(datum/source)
	SIGNAL_HANDLER

	src.update_transform(1.25)
	src.visible_message(span_danger("[src] suddenly grows!"), span_notice("Everything around you seems to shrink.."))

/mob/living/carbon/human/proc/on_lose_giant_trait(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_GIANT)) //They have the trait through another source, cancel out.
		return
	src.update_transform(0.8)
	src.visible_message(span_danger("[src] suddenly shrinks!"), span_notice("Everything around you seems to grow.."))

/mob/living/carbon/human/proc/on_fat(datum/source)
	SIGNAL_HANDLER
	hud_used?.hunger?.update_hunger_bar()
	mob_mood?.update_nutrition_moodlets()

	if(HAS_TRAIT(src, TRAIT_FAT))
		add_movespeed_modifier(/datum/movespeed_modifier/obesity)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/obesity)

/mob/living/carbon/human/proc/on_nohunger(datum/source)
	SIGNAL_HANDLER
	// When gaining NOHUNGER, we restore nutrition to normal levels, since we no longer interact with the hunger system
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		set_nutrition(NUTRITION_LEVEL_FED, forced = TRUE)
		satiety = 0
		overeatduration = 0
		REMOVE_TRAIT(src, TRAIT_FAT, OBESITY)
	else
		hud_used?.hunger?.update_hunger_bar()
		mob_mood?.update_nutrition_moodlets()
