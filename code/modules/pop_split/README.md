# Pop Split module

Experimental population splitting module that splits based on playtime/connection time/random, and sends users to a freshly rebooted target server. If the target server does not reboot when requested, pop-split does not happen.

### What this does:

- On round-end, checks target server's population.
- If server has all dead mobs, or only lobby players or observers, it tells the target server to reboot immediately, so when players get connected, the server is already initialized.
- Grabs a list of clients eligible for pop-split, sorting by whatever the server operator has chosen via config (RANDOM, MOST_CONNECTION_TIME, LEAST_CONNECTION_TIME, MOST_PLAYTIME, LEAST_PLAYTIME), and cutting the list in half (splitting). Eventually this will be configurable so you can choose what fraction of players youd like to pop split, most times you'll only split half and half but who knows, maybe 60/40 will work
- Stores that list of clients in a global variable, hooks onto the `server_maint` subsystem shutdown, and does all the pop splitting there

There's checks at various points to make sure the code doesn't send players to a populated server, or a round that's 4 hours in the making with 2 pop.
