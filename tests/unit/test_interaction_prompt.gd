extends UnitTestCase

## InteractionPrompt (Fase 1): texto contextual com ação e nome, e limpeza
## quando não há alvo válido.

const HUD_SCENE_PATH := "res://scenes/ui/hud.tscn"
const INTERACTABLE_SCRIPT := preload("res://scripts/interactables/interactable.gd")


func _make_prompt() -> InteractionPrompt:
	var scene: PackedScene = load(HUD_SCENE_PATH)
	var hud := scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(hud)
	return hud.get_node("InteractionPrompt") as InteractionPrompt


func _make_target(id: StringName, action: String, name: String) -> Interactable:
	var target := INTERACTABLE_SCRIPT.new() as Interactable
	target.interactable_id = id
	target.interaction_label = action
	target.display_name = name
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(target)
	return target


func test_prompt_shows_action_and_display_name() -> void:
	var prompt := _make_prompt()
	var target := _make_target(&"evidence_broken_glass", "Examinar", "Vidro quebrado")
	prompt.show_for_target(target)

	var label := prompt.get_node("PromptLabel") as Label
	assert_true(prompt.visible, "prompt visível com alvo válido")
	assert_eq(label.text, "[E] Examinar — Vidro quebrado", "texto contextual correto")
	assert_eq(prompt.current_target_id, &"evidence_broken_glass", "ID do alvo registrado no prompt")

	prompt.get_parent().free()
	target.free()


func test_prompt_hides_without_target() -> void:
	var prompt := _make_prompt()
	var target := _make_target(&"suspect_mara", "Entrevistar", "Mara")
	prompt.show_for_target(target)
	prompt.hide_prompt()

	var label := prompt.get_node("PromptLabel") as Label
	assert_false(prompt.visible, "prompt oculto após hide")
	assert_eq(label.text, "", "texto limpo após hide")
	assert_eq(prompt.current_target_id, &"", "ID limpo após hide")

	prompt.get_parent().free()
	target.free()


func test_prompt_hides_for_deactivated_target() -> void:
	var prompt := _make_prompt()
	var target := _make_target(&"exit_apartment", "Sair", "Apartamento")
	target.is_interactable = false
	prompt.show_for_target(target)

	assert_false(prompt.visible, "alvo desativado não exibe prompt")

	prompt.get_parent().free()
	target.free()
