#define INSPECT_TIMER 10 SECONDS
#define PET_COOLDOWN 10 SECONDS
#define GROOM_COOLDOWN 30 SECONDS

/*
 * A component that allows mobs to have happiness levels
 */
/datum/component/happiness
	dupe_mode = COMPONENT_DUPE_UNIQUE //Prioritize the old comp over, which may have callbacks and stuff specific to the mob.
	///our current happiness level
	var/happiness_level
	///our maximum happiness level
	var/maximum_happiness
	///happiness AI blackboard key
	var/blackboard_key
	///happiness when we get groomed
	var/on_groom_change
	///happiness when we get petted
	var/on_petted_change
	///happiness when we eat
	var/on_eat_change
	///percentages we should be calling back on
	var/list/callback_percentages
	///callback when our happiness changes
	var/datum/callback/happiness_callback

	///how long till we can inspect happiness again?
	COOLDOWN_DECLARE(happiness_inspect)
	///how long till we can pet it again?
	COOLDOWN_DECLARE(pet_cooldown)
	///how long till we can groom it again
	COOLDOWN_DECLARE(groom_cooldown)

/datum/component/happiness/Initialize(maximum_happiness = 400, blackboard_key = BB_BASIC_HAPPINESS, on_groom_change = 200, on_eat_change = 300, on_petted_change = 30, callback_percentages = list(0, 25, 50, 75, 100), happiness_callback)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.maximum_happiness = maximum_happiness
	src.blackboard_key = blackboard_key
	src.on_groom_change = on_groom_change
	src.on_petted_change = on_petted_change
	src.on_eat_change = on_eat_change
	src.happiness_callback = happiness_callback
	src.callback_percentages = callback_percentages

	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/happiness/RegisterWithParent()

	if(on_petted_change)
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_petted))
	if(on_groom_change)
		RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	if(on_eat_change)
		RegisterSignal(parent, COMSIG_LIVING_ATE, PROC_REF(on_eat))
	RegisterSignal(parent, COMSIG_SHIFT_CLICKED_ON, PROC_REF(view_happiness))

/datum/component/happiness/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_LIVING_ATE))
	happiness_callback = null

/// Increases the happiness of the parent when it eats
/datum/component/happiness/proc/on_eat(datum/source)
	SIGNAL_HANDLER

	increase_happiness_level(on_eat_change)

/// Increases the happiness of the parent when it grooms itself, if the cooldown is over
/datum/component/happiness/proc/on_clean(mob/living/source)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, groom_cooldown))
		return

	var/mob/living/living_parent = parent
	if (living_parent.stat != CONSCIOUS)
		return

	COOLDOWN_START(src, groom_cooldown, GROOM_COOLDOWN)
	increase_happiness_level(on_groom_change)

/// Increases the happiness of the parent when it's petted with the left mouse button
/datum/component/happiness/proc/on_petted(datum/source, mob/living/petter, list/modifiers)
	SIGNAL_HANDLER
	if(!LAZYACCESS(modifiers, LEFT_CLICK) || (petter.istate & ISTATE_HARM))
		return

	var/mob/living/living_parent = parent
	if (living_parent.stat != CONSCIOUS)
		return

	pet_animal()

/// Increases the happiness of the parent and shows some hearts, if the cooldown is over
/datum/component/happiness/proc/pet_animal()
	if(!COOLDOWN_FINISHED(src, pet_cooldown))
		return
	increase_happiness_level(on_petted_change)
	COOLDOWN_START(src, pet_cooldown, PET_COOLDOWN)


/// Increases the happiness level of the parent by amount, showing a heart and a little spin unless the happiness is hidden
/datum/component/happiness/proc/increase_happiness_level(amount)
	happiness_level = min(happiness_level + amount, maximum_happiness)
	if(!HAS_TRAIT(parent, TRAIT_MOB_HIDE_HAPPINESS))
		var/mob/living/living_parent = parent
		new /obj/effect/temp_visual/heart(living_parent.loc)
		living_parent.spin(spintime = 2 SECONDS, speed = 1)
	START_PROCESSING(SSprocessing, src)

/// Shows the happiness level of the parent to the clicker as a hearts overlay above it
/datum/component/happiness/proc/view_happiness(mob/living/source, mob/living/clicker)
	if(HAS_TRAIT(source, TRAIT_MOB_HIDE_HAPPINESS) || !istype(clicker) || !clicker.client || !COOLDOWN_FINISHED(src, happiness_inspect) || !clicker.CanReach(source))
		return
	var/alist/offset_to_add = get_icon_dimensions(source.icon)
	var/y_position = offset_to_add["height"] + 1
	var/obj/effect/overlay/happiness_overlay/hearts = new(null, clicker)
	hearts.pixel_y = y_position
	hearts.set_hearts(happiness_level/maximum_happiness)
	var/image/new_image = new(source)
	new_image.appearance = hearts.appearance
	new_image.loc = isturf(source.loc) ? source : source.loc
	SET_PLANE(new_image, new_image.plane, source)
	clicker.client.images += new_image
	hearts.image = new_image
	QDEL_IN(hearts, INSPECT_TIMER / 2)
	COOLDOWN_START(src, happiness_inspect, INSPECT_TIMER)


/datum/component/happiness/process()
	var/mob/living/living_parent = parent
	var/happiness_percentage = happiness_level/maximum_happiness
	living_parent.ai_controller?.set_blackboard_key(blackboard_key, happiness_percentage)
	var/check_percentage_in_list = round(happiness_percentage * 100, 1)
	if(check_percentage_in_list in callback_percentages)
		SEND_SIGNAL(parent, COMSIG_MOB_HAPPINESS_CHANGE, happiness_percentage)
		happiness_callback?.Invoke(happiness_percentage)

	if(happiness_level <= 0)
		return PROCESS_KILL
	var/modifier = living_parent.ai_controller?.blackboard[BB_BASIC_DEPRESSED] ? 2 : 1
	happiness_level = max(0, happiness_level - modifier)

#undef INSPECT_TIMER
#undef PET_COOLDOWN
#undef GROOM_COOLDOWN
