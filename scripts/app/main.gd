extends Node
class_name Main

@onready var world_host: Node = get_node("WorldHost")
@onready var ui_host: CanvasLayer = get_node("UIHost")
@onready var fade_overlay: CanvasLayer = get_node("FadeOverlay")
@onready var debug_overlay: CanvasLayer = get_node("DebugOverlay")

# Autoloads acessados via árvore de nós (singletons registrados no projeto).
var game_state = null
var scene_router = null

var current_world_scene: Node = null

func _ready() -> void:
    game_state = get_node("/root/GameState")
    scene_router = get_node("/root/SceneRouter")
    scene_router.scene_transition_started.connect(_on_transition_started)
    scene_router.scene_transition_finished.connect(_on_transition_finished)
    _show_main_menu()

func _show_main_menu() -> void:
    game_state.game_phase = "menu"
    _load_world_scene("res://scenes/app/main_menu.tscn")

func _load_world_scene(scene_path: String) -> void:
    if current_world_scene != null:
        current_world_scene.queue_free()
        current_world_scene = null
    scene_router.load_world_host(world_host, scene_path)

func _on_transition_started() -> void:
    pass

func _on_transition_finished(new_scene: Node) -> void:
    current_world_scene = new_scene

func start_case() -> void:
    game_state.game_phase = "briefing"
    _load_world_scene("res://scenes/investigation/investigation_level.tscn")

func quit_game() -> void:
    get_tree().quit()

func _process(_delta: float) -> void:
    if debug_overlay.visible:
        _update_debug_overlay()

func _update_debug_overlay() -> void:
    pass
