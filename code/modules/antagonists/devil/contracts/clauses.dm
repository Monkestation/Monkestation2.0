/datum/devil_clause
	/// Name of the clause
	var/name = "Suicide"
	/// The prefix this clause gets in the contract "[prefix]: [name]"
	var/prefix = "Commit"
	/// What does this clause do
	var/desc = "Literally kills you."
	/// How much does it cost? (good clause = positive number)
	var/cost = 0
	/// The clauses this clause conflicts with, making them unable to be picked together
	var/list/conflicts = list()
	/// If this clause should be given into contracts by default
	var/default_clause = FALSE
	/// Reference to the devil datum we reside in
	// i want to make this static so bad, but then no more multi-devil rounds
	var/datum/antagonist/devil/devil = null

/datum/devil_clause/New(datum/antagonist/devil/devil_datum = null)
	. = ..()
	if(devil_datum)
		devil = devil_datum
		devil.clauses += src
		if(default_clause)
			devil.default_clauses += src

/datum/devil_clause/Destroy(force)
	if(devil)
		devil.clauses -= src
		if(default_clause)
			devil.default_clauses -= src
		devil = null
	return ..()

/// The proc that gets called when the contract is signed, should apply all the effects
/// It can also be called when the victim switches bodies, then first_apply will be false
/datum/devil_clause/proc/apply(mob/living/victim, first_apply = TRUE)
	victim.death()

/// The proc that gets called when the devil antag datum gets deleted, or before apply() when a victim switches bodies
/datum/devil_clause/proc/remove(mob/living/victim)
	return

/datum/devil_clause/trait_giver // A suprising amount of clauses are just traits
	/// A trait or a list of traits we give to the victim
	var/trait = null

/datum/devil_clause/trait_giver/apply(mob/living/victim, first_apply = TRUE)
	if(islist(trait))
		victim.add_traits(trait, DEVIL_TRAIT)
	else
		ADD_TRAIT(victim, trait, DEVIL_TRAIT)

/datum/devil_clause/trait_giver/remove(mob/living/victim)
	if(islist(trait))
		victim.remove_traits(trait, DEVIL_TRAIT)
	else
		REMOVE_TRAIT(victim, trait, DEVIL_TRAIT)

/datum/devil_clause/ability_giver
	/// The typepath to our ability
	var/datum/action/cooldown/spell/devil/ability = null

/datum/devil_clause/ability_giver/apply(mob/living/victim, first_apply = TRUE)
	if(first_apply)
		var/datum/action/cooldown/spell/devil/granted_ability = new ability(victim.mind)
		granted_ability.Grant(victim)
		. = granted_ability // in case the clause wants it

/datum/devil_clause/ability_giver/remove(mob/living/victim)
	if(victim.mind) // Could be they are transferring minds, in that case this will be null
		var/datum/action/cooldown/spell/devil/spell = locate(ability) in victim.actions
		if(spell)
			qdel(spell)

/datum/devil_clause/ability_giver/immortality
	name = "Immortality"
	prefix = "Obtain"
	desc = "So long as the signers vessel remains intact they will be able to resurrect after death."
	cost = 27
	conflicts = list(/datum/devil_clause/ability_giver/revival, /datum/devil_clause/time)
	ability = /datum/action/cooldown/spell/devil/revival

/datum/devil_clause/resistance
	name = "Resistance"
	prefix = "Gain"
	desc = "Cuts down the damage the signer takes by half, however they shall become weaker to holy magicks."
	cost = 7

/datum/devil_clause/resistance/apply(mob/living/victim, first_apply = TRUE)
	RegisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(affect_resistances))

/datum/devil_clause/resistance/remove(mob/living/victim)
	UnregisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)

/datum/devil_clause/resistance/proc/affect_resistances(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER
	if(istype(attacking_item, /obj/item/nullrod))
		damage_mods += 2
		return
	damage_mods += 0.5

/datum/devil_clause/trait_giver/no_crit
	name = "Fear of Death"
	prefix = "Get rid of the"
	desc = "The signer shall be able to walk and act under normally mortal wounds, until the body can no longer physically take it."
	cost = 5
	trait = list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT)

