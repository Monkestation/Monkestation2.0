/datum/mutation/human/acid_spit
	name = "Acid Spit"
	desc = "An ancient mutation from xenomorphs that changes the salivary glands to produce acid."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("Your saliva burns your mouth!")
	text_lose_indication = span_notice("Your saliva cools down.")
	power_path = /datum/action/cooldown/spell/pointed/projectile/acid_spit
	instability = 20
	difficulty = 12
	conflicts = list(/datum/mutation/human/acid_spit/unstable)
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/acid_spit/modify()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/pointed/projectile/acid_spit/modified_power = .
	modified_power.acid_multiplier = GET_MUTATION_POWER(src)

/datum/action/cooldown/spell/pointed/projectile/acid_spit
	name = "Acid Spit"
	desc = "You focus your corrosive saliva to spit at your target, if used on yourself you'll burn away any restraints holding you."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_neurotoxin_0"
	active_icon_state = "alien_neurotoxin_1"
	base_icon_state = "alien_neurotoxin_0"
	cooldown_time = 18 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	sound = 'monkestation/code/modules/blueshift/sounds/alien_spitacid.ogg'

	active_msg = "You focus your acid spit!"
	deactive_msg = "You relax."
	projectile_type = /obj/projectile/bullet/acid_spit
	var/acid_multiplier = 1

/datum/action/cooldown/spell/pointed/projectile/acid_spit/IsAvailable(feedback = FALSE)
	if(owner)
		var/mob/living/carbon/human = owner
		if(istype(owner) && human.is_mouth_covered())
			if(feedback)
				owner.balloon_alert(owner, "mouth blocked!")
			return FALSE

	return ..()

/datum/action/cooldown/spell/pointed/projectile/acid_spit/cast(atom/cast_on)
	. = ..()
	if(.)
		return

	var/obj/structure/closet/C = owner.loc
	if(!istype(C))
		return

	current_amount--
	C.visible_message(span_warning("[C]'s hinges suddenly begin to melt and run!"))
	to_chat(owner, span_warning("You vomit corrosive saliva onto the interior of [C]!"))
	addtimer(CALLBACK(src, PROC_REF(open_closet), owner, C), 14 SECONDS / acid_multiplier)
	unset_click_ability(owner, refund_cooldown = FALSE)
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/acid_spit/fire_projectile(atom/target)
	var/mob/living/carbon/human/human = owner
	if(!istype(human) || target != owner)
		return ..()

	if(!HAS_TRAIT(human, TRAIT_RESTRAINED) && !human.legcuffed && isopenturf(human.loc))
		return ..()

	current_amount--
	if(human.handcuffed) // The following is basically changeling's biodegrade, but twice as slow.
		var/obj/O = human.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(!istype(O))
			return FALSE
		human.visible_message(span_warning("[human] vomits a glob of corrosive saliva on [human.p_their()] [O]!"), \
			span_warning("You vomit corrosive saliva onto your [O]!"))

		addtimer(CALLBACK(src, PROC_REF(dissolve_handcuffs), human, O), 6 SECONDS / acid_multiplier)
		return TRUE

	if(human.legcuffed)
		var/obj/O = human.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(!istype(O))
			return FALSE
		human.visible_message(span_warning("[human] vomits a glob of corrosive saliva on [human.p_their()] [O]!"), \
			span_warning("You vomit corrosive saliva onto your [O]!"))

		addtimer(CALLBACK(src, PROC_REF(dissolve_legcuffs), human, O), 6 SECONDS / acid_multiplier)
		return TRUE

	if(human.wear_suit && human.wear_suit.breakouttime)
		var/obj/item/clothing/suit/S = human.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(!istype(S))
			return FALSE
		human.visible_message(span_warning("[human] vomits a glob of corrosive saliva across the front of [human.p_their()] [S]!"), \
			span_warning("You vomit corrosive saliva onto your straight jacket!"))
		addtimer(CALLBACK(src, PROC_REF(dissolve_straightjacket), human, S), 6 SECONDS / acid_multiplier)
		return TRUE

	current_amount++
	return ..()

/datum/action/cooldown/spell/pointed/projectile/acid_spit/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/O)
	if(O && user.handcuffed == O)
		user.visible_message(span_warning("[O] dissolve[O.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(O.drop_location())
		qdel(O)

/datum/action/cooldown/spell/pointed/projectile/acid_spit/proc/dissolve_legcuffs(mob/living/carbon/human/user, obj/O)
	if(O && user.legcuffed == O)
		user.visible_message(span_warning("[O] dissolve[O.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(O.drop_location())
		qdel(O)

/datum/action/cooldown/spell/pointed/projectile/acid_spit/proc/dissolve_straightjacket(mob/living/carbon/human/user, obj/S)
	if(S && user.wear_suit == S)
		user.visible_message(span_warning("[S] dissolves into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(S.drop_location())
		qdel(S)

/datum/action/cooldown/spell/pointed/projectile/acid_spit/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/C)
	if(C && user.loc == C)
		C.visible_message(span_warning("[C]'s door breaks and opens!"))
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		to_chat(user, span_warning("You open the container restraining you!"))

/obj/projectile/bullet/acid_spit
	name = "acid spit"
	icon_state = "neurotoxin"
	damage = 2
	damage_type = BURN
	armor_flag = BIO
	range = 7
	speed = 1.8 // spit is not very fast
	var/multiplier = 1

/obj/projectile/bullet/acid_spit/preparePixelProjectile(atom/target, atom/source, list/modifiers = null, deviation = 0)
	if(fired_from)
		var/datum/action/cooldown/spell/pointed/projectile/acid_spit/ability = fired_from
		if(istype(ability))
			multiplier = ability.acid_multiplier

	return ..()

/obj/projectile/bullet/acid_spit/on_hit(atom/target, blocked = FALSE, pierce_hit)
	if(isalien(target)) // shouldn't work on xenos
		damage = 0
		return ..()

	if(isturf(target))
		target.acid_act(50 * multiplier, 15) // does good damage to objects and structures

	else if(iscarbon(target))
		target.acid_act(18 * multiplier, 15) // balanced

	return ..()

/datum/mutation/human/acid_spit/unstable
	name = "Unstable Acid Spit"
	desc = "An ancient mutation from xenomorphs that changes the salivary glands to produce acid, this is a highly unstable strain."
	instability = 70
	conflicts = list(/datum/mutation/human/acid_spit)
