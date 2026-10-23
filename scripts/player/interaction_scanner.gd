extends Node
class_name InteractionScanner

signal interaction_target_changed(target_id: StringName, interaction_label: String)
signal interaction_target_lost

@export var interaction_range: float = 90.0
@export var player_node: Node2D

var current_target: Interactable = null
var nearby_interactables: Array[Interactable] = []

func _physics_process(_delta: float) -> void:
    if player_node == null:
        return
    _update_nearby()
    _select_best_target()

func register_interactable(interactable: Interactable) -> void:
    if not nearby_interactables.has(interactable):
        nearby_interactables.append(interactable)

func unregister_interactable(interactable: Interactable) -> void:
    nearby_interactables.erase(interactable)
    if current_target == interactable:
        _set_target_highlighted(false)
        current_target = null
        interaction_target_lost.emit()

func _update_nearby() -> void:
    # Decisão 1: detecção por distância euclidiana simples.
    var player_pos: Vector2 = player_node.global_position
    var still_nearby: Array[Interactable] = []
    for interactable in nearby_interactables:
        if not is_instance_valid(interactable):
            continue
        var distance: float = player_pos.distance_to(interactable.global_position)
        if distance <= interaction_range:
            still_nearby.append(interactable)
    nearby_interactables = still_nearby

func _select_best_target() -> void:
    # Decisão 2: mais próximo, desempate determinístico por ID lexicográfico.
    var player_pos: Vector2 = player_node.global_position
    var best: Interactable = null
    var best_distance: float = interaction_range
    var best_id: StringName = &""

    for interactable in nearby_interactables:
        if interactable == null or not interactable.is_interactable:
            continue
        var distance: float = player_pos.distance_to(interactable.global_position)
        if distance < best_distance:
            best = interactable
            best_distance = distance
            best_id = interactable.interactable_id
        elif distance == best_distance and best != null:
            # Desempate determinístico: menor ID lexicograficamente.
            if interactable.interactable_id < best_id:
                best = interactable
                best_id = interactable.interactable_id

    if best != current_target:
        _set_target_highlighted(false)
        current_target = best
        if best != null:
            _set_target_highlighted(true)
            interaction_target_changed.emit(best.interactable_id, best.interaction_label)
        else:
            interaction_target_lost.emit()

func _set_target_highlighted(highlighted: bool) -> void:
    if current_target != null:
        current_target.set_highlighted(highlighted)

func get_current_target() -> Interactable:
    return current_target

func interact_with_current() -> Interactable:
    return current_target
