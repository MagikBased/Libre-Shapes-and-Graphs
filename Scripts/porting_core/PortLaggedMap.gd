class_name PortLaggedMap
extends PortLaggedGroup


func _init(
	targets: Array,
	animation_factory: Callable,
	p_lag_ratio: float = 0.2,
	p_rate_func_name: StringName = &"linear"
) -> void:
	var mapped_animations: Array[PortAnimation] = []
	for i in range(targets.size()):
		var mapped := _map_to_animation(animation_factory, targets[i], i)
		if mapped != null:
			mapped_animations.append(mapped)
	super(mapped_animations, p_lag_ratio, p_rate_func_name)


func _map_to_animation(animation_factory: Callable, target_item: Variant, index: int) -> PortAnimation:
	if not animation_factory.is_valid():
		return null
	var arg_count := animation_factory.get_argument_count()
	var result = null
	if arg_count <= 0:
		result = animation_factory.call()
	elif arg_count == 1:
		result = animation_factory.call(target_item)
	else:
		result = animation_factory.call(target_item, index)
	if result is PortAnimation:
		return result as PortAnimation
	if result is PortAnimationBuilder:
		return (result as PortAnimationBuilder).build()
	return null
