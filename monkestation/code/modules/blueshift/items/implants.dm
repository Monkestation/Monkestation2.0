//xeno-organs
/obj/item/autosurgeon/xeno
	name = "strange autosurgeon"
	icon = 'monkestation/code/modules/blueshift/icons/alien.dmi'
	surgery_speed = 2
	organ_whitelist = list(/obj/item/organ/internal/alien)

/obj/item/organ/internal/alien/plasmavessel/opfor
	stored_plasma = 500
	max_plasma = 500
	plasma_rate = 10

/obj/item/storage/organbox/strange
	name = "strange organ transport box"
	icon = 'monkestation/code/modules/blueshift/icons/alien.dmi'

/obj/item/storage/organbox/strange/Initialize(mapload)
	. = ..()
	reagents.add_reagent_list(list(/datum/reagent/cryostylane = 60))

/obj/item/storage/organbox/strange/PopulateContents()
	new /obj/item/autosurgeon/xeno(src)
	new /obj/item/organ/internal/alien/plasmavessel/opfor(src)
	new /obj/item/organ/internal/alien/resinspinner(src)
	new /obj/item/organ/internal/alien/acid(src)
	new /obj/item/organ/internal/alien/neurotoxin(src)
	new /obj/item/organ/internal/alien/hivenode(src)

/obj/item/storage/organbox/strange/eggsac/PopulateContents()
	. = ..()
	new /obj/item/organ/internal/alien/eggsac(src)
