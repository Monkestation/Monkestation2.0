/obj/item/holosign_creator/emp_act(severity)
	. = ..()
	if(!LAZYLEN(signs))
		return
	for(var/obj/structure/holosign/sign as anything in signs)
		qdel(sign)
