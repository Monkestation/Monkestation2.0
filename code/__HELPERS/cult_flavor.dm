/* -- Flavour text for refusing/accepting conversion.
-- Possible context (static) :
	=> Dept (weighted 3)
	=> Specific job (weighted 5)
	=> Race (weighted 3)
	=> Specific special role (weighted 5)
-- Possible context (dynamic) :
	=> The guy that converted you is from the same dept (weighted 3)
	=> Your boss is in the cult (CMO for medbay, ...)
	=> Your underlings are in the cult
	=> Your colleagues are in the cult
	=> Cult has a few/a lot of alive members
*/


GLOBAL_LIST_INIT(acceptance_lines_by_dept,  list(
	ACCOUNT_CMD = list(
		"I knew you had it in you." = 3,
		"The chains of commanding are broken." = 3,
		"Be ready to lead the stronger side." = 3,
		"Arise, new champion." = 3,
	),
	ACCOUNT_ENG = list(
		"The forges of the Geometer welcome you." = 3,
		"Your true potential has been unraveled. " = 3,
		"Forge the sword that will slay my enemies." = 3,
		"Arise, new craftsman." = 3,
	),
	ACCOUNT_MED = list(
		"The blood was always your companion." = 3,
		"You healed so many... but only now are you truly alive." = 3,
		"Arise, new healer." = 3,
	),
	ACCOUNT_SCI = list(
		"This always was your calling." = 3,
		"The secrets of the veil are now yours to research." = 3,
		"The logical conclusion to your career choice." = 3,
		"Was it not what you always wanted?" = 3,
		"Arise, new adept." = 3,
	),
	ACCOUNT_CIV = list(
		"Only here will you be fulfilled." = 3,
		"A task has finally been given to you." = 3,
		"Rise up." = 3,
		"And there goes a life of servitude." = 3,
		"Arise, new peon." = 3,
	),
	ACCOUNT_CAR = list(
		"When this is over, expect much more than your dreamed 'Cargonia'." = 3,
		"Be the hand that arms my soldiers." = 3,
		"Arive, new armourer." = 3,
	),
	ACCOUNT_SEC = list(
		"Congratulations on joining the stronger side." = 3,
		"The corporate slave died. Let a new, free man take their place." = 3,
		"You have finally seen the light." = 3,
		"Your freedom begins at this hour, in this place." = 3,
		"Arise, new warrior." = 3,
	),
))

GLOBAL_LIST_INIT(acceptance_lines_by_specific_race,  list(
	/datum/species/plasmaman = list(
		"The pain ends now." = 3,
		"Even the dead may serve." = 3,
	),
))

// Context lines

GLOBAL_LIST_INIT(acceptance_lines_few_cultists, list(
	"Be the hand I need in these times." = 3,
	"You have been chosen." = 3,
))

GLOBAL_LIST_INIT(acceptance_lines_numerous_cultists, list(
	"Our numbers are limitless." = 3,
	"We get stronger with each soul." = 3,
	"Nothing will resist our might." = 3,
))


#define acceptance_lines_same_dept list( \
	"[converter.gender == MALE ? "He" : "She"] judged you well." = 5, \
	"And now you both serve the same purpose." = 5, \
	"Isn't teamwork a wonderful thing." = 5, \
)


/datum/team/cult/proc/send_flavour_text_accept(mob/victim, mob/converter)
	// -- Static context
	// Default lines
	var/list/valid_lines = list(
		"Another one joins the fold." = 1,
		"With each new one, the veil gets thinner." = 1,
		"All are welcome." = 1,
	)
	// The departement
	var/datum/job/victim_job = victim?.mind.assigned_role
	var/datum/job/converter_job = converter?.mind.assigned_role
	for (var/list/L in GLOB.acceptance_lines_by_dept)
		if (victim_job.paycheck_department in L)
			valid_lines += GLOB.acceptance_lines_by_dept[victim_job.paycheck_department]

	// The race
	if (ishuman(victim))
		var/mob/living/carbon/human/dude = victim
		if(dude.dna.species.type in GLOB.acceptance_lines_by_specific_race)
			valid_lines += GLOB.acceptance_lines_by_specific_race[dude.dna.species.type]

	// -- Dynamic context
	// Cultist count
	var/cultists = 0
	for (var/datum/mind/mind in members)
		if (mind&& mind.current && !mind.current.stat) // If he's alive
			cultists++

	// Not a lot of cultists...
	if (cultists < 3)
		valid_lines += GLOB.acceptance_lines_few_cultists

	// Or a lot of them !
	else if (cultists > 10)
		valid_lines += GLOB.acceptance_lines_numerous_cultists

	// Converter and victim are of the same dept
	if ((victim_job.paycheck_department) == (converter_job.paycheck_department))
		valid_lines += acceptance_lines_same_dept

	var/chosen_line = pick_weight(valid_lines)
	to_chat(victim, "<span class = 'game say'><span class = 'danger'>Nar-Sie</span> murmurs, <span class = 'sinister'>[chosen_line]</span>")

