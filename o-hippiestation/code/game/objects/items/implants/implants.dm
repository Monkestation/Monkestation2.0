//only ment for ert or bussing
/obj/item/implant/adrenaline
	name = "adrenaline pump"
	desc = "When meth isn't enough."
	icon_state = "adrenal"
	implant_color = "r"
	uses = 2

/obj/item/implant/adrenaline/activate(source)
	. = ..()
	var/mob/living/carbon/carbon_imp_in = imp_in
	to_chat(carbon_imp_in, span_notice("Energy rushes through us."))
	carbon_imp_in.SetKnockdown(0)
	carbon_imp_in.set_resting(FALSE)
	SEND_SOUND(carbon_imp_in, sound('sound/magic/clockwork/narsie_attack.ogg'))
	carbon_imp_in.emote("fart")
	carbon_imp_in.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 10) //50 seconds
	carbon_imp_in.reagents.add_reagent(/datum/reagent/medicine/changelinghaste, 5) //10 seconds
	uses--

	if(!uses)
		addtimer(CALLBACK(carbon_imp_in, TYPE_PROC_REF(/atom, balloon_alert), carbon_imp_in, "adrenaline sack depleted!"), 1 SECONDS)
		qdel(src)


