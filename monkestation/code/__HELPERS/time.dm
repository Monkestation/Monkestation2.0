///returns time diff of two times normalized to time_rate_multiplier
/proc/daytimeDiff(timeA, timeB)

	//if the time is less than station time, add 24 hours (MIDNIGHT_ROLLOVER)
	var/time_diff = timeA > timeB ? (timeB + 24 HOURS) - timeA : timeB - timeA
	return time_diff / SSticker.station_time_rate_multiplier // normalise with the time rate multiplier
