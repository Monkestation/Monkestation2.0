/////////////////////////////////////////// LIGHT AMPLIFICATION /////////////////////////////////////////////
/obj/item/mecha_parts/mecha_equipment/light_amplification
	name = "exosuit light amplification module"
	desc = "An enhancement module for the mech cockpit which enables night vision and meson vision functionality."
	icon_state = "mecha_lightamplification"
	equipment_slot = MECHA_UTILITY
	can_be_toggled = TRUE
	equip_weight = 20

/obj/item/mecha_parts/mecha_equipment/light_amplification/set_active(active)
	. = ..()
	if(active)
		to_chat(usr, "[icon2html(src, usr)][span_warning("Light amplification functionality enabled.")]")
		chassis.initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/light_amplification)
		log_message("Activated.", LOG_MECHA)
	else
		to_chat(usr, "[icon2html(src, usr)][span_warning("Light amplification functionality disabled.")]")
		chassis.remove_passenger_action_type(/datum/action/vehicle/sealed/mecha/light_amplification)
		log_message("Deactivated.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/light_amplification/attach(obj/vehicle/sealed/mecha/new_mecha, attach_right = FALSE)
	new_mecha.initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/light_amplification)
	return ..()

/obj/item/mecha_parts/mecha_equipment/light_amplification/detach()
	chassis.remove_passenger_action_type(/datum/action/vehicle/sealed/mecha/light_amplification)
	return ..()
