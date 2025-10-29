// Object signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj signals
///from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
///from base of code/game/machinery
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
///from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide
#define COMSIG_OBJ_HIDE "obj_hide"
/// from /obj/obj_reskin: (mob/user, skin)
#define COMSIG_OBJ_RESKIN "obj_reskin"

// /obj/machinery signals

///from /obj/machinery/atom_break(damage_flag): (damage_flag)
#define COMSIG_MACHINERY_BROKEN "machinery_broken"
///from base power_change() when power is lost
#define COMSIG_MACHINERY_POWER_LOST "machinery_power_lost"
///from base power_change() when power is restored
#define COMSIG_MACHINERY_POWER_RESTORED "machinery_power_restored"
///from /obj/machinery/set_occupant(atom/movable/O): (new_occupant)
#define COMSIG_MACHINERY_SET_OCCUPANT "machinery_set_occupant"
///from /obj/machinery/destructive_scanner/proc/open(aggressive): Runs when the destructive scanner scans a group of objects. (list/scanned_atoms)
#define COMSIG_MACHINERY_DESTRUCTIVE_SCAN "machinery_destructive_scan"
///from /obj/machinery/computer/arcade/prizevend(mob/user, prizes = 1)
#define COMSIG_ARCADE_PRIZEVEND "arcade_prizevend"
///from /datum/controller/subsystem/air/proc/start_processing_machine: ()
#define COMSIG_MACHINERY_START_PROCESSING_AIR "start_processing_air"
///from /datum/controller/subsystem/air/proc/stop_processing_machine: ()
#define COMSIG_MACHINERY_STOP_PROCESSING_AIR "stop_processing_air"
///from /obj/machinery/RefreshParts: ()
#define COMSIG_MACHINERY_REFRESH_PARTS "machine_refresh_parts"
///from /obj/machinery/default_change_direction_wrench: (mob/user, obj/item/wrench)
#define COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH "machinery_default_rotate_wrench"

///from /obj/machinery/can_interact(mob/user): Called on user when attempting to interact with a machine (obj/machinery/machine)
#define COMSIG_TRY_USE_MACHINE "try_use_machine"
	/// Can't interact with the machine
	#define COMPONENT_CANT_USE_MACHINE_INTERACT (1<<0)
	/// Can't use tools on the machine
	#define COMPONENT_CANT_USE_MACHINE_TOOLS (1<<1)

#define COMSIG_ORE_SILO_PERMISSION_CHECKED "ore_silo_permission_checked"
	/// The ore silo is not allowed to be used
	#define COMPONENT_ORE_SILO_DENY (1<<0)
	/// The ore silo is allowed to be used
	#define COMPONENT_ORE_SILO_ALLOW (1<<1)

///from obj/machinery/iv_drip/IV_attach(target, usr) : (attachee)
#define COMSIG_IV_ATTACH "iv_attach"
///from obj/machinery/iv_drip/IV_detach() : (detachee)
#define COMSIG_IV_DETACH "iv_detach"


// /obj/machinery/computer/teleporter
/// from /obj/machinery/computer/teleporter/proc/set_target(target, old_target)
#define COMSIG_TELEPORTER_NEW_TARGET "teleporter_new_target"

// /obj/machinery/power/supermatter_crystal
/// from /obj/machinery/power/supermatter_crystal/process_atmos(); when the SM sounds an audible alarm
#define COMSIG_SUPERMATTER_DELAM_ALARM "sm_delam_alarm"


// /obj/machinery/cryo_cell signals

/// from /obj/machinery/cryo_cell/set_on(bool): (on)
#define COMSIG_CRYO_SET_ON "cryo_set_on"

/// from /obj/proc/unfreeze()
#define COMSIG_OBJ_UNFREEZE "obj_unfreeze"

// /obj/machinery/atmospherics/components/binary/valve signals

/// from /obj/machinery/atmospherics/components/binary/valve/toggle(): (on)
#define COMSIG_VALVE_SET_OPEN "valve_toggled"

/// from /obj/machinery/atmospherics/set_on(active): (on)
#define COMSIG_ATMOS_MACHINE_SET_ON "atmos_machine_set_on"

