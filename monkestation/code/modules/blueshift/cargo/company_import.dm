/datum/supply_order/company_import
	/// The armament entry used to fill the supply order
	var/datum/armament_entry/company_import/selected_entry
	/// The component used to create the order
	var/datum/component/armament/company_imports/used_component

/datum/supply_order/company_import/Destroy(force)
	selected_entry = null
	used_component = null
	return ..()

/datum/supply_order/company_import/proc/reimburse_armament()
	if(!selected_entry || !used_component)
		return
	used_component.purchased_items[selected_entry]--

#define CARGO_CUT 0.05

/datum/supply_pack/armament
	goody = TRUE
	crate_type = /obj/structure/closet/crate/large/import

/datum/supply_pack/armament/generate(atom/A, datum/bank_account/paying_account)
	. = ..()
	var/datum/bank_account/cargo_dep = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo_dep.account_balance += round(cost * CARGO_CUT)
	var/obj/structure/container = .
	for(var/obj/item/gun/gun_actually in container.contents)
		QDEL_NULL(gun_actually.pin)
		var/obj/item/firing_pin/permit_pin/new_pin = new(gun_actually)
		gun_actually.pin = new_pin

#undef CARGO_CUT


/obj/machinery/computer/cargo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armament/company_imports, subtypesof(/datum/armament_entry/company_import), 0)

/// Proc for speaking over radio without needing to reuse a bunch of code
/obj/machinery/computer/cargo/proc/radio_wrapper(atom/movable/speaker, message, channel)
	radio.talk_into(speaker, message, channel)

/obj/item/storage/lockbox/order
	/// Bool if this was departmentally ordered or not
	var/department_purchase
	/// Department of the person buying the crate if buying via the NIRN app.
	var/datum/bank_account/department/department_account

/obj/structure/closet/crate/large/import
	name = "heavy-duty wooden crate"
	icon = 'monkestation/code/modules/blueshift/icons/import_crate.dmi'

/obj/machinery/computer/cargo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action == "company_import_window")
		var/datum/component/armament/company_imports/company_import_component = GetComponent(/datum/component/armament/company_imports)
		company_import_component.ui_interact(usr)
		return TRUE
