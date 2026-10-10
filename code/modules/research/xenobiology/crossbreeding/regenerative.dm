/*
Regenerative extracts:
	Work like a legion regenerative core.
	Has a unique additional effect.
*/
/obj/item/slimecross/regenerative
	name = "regenerative extract"
	desc = "It's filled with a milky substance, and pulses like a heartbeat."
	effect = "regenerative"
	icon_state = "regenerative"

/obj/item/slimecross/regenerative/proc/core_effect(mob/living/carbon/human/target, mob/user)
	return
/obj/item/slimecross/regenerative/proc/core_effect_before(mob/living/carbon/human/target, mob/user)
	return

/// Returns the typepath to the status effect that should be applied to the target when this extract is used on them.
/obj/item/slimecross/regenerative/proc/get_status_path()
	var/color_path = text2path("/datum/status_effect/regenerative_extract/[colour]")
	if(ispath(color_path, /datum/status_effect/regenerative_extract))
		return color_path
	return /datum/status_effect/regenerative_extract

/// Whether the target can take this extract. Tells the user why not.
/obj/item/slimecross/regenerative/proc/can_use(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		to_chat(user, span_warning("[src] will not work on the dead!"))
		return FALSE
	if(target.has_status_effect(/datum/status_effect/regenerative_extract))
		to_chat(user, span_warning("[target == user ? "You are" : "[target] is"] already being healed by a regenerative extract!"))
		return FALSE
	return TRUE

/obj/item/slimecross/regenerative/interact_with_atom(mob/living/target, mob/living/user, list/modifiers)
	if(!isliving(target))
		return NONE
	if(!can_use(target, user))
		return ITEM_INTERACT_BLOCKING
	if(target != user)
		user.visible_message(span_notice("[user] crushes [src] over [target], the milky goo coating [target.p_their()] injuries!"),
			span_notice("You squeeze [src], and it bursts over [target], the milky goo beginning to regenerate [target.p_their()] injuries."))
	else
		user.visible_message(span_notice("[user] crushes [src] over [user.p_them()]self, the milky goo quickly regenerating all of [user.p_their()] injuries!"),
			span_notice("You squeeze [src], and it bursts in your hand, splashing you with milky goo which quickly regenerates your injuries!"))
	core_effect_before(target, user)
	apply_effect(target)
	core_effect(target, user)
	playsound(target, 'sound/effects/splat.ogg', vol = 40, vary = TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Gives the target this extract's regenerative status effect.
/obj/item/slimecross/regenerative/proc/apply_effect(mob/living/target)
	target.apply_status_effect(get_status_path(), color)

/obj/item/slimecross/regenerative/grey
	colour = "grey" //Has no bonus effect.
	effect_desc = "Rapidly heals the target and does nothing else."

/obj/item/slimecross/regenerative/orange
	colour = "orange"

/obj/item/slimecross/regenerative/orange/core_effect_before(mob/living/target, mob/user)
	target.visible_message(span_warning("\The [src] boils over!"))
	for(var/turf/targetturf in RANGE_TURFS(1,target))
		if(!locate(/obj/effect/hotspot) in targetturf)
			new /obj/effect/hotspot(targetturf)

/obj/item/slimecross/regenerative/purple
	colour = "purple"
	effect_desc = "Rapidly heals the target, and injects them with some regenerative jelly afterwards. Prevents softcrit while active."

/obj/item/slimecross/regenerative/blue
	colour = "blue"
	effect_desc = "Rapidly heals the target and makes the floor wet."

/obj/item/slimecross/regenerative/blue/core_effect(mob/living/target, mob/user)
	if(isturf(target.loc))
		var/turf/open/T = get_turf(target)
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)
		target.visible_message(span_warning("The milky goo in the extract gets all over the floor!"))

/obj/item/slimecross/regenerative/metal
	colour = "metal"
	effect_desc = "Rapidly heals the target and encases the target in a locker."

/obj/item/slimecross/regenerative/metal/core_effect(mob/living/target, mob/user)
	target.visible_message(span_warning("The milky goo hardens and reshapes itself, encasing [target]!"))
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Looking closer, it seems to be made of a sort of solid, opaque, metal-like goo."
	target.forceMove(C)

/obj/item/slimecross/regenerative/yellow
	colour = "yellow"
	effect_desc = "Rapidly heals the target and fully recharges a single item on the target. Provides shock immunity while active."

/obj/item/slimecross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	var/list/batteries = list()
	for(var/obj/item/stock_parts/power_store/cell/C in target.get_all_contents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/power_store/cell/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, span_notice("You feel a strange electrical pulse, and one of your electrical items was recharged."))

/obj/item/slimecross/regenerative/darkpurple
	colour = "dark purple"
	effect_desc = "Rapidly heals the target and gives them purple clothing if they are naked."

/obj/item/slimecross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	var/equipped = 0
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/purple(null), ITEM_SLOT_FEET)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(null), ITEM_SLOT_ICLOTHING)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(null), ITEM_SLOT_GLOVES)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple(null), ITEM_SLOT_HEAD)
	if(equipped > 0)
		target.visible_message(span_notice("The milky goo congeals into clothing!"))