/// from /obj/machinery/light_switch/set_lights(), sent to every switch in the area: (status)
#define COMSIG_LIGHT_SWITCH_SET "light_switch_set"

/// from /obj/machinery/fire_alarm/reset(), /obj/machinery/fire_alarm/alarm(): (status)
#define COMSIG_FIREALARM_ON_TRIGGER "firealarm_trigger"
#define COMSIG_FIREALARM_ON_RESET "firealarm_reset"

// /obj access signals

#define COMSIG_OBJ_ALLOWED "door_try_to_activate"
	#define COMPONENT_OBJ_ALLOW (1<<0)
	#define COMPONENT_OBJ_DISALLOW (1<<1)

#define COMSIG_AIRLOCK_SHELL_ALLOWED "airlock_shell_try_allowed"

// /obj/machinery/door/airlock signals

//from /obj/machinery/door/airlock/open(): (forced)
#define COMSIG_AIRLOCK_OPEN "airlock_open"
//from /obj/machinery/door/airlock/close(): (forced)
#define COMSIG_AIRLOCK_CLOSE "airlock_close"
///from /obj/machinery/door/airlock/set_bolt():
#define COMSIG_AIRLOCK_SET_BOLT "airlock_set_bolt"
///from /obj/machinery/door/airlock/bumpopen(), to the carbon who bumped: (airlock)
#define COMSIG_CARBON_BUMPED_AIRLOCK_OPEN "carbon_bumped_airlock_open"
	/// Return to stop the door opening on bump.
	#define STOP_BUMP (1<<0)

///Closets
///From base of [/obj/structure/closet/proc/insert]: (atom/movable/inserted)
#define COMSIG_CLOSET_INSERT "closet_insert"
	///used to interrupt insertion
	#define COMPONENT_CLOSET_INSERT_INTERRUPT (1<<0)

///From open: (forced)
#define COMSIG_CLOSET_PRE_OPEN "closet_pre_open"
	#define BLOCK_OPEN (1<<0)
///From open: (forced)
#define COMSIG_CLOSET_POST_OPEN "closet_post_open"

///From close
#define COMSIG_CLOSET_PRE_CLOSE "closet_pre_close"
	#define BLOCK_CLOSE (1<<1)
///From close
#define COMSIG_CLOSET_POST_CLOSE "closet_post_close"

///a deliver_first element closet was successfully delivered
#define COMSIG_CLOSET_DELIVERED "crate_delivered"

///Eigenstasium
///From base of [/datum/controller/subsystem/eigenstates/proc/use_eigenlinked_atom]: (var/target)
#define COMSIG_EIGENSTATE_ACTIVATE "eigenstate_activate"

// /obj signals for economy
///called when the payment component tries to charge an account.
#define COMSIG_OBJ_ATTEMPT_CHARGE "obj_attempt_simple_charge"
	#define COMPONENT_OBJ_CANCEL_CHARGE  (1<<0)
///Called when a payment component changes value
#define COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE "obj_attempt_simple_charge_change"

// /obj/item signals for economy
///called before an item is sold by the exports system.
#define COMSIG_ITEM_PRE_EXPORT "item_pre_sold"
	/// Stops the export from calling sell_object() on the item, so you can handle it manually.
	#define COMPONENT_STOP_EXPORT (1<<0)
///called when an item is sold by the exports subsystem
#define COMSIG_ITEM_EXPORTED "item_sold"
	/// Stops the export from adding the export information to the report, so you can handle it manually.
	#define COMPONENT_STOP_EXPORT_REPORT (1<<0)
///called when a wrapped up item is opened by hand
#define COMSIG_ITEM_UNWRAPPED "item_unwrapped"
///called when getting the item's exact ratio for cargo's profit.
#define COMSIG_ITEM_SPLIT_PROFIT "item_split_profits"
///called when getting the item's exact ratio for cargo's profit, without selling the item.
#define COMSIG_ITEM_SPLIT_PROFIT_DRY "item_split_profits_dry"

/// Called on component/uplink/OnAttackBy(..)
#define COMSIG_ITEM_ATTEMPT_TC_REIMBURSE "item_attempt_tc_reimburse"
///Called when a holoparasite/guardiancreator is used.
#define COMSIG_TRAITOR_ITEM_USED(type) "traitor_item_used_[type]"

