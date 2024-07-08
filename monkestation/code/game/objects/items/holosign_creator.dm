/obj/item/holosign_creator/emp_act(severity)
	. = ..()
	if(LAZYLEN(signs))
		for(var/sign as anything in signs)
			qdel(sign)
		return