/obj/item/slimecross/regenerative/darkblue
	colour = "dark blue"
	effect_desc = "Rapidly heals the target and fireproofs their clothes."

/obj/item/slimecross/regenerative/darkblue/core_effect(mob/living/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/fireproofed = FALSE
	if(H.get_item_by_slot(ITEM_SLOT_OCLOTHING))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		fireproof(C)
	if(H.get_item_by_slot(ITEM_SLOT_HEAD))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_HEAD)
		fireproof(C)
	if(fireproofed)
		target.visible_message(span_notice("Some of [target]'s clothing gets coated in the goo, and turns blue!"))

/obj/item/slimecross/regenerative/darkblue/proc/fireproof(obj/item/clothing/clothing_piece)
	clothing_piece.name = "fireproofed [clothing_piece.name]"
	clothing_piece.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	clothing_piece.add_atom_colour(color_transition_filter(COLOR_NAVY, SATURATION_OVERRIDE), FIXED_COLOUR_PRIORITY)
	clothing_piece.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	clothing_piece.resistance_flags |= FIRE_PROOF

/obj/item/slimecross/regenerative/silver
	colour = "silver"
	effect_desc = "Rapidly heals the target, regenerating their nutrition at a far greater rate than normal"

/obj/item/slimecross/regenerative/bluespace
	colour = "bluespace"
	effect_desc = "Rapidly heals the target and teleports them to where this core was created."
	var/turf/open/T

/obj/item/slimecross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	var/turf/old_location = get_turf(target)
	if(do_teleport(target, T, channel = TELEPORT_CHANNEL_QUANTUM)) //despite being named a bluespace teleportation method the quantum channel is used to preserve precision teleporting with a bag of holding
		old_location.visible_message(span_warning("[target] disappears in a shower of sparks!"))
		to_chat(target, span_danger("The milky goo teleports you somewhere it remembers!"))


/obj/item/slimecross/regenerative/bluespace/Initialize(mapload)
	. = ..()
	T = get_turf(src)

/obj/item/slimecross/regenerative/sepia
	colour = "sepia"
	effect_desc = "Rapidly heals the target. After 10 seconds, relocate the target to the initial position the core was used with their previous health status."

/obj/item/slimecross/regenerative/sepia/core_effect_before(mob/living/target, mob/user)
	to_chat(target, span_notice("You try to forget how you feel."))
	target.AddComponent(/datum/component/dejavu)

/obj/item/slimecross/regenerative/cerulean
	colour = "cerulean"
	effect_desc = "Rapidly heals the target and makes a second regenerative core with no special effects."

/obj/item/slimecross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	src.forceMove(user.loc)
	var/obj/item/slimecross/X = new /obj/item/slimecross/regenerative(user.drop_location())
	X.name = name
	X.desc = desc
	user.put_in_active_hand(X)
	to_chat(user, span_notice("Some of the milky goo congeals in your hand!"))

/obj/item/slimecross/regenerative/pyrite
	colour = "pyrite"
	effect_desc = "Rapidly heals and randomly colors the target."

