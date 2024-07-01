//yeah this is totally worth its own file 100%
/obj/item/gang_device
	name = "gang device"
	icon = 'icons/obj/device.dmi' //used by multiple so sure
	///Text to add on init via a /datum/element/extra_examine/gang
	var/gang_examine

/obj/item/gang_device/Initialize(mapload)
	. = ..()
	if(gang_examine)
		AddElement(/datum/element/extra_examine/gang, span_syndradio(gang_examine))
