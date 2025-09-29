// rbmk_integrity.dm
// Handles reactor integrity, repairable state, and meltdown triggers

/obj/machinery/rbmk/reactor/proc/update_reactor_integrity()
	if(!running)
		return

	var/damage = 0

	// --- Temperature stress ---
	if(temperature > 1500)
		// Damage scales faster the hotter it gets
		damage += (temperature - 1500) / 2000   // was /4000

	if(temperature > (max_temp * 0.9))
		// Near max temp = exponential stress
		damage += (temperature - (max_temp * 0.9)) / 200

	// --- Flux stress ---
	if(flux > 100)
		damage += (flux - 100) / 1000   // was /1500

	if(flux > 300)
		// High neutron flux snowballs hard
		damage += (flux - 300) / 300

	// --- Radiation stress ---
	if(radiation > 50)
		damage += (radiation - 50) / 500

	// --- Instability-driven stress ---
	if(instability > 100)
		// Above 100% instability, structural damage accelerates
		damage += (instability - 100) / 50

	// --- Pressure stress ---
	if(pressure > 17000) // warning zone
		damage += (pressure - 17000) / 2000

	if(pressure > 20000) // critical pressure zone
		damage += (pressure - 20000) / 500

	if(pressure > 23000) // extreme pressure zone
		damage += (pressure - 23000) / 100

	// --- Apply damage ---
	if(damage > 0)
		reactor_integrity = max(reactor_integrity - damage, 0)

		if(reactor_integrity <= 0)
			trigger_meltdown("⚠ Reactor breached from combined overload!")

	// --- Repairable flag ---
	repairable = (temperature < (max_temp * 0.7) && flux < 80 && pressure < 17000)
