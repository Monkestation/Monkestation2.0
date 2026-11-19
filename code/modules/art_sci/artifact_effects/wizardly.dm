/datum/artifact_effect/wizardly
	examine_hint = "Radiates a magical aura."
	examine_discovered = "Bestows Magic."
	weight = ARTIFACT_RARE //Suprisingly still rare, as requires a touch-wizard artifact.
	research_value = TECHWEB_TIER_6_POINTS //Its fucking MAGIC
	discovered_credits = CARGO_CRATE_VALUE*10//YOU SOLD A FUCKING WIZARD BOOK?
	type_name = "Wizardly Tome"
	super_secret = TRUE
	valid_activators = list(/datum/artifact_activator/touch/carbon)
	valid_origins = list(/datum/artifact_origin/wizard)
	/// What can this artifact grant when touched [and thus activated]
	var/valid_grants = list(/datum/action/cooldown/spell/basic_heal,
	/datum/action/cooldown/spell/pointed/projectile/fireball,
	/datum/action/cooldown/spell/summonitem,
	/datum/action/cooldown/spell/conjure_item/spellpacket,
	/datum/action/cooldown/spell/forcewall,
	/datum/action/cooldown/spell/conjure/bee,
	/datum/action/cooldown/spell/smoke/lesser,
	/datum/action/cooldown/spell/conjure/cheese)

/datum/artifact_effect/wizardly/effect_touched(mob/living/user)
	var/spell = pick(valid_grants)
	var/datum/action/cooldown/spell/boi = new spell(user)
	if(boi)
		if(boi.spell_requirements & SPELL_REQUIRES_WIZARD_GARB)
			boi.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB
		boi.Grant(user)
	our_artifact?.holder?.visible_message(span_boldnotice("[src.our_artifact.holder] vanishes in a wizardly fashion!"))
	qdel(our_artifact?.holder)
