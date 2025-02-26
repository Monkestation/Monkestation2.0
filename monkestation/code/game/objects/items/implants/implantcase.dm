/obj/item/implantcase/emag_act(mob/user, obj/item/card/emag/emag_card)
	if (imp)
		imp = imp.storage_emagged(user, emag_card)
		update_appearance()
		return TRUE