/datum/devil_clause/ability_giver/revival
	name = "Revival"
	prefix = "Obtain"
	desc = "Makes the signer able to revive themselfes exactly one time."
	cost = 5
	conflicts = list(/datum/devil_clause/ability_giver/immortality, /datum/devil_clause/time)
	default_clause = TRUE
	ability = /datum/action/cooldown/spell/devil/revival

/datum/devil_clause/ability_giver/revival/apply(mob/living/victim, first_apply = TRUE)
	. = ..()
	if(first_apply && .)
		var/datum/action/cooldown/spell/devil/revival/revival = .
		revival.one_time = TRUE

/datum/devil_clause/ability_giver/invisibility
	name = "Invisibility"
	prefix = "Obtain"
	desc = "Makes the signer able to turn mostly invisible at any time they may desire."
	cost = 5
	ability = /datum/action/cooldown/spell/devil/invisibility

/datum/devil_clause/trait_giver/no_fire
	name = "Fear of Fire"
	prefix = "Get rid of the"
	desc = "The signer shall never be set on fire again."
	cost = 4
	trait = TRAIT_NOFIRE

/datum/devil_clause/random
	name = "Chance"
	prefix = "Embrace"
	desc = "The signer shall get a completelly random clause, be it good or evil."
	cost = 4

/datum/devil_clause/random/apply(mob/living/carbon/human/victim, first_apply = TRUE)
	if(first_apply)
		var/list/available_clauses = devil.clauses.Copy() - devil.contracted[victim.mind]
		if(!length(available_clauses)) // You only played yourself, really
			return
		var/datum/devil_clause/picked_clause = pick(available_clauses)
		devil.contracted[victim.mind] += picked_clause
		picked_clause.apply(victim, TRUE)

/datum/devil_clause/trait_giver/flash
	name = "Fear of Light"
	prefix = "Get rid of the"
	desc = "The signer shall never be flashed by flashing devices again." // need to specify, FLASHING. DEVICES.
	cost = 3
	trait = TRAIT_NOFLASH

/datum/devil_clause/trait_giver/no_shock
	name = "Fear of Electricity"
	prefix = "Get rid of the"
	desc = "The signer shall never be shocked by electricity again."
	cost = 3
	trait = TRAIT_SHOCKIMMUNE

/datum/devil_clause/trait_giver/no_food
	name = "Gluttony"
	prefix = "Embrace"
	desc = "The signer shall never need to eat again."
	cost = 2
	trait = TRAIT_NOHUNGER

/datum/devil_clause/trait_giver/no_breath
	name = "Fear of Drowning"
	prefix = "Get rid of the"
	desc = "The signer shall never need to breathe air again."
	cost = 2
	trait = TRAIT_NOBREATH

/datum/devil_clause/trait_giver/no_slip
	name = "Fear of Clowns"
	prefix = "Get rid of the"
	desc = "The signer shall never be slipped again."
	cost = 2
	trait = TRAIT_NO_SLIP_ALL

/datum/devil_clause/trait_giver/pressure
	name = "Fear of Crushing"
	prefix = "Get rid of the"
	desc = "The signer shall not be crushed by any pressure anymore."
	cost = 2
	trait = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE)

/datum/devil_clause/trait_giver/freeze
	name = "Fear of Freezing"
	prefix = "Get rid of the"
	desc = "The signer shall not be affected by low temperatures anymore."
	cost = 2
	trait = TRAIT_RESISTCOLD

/datum/devil_clause/greed
	name = "Greed"
	prefix = "Embrace"
	desc = "The signer shall receive a sizable amount of funds."
	cost = 2

/datum/devil_clause/handy/apply(mob/living/carbon/human/victim, first_apply = TRUE)
	if(first_apply)
		var/obj/item/stack/spacecash/c10000/cash = new(victim.loc)
		cash.add(4)
		victim.put_in_hands(cash)

/datum/devil_clause/trait_giver/no_pain
	name = "Pain"
	prefix = "Resist"
	desc = "The signer shall feel no pain nor move slower from being near death."
	cost = 1
	trait = list(TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_NO_PAIN_EFFECTS, TRAIT_NO_SHOCK_BUILDUP)

