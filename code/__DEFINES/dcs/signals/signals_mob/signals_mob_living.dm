///called on /living when attempting to pick up an item, from base of /mob/living/put_in_hand_check(): (obj/item/I)
#define COMSIG_LIVING_TRY_PUT_IN_HAND "living_try_put_in_hand"
	/// Can't pick up
	#define COMPONENT_LIVING_CANT_PUT_IN_HAND (1<<0)

// Organ signals
/// Called on the organ when it is implanted into someone (mob/living/carbon/receiver)
#define COMSIG_ORGAN_IMPLANTED "comsig_organ_implanted"
/// Called when using the *wag emote
#define COMSIG_ORGAN_WAG_TAIL "comsig_wag_tail"
/// Called on the organ when it is removed from someone (mob/living/carbon/old_owner)
#define COMSIG_ORGAN_REMOVED "comsig_organ_removed"
/// Called when an organ is being regenerated with a new copy in species regenerate_organs (obj/item/organ/replacement)
#define COMSIG_ORGAN_BEING_REPLACED "organ_being_replaced"

///from base of mob/update_transform()
#define COMSIG_LIVING_POST_UPDATE_TRANSFORM "living_post_update_transform"

///from /obj/structure/door/crush(): (mob/living/crushed, /obj/machinery/door/crushing_door)
#define COMSIG_LIVING_DOORCRUSHED "living_doorcrush"
///from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
///from base of mob/living/ignite_mob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
///from base of mob/living/extinguish_mob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
///from base of mob/living/electrocute_act(): (shock_damage, source, siemens_coeff, flags)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
///sent when items with siemen coeff. of 0 block a shock: (power_source, source, siemens_coeff, dist_check)
#define COMSIG_LIVING_SHOCK_PREVENTED "living_shock_prevented"
///sent by stuff like stunbatons and tasers: ()
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"
///from base of mob/living/revive() (full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"
///from base of mob/living/set_buckled(): (new_buckled)
#define COMSIG_LIVING_SET_BUCKLED "living_set_buckled"
///from base of mob/living/set_body_position()
#define COMSIG_LIVING_SET_BODY_POSITION  "living_set_body_position"
///From post-can inject check of syringe after attack (mob/user)
#define COMSIG_LIVING_TRY_SYRINGE "living_try_syringe"
///From living/Life(). (deltatime, times_fired)
#define COMSIG_LIVING_LIFE "living_life"
	/// Block the Life() proc from proceeding... this should really only be done in some really wacky situations.
	#define COMPONENT_LIVING_CANCEL_LIFE_PROCESSING (1<<0)
///From living/set_resting(): (new_resting, silent, instant)
#define COMSIG_LIVING_RESTING "living_resting"

///from base of element/bane/activate(): (item/weapon, mob/user)
#define COMSIG_LIVING_BANED "living_baned"

///from base of element/bane/activate(): (item/weapon, mob/user)
#define COMSIG_OBJECT_PRE_BANING "obj_pre_baning"
	#define COMPONENT_CANCEL_BANING (1<<0)

///from base of element/bane/activate(): (item/weapon, mob/user)
#define COMSIG_OBJECT_ON_BANING "obj_on_baning"

// adjust_x_loss messages sent from /mob/living/proc/adjust[x]Loss
/// Returned from all the following messages if you actually aren't going to apply any change
#define COMPONENT_IGNORE_CHANGE (1<<0)
// Each of these messages sends the damagetype even though it is inferred by the signal so you can pass all of them to the same proc if required
/// Send when bruteloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_BRUTE_DAMAGE "living_adjust_brute_damage"
/// Send when fireloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_BURN_DAMAGE "living_adjust_burn_damage"
/// Send when oxyloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_OXY_DAMAGE "living_adjust_oxy_damage"
/// Send when toxloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_TOX_DAMAGE "living_adjust_tox_damage"
/// Send when cloneloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_CLONE_DAMAGE "living_adjust_clone_damage"
/// Send when staminaloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_STAMINA_DAMAGE "living_adjust_stamina_damage"

/// List of signals sent when you receive any damage except stamina
#define COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES list(\
	COMSIG_LIVING_ADJUST_BRUTE_DAMAGE,\
	COMSIG_LIVING_ADJUST_BURN_DAMAGE,\
	COMSIG_LIVING_ADJUST_CLONE_DAMAGE,\
	COMSIG_LIVING_ADJUST_OXY_DAMAGE,\
	COMSIG_LIVING_ADJUST_TOX_DAMAGE,\
)
/// List of signals sent when you receive any kind of damage at all
#define COMSIG_LIVING_ADJUST_ALL_DAMAGE_TYPES (COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES + COMSIG_LIVING_ADJUST_STAMINA_DAMAGE)


