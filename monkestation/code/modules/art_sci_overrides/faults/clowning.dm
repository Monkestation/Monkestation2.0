/datum/artifact_fault/clown
	name = "Funny Fault"
	trigger_chance = 5
	inspect_warning = list("Smells faintly of bananas","Looks Funny.","Hates mimes.")
	visible_message = "Brings forth a clown!"
	discovered_credits = -500
	research_value = 250

	weight = ARTIFACT_VERYRARE

/datum/artifact_fault/clown/on_trigger()
	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	var/mob/living/basic/clown/hehe = new(src)

	addtimer(CALLBACK(hehe,PROC_REF(Destroy)),3 MINUTE)
