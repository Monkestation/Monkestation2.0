/datum/rune_spell/summon_plushie
	secret = TRUE
	name = "Manifest Nar'sie Plushie"
	desc = "Manifest's Nar'sie in plushie form, helps prepare yourself for the ritual."
	desc_talisman = "Summons Nar'sie in plushie form, helps prepare yourself for the ritual."
	invocation = "Sa Tatha Plu'Shi"
	word1 = /datum/rune_word/see
	word2 = /datum/rune_word/self
	word3 = /datum/rune_word/hide
	talisman_uses = 1
	page = "This rune, summons a plushie of your god."
	var/casting = FALSE

/datum/rune_spell/summon_plushie/cast()
	if(casting)
		return
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	spell_holder.overlays += image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "build")
	casting = TRUE
	sleep(3 SECONDS)
	var/obj/item/toy/plush/narplush/plush = new /obj/item/toy/plush/narplush(get_turf(R))
	plush.alpha = 0
	plush.anchored = TRUE
	animate(plush, alpha = 255, 1.4 SECONDS)
	sleep(1.5 SECONDS)
	plush.anchored = FALSE
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "build")
	qdel(R)
