/// From /datum/status_effect/slime_leech/tick(), sent to the victim when drained to death: (mob/living/basic/slime/draining_slime)
#define COMSIG_SLIME_DRAINED "slime_drained"
/// From /mob/living/basic/slime/proc/eat_wanted_item(): (obj/item/meal)
/// Return COMPONENT_SLIME_WANTS_ITEM if this meal is worth something to you.
#define COMSIG_SLIME_CHECK_WANTED_ITEM "slime_check_wanted_item"
	#define COMPONENT_SLIME_WANTS_ITEM (1<<0)
/// From /mob/living/basic/slime/proc/eat_wanted_item(), after the item is gone: (meal_type)
#define COMSIG_SLIME_ATE_ITEM "slime_ate_item"
/// From /mob/living/basic/slime/proc/set_mood(): (old_mood, new_mood)
#define COMSIG_SLIME_UPDATE_MOOD "slime_update_mood"
/// From /datum/status_effect/slime_leech/tick(): (mob/living/meal, drained)
#define COMSIG_SLIME_LATCH_DRAINED "slime_latch_drained"
/// From /mob/living/basic/slime/proc/on_slime_pre_attack(), when a slime shocks a carbon: (mob/living/carbon/target)
#define COMSIG_SLIME_SHOCKED "slime_shocked"
/// From /mob/living/basic/slime/proc/finish_reproduce() and death(), once per new baby: (mob/living/basic/slime/baby)
#define COMSIG_SLIME_SPLIT "slime_split"

/// From /obj/item/vacuum_pack/proc/store(): (mob/living/stored_mob)
#define COMSIG_VACUUM_STORED "vacuum_stored"
/// From /obj/item/vacuum_pack/Exited(): (mob/living/released_mob)
#define COMSIG_VACUUM_RELEASED "vacuum_released"
