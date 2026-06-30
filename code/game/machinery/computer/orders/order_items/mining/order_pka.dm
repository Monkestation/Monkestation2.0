/datum/orderable_item/accelerator //self explanitory, only PKA's go here, NO wastepin locked weapons.
	category_index = CATEGORY_PKA

/datum/orderable_item/accelerator/gun
	item_path = /obj/item/gun/energy/recharge/kinetic_accelerator
	cost_per_order = 750

// MONKESTATION EDIT ADDITION START
/datum/orderable_item/accelerator/gun/repeater
	item_path = /obj/item/gun/energy/recharge/kinetic_accelerator/repeater
	cost_per_order = 1250

/datum/orderable_item/accelerator/gun/shockwave
	item_path = /obj/item/storage/box/shockwave
	cost_per_order = 1250

/datum/orderable_item/accelerator/gun/glock
	item_path = /obj/item/gun/energy/recharge/kinetic_accelerator/glock
	cost_per_order = 1250
// MONKESTATION EDIT ADDITION END

/datum/orderable_item/accelerator/range
	item_path = /obj/item/borg/upgrade/modkit/range
	cost_per_order = 1000

/datum/orderable_item/accelerator/damage
	item_path = /obj/item/borg/upgrade/modkit/damage
	cost_per_order = 1000

/datum/orderable_item/accelerator/cooldown
	item_path = /obj/item/borg/upgrade/modkit/cooldown
	cost_per_order = 1000

/datum/orderable_item/accelerator/aoe_mobs
	item_path = /obj/item/borg/upgrade/modkit/aoe/mobs
	cost_per_order = 2000

/datum/orderable_item/accelerator/minebot_passthrough
	item_path = /obj/item/borg/upgrade/modkit/minebot_passthrough
	cost_per_order = 1000

/datum/orderable_item/accelerator/chasis
	item_path = /obj/item/borg/upgrade/modkit/chassis_mod
	cost_per_order = 250

/datum/orderable_item/accelerator/chasis_orange
	item_path = /obj/item/borg/upgrade/modkit/chassis_mod/orange
	cost_per_order = 300

/datum/orderable_item/accelerator/tracer
	item_path = /obj/item/borg/upgrade/modkit/tracer
	cost_per_order = 100

/datum/orderable_item/accelerator/adjustable_tracer
	item_path = /obj/item/borg/upgrade/modkit/tracer/adjustable
	cost_per_order = 150

// MONKESTATION EDIT ADDITION START
/datum/orderable_item/accelerator/hardmode_upgrade
	item_path = /obj/item/borg/upgrade/modkit/hardmode
	cost_per_order = 500
// MONKESTATION EDIT ADDITION END