/// from base of mob/living/updatehealth()
#define COMSIG_LIVING_HEALTH_UPDATE "living_health_update"
///from base of mob/living/death(): (gibbed)
#define COMSIG_LIVING_DEATH "living_death"

///from base of mob/living/gib(): (no_brain, no_organs, no_bodyparts)
///Note that it is fired regardless of whether the mob was dead beforehand or not.
#define COMSIG_LIVING_GIBBED "living_gibbed"

///from base of mob/living/Write_Memory(): (dead, gibbed)
#define COMSIG_LIVING_WRITE_MEMORY "living_write_memory"
	#define COMPONENT_DONT_WRITE_MEMORY (1<<0)

/// from /proc/healthscan(): (list/scan_results, advanced, mob/user, mode)
/// Consumers are allowed to mutate the scan_results list to add extra information
#define COMSIG_LIVING_HEALTHSCAN "living_healthscan"

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!

///from base of mob/living/Stun() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
///from mob/living/carbon/enter_stamina_stun()
#define COMSIG_LIVING_STAMINA_STUN "carbon_stamina_stun"
///from base of mob/living/Knockdown() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
///from base of mob/living/Paralyze() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
///from base of mob/living/Immobilize() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
///from base of mob/living/incapacitate() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_INCAPACITATE "living_incapacitate"
///from base of mob/living/Unconscious() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
///from base of mob/living/Sleeping() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
/// from mob/living/check_stun_immunity(): (check_flags)
#define COMSIG_LIVING_GENERIC_STUN_CHECK "living_check_stun"
	#define COMPONENT_NO_STUN (1<<0) //For all of them
///from base of /mob/living/can_track(): (mob/user)
#define COMSIG_LIVING_CAN_TRACK "mob_cantrack"
	#define COMPONENT_CANT_TRACK (1<<0)
///from end of fully_heal(): (heal_flags)
#define COMSIG_LIVING_POST_FULLY_HEAL "living_post_fully_heal"
/// from start of /mob/living/handle_breathing(): (seconds_per_tick, times_fired)
#define COMSIG_LIVING_HANDLE_BREATHING "living_handle_breathing"
///from /obj/item/hand_item/slapper/attack_atom(): (source=mob/living/slammer, obj/structure/table/slammed_table)
#define COMSIG_LIVING_SLAM_TABLE "living_slam_table"
///from /obj/item/hand_item/slapper/attack(): (source=mob/living/slapper, mob/living/slapped)
#define COMSIG_LIVING_SLAP_MOB "living_slap_mob"
/// from /mob/living/*/UnarmedAttack(), before sending [COMSIG_LIVING_UNARMED_ATTACK]: (mob/living/source, atom/target, proximity, modifiers)
#define COMSIG_LIVING_EARLY_UNARMED_ATTACK "human_pre_attack_hand"
///(NOT on humans) from mob/living/*/UnarmedAttack(): (mob/living/source, atom/target, proximity, modifiers)
#define COMSIG_LIVING_UNARMED_ATTACK "living_unarmed_attack"
///From base of mob/living/MobBump() (mob/living)
#define COMSIG_LIVING_MOB_BUMP "living_mob_bump"
///From base of mob/living/Bump() (turf/closed)
#define COMSIG_LIVING_WALL_BUMP "living_wall_bump"
///From base of turf/closed/Exited() (turf/closed)
#define COMSIG_LIVING_WALL_EXITED "living_wall_exited"
///From base of mob/living/ZImpactDamage() (mob/living, levels, turf/t)
#define COMSIG_LIVING_Z_IMPACT "living_z_impact"
	#define NO_Z_IMPACT_DAMAGE (1<<0)

/// From mob/living/try_speak(): (message, ignore_spam, forced)
#define COMSIG_LIVING_TRY_SPEECH "living_vocal_speech"
	/// Return if the mob can speak the message, regardless of any other signal returns or checks.
	#define COMPONENT_CAN_ALWAYS_SPEAK (1<<0)
	/// Return if the mob cannot speak.
	#define COMPONENT_CANNOT_SPEAK (1<<1)

