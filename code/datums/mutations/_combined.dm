/datum/generecipe
	var/required = "" //it hurts so bad but initial is not compatible with lists
	var/result = null

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	for(var/A in GLOB.mutation_recipes)
		if(findtext(A, "[mutation1]") && findtext(A, "[mutation2]"))
			return GLOB.mutation_recipes[A]

/* RECIPES */

/datum/generecipe/hulk
	required = "/datum/mutation/strong; /datum/mutation/radioactive"
	result = /datum/mutation/hulk

/datum/generecipe/mindread
	required = "/datum/mutation/antenna; /datum/mutation/paranoia"
	result = /datum/mutation/mindreader

/datum/generecipe/shock
	required = "/datum/mutation/insulated; /datum/mutation/radioactive"
	result = /datum/mutation/shock

/datum/generecipe/pyrokinesis
//	required = "/datum/mutation/cryokinesis; /datum/mutation/fire_breath" // MONKESTATION EDIT OLD
	required = "/datum/mutation/cryokinesis; /datum/mutation/fire" // MONKESTATION EDIT NEW
	result = /datum/mutation/cryokinesis/pyrokinesis

/datum/generecipe/antiglow
	required = "/datum/mutation/glow; /datum/mutation/void"
	result = /datum/mutation/glow/anti

/datum/generecipe/tonguechem
	required = "/datum/mutation/tongue_spike; /datum/mutation/stimmed"
	result = /datum/mutation/tongue_spike/chem

/datum/generecipe/martyrdom
	required = "/datum/mutation/strong; /datum/mutation/stimmed"
	result = /datum/mutation/martyrdom
