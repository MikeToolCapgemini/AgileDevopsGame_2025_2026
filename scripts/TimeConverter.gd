extends Node
class_name TimeConverter

enum TimeUnit { DAYS, MONTHS , YEARS}

func subtract_months(datetime: Dictionary, months: int) -> Dictionary:
	var result = datetime.duplicate()

	result.month -= months
	while result.month <= 0:
		result.month += 12
		result.year -= 1

	return result


func get_cutoff_time(amount: int, unit: TimeUnit) -> int:
	if unit == TimeUnit.DAYS:
		return Time.get_unix_time_from_system() - amount * 86400

	var dt = subtract_months(
		Time.get_datetime_dict_from_system(),
		amount
	)
	return Time.get_unix_time_from_datetime_dict(dt)