/obj/item/slimecross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	target.visible_message(span_warning("The milky goo coating [target] leaves [target.p_them()] a different color!"))
	target.add_atom_colour(color_transition_filter(rgb(rand(0,255), rand(0,255), rand(0,255)), SATURATION_OVERRIDE), WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/regenerative/red
	colour = "red"
	effect_desc = "Rapidly heals the target and injects them with some ephedrine."

/obj/item/slimecross/regenerative/red/core_effect(mob/living/target, mob/user)
	to_chat(target, span_notice("You feel... <i>faster.</i>"))
	target.reagents.add_reagent(/datum/reagent/medicine/ephedrine,3)

/obj/item/slimecross/regenerative/green
	colour = "green"
	effect_desc = "Rapidly heals the target and changes the species or color of a slime or jellyperson."

/obj/item/slimecross/regenerative/green/core_effect(mob/living/target, mob/user)
	if(isslime(target))
		target.visible_message(span_warning("\The [target] suddenly changes color!"))
		var/mob/living/basic/slime/S = target
		S.set_slime_type(SLIME_TYPE_RANDOM)
	else if(isoozeling(target))
		target.reagents.add_reagent(/datum/reagent/mutationtoxin/jelly, 5)


/obj/item/slimecross/regenerative/pink
	colour = "pink"
	effect_desc = "Rapidly heals the target and injects them with some krokodil."

/obj/item/slimecross/regenerative/pink/core_effect(mob/living/target, mob/user)
	to_chat(target, span_notice("You feel more calm."))
	target.reagents.add_reagent(/datum/reagent/drug/krokodil,4)

/obj/item/slimecross/regenerative/gold
	colour = "gold"
	effect_desc = "Rapidly heals the target and produces a random coin."

/obj/item/slimecross/regenerative/gold/core_effect(mob/living/target, mob/user)
	var/newcoin = pick(/obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
	var/obj/item/coin/C = new newcoin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, TRUE)
	target.put_in_hand(C)

/obj/item/slimecross/regenerative/oil
	colour = "oil"
	effect_desc = "Rapidly heals the target and flashes everyone in sight."

/obj/item/slimecross/regenerative/oil/core_effect(mob/living/target, mob/user)
	playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
	for(var/mob/living/L in view(user,7))
		L.flash_act()

/obj/item/slimecross/regenerative/black
	colour = "black"
	effect_desc = "Rapidly heals the target and creates an imperfect duplicate of them made of slime, that fakes their death."

/obj/item/slimecross/regenerative/black/core_effect_before(mob/living/target, mob/user)
	var/dummytype = target.type
	if(ismegafauna(target)) //Prevents megafauna duping in a lame way
		dummytype = /mob/living/basic/slime
		to_chat(user, span_warning("The milky goo flows over [target], falling into a weak puddle."))
	var/mob/living/dummy = new dummytype(target.loc)
	to_chat(target, span_notice("The milky goo flows from your skin, forming an imperfect copy of you."))
	dummy.copy_voice_from(target)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/mob/living/carbon/carbon_dummy = dummy
		carbon_dummy.real_name = carbon_target.real_name
		if(carbon_target.dna)
			carbon_target.dna.copy_dna(carbon_dummy.dna, COPY_DNA_SE|COPY_DNA_SPECIES)
		carbon_dummy.updateappearance(mutcolor_update = TRUE)
	dummy.adjustBruteLoss(target.getBruteLoss())
	dummy.adjustFireLoss(target.getFireLoss())
	dummy.adjustToxLoss(target.getToxLoss())
	dummy.death()

/obj/item/slimecross/regenerative/lightpink
	colour = "light pink"
	effect_desc = "Rapidly heals the target and also heals the user."

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/living/user)
	if(!isliving(user))
		return
	if(target == user)
		return
	if(!user.has_status_effect(/datum/status_effect/regenerative_extract))
		apply_effect(user)
		to_chat(user, span_notice("Some of the milky goo sprays onto you, as well!"))
	else
		to_chat(user, span_warning("Some of the milky goo sprays onto you, but slides off due to the regenerative effect..."))

/obj/item/slimecross/regenerative/adamantine
	colour = "adamantine"
	effect_desc = "Rapidly heals the target, while boosting their armor and general resilience."

/obj/item/slimecross/regenerative/adamantine/core_effect(mob/living/target, mob/user) //WIP - Find out why this doesn't work.
	target.apply_status_effect(/datum/status_effect/slimeskin)

/obj/item/slimecross/regenerative/rainbow
	colour = "rainbow"
	effect_desc = "Fully heals the target, including all forms of damage, wounds, brain traumas, sickness, blood loss, and unsafe body temperature. Does not regrow limbs (except for oozelings) or refresh organs. Temporarily makes them immortal, but pacifistic."

/obj/item/slimecross/regenerative/rainbow/core_effect(mob/living/target, mob/user)
	target.apply_status_effect(/datum/status_effect/rainbow_protection)

