/datum/ai_project/firewall
	name = "Download Firewall"
	description = "By hiding your various functions you should be able to prolong the time it takes to download your consciousness by 2x."
	research_cost = 1500
	ram_required = 2
	category = AI_PROJECT_MISC

/datum/ai_project/firewall/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.downloadSpeedModifier *= 0.5


/datum/ai_project/firewall/stop()
	ai.downloadSpeedModifier *= 2
	..()

/datum/ai_project/blockade
	name = "Download Blockade"
	description = "By converting old tools from online archives to fit your systems, you should be able to halt any attempts to download your consciousness."
	research_cost = 3000
	ram_required = 3
	research_requirements = list(/datum/ai_project/firewall)
	category = AI_PROJECT_MISC

/datum/ai_project/blockade/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.can_download = FALSE

/datum/ai_project/blockade/stop()
	ai.can_download = TRUE
	..()