/// From mob/living/treat_message(): (list/message_args)
#define COMSIG_LIVING_TREAT_MESSAGE "living_treat_message"
	/// The index of message_args that corresponds to the actual message
	#define TREAT_MESSAGE_MESSAGE 1

///From obj/item/toy/crayon/spraycan
#define COMSIG_LIVING_MOB_PAINTED "living_mob_painted"

///From mob/living/proc/wabbajack(): (randomize_type)
#define COMSIG_LIVING_PRE_WABBAJACKED "living_mob_wabbajacked"
	/// Return to stop the rest of the wabbajack from triggering.
	#define STOP_WABBAJACK (1<<0)
///From mob/living/proc/on_wabbajack(): (mob/living/new_mob)
#define COMSIG_LIVING_ON_WABBAJACKED "living_wabbajacked"

/// From /datum/status_effect/shapechange_mob/on_apply(): (mob/living/shape)
#define COMSIG_LIVING_SHAPESHIFTED "living_shapeshifted"
/// From /datum/status_effect/shapechange_mob/after_unchange(): (mob/living/caster)
#define COMSIG_LIVING_UNSHAPESHIFTED "living_unshapeshifted"

///From /obj/effect/rune/convert/do_sacrifice() : (list/invokers)
#define COMSIG_LIVING_CULT_SACRIFICED "living_cult_sacrificed"
	/// Return to stop the sac from occurring
	#define STOP_SACRIFICE (1<<0)
	/// Don't send a message for sacrificing this thing, we have our own
	#define SILENCE_SACRIFICE_MESSAGE (1<<1)

/// From /mob/living/befriend() : (mob/living/new_friend)
#define COMSIG_LIVING_BEFRIENDED "living_befriended"

/// From /obj/item/proc/pickup(): (/obj/item/picked_up_item)
#define COMSIG_LIVING_PICKED_UP_ITEM "living_picked_up_item"

/// From /mob/living/unfriend() : (mob/living/old_friend)
#define COMSIG_LIVING_UNFRIENDED "living_unfriended"

/// From /obj/effect/temp_visual/resonance/burst() : (mob/creator, mob/living/hit_living)
#define COMSIG_LIVING_RESONATOR_BURST "living_resonator_burst"

/// From /obj/projectile/attempt_parry() : (obj/projectile/parried_projectile)
#define COMSIG_LIVING_PROJECTILE_PARRYING "living_projectile_parrying"
	/// Return to allow the parry to happen
	#define ALLOW_PARRY (1<<0)

/// From /obj/projectile/on_parry() : (obj/projectile/parried_projectile)
#define COMSIG_LIVING_PROJECTILE_PARRIED "living_projectile_parried"
	/// Return to prevent the projectile from executing any code in on_parry()
	#define INTERCEPT_PARRY_EFFECTS (1<<0)

/// From /turf/closed/mineral/gibtonite/defuse() : (det_time)
#define COMSIG_LIVING_DEFUSED_GIBTONITE "living_defused_gibtonite"

/// From /obj/item/kinetic_crusher/afterattack() : (mob/living/target, obj/item/kinetic_crusher/crusher, backstabbed)
#define COMSIG_LIVING_CRUSHER_DETONATE "living_crusher_detonate"

/// From /obj/structure/geyser/attackby() : (obj/structure/geyser/geyser)
#define COMSIG_LIVING_DISCOVERED_GEYSER "living_discovered_geyser"

/// From /datum/ai/behavior/climb_tree/perform() : (mob/living/basic/living_pawn)
#define COMSIG_LIVING_CLIMB_TREE "living_climb_tree"

/// Sent on a mob from /datum/component/mob_chain when component is attached with it as the "front" : (mob/living/basic/tail)
#define COMSIG_MOB_GAINED_CHAIN_TAIL "living_gained_chain_tail"
/// Sent on a mob from /datum/component/mob_chain when component is detached from it as the "front" : (mob/living/basic/tail)
#define COMSIG_MOB_LOST_CHAIN_TAIL "living_detached_chain_tail"
/// Sent from a 'contract chain' button on a mob chain
#define COMSIG_MOB_CHAIN_CONTRACT "living_chain_contracted"

#define COMSIG_LIVING_BODY_TEMPERATURE_CHANGE "living_body_temperature_change"

#define COMSIG_LIVING_HOMEOSTASIS "living_homeostasis"
	/// Return to do no homeostasis at all
	#define HOMEOSTASIS_HANDLED (1<<0)
	/// Return to not reduce hunger at all
	#define HOMEOSTASIS_NO_HUNGER (1<<1)
