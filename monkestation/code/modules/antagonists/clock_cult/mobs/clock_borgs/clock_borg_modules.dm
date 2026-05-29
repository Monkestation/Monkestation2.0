/obj/item/clock_module
	name = "ratvarian borg module"
	desc = "cool."
	icon = 'monkestation/icons/mob/clock_cult/actions_clock.dmi'
	icon_state = "Replicant"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = NOBLUDGEON
	///what scripture type are we
	var/datum/scripture/scripture_datum = /datum/scripture

/obj/item/clock_module/Initialize(mapload)
	. = ..()

	scripture_datum = new scripture_datum()
	name = scripture_datum.name
	desc = scripture_datum.desc
	icon_state = scripture_datum.button_icon_state

/obj/item/clock_module/Destroy(force)
	var/scripture_ref = scripture_datum
	scripture_datum = null
	QDEL_NULL(scripture_ref)
	return ..()

/obj/item/clock_module/abscond
	scripture_datum = /datum/scripture/abscond

/obj/item/clock_module/kindle
	scripture_datum = /datum/scripture/slab/kindle

/obj/item/clock_module/sentinels_compromise
	scripture_datum = /datum/scripture/slab/sentinels_compromise

/obj/item/clock_module/sigil_transmission
	scripture_datum = /datum/scripture/create_structure/sigil_transmission

/obj/item/clock_module/prosperity_prism
	scripture_datum = /datum/scripture/create_structure/prosperity_prism

/obj/item/clock_module/ocular_warden
	scripture_datum = /datum/scripture/create_structure/ocular_warden

/obj/item/clock_module/tinkerers_cache
	scripture_datum = /datum/scripture/create_structure/tinkerers_cache

/obj/item/clock_module/stargazer
	scripture_datum = /datum/scripture/create_structure/stargazer

/obj/item/clock_module/vanguard
	scripture_datum = /datum/scripture/slab/vanguard

/obj/item/clock_module/sigil_submission
	scripture_datum = /datum/scripture/create_structure/sigil_submission
