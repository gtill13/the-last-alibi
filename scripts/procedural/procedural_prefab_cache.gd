extends Node
class_name ProceduralPrefabCache

## Autoload opcional que mantém PackedScene carregadas e reutiliza instâncias.
## O cache é limitado para não acumular nós indefinidamente.

@export_range(0, 32, 1) var max_cached_instances_per_prefab: int = 4

var _packed_scenes: Dictionary = {} # scene_path -> PackedScene
var _instance_pools: Dictionary = {} # pool_key -> Array[Node]

## Obtém uma instância da cena, reutilizando uma instância inativa se existir.
## pool_key precisa ser igual no acquire_prefab() e release_prefab().
func acquire_prefab(scene_path: String, parent: Node, pool_key: StringName = &"") -> Node:
	if not is_instance_valid(parent):
		push_error("ProceduralPrefabCache: o parent informado não é válido.")
		return null

	var key := _make_key(scene_path, pool_key)
	var pool: Array = _instance_pools.get(key, [])
	var instance: Node = null

	while not pool.is_empty() and instance == null:
		var candidate: Variant = pool.pop_back()
		if is_instance_valid(candidate):
			instance = candidate as Node

	_instance_pools[key] = pool

	if instance == null:
		var packed_scene := _get_packed_scene(scene_path)
		if packed_scene == null:
			return null
		instance = packed_scene.instantiate()

	parent.add_child(instance)
	if instance is CanvasItem:
		(instance as CanvasItem).show()

	if instance.has_method("on_procedural_cache_acquired"):
		instance.call("on_procedural_cache_acquired")

	return instance

## Retira a instância da árvore, mas a mantém viva para reutilização posterior.
## Passe a mesma pool_key usada na aquisição. Se o pool estiver cheio, a instância é liberada.
func release_prefab(instance: Node, scene_path: String, pool_key: StringName = &"") -> void:
	if not is_instance_valid(instance):
		return

	var key := _make_key(scene_path, pool_key)
	if instance.has_method("on_procedural_cache_released"):
		instance.call("on_procedural_cache_released")

	if instance is CanvasItem:
		(instance as CanvasItem).hide()

	if instance.get_parent() != null:
		instance.get_parent().remove_child(instance)

	var pool: Array = _instance_pools.get(key, [])
	if pool.size() >= max_cached_instances_per_prefab:
		instance.queue_free()
	else:
		pool.append(instance)
		_instance_pools[key] = pool

## Quantidade de instâncias inativas guardadas para uma família.
func get_cached_instance_count(scene_path: String, pool_key: StringName = &"") -> int:
	var key := _make_key(scene_path, pool_key)
	var pool: Array = _instance_pools.get(key, [])
	return pool.size()

## Limpa instâncias inativas de uma família. Não afeta instâncias em uso.
func clear_pool(scene_path: String, pool_key: StringName = &"") -> void:
	var key := _make_key(scene_path, pool_key)
	var pool: Array = _instance_pools.get(key, [])
	for instance in pool:
		if is_instance_valid(instance):
			instance.queue_free()
	_instance_pools.erase(key)

## Limpa todos os pools de instâncias inativas.
func clear_all_pools() -> void:
	for key in _instance_pools.keys():
		var pool: Array = _instance_pools[key]
		for instance in pool:
			if is_instance_valid(instance):
				instance.queue_free()
	_instance_pools.clear()

func _get_packed_scene(scene_path: String) -> PackedScene:
	if _packed_scenes.has(scene_path):
		return _packed_scenes[scene_path] as PackedScene

	var loaded: Resource = ResourceLoader.load(scene_path)
	if loaded == null:
		push_error("ProceduralPrefabCache: não foi possível carregar '%s'." % scene_path)
		return null
	if not (loaded is PackedScene):
		push_error("ProceduralPrefabCache: '%s' não é uma PackedScene." % scene_path)
		return null

	var packed_scene := loaded as PackedScene
	_packed_scenes[scene_path] = packed_scene
	return packed_scene

func _make_key(scene_path: String, requested_key: StringName) -> StringName:
	if requested_key != &"":
		# Inclui o caminho para impedir que chaves repetidas misturem cenas diferentes.
		return StringName(scene_path + "#" + String(requested_key))
	return StringName(scene_path)
