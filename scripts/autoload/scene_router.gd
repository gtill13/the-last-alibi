extends Node
class_name SceneRouter

signal scene_transition_started
signal scene_transition_finished(new_scene: Node)

var fade_duration: float = 0.4

# Carrega uma cena de nível no WorldHost.
func load_world_host(world_host: Node, scene_path: String) -> void:
    var packed = load(scene_path)
    if packed == null:
        push_error("SceneRouter: não foi possível carregar a cena %s" % [scene_path])
        return
    scene_transition_started.emit()
    clear_world_host(world_host)
    var instance = packed.instantiate()
    world_host.add_child(instance)
    scene_transition_finished.emit(instance)

# Limpa o conteúdo atual do WorldHost.
func clear_world_host(world_host: Node) -> void:
    for child in world_host.get_children():
        if child is Node:
            child.queue_free()
