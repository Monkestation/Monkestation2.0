/client/verb/show_tickets()
	set name = "Tickets"
	set desc = "Show list of tickets"
	set category = "Admin"

	if(holder)
		GLOB.ahelp_tickets.ui_interact(usr)
	else
		if(current_ticket && current_ticket.state == AHELP_ACTIVE)
			current_ticket.TicketPanel()
			return
		to_chat(src, span_danger("You have no open tickets!"))
	return
