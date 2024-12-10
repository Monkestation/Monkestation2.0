/obj/item/holosign_creator/emp_act(severity)
	. = ..()
	for(var/obj/structure/holosign/sign as anything in signs)
		qdel(sign)
