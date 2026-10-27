extends UnitTestCase

## Cena-demo de arte procedural: fundo, cinco props, mesmo renderer,
## definições corretas, posições independentes e troca de variante.

const DEMO_SCENE_PATH := "res://scenes/procedural/procedural_art_demo.tscn"
const RENDERER_SCRIPT_PATH := "res://scripts/procedural/procedural_art_renderer.gd"

const ART_PATHS: Array[String] = [
	"Background",
	"Props/HotelDesk/Art",
	"Props/HotelDeskAlt/Art",
	"Props/HotelPlant/Art",
	"Props/HotelPainting/Art",
	"Props/Detective/Art",
]


func _instantiate_demo():
	var tree := Engine.get_main_loop() as SceneTree
	var scene: PackedScene = load(DEMO_SCENE_PATH)
	var demo = scene.instantiate()
	tree.root.add_child(demo)
	return demo


func test_demo_has_background_and_props_with_definitions() -> void:
	var demo = _instantiate_demo()
	var expected := {
		"Background": &"room_background",
		"Props/HotelDesk/Art": &"hotel_desk",
		"Props/HotelDeskAlt/Art": &"hotel_desk_alt",
		"Props/HotelPlant/Art": &"hotel_plant",
		"Props/HotelPainting/Art": &"hotel_painting",
		"Props/Detective/Art": &"detective",
	}

	for path: String in expected:
		var art := demo.get_node(path) as ProceduralArtRenderer
		assert_not_null(art, "%s usa ProceduralArtRenderer" % path)
		if art == null:
			continue
		assert_not_null(art.definition, "%s tem definição" % path)
		if art.definition == null:
			continue
		assert_eq(art.definition.definition_id, expected[path], "%s aponta para a definição certa" % path)
		assert_true(art.definition.commands.size() > 0, "%s tem comandos" % path)

	demo.free()


func test_all_art_nodes_use_the_same_renderer_script() -> void:
	var demo = _instantiate_demo()
	var renderer_script: GDScript = load(RENDERER_SCRIPT_PATH)
	for path: String in ART_PATHS:
		assert_eq(demo.get_node(path).get_script(), renderer_script, "%s usa o renderer único" % path)
	demo.free()


func test_props_can_be_positioned_independently() -> void:
	var demo = _instantiate_demo()
	var desk := demo.get_node("Props/HotelDesk") as Node2D
	var alt := demo.get_node("Props/HotelDeskAlt") as Node2D

	assert_ne(desk.position, alt.position, "instâncias começam em posições diferentes")
	desk.position = Vector2(120, 120)
	assert_eq(alt.position, Vector2(1020, 520), "mover uma instância não move a outra")
	demo.free()


func test_same_prefab_can_be_instantiated_twice_independently() -> void:
	var scene: PackedScene = load("res://scenes/props/hotel_desk.tscn")
	var first := scene.instantiate() as Node2D
	var second := scene.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(first)
	tree.root.add_child(second)

	first.position = Vector2(100, 100)
	second.position = Vector2(300, 100)
	var first_art := first.get_node("Art") as ProceduralArtRenderer
	var second_art := second.get_node("Art") as ProceduralArtRenderer

	assert_ne(first.position, second.position, "instâncias têm posições independentes")
	assert_eq(first_art.definition, second_art.definition, "as duas usam a mesma definição")
	assert_eq(first_art.definition.definition_id, &"hotel_desk", "definição compartilhada é a mesa clara")
	first.free()
	second.free()


func test_demo_switches_desk_definition_by_variant() -> void:
	var demo = _instantiate_demo()
	var art := demo.get_node("Props/HotelDesk/Art") as ProceduralArtRenderer
	var label := demo.get_node("UI/VariantLabel") as Label

	assert_eq(art.definition.definition_id, &"hotel_desk", "demo começa com a mesa clara")
	demo._apply_variant(1)
	assert_eq(art.definition.definition_id, &"hotel_desk_alt", "variante 1 troca a definição")
	assert_true(label.text.contains("hotel_desk_alt"), "rótulo acompanha a variante")
	demo._apply_variant(0)
	assert_eq(art.definition.definition_id, &"hotel_desk", "variante 0 volta à mesa clara")
	demo.free()


func test_demo_definition_ids_are_unique() -> void:
	var demo = _instantiate_demo()
	var ids: Array[StringName] = []
	for path: String in ART_PATHS:
		var art := demo.get_node(path) as ProceduralArtRenderer
		if art == null or art.definition == null:
			continue
		assert_false(ids.has(art.definition.definition_id), "%s reutiliza um ID" % path)
		ids.append(art.definition.definition_id)
	assert_eq(ids.size(), ART_PATHS.size(), "todos os nós de arte têm definição")
	demo.free()
