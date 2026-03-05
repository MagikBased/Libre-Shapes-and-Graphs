class_name LsgRateFunctions
extends RefCounted

static func linear(t: float) -> float:
	return t


static func smooth(t: float) -> float:
	var s := 1.0 - t
	return pow(t, 3.0) * (10.0 * s * s + 5.0 * s * t + t * t)


static func rush_into(t: float) -> float:
	return 2.0 * smooth(0.5 * t)


static func rush_from(t: float) -> float:
	return 2.0 * smooth(0.5 * (t + 1.0)) - 1.0


static func slow_into(t: float) -> float:
	return sqrt(maxf(0.0, 1.0 - (1.0 - t) * (1.0 - t)))


static func double_smooth(t: float) -> float:
	if t < 0.5:
		return 0.5 * smooth(2.0 * t)
	return 0.5 * (1.0 + smooth(2.0 * t - 1.0))


static func there_and_back(t: float) -> float:
	var new_t := 2.0 * t if t < 0.5 else 2.0 * (1.0 - t)
	return smooth(new_t)


static func there_and_back_with_pause(t: float, pause_ratio: float = 1.0 / 3.0) -> float:
	var a := 2.0 / (1.0 - pause_ratio)
	if t < 0.5 - pause_ratio * 0.5:
		return smooth(a * t)
	elif t < 0.5 + pause_ratio * 0.5:
		return 1.0
	return smooth(a - a * t)


static func running_start(t: float) -> float:
	return -0.5 * t * (1.0 - t) + t


static func overshoot(t: float, pull_factor: float = 1.5) -> float:
	var s := pull_factor
	var u := t - 1.0
	return 1.0 + u * u * ((s + 1.0) * u + s)


static func wiggle(t: float, wiggles: float = 2.0) -> float:
	return there_and_back(t) * sin(wiggles * PI * t)


static func lingering(t: float) -> float:
	if t < 0.8:
		return t / 0.8
	return 1.0


static func exponential_decay(t: float, half_life: float = 0.1) -> float:
	return 1.0 - exp(-t / half_life)


static func apply(rate_func_name: StringName, t: float) -> float:
	var clamped_t: float = clampf(t, 0.0, 1.0)
	match String(rate_func_name).to_lower():
		"linear":
			return linear(clamped_t)
		"smooth":
			return smooth(clamped_t)
		"rush_into":
			return rush_into(clamped_t)
		"rush_from":
			return rush_from(clamped_t)
		"slow_into":
			return slow_into(clamped_t)
		"double_smooth":
			return double_smooth(clamped_t)
		"there_and_back":
			return there_and_back(clamped_t)
		"there_and_back_with_pause":
			return there_and_back_with_pause(clamped_t)
		"running_start":
			return running_start(clamped_t)
		"overshoot":
			return overshoot(clamped_t)
		"wiggle":
			return wiggle(clamped_t)
		"lingering":
			return lingering(clamped_t)
		"exponential_decay":
			return exponential_decay(clamped_t)
		_:
			return smooth(clamped_t)
