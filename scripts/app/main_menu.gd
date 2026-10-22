extends Control

@onready var button_start: Button = $Container/ButtonStart
@onready var button_quit: Button = $Container/ButtonQuit

func _ready() -> void:
    button_start.pressed.connect(_on_start_pressed)
    button_quit.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
    var main = get_node("../..")
    main.start_case()

func _on_quit_pressed() -> void:
    get_tree().quit()