// /obj/item/clothing signals

///from [/mob/living/carbon/human/Move]: ()
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"

// /obj/projectile signals (sent to the firer)

///from base of /obj/projectile/proc/on_hit(), like COMSIG_PROJECTILE_ON_HIT but on the projectile itself and with the hit limb (if any): (atom/movable/firer, atom/target, angle, hit_limb)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, angle, hit_limb)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/firer, atom/original_target)
#define COMSIG_PROJECTILE_FIRER_BEFORE_FIRE "projectile_firer_before_fire"
///from the base of /obj/projectile/proc/fire(): ()
#define COMSIG_PROJECTILE_FIRE "projectile_fire"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"
	#define PROJECTILE_INTERRUPT_HIT (1<<0)
///from /obj/projectile/pixel_move(): ()
#define COMSIG_PROJECTILE_PIXEL_STEP "projectile_pixel_step"
///sent to self during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_SELF_PREHIT "com_proj_prehit"
///from the base of /obj/projectile/Range(): ()
#define COMSIG_PROJECTILE_RANGE "projectile_range"
///from the base of /obj/projectile/on_range(): ()
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"
///from the base of /obj/projectile/process(): ()
#define COMSIG_PROJECTILE_BEFORE_MOVE "projectile_before_move"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"

// /obj/vehicle/sealed/car/vim signals

///from /datum/action/vehicle/sealed/noise/chime/Trigger(): ()
#define COMSIG_VIM_CHIME_USED "vim_chime_used"
///from /datum/action/vehicle/sealed/noise/buzz/Trigger(): ()
#define COMSIG_VIM_BUZZ_USED "vim_buzz_used"
///from /datum/action/vehicle/sealed/headlights/vim/Trigger(): (headlights_on)
#define COMSIG_VIM_HEADLIGHTS_TOGGLED "vim_headlights_toggled"

// /obj/vehicle/sealed/mecha signals

/// sent if you attach equipment to mecha
#define COMSIG_MECHA_EQUIPMENT_ATTACHED "mecha_equipment_attached"
/// sent if you detach equipment to mecha
#define COMSIG_MECHA_EQUIPMENT_DETACHED "mecha_equipment_detached"
/// sent when you are able to drill through a mob
#define COMSIG_MECHA_DRILL_MOB "mecha_drill_mob"

///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_TRIGGER "mecha_action_activate"

///sent from clicking while you have no equipment selected. Sent before cooldown and adjacency checks, so you can use this for infinite range things if you want.
#define COMSIG_MECHA_MELEE_CLICK "mecha_action_melee_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_MELEE_CLICK (1<<0)
///sent from clicking while you have equipment selected.
#define COMSIG_MECHA_EQUIPMENT_CLICK "mecha_action_equipment_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_EQUIPMENT_CLICK (1<<0)

/// from /obj/structure/sign/poster/trap_succeeded() : (mob/user)
#define COMSIG_POSTER_TRAP_SUCCEED "poster_trap_succeed"

/// from /obj/machinery/mineral/ore_redemption/pickup_item when it successfully picks something up
#define COMSIG_ORM_COLLECTED_ORE "orm_collected_ore"

#define COMSIG_RADIATION_RECIEVED "radiation_recieved"
/// from /obj/plunger_act when an object is being plungered
#define COMSIG_PLUNGER_ACT "plunger_act"

/// from /obj/structure/cursed_slot_machine/handle_status_effect() when someone pulls the handle on the slot machine
#define COMSIG_CURSED_SLOT_MACHINE_USE "cursed_slot_machine_use"
	#define SLOT_MACHINE_USE_CANCEL (1<<0) //! we've used up the number of times we may use this slot machine. womp womp.
	#define SLOT_MACHINE_USE_POSTPONE (1<<1) //! we haven't used up all our attempts to gamble away our life but we should chill for a few seconds

/// from /obj/structure/cursed_slot_machine/determine_victor() when someone loses.
#define COMSIG_CURSED_SLOT_MACHINE_LOST "cursed_slot_machine_lost"

/// from /obj/structure/cursed_slot_machine/determine_victor() when someone finally wins.
#define COMSIG_GLOB_CURSED_SLOT_MACHINE_WON "cursed_slot_machine_won"
