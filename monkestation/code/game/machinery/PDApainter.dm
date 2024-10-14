/obj/machinery/pdapainter
	/// A blacklist of PDA types that we should not be able to paint.
	var/static/list/pda_type_blacklist = list(
		/obj/item/modular_computer/pda/heads,
		/obj/item/modular_computer/pda/blueshield,
		/obj/item/modular_computer/pda/clear,
		/obj/item/modular_computer/pda/syndicate,
		/obj/item/modular_computer/pda/chameleon,
		/obj/item/modular_computer/pda/chameleon/broken)
