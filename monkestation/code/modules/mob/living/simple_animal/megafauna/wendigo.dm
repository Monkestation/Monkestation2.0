/*

Difficulty: Medium

This is a monkestation override for wendigo

*/

/mob/living/simple_animal/hostile/megafauna/wendigo/monkestation_override
	name = "malnurished wendigo"
	desc = "A mythological man-eating legendary creature, the sockets of it's eyes track you with an unsatiated hunger. \
			This one seems highly malnurished, it will probably be easier to fight"

	stomp_range = 0
	scream_cooldown_time = 5 SECONDS
	weakened = TRUE
