#define CREDITS_PER_THREAT 60
#define DESIRED_THREAT_PER_PROCESS 2 //we process on SStraitor which has a wait of 10 SECONDS

/obj/machinery/gang_machine/credit_converter
	desc = "A suspicious looking machine with something that looks like a slot to input credits. Maybe its a vending machine?"
	icon_state = "exonet_node"
	circuit = /obj/item/circuitboard/machine/gang_credit_converter
	extra_examine_text = span_syndradio("A machine that will slowly convert inserted credits to threat for the gang that owns it.")
	setup_tc_cost = 15
	///Were we powered last time we checked
	var/is_powered = TRUE
	///How many credits do we have stored
	var/stored_credits = 0

/obj/machinery/gang_machine/credit_converter/do_setup(area/passed_area)
	. = ..()
	if(!owner)
		return

	var/area/our_area = passed_area || get_area(src)
	if(!our_area)
		return

	send_gang_message(owner, null, "Credit converter activated in [initial(our_area.name)]", "<span class='alertsyndie'>")

/obj/machinery/gang_machine/credit_converter/examine(mob/user)
	. = ..()
	if(!powered())
		. += "It looks to lack power and seems to be operating slower."

/obj/machinery/gang_machine/credit_converter/deconstruct(disassembled)
	. = ..()
	if(!. || !stored_credits)
		return

	new /obj/item/holochip(get_turf(src), stored_credits)

/obj/machinery/gang_machine/credit_converter/process(seconds_per_tick)
	if(!owner || !setup)
		end_processing()
		return

	is_powered = use_power(ACTIVE_POWER_USE)
	/*if(is_powered != use_power(ACTIVE_POWER_USE))
		is_powered = !is_powered
		if(is_powered)
			extra_examine_text = initial(extra_examine_text)*/
	var/desired_threat = round((DESIRED_THREAT_PER_PROCESS * seconds_per_tick) * is_powered ? 1 : 0.5, 0.1)
	var/threat_to_give = 0
	var/credits_to_pay = 0
	var/min_cost = DESIRED_THREAT_PER_PROCESS * CREDITS_PER_THREAT
	if((stored_credits / CREDITS_PER_THREAT) < desired_threat)
		end_processing()
		if(stored_credits < min_cost)
			return
		credits_to_pay = min_cost
		threat_to_give = DESIRED_THREAT_PER_PROCESS
	else
		threat_to_give = desired_threat
		credits_to_pay = round(desired_threat * CREDITS_PER_THREAT, 0.1)

	owner.threat += threat_to_give MINUTES //for now im just gonna leave updating the UI for this to the traitor SS loop as I need to check how expensive it is
	stored_credits -= credits_to_pay
	if(stored_credits < min_cost)
		end_processing()

/obj/machinery/gang_machine/credit_converter/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/holochip) || istype(weapon, /obj/item/stack/spacecash))
		if(!setup)
			to_chat(span_warning("[src] needs to be setup first!"))
			return ..()

		stored_credits += weapon.get_item_credit_value()
		balloon_alert(user, "You insert \the [weapon] into [src].")
		qdel(weapon)
		if(stored_credits >= DESIRED_THREAT_PER_PROCESS * CREDITS_PER_THREAT)
			begin_processing()
		return
	return ..()

/obj/item/circuitboard/machine/gang_credit_converter
	name = "Suspicious Circuitboard"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/gang_machine/credit_converter

#undef CREDITS_PER_THREAT
#undef DESIRED_THREAT_PER_PROCESS