/datum/devil_clause/trait_giver/clumsy
	name = "Clumsy"
	prefix = "Become"
	desc = "The signer shall become clumsy and make mistakes."
	cost = -2
	trait = TRAIT_CLUMSY

/datum/devil_clause/trait_giver/mute
	name = "Voice"
	prefix = "Lose your"
	desc = "The signer won't be able to utter a word."
	cost = -4
	trait = TRAIT_MUTE

/datum/devil_clause/handy
	name = "Hand"
	prefix = "Lose your"
	desc = "The signers hand will be donated to the devil orphanage."
	cost = -4
	var/list/zones_to_target = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/devil_clause/handy/apply(mob/living/carbon/victim, first_apply = TRUE)
	if(!istype(victim))
		return
	for(var/zone as anything in zones_to_target)
		var/obj/item/bodypart/arm = victim.get_bodypart(zone)
		if(!arm)
			continue
		arm.dismember()
		victim.visible_message(span_danger("<B>[victim]'s [arm] is violently dismembered as it burns to ash!</B>"))
		new /obj/effect/decal/cleanable/ash(arm.loc)
		QDEL_IN(arm, 1 SECONDS)
		break

/datum/devil_clause/handy/leggy
	name = "Leg"
	desc = "The signers leg will be donated to the devil leg foundation."
	zones_to_target = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/devil_clause/trait_giver/soul
	name = "Soul"
	prefix = "Lose your"
	desc = "Gives the signers soul to the contractor."
	cost = -5
	default_clause = TRUE
	trait = list(TRAIT_DEFIB_BLACKLISTED, TRAIT_BADDNA, TRAIT_NO_SOUL)

/datum/devil_clause/trait_giver/soul/apply(mob/living/victim, first_apply = TRUE)
	. = ..()
	if(first_apply)
		var/datum/objective/collect_souls/soul_objective = locate(/datum/objective/collect_souls) in devil.objectives
		if(soul_objective)
			soul_objective.collected_souls++
			soul_objective.check_completion()

/datum/devil_clause/weakness
	name = "Weakness"
	prefix = "Embrace"
	desc = "The signer shall take double damage from any source."
	cost = -6

/datum/devil_clause/weakness/apply(mob/living/victim, first_apply = TRUE)
	RegisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(affect_resistances))

/datum/devil_clause/weakness/remove(mob/living/victim)
	UnregisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)