/obj/item/slimecross/regenerative/rainbow/can_use(mob/living/target, mob/living/user)
	if(target.has_status_effect(/datum/status_effect/slime_regen_cooldown))
		to_chat(user, span_warning("[target == user ? "You are" : "[target] is"] still recovering from the last regenerative extract!"))
		return FALSE
	return ..()

/// Heals the owner over time, then leaves a cooldown that weakens the next extract.
/datum/status_effect/regenerative_extract
	id = "Slime Regeneration"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	tick_interval = 0.2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/regen_extract
	show_duration = TRUE
	processing_speed = STATUS_EFFECT_PRIORITY
	/// The damage healed (for each type) per tick.
	/// This is multipled against the multiplier derived from cooldowns.
	var/base_healing_amt = 4
	/// The number multiplied against the base healing amount,
	/// used for the "diminishing returns" cooldown effect.
	var/multiplier = 1
	/// The multiplier that the cooldown applied after the effect ends will use.
	var/diminishing_multiplier = 0.75
	/// How long the subsequent cooldown effect will last.
	var/diminish_time = 90 SECONDS
	/// The maximum nutrition level this regenerative extract can heal up to.
	var/nutrition_heal_cap = NUTRITION_LEVEL_FED - 50
	/// Base traits given to the owner.
	var/static/list/given_traits = list(TRAIT_ANALGESIA, TRAIT_NOCRITDAMAGE)
	/// Extra traits given to the owner, added to the base traits.
	var/list/extra_traits

/datum/status_effect/regenerative_extract/on_creation(mob/living/new_owner, alert_color)
	. = ..()
	if(. && linked_alert)
		apply_alert_effect(alert_color)

/datum/status_effect/regenerative_extract/on_apply()
	// So this seems weird, but this allows us to have multiple things affect the regen multiplier,
	// without doing something like hardcoding a `for(var/datum/status_effect/slime_regen_cooldown/cooldown in owner.status_effects)`
	// Instead, cooldown effects register the [COMSIG_SLIME_REGEN_CALC] signal, and can affect our multiplier via the pointer we pass.
	SEND_SIGNAL(owner, COMSIG_SLIME_REGEN_CALC, &multiplier)
	if(multiplier < 1)
		to_chat(owner, span_warning("The previous regenerative goo hasn't fully evaporated yet, weakening the new regenerative effect!"))
	owner.add_traits(islist(extra_traits) ? (given_traits + extra_traits) : given_traits, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/regenerative_extract/on_remove()
	owner.remove_traits(islist(extra_traits) ? (given_traits + extra_traits) : given_traits, TRAIT_STATUS_EFFECT(id))
	owner.apply_status_effect(/datum/status_effect/slime_regen_cooldown, diminishing_multiplier, diminish_time)

/datum/status_effect/regenerative_extract/tick(seconds_between_ticks, times_fired)
	var/heal_amt = base_healing_amt * seconds_between_ticks * multiplier
	heal_act(heal_amt)
	owner.updatehealth()

/// Tints the alert to match the extract's color.
/datum/status_effect/regenerative_extract/proc/apply_alert_effect(alert_color)
	if(alert_color)
		linked_alert.add_atom_colour(alert_color, FIXED_COLOUR_PRIORITY)

/// Does one tick of healing, using every heal_* proc below.
/datum/status_effect/regenerative_extract/proc/heal_act(heal_amt)
	if(!heal_amt)
		return
	heal_damage(heal_amt)
	heal_misc(heal_amt)
	if(iscarbon(owner))
		heal_organs(heal_amt)
		heal_wounds()

/// Heals brute, burn, oxygen, toxin, and clone damage.
/datum/status_effect/regenerative_extract/proc/heal_damage(heal_amt)
	owner.heal_overall_damage(brute = heal_amt, burn = heal_amt, updating_health = FALSE)
	owner.adjustOxyLoss(-heal_amt, updating_health = FALSE)
	owner.adjustToxLoss(-heal_amt, updating_health = FALSE, forced = TRUE)
	owner.adjustCloneLoss(-heal_amt, updating_health = FALSE)

/// Restores blood and nutrition, and lowers disgust.
/datum/status_effect/regenerative_extract/proc/heal_misc(heal_amt)
	var/blood_restore = (heal_amt * 0.25)
	owner.adjust_disgust(-blood_restore)
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = min(owner.blood_volume + blood_restore, BLOOD_VOLUME_NORMAL)
	if((owner.nutrition < nutrition_heal_cap) && !HAS_TRAIT(owner, TRAIT_NOHUNGER))
		owner.nutrition = min(owner.nutrition + blood_restore, nutrition_heal_cap)

/// Heals every organ, and cures brain traumas.
/datum/status_effect/regenerative_extract/proc/heal_organs(heal_amt)
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/organ/organ in carbon_owner.organs)
		organ.apply_organ_damage(-heal_amt)
	carbon_owner.cure_trauma_type(resilience = TRAUMA_RESILIENCE_MAGIC, ignore_flags = TRAUMA_SPECIAL_CURE_PROOF)

