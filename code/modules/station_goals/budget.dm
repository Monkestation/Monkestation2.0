/// Crew must have more than 50K of credits available in the budget when they reach C.C
/datum/station_goal/budget
	name = "Budget Necessity"

/datum/station_goal/budget/get_report()
	return list(
		"<blockquote>Our financial advisors are worried.",
		"We need you to prove that this station remain financially viable.",
		"",
		"Secure atleast 50K of credits within the Cargo's budget before arriving to Central Command.",
		"-Nanotrasen Board of Shareholders</blockquote>",
	).Join("\n")

/datum/station_goal/budget/check_completion()
	if(..())
		return TRUE
	if(SSeconomy.get_dep_account(ACCOUNT_CAR)?.account_balance >= 50000)
		return TRUE
	return FALSE