/datum/devil_clause/weakness/proc/affect_resistances(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER
	damage_mods += 2

/datum/devil_clause/organ
	name = "Organ"
	prefix = "Lose an"
	desc = "The signer shall have one of their organs taken, with the exception of the brain."
	cost = -6

/datum/devil_clause/weakness/apply(mob/living/carbon/victim, first_apply = TRUE)
	if(!istype(victim))
		return
	var/list/organs = victim.organs.Copy()
	var/organ_count = length(organs)
	if(!organ_count)
		return
	var/obj/item/organ/picked_organ = pick(organs)
	// Yeah the safety can't help you if the brain is your ONLY organ. That's on you
	if(organ_count > 1 && istype(picked_organ, /obj/item/organ/internal/brain))
		organs -= picked_organ
		picked_organ = pick(organs)
	qdel(picked_organ)

/datum/devil_clause/greater_leggy
	name = "Paralyzed legs"
	prefix = "Suffer"
	desc = "The signer shall have their legs permanently paralyzed."
	cost = -8

/datum/brain_trauma/severe/paralysis/paraplegic/devil // Just to prevent any tomfoolery
	name = "Strange Paralysis"
	desc = "Patient's brain can no longer control part of its motor functions due to outside influence."
	scan_desc = "strange cerebral paralysis"

/datum/movespeed_modifier/devils_wheelchair
	multiplicative_slowdown = CRAWLING_ADD_SLOWDOWN
	movetypes = GROUND

/datum/devil_clause/greater_leggy/apply(mob/living/carbon/victim, first_apply = TRUE)
	if(!istype(victim))
		victim.add_movespeed_modifier(/datum/movespeed_modifier/devils_wheelchair)
		if(first_apply)
			var/obj/vehicle/ridden/wheelchair/ride = new(victim.drop_location())
			ride.buckle_mob(victim)
			ride.visible_message(span_warning("A stylish wheelchair appears from under the floor catching [victim] as their (legs?) wither!"))
		return

	if(!victim.has_trauma_type(/datum/brain_trauma/severe/paralysis/paraplegic))
		if(first_apply)
			var/obj/vehicle/ridden/wheelchair/ride = new(victim.drop_location())
			ride.buckle_mob(victim)
			ride.visible_message(span_warning("A stylish wheelchair appears from under the floor catching [victim] as their legs give out!"))
		victim.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic/devil)
		return

	// Already wasn't using your legs? Don't worry, we'll take them as payment then
	for(var/zone as anything in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/leggy = victim.get_bodypart(zone)
		if(!leggy)
			continue
		leggy.dismember()
		victim.visible_message(span_danger("<B>[victim]'s [leggy] is violently dismembered as it burns to ash!</B>"))
		new /obj/effect/decal/cleanable/ash(leggy.loc)
		QDEL_IN(leggy, 1 SECONDS)

/datum/devil_clause/greater_leggy/remove(mob/living/carbon/victim)
	if(istype(victim))
		victim.cure_trauma_type(/datum/brain_trauma/severe/paralysis/paraplegic/devil, TRAUMA_RESILIENCE_ABSOLUTE)
	else
		victim.remove_movespeed_modifier(/datum/movespeed_modifier/devils_wheelchair)

/datum/devil_clause/blind
	name = "Blindness"
	prefix = "Suffer"
	desc = "The signer shall become blind to the world around them, and just in general to everything."
	cost = -12

/datum/devil_clause/blind/apply(mob/living/victim, first_apply = TRUE)
	victim.become_blind(DEVIL_TRAIT)

/datum/devil_clause/blind/remove(mob/living/victim)
	victim.cure_blind(DEVIL_TRAIT)

/datum/devil_clause/trait_giver/mute
	name = "Will to fight"
	prefix = "Lose your"
	desc = "The signer won't be able hurt anyone anymore."
	cost = -12
	trait = TRAIT_PACIFISM

/datum/devil_clause/frog
	name = "Humanity"
	prefix = "Give up your"
	desc = "The signer will discard their humanity, turning into a frog, permanently."
	cost = -16

/datum/devil_clause/frog/apply(mob/living/basic/frog/victim, first_apply = TRUE)
	if(istype(victim)) // Make sure we don't do an infinite loop of creating frogs, transferring into them and refreshing yeah?
		if(first_apply)
			victim.name = "evil frog"
			victim.desc = "They seem a little evil."
			victim.butcher_results = list(/obj/item/food/tofu/prison = 5)
			victim.melee_damage_lower = 1 // Jokes aside, we need to actually not make this free for frogs now.
			victim.melee_damage_upper = 1
			victim.obj_damage = 2
			victim.melee_attack_cooldown = floor(initial(victim.melee_attack_cooldown) * 0.5)
		return
	var/mob/living/basic/frog/frogger = new(victim.loc) // Notice how first_apply isn't used? Get the implication?
	victim.mind.transfer_to(frogger)
	qdel(victim)

/datum/devil_clause/time
	name = "Time"
	prefix = "Give up your"
	desc = "The signer will become dust after five minutes."
	cost = -30
	conflicts = list(/datum/devil_clause/ability_giver/immortality, /datum/devil_clause/ability_giver/revival)

/datum/devil_clause/time/apply(mob/living/basic/frog/victim, first_apply = TRUE)
	if(first_apply)
		addtimer(CALLBACK(src, PROC_REF(become_dust), victim.mind), 5 MINUTES, TIMER_DELETE_ME)

/datum/devil_clause/time/proc/become_dust(datum/mind/mind)
	SIGNAL_HANDLER
	if(QDELETED(mind))
		return
	mind.current?.dust()
