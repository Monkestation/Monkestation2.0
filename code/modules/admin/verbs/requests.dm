ADMIN_VERB(requests, R_NONE, FALSE, "Requests Manager", "Open the request manager panel to view all requests during this round", ADMIN_CATEGORY_GAME)
	BLACKBOX_LOG_ADMIN_VERB("Request Manager")
	GLOB.requests.ui_interact(user.mob)
