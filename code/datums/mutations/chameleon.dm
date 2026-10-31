//Chameleon causes the owner to slowly become transparent when not moving.
/datum/mutation/chameleon
	name = "Chameleon"
	desc = "A genome that causes the holder's skin to become transparent over time."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>You feel one with your surroundings.</span>"
	text_lose_indication = "<span class='notice'>You feel oddly exposed.</span>"
	instability = 25
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/chameleon/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_attack_item))
	START_PROCESSING(SSfastprocess, src)

/datum/mutation/chameleon/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	owner.alpha = initial(owner.alpha)
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK))
	STOP_PROCESSING(SSfastprocess, src)

/datum/mutation/chameleon/process(seconds_per_tick)
	if(owner.stat == DEAD)
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
		return

	owner.alpha = max(owner.alpha - (12.5 / (min(GET_MUTATION_ENERGY(src) * 1.4, 1)) * seconds_per_tick), 0)

//Upgraded mutation of the base variant, used for changelings. No instability and better power_coeff
/datum/mutation/chameleon/changeling
	instability = 0
	energy_coeff = 0.28
	locked = TRUE

/**
 * Resets the alpha of the host to the chameleon default if they move.
 *
 * Arguments:
 * - [source][/atom/movable]: The source of the signal. Presumably the host mob.
 * - [old_loc][/atom]: The location the host mob used to be in.
 * - move_dir: The direction the host mob moved in.
 * - forced: Whether the movement was caused by a forceMove or moveToNullspace.
 * - [old_locs][/list/atom]: The locations the host mob used to be in.
 */
/datum/mutation/chameleon/proc/on_move(atom/movable/source, atom/old_loc, move_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER

	owner.alpha = min(owner.alpha + CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY / (GET_MUTATION_POWER(src) > 1 ? GET_MUTATION_POWER(src) * 2 : 1), CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY)

/**
 * Resets the alpha of the host if they click on something nearby.
 *
 * Arguments:
 * - [source][/mob/living/carbon/human]: The host mob that just clicked on something.
 * - [target][/atom]: The thing the host mob clicked on.
 * - proximity: Whether the host mob can physically reach the thing that they clicked on.
 * - [modifiers][/list]: The set of click modifiers associated with this attack chain call.
 */
/datum/mutation/chameleon/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, list/modifiers)
	SIGNAL_HANDLER

	if(!proximity) //stops tk from breaking chameleon
		return

	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/chameleon/proc/on_attack_item(mob/living/carbon/human/owner, mob/target, mob/user, params, obj/item/weapon)
	SIGNAL_HANDLER

	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