/// Removes the most severe wound.
/datum/status_effect/regenerative_extract/proc/heal_wounds()
	var/mob/living/carbon/carbon_owner = owner
	if(length(carbon_owner.all_wounds))
		var/list/datum/wound/ordered_wounds = sort_list(carbon_owner.all_wounds, GLOBAL_PROC_REF(cmp_wound_severity_dsc))
		ordered_wounds[1]?.remove_wound()

/datum/status_effect/regenerative_extract/get_examine_text()
	return "[owner.p_They()] [owner.p_have()] a subtle, gentle glow to [owner.p_their()] skin, with slime soothing [owner.p_their()] wounds."

/atom/movable/screen/alert/status_effect/regen_extract
	name = "Slime Regeneration"
	desc = "A milky slime covers your skin, regenerating your injuries!"
	icon_state = "slime_regen"

/// Left behind by a regenerative extract, and weakens the next one.
/datum/status_effect/slime_regen_cooldown
	id = "slime_regen_cooldown"
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN
	/// The multiplier applied to the effect of a regen extract while this cooldown is active.
	/// As multiple cooldowns can be active at the same time, these multipliers stack, resulting in exponentially diminishing returns.
	var/multiplier = 1

/datum/status_effect/slime_regen_cooldown/on_creation(mob/living/new_owner, multiplier = 1, duration = 45 SECONDS)
	src.multiplier = multiplier
	src.duration = duration
	return ..()

/datum/status_effect/slime_regen_cooldown/on_apply()
	RegisterSignal(owner, COMSIG_SLIME_REGEN_CALC, PROC_REF(apply_multiplier))
	return TRUE

/datum/status_effect/slime_regen_cooldown/on_remove()
	UnregisterSignal(owner, COMSIG_SLIME_REGEN_CALC)

/// Multiplies a new extract's healing multiplier by ours.
/datum/status_effect/slime_regen_cooldown/proc/apply_multiplier(datum/source, multiplier_ptr)
	SIGNAL_HANDLER
	*multiplier_ptr *= multiplier

/datum/status_effect/regenerative_extract/purple
	base_healing_amt = 4
	extra_traits = list(TRAIT_NOCRITOVERLAY, TRAIT_NOSOFTCRIT)

/datum/status_effect/regenerative_extract/purple/on_remove()
	. = ..()
	if(owner.has_dna()?.species?.reagent_tag & PROCESS_ORGANIC) // won't work during cooldown, and won't waste effort injecting into IPCs
		var/inject_amt = round(10 * multiplier)
		if(inject_amt >= 1)
			owner.reagents?.add_reagent(/datum/reagent/medicine/regen_jelly, inject_amt)

/datum/status_effect/regenerative_extract/silver
	base_healing_amt = 4
	nutrition_heal_cap = NUTRITION_LEVEL_WELL_FED + 50
	diminishing_multiplier = 0.8
	diminish_time = 30 SECONDS
	extra_traits = list(TRAIT_NOFAT)

/datum/status_effect/regenerative_extract/yellow
	extra_traits = list(TRAIT_SHOCKIMMUNE, TRAIT_TESLA_SHOCKIMMUNE, TRAIT_AIRLOCK_SHOCKIMMUNE)

/datum/status_effect/regenerative_extract/adamantine
	extra_traits = list(TRAIT_FEARLESS, TRAIT_HARDLY_WOUNDED)

// rainbow extracts are similar to old regen extract effects, albeit it won't replace your organs, and won't heal limbs
/datum/status_effect/regenerative_extract/rainbow
	duration = 30 SECONDS
	base_healing_amt = 15
	diminishing_multiplier = 1
	diminish_time = 1.5 MINUTES
	extra_traits = list(TRAIT_NOCRITOVERLAY, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT)

/datum/status_effect/regenerative_extract/rainbow/apply_alert_effect(alert_color)
	linked_alert.rainbow_effect()
