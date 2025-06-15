
/obj/item/reagent_containers/hypospray/medipen/temperature //not a survival subtype, because a low pressure seal on a medipen as harmless as this is pointless
	name = "Temperature Stabilization Injector"
	desc = "A three use medipen with the only purpose being to stabilize body temperature. Handy if you plan to be lit on fire or fight a watcher."
	icon_state = "morphen"
	base_icon_state = "morphen"
	amount_per_transfer_from_this = 10
	volume = 30
	list_reagents = list(/datum/reagent/medicine/leporazine = 30)

/obj/item/reagent_containers/hypospray/medipen/survival/penthrite
	name = "Rapid Penthrite Injector"
	desc = "An expensive single use injector containing penthrite, allowing your body to keep functioning even with wounds that would make someone collapse. Seems to only be rapid in a low pressure enviorment as well... thats misleading. <b> WARNING: DO NOT MIX WITH EPINEPHRINE OR ATROPINE. </b>"
	icon_state = "atropen"
	base_icon_state = "atropen"
	amount_per_transfer_from_this = 15
	volume = 15
	list_reagents = list(/datum/reagent/medicine/c2/penthrite = 15)

/obj/item/reagent_containers/hypospray/medipen/survival/speed
	name = "Rush Injector"
	desc = "An experimental medipen containing some mysterious chemical cocktail that allows the user to move incredibly fast for a very short period of time. Takes a second to kick in. <b> SIDE EFFECTS OF USING MANY STIMS IN A SHORT PERIOD UNKNOWN </b>"
	icon_state = "gorillapen"
	base_icon_state = "gorillapen"
	amount_per_transfer_from_this = 4
	volume = 4
	list_reagents = list(/datum/reagent/consumable/monkey_energy = 1, /datum/reagent/medicine/stimulants = 1, /datum/reagent/medicine/ephedrine = 1, /datum/reagent/drug/cocaine = 1)

/obj/item/reagent_containers/hypospray/medipen/magnet
	name = "Magnetization Injector"
	desc = "A single use medipen that gives a long lasting magnetization effect, causing you to pull in ores laying on the ground. <b> WARNING : CONTENTS MAY BE LIGHTLY ALCOHOLIC IN NATURE </b>"
	icon_state = "invispen"
	base_icon_state = "invispen"
	amount_per_transfer_from_this = 30
	volume = 30
	list_reagents = list(/datum/reagent/consumable/ethanol/fetching_fizz = 30)

/obj/item/reagent_containers/hypospray/medipen/survival/luxury/oozling //oozling safe version of the luxury pen!
	name = "luxury oozling medipen"
	desc = "Even more cutting edge bluespace technology allowed Nanotrasen to compact 90u of volume into a single medipen. Contains rare and powerful chemicals that are also oozling safe! Used to aid in exploration of very harsh enviroments. WARNING: DO NOT MIX WITH EPINEPHRINE OR ATROPINE. <b> EXTRA WARNING : UNSAFE FOR NON OOZLING LIFE </b>"
	icon_state = "luxpen"
	inhand_icon_state = "atropen"
	base_icon_state = "luxpen"
	volume = 90
	amount_per_transfer_from_this = 90
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/c2/penthrite = 10, /datum/reagent/medicine/oxandrolone = 10, /datum/reagent/medicine/sal_acid = 10 ,/datum/reagent/medicine/regen_jelly = 10 ,/datum/reagent/toxin/plasma = 10, /datum/reagent/toxin = 10,/datum/reagent/medicine/leporazine = 10, /datum/reagent/medicine/painkiller/hydromorphone = 10)

/obj/item/reagent_containers/hypospray/medipen/synthcare
	name = "Small Synthetic Care Pen"
	desc = "A single use applicator made to care for synthetic parts on the go anywhere, be it a single prosthetic or an IPC. Contains chemicals that are safe but otherwise worthless for organics. <b> WARNING : DO NOT APPLY A SECOND APPLICATOR UNTIL FIRST HAS FULLY PROCESSED. FAILURE TO FOLLOW INSTRUCTIONS CAN PROVE HAZARDOUS TO SYNTHETICS. DOES NOT WORK ON CYBORGS. UNDER NO CIRCUMSTANCES IS THIS TO BE MIXED WITH ADVANCED NANITE SLURRY (FOUND IN THE ADVANCED SYNTHETIC CARE PEN)</b>"
	icon_state = "syndipen"
	base_icon_state = "syndipen"
	amount_per_transfer_from_this = 9
	volume = 9
	list_reagents = list(/datum/reagent/medicine/nanite_slurry = 9)

/obj/item/reagent_containers/hypospray/medipen/survival/synthcare
	name = "Advanced Synthetic Care Pen"
	desc = "A single use applicator made to rapidly fix urgent damage to synthetic parts on the go in low pressure enviorments and provide a small speed boost. Contains chemicals that are safe but otherwise worthless for organics. <b> WARNING : DO NOT APPLY A SECOND APPLICATOR UNTIL FIRST HAS FULLY PROCESSED. FAILURE TO FOLLOW INSTRUCTIONS IS GURANTEED TO BE LETHAL TO SYNTHETICS. DOES NOT WORK ON CYBORGS. UNDER NO CIRCUMSTANCES IS THIS TO BE MIXED WITH BASIC NANITE SLURRY (FOUND IN THE SMALL SYNTHETIC CARE PEN)</b>"
	icon_state = "nanite_hypo"
	base_icon_state = "nanite_hypo"
	amount_per_transfer_from_this = 10
	volume = 10
	list_reagents = list(/datum/reagent/medicine/nanite_slurry/strong = 9, /datum/reagent/medicine/stimulants = 1)
