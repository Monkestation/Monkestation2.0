//machining skills, each level gives you the ability to cosntruct more recipes
#define MACHINING_SKILL_STOCK 3 //stock
#define MACHINING_SKILL_T1 (MACHINING_SKILL_STOCK*5) //tier 1
#define MACHINING_SKILL_T2 (MACHINING_SKILL_T1*2) //tier 2
#define MACHINING_SKILL_T3 (MACHINING_SKILL_T2*2) // tier 3
#define MACHINING_SKILL_T4 (MACHINING_SKILL_T3*2) // tier 4

/datum/skill/machinist
	name = "Machining"
	title = "Machinist"
	desc = "From the lathe to the workstation, this widens the scope of what you can create. Machining is the skill of crafting and assembling various mechanical and electronic components, allowing you to build everything from simple tools to complex machinery."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.75, 0.6, 0.5),
				SKILL_PROBS_MODIFIER = list(0, 2, 4, 6, 8, 10, 12))
