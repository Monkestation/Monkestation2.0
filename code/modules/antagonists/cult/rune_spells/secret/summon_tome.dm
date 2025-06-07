
/datum/rune_spell/summontome
	secret=TRUE
	name="Summon Tome"
	desc="Bring forth an arcane tome filled with Nar-Sie's knowledge."
	desc_talisman="Turns into an arcane tome upon use."
	invocation="N'ath reth sh'yro eth d'raggathnor!"
	word1=/datum/rune_word/see
	word2=/datum/rune_word/blood
	word3=/datum/rune_word/hell
	cost_invoke=4
	page=""

/datum/rune_spell/summontome/cast()
	var/obj/effect/new_rune/R=spell_holder
	R.one_pulse()

	if (pay_blood())
		var/datum/antagonist/cult/cult_datum=activator.mind.has_antag_datum(/datum/antagonist/cult)
		cult_datum.gain_devotion(10, DEVOTION_TIER_0, "conjure_paraphernalia", "Arcane Tome")
		spell_holder.visible_message(span_rose("The rune's symbols merge into each others, and an Arcane Tome takes form in their place"))
		var/turf/T=get_turf(spell_holder)
		var/obj/item/tome/AT=new (T)
		anim(target=AT, a_icon='monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim="tome_spawn")
		qdel(spell_holder)
	else
		qdel(src)

/datum/rune_spell/summontome/cast_talisman()//The talisman simply turns into a tome.
	var/turf/T=get_turf(spell_holder)
	var/obj/item/tome/AT=new (T)
	if (spell_holder == activator.get_active_held_item())
		activator.dropItemToGround(spell_holder, T)
		activator.put_in_active_hand(AT)
		var/datum/antagonist/cult/cult_datum=activator.mind.has_antag_datum(/datum/antagonist/cult)
		cult_datum.gain_devotion(10, DEVOTION_TIER_0, "conjure_paraphernalia", "Arcane Tome")
	else//are we using the talisman from a tome?
		activator.put_in_hands(AT)
	flick("tome_spawn", AT)
	qdel(src)
