class_name InteractionScanner
extends Area2D

## Detecta Interactables sobrepostos ao círculo do scanner e mantém apenas o
## alvo válido mais próximo ativo. A seleção não depende da ordem dos sinais
## de área: usa distância ao pivô e, em empate exato, o ID lexicográfico.

signal active_target_changed(target: Interactable)
signal interaction_requested(target: Interactable)

var _nearby_targets: Array[Interactable] = []
var _active_target: Interactable = null


func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not area_exited.is_connected(_on_area_exited):
		area_exited.connect(_on_area_exited)


func _physics_process(_delta: float) -> void:
	_refresh_active_target()


func register_interactable(interactable: Interactable) -> void:
	if not is_instance_valid(interactable):
		return
	if not _nearby_targets.has(interactable):
		_nearby_targets.append(interactable)
	_refresh_active_target()


func unregister_interactable(interactable: Interactable) -> void:
	_nearby_targets.erase(interactable)
	if _active_target == interactable:
		_set_target_highlighted(null)
		_active_target = null
		active_target_changed.emit(null)


func request_interaction_with_active_target() -> void:
	_refresh_active_target()

	if not is_instance_valid(_active_target):
		return
	if not _active_target.can_interact():
		return

	interaction_requested.emit(_active_target)


func get_current_target() -> Interactable:
	return _active_target


func get_interaction_range() -> float:
	var circle := _get_circle_shape()
	if circle == null:
		return 0.0
	return circle.radius


func _on_area_entered(area: Area2D) -> void:
	var target := area as Interactable
	if target != null:
		register_interactable(target)


func _on_area_exited(area: Area2D) -> void:
	var target := area as Interactable
	if target != null:
		unregister_interactable(target)


func _refresh_active_target() -> void:
	_prune_invalid_targets()

	var best_target: Interactable = null
	var best_distance_squared := INF
	var max_range_squared := _get_circle_radius_squared()

	for target in _nearby_targets:
		if not target.can_interact():
			continue

		var distance_squared := global_position.distance_squared_to(target.global_position)
		if distance_squared > max_range_squared:
			continue

		var is_closer := distance_squared < best_distance_squared
		var is_exact_tie_with_lower_id := (
			distance_squared == best_distance_squared
			and best_target != null
			and String(target.interactable_id) < String(best_target.interactable_id)
		)

		if best_target == null or is_closer or is_exact_tie_with_lower_id:
			best_target = target
			best_distance_squared = distance_squared

	if best_target == _active_target:
		return

	_set_target_highlighted(best_target)
	_active_target = best_target
	if is_instance_valid(_active_target):
		_active_target.set_highlighted(true)
	active_target_changed.emit(_active_target)


func _prune_invalid_targets() -> void:
	for index in range(_nearby_targets.size() - 1, -1, -1):
		var target := _nearby_targets[index]
		if (
			not is_instance_valid(target)
			or target.is_queued_for_deletion()
			or not target.is_inside_tree()
		):
			_nearby_targets.remove_at(index)


func _set_target_highlighted(target: Interactable) -> void:
	if is_instance_valid(_active_target) and _active_target != target:
		_active_target.set_highlighted(false)


func _get_circle_shape() -> CircleShape2D:
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or shape_node.shape == null:
		push_error("InteractionScanner: CollisionShape2D com CircleShape2D não configurado.")
		return null
	var circle := shape_node.shape as CircleShape2D
	if circle == null:
		push_error("InteractionScanner: a forma de colisão deve ser CircleShape2D.")
	return circle


func _get_circle_radius_squared() -> float:
	var circle := _get_circle_shape()
	if circle == null:
		return 0.0
	return circle.radius * circle.radius
