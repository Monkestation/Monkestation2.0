/datum/export/cash
	cost = 1
	unit_name = "bills"
	export_types = list(/obj/item/stack/spacecash)

/datum/export/cash/get_cost(obj/O)
	var/obj/item/stack/spacecash/C = O
	return C.amount * C.value

/datum/export/holochip
	cost = 1
	unit_name = "holochip"
	export_types = list(/obj/item/holochip)

/datum/export/holochip/get_cost(atom/movable/AM)
	var/obj/item/holochip/H = AM
	return H.credits
