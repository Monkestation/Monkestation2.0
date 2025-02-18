/**
 * Converts a memory size with unit into bytes
 *
 * Converts a given size and unit into its equivalent in bytes, using binary prefixes
 * (1 KB = 1024 bytes). Supports B, KB, MB, and GB units. Units are case-insensitive.
 * Numbers are rounded to whole bytes.
 *
 * Arguments:
 * * size - Numeric value to convert (can be integer or floating point)
 * * unit - Text unit to convert from ("B", "KB", "MB", or "GB")
 *
 * Returns: Number of bytes as an integer, or null if input is invalid
 */
/proc/text2bytes(size, unit)
	if(!IS_FINITE(size) || !istext(unit))
		return null

	switch(uppertext(unit))
		if("B")
			return round(size)
		if("KB")
			return round(size * 1024)
		if("MB")
			return round(size * 1024 * 1024)
		if("GB")
			return round(size * 1024 * 1024 * 1024)
		else
			return null

