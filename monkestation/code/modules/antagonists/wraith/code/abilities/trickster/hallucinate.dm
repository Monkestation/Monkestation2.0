/datum/action/cooldown/spell/pointed/wraith/hallucinate
	name = "Hallucinate"
	desc = "Send whomever you target into a spiral of hallucinations."
	button_icon_state = "hallucinate"

	essence_cost = 30
	cooldown_time = 45 SECONDS

	antimagic_flags = MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND

/datum/action/cooldown/spell/pointed/wraith/hallucinate/before_cast(mob/living/cast_on)
	. = ..()
	if(!istype(cast_on))
		return . | SPELL_CANCEL_CAST

	if(!cast_on.mind)
		to_chat(owner, span_revennotice("Giving them hallucinations would be a waste, their mind couldn't comprehend it."))
		return . | SPELL_CANCEL_CAST

	if(cast_on.mob_biotypes & NO_HALLUCINATION_BIOTYPES)
		to_chat(owner, span_revennotice("[cast_on] seems to resists our influence."))
		return . | SPELL_CANCEL_CAST

	if(HAS_TRAIT(cast_on, TRAIT_MADNESS_IMMUNE) || (HAS_TRAIT(cast_on.mind, TRAIT_MADNESS_IMMUNE)))
		to_chat(owner, span_revennotice("[cast_on] seems to resists our influence."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/hallucinate/cast(mob/living/cast_on)
	. = ..()
	cast_on.adjust_hallucinations_up_to(cooldown_time * 2, cooldown_time * 4)
