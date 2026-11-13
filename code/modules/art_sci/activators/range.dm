//range artifacts require stimuli to fall within a range between amount and base trigger amount
// hint range and hint chance are added onto range to see if something we should pull a hint for the user

/datum/artifact_activator/range
	name = "Generic Range Trigger"
	can_appear = FALSE
/datum/artifact_activator/range/setup(potency)
	. = ..()

/datum/artifact_activator/range/force
	name = "Physical Trauma"
	required_stimuli = list(STIMULUS_FORCE)
	highest_trigger_amount = 10 //*meaty thwack* *both chuckle*
	hint_texts = list("You almost want to start hitting things.", "A good whack might fix this.", "You suddenly want to throw something heavy at it.")
	discovered_text = "Activated by Kinetic Energy"
	can_appear = TRUE

/datum/artifact_activator/range/force/New()
	base_trigger_amount = rand(2,highest_trigger_amount)

/datum/artifact_activator/range/heat
	name = "Heat Sensitivity"
	required_stimuli = list(STIMULUS_HEAT)
	highest_trigger_amount = 750
	hint_texts = list("It feels like someone messed with the thermostat.", "It feels unpleasant being near.", "You can't tell if its hot or cold.")
	discovered_text = "Activated by Thermal Energy"
	can_appear = TRUE

/datum/artifact_activator/range/heat/New()
	base_trigger_amount = rand(350, highest_trigger_amount)

/datum/artifact_activator/range/shock
	name = "Electrically Charged"
	required_stimuli = list(STIMULUS_SHOCK)
	highest_trigger_amount = 1200
	hint_texts = list("You can feel the static in the air.", "Your hairs stand on their ends.","Shockingly, it exists.")
	discovered_text = "Activated by Electrical Energy"
	can_appear = TRUE

/datum/artifact_activator/range/shock/New()
	base_trigger_amount = rand(400, highest_trigger_amount)

/datum/artifact_activator/range/radiation
	name = "Radioactivity"
	required_stimuli = list(STIMULUS_RADIATION)
	highest_trigger_amount = 5
	base_trigger_amount = 1 //x-ray machine goes from 1-10
	hint_texts = list("Emits a hum that resembles the Supermatter.", "You swear you saw your bones for a second.", "It desires to glow like uranium glass.")
	discovered_text = "Activated by Radiation"
	can_appear = TRUE

/datum/artifact_activator/range/radiation/New()
	base_trigger_amount = rand(1,highest_trigger_amount)
