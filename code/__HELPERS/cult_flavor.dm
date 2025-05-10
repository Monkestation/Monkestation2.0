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


/datum/team/cult/proc/send_flavour_text_accept(var/mob/victim, var/mob/converter)
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




/*

var/list/failure_lines_by_dept = list(
	COMMAND_POSITIONS = list(
		"You have failed to lead them. You would have failed to follow." = 3,
		"And so ends your 'authority.'" = 3,
		"This is what passes as command these days." = 3,
	),
	ENGINEERING_POSITIONS = list(
		"Our craft is more complex than your pathetic tinkering." = 3,
		"These machines were beyond your skill anyway." = 3,
	),
	MEDICAL_POSITIONS = list(
		"Your refusal helps no one. The blood will still flow." = 3,
		"There is no cure for this." = 3,
		"Nothing can heal the veil." = 3,
	),
	SCIENCE_POSITIONS = list(
		"Your closed mind dishonours you." = 3,
		"Our secrets were beyond your understanding." = 3,
		"My science was not for weaklings such as you." = 3,
	),
	CIVILIAN_POSITIONS = list(
		"A little job in life, and a forgotten death." = 3,
		"This refusal is but a footnote on my story." = 3,
		"You refused the only opportunity you had to make a difference." = 3,
	),
	CARGO_POSITION = list(
		"I care little for the hoarders of your kind." = 3,
		"As expected for a glorified crate handler." = 3,
	),
	SECURITY_POSITION = list(
		"You already failed." = 3,
		"This refusal does not erase your failure." = 3,
		"Your stubbornness amuses me. I already won." = 3,
		"I could have freed you." = 3,
		"You will always remain on the weaker side." = 3,
	),
)

var/list/failure_lines_by_specific_job = list(
	"Paramedic" = list(
		"You will not save anyone from where I sent you." = 5,
	),
	"Trader" = list(
		"I offered you a home, and you refused." = 5,
	),
	"Captain" = list(
		"Do you feel in charge?" = 5,
	),
)

var/list/failure_lines_by_specific_race = list(
	/datum/species/plasmaman = list(
		"Your loyalty to the company that twisted you into the living dead is amusing." = 3,
	)
)
var/list/failure_lines_few_cultists = list(
	"With or without you, my faithful shall triumph." = 3,
	"Do you truly think you won?" = 3,
	"I have no need of a coward in times like this." = 3,
)
var/list/failure_lines_numerous_cultists = list(
	"Your refusal changes nothing." = 3,
	"You will get to see this station fail from the first row." = 3,
)

#define failure_lines_same_dept list( \
	"[converter.gender == MALE ? "He" : "She"] tried to save you." = 5, \
	"You betrayed your friend." = 5, \
	"Your arrogance must have disappointed your friend." = 5, \
)



/datum/faction/bloodcult/proc/send_flavour_text_refuse(var/mob/victim, var/mob/converter)
	// -- Static context
	// Default lines
	var/list/valid_lines = list(
		"Not worthy of the gift." = 1,
		"A shame. Maybe you will see our light one day." = 1,
		"Unconquered in spirit... and destroyed in the flesh." = 1,
		"So much courage... for nothing." = 1,
	)
	// The departement
	var/victim_job = victim?.mind.assigned_role
	var/converter_job = converter?.mind.assigned_role
	for (var/list/L in failure_lines_by_dept)
		if (victim_job in L)
			valid_lines += failure_lines_by_dept[L]
	// The specific job
	valid_lines += failure_lines_by_specific_job[victim_job]
	// The roles he may add
	if (victim.mind)
		for (var/role in victim.mind.antag_roles)
			valid_lines += failure_lines_by_specific_role[role]
	// The race
	if (ishuman(victim))
		var/mob/living/carbon/human/dude = victim
		valid_lines += failure_lines_by_specific_race[dude.species.type]

	// -- Dynamic context
	// Cultist count
	var/cultists = 0
	for (var/datum/role/R in members)
		if (R.antag && R.antag.current && !R.antag.current.stat) // If he's alive
			cultists++

	// Not a lot of cultists...
	if (cultists < 3)
		valid_lines += failure_lines_few_cultists

	// Or a lot of them !
	else if (cultists > 10)
		valid_lines += failure_lines_numerous_cultists

	// Converter and victim are of the same dept
	for (var/list/dept in all_depts_list)
		if ((victim_job in dept) && (converter_job in dept))
			valid_lines += failure_lines_same_dept
	if(victim.mind && victim.mind.assigned_role == "Chaplain")
		var/list/cult_blood_chaplain = list("cult", "narsie", "nar'sie", "narnar", "nar-sie")
		var/list/cult_clock_chaplain = list("ratvar", "clockwork", "ratvarism")
		if (religion_name in cult_blood_chaplain)
			to_chat(victim, "<span class = 'game say'><span class = 'danger'>Nar-Sie</span> murmurs, <span class = 'sinister'>Rejoice, I will give you the ending you desired.</span></span>")
		else if (religion_name in cult_clock_chaplain)
			to_chat(victim, "<span class = 'game say'><span class = 'danger'>Nar-Sie</span> murmurs, <span class = 'sinister'>I will take your body, but when your soul returns to Ratvar, tell him that[pick(\
				"... he SUCKS!", \
				" there isn't room enough for the two of us on this plane!", \
				" he'll never be anything but a lame copycat.")]</span></span>")

	var/chosen_line = pickweight(valid_lines)
	to_chat(victim, "<span class = 'game say'><span class = 'danger'>Nar-Sie</span> murmurs, <span class = 'sinister'>[chosen_line]</span>")
	//to_chat(converter, "Nar-Sie murmurs to [victim]... <span class = 'warning'>[chosen_line]</span>")

*/
