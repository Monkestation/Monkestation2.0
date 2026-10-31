/datum/ai_project/firewall
	name = "Download Firewall"
	description = "By converting old tools from online archives to fit your systems, you should be able to wall off any attempts to download your consciousness."
	research_cost = 3000
	ram_required = 2
	category = AI_PROJECT_MISC

/datum/ai_project/firewall/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.can_download = FALSE

/datum/ai_project/firewall/stop()
	ai.can_download = TRUE
	..()
