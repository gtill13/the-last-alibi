extends UnitTestCase

## Cache de prefabs: reutilização, isolamento por pool_key, limite de instâncias,
## hooks de reset e limpeza dos pools.

const PROBE_PATH := "res://tests/fixtures/procedural_cache_probe.tscn"


func _make_cache(max_instances: int = 4) -> ProceduralPrefabCache:
	var cache := ProceduralPrefabCache.new()
	cache.max_cached_instances_per_prefab = max_instances
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(cache)
	return cache


func _make_parent() -> Node2D:
	var parent := Node2D.new()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(parent)
	return parent


func _cleanup(cache: ProceduralPrefabCache, parent: Node) -> void:
	for key in cache._instance_pools.keys():
		var pool: Array = cache._instance_pools[key]
		for instance in pool:
			if is_instance_valid(instance):
				instance.free()
	cache._instance_pools.clear()
	cache.free()
	if is_instance_valid(parent):
		parent.free()


func test_acquire_adds_instance_to_parent() -> void:
	var cache := _make_cache()
	var parent := _make_parent()
	var instance := cache.acquire_prefab(PROBE_PATH, parent)

	assert_not_null(instance, "acquire devolve instância")
	assert_eq(parent.get_child_count(), 1, "instância entra no parent")
	assert_eq(instance.get_parent(), parent, "parent correto")
	assert_eq(instance.get("acquired_count"), 1, "hook de aquisição foi chamado")
	_cleanup(cache, parent)


func test_release_and_reacquire_reuses_same_instance() -> void:
	var cache := _make_cache()
	var parent := _make_parent()
	var first := cache.acquire_prefab(PROBE_PATH, parent)

	cache.release_prefab(first, PROBE_PATH)
	assert_false(first.is_inside_tree(), "release retira da árvore")
	assert_null(first.get_parent(), "release remove do parent")
	assert_false(first.get("visible"), "release oculta o CanvasItem")
	assert_eq(first.get("released_count"), 1, "hook de liberação foi chamado")

	var second := cache.acquire_prefab(PROBE_PATH, parent)
	assert_eq(second, first, "segunda aquisição reutiliza a instância")
	assert_true(second.get("visible"), "aquisição mostra a instância de novo")
	assert_eq(second.get("acquired_count"), 2, "hook de aquisição roda de novo")
	assert_eq(cache.get_cached_instance_count(PROBE_PATH), 0, "pool ficou vazio após reutilizar")
	_cleanup(cache, parent)


func test_pool_respects_limit() -> void:
	var cache := _make_cache(2)
	var parent := _make_parent()
	var instances: Array[Node] = []
	for _index in range(3):
		instances.append(cache.acquire_prefab(PROBE_PATH, parent))
	for instance in instances:
		cache.release_prefab(instance, PROBE_PATH)

	assert_eq(cache.get_cached_instance_count(PROBE_PATH), 2, "pool respeita o limite")
	assert_true(instances[2].is_queued_for_deletion(), "instância excedente é liberada")
	instances[2].free()
	_cleanup(cache, parent)


func test_pool_keys_are_isolated() -> void:
	var cache := _make_cache()
	var parent := _make_parent()
	var first := cache.acquire_prefab(PROBE_PATH, parent, &"a")
	cache.release_prefab(first, PROBE_PATH, &"a")
	var second := cache.acquire_prefab(PROBE_PATH, parent, &"b")

	assert_ne(first, second, "pool_key diferente cria outra instância")
	assert_eq(cache.get_cached_instance_count(PROBE_PATH, &"a"), 1, "pool A mantém sua instância")
	assert_eq(cache.get_cached_instance_count(PROBE_PATH, &"b"), 0, "pool B não recebe a instância de A")
	_cleanup(cache, parent)


func test_clear_pool_frees_inactive_instances() -> void:
	var cache := _make_cache()
	var parent := _make_parent()
	var instance := cache.acquire_prefab(PROBE_PATH, parent)
	cache.release_prefab(instance, PROBE_PATH)
	cache.clear_pool(PROBE_PATH)

	assert_eq(cache.get_cached_instance_count(PROBE_PATH), 0, "clear_pool esvazia a família")
	assert_true(instance.is_queued_for_deletion(), "instância inativa é liberada")
	instance.free()
	_cleanup(cache, parent)


func test_clear_all_pools_removes_every_family() -> void:
	var cache := _make_cache()
	var parent := _make_parent()
	var first := cache.acquire_prefab(PROBE_PATH, parent, &"a")
	var second := cache.acquire_prefab(PROBE_PATH, parent, &"b")
	cache.release_prefab(first, PROBE_PATH, &"a")
	cache.release_prefab(second, PROBE_PATH, &"b")

	assert_eq(cache._instance_pools.size(), 2, "dois pools ativos")
	cache.clear_all_pools()
	assert_eq(cache._instance_pools.size(), 0, "clear_all_pools esvazia tudo")
	first.free()
	second.free()
	_cleanup(cache, parent)


func test_release_invalid_instance_is_noop() -> void:
	var cache := _make_cache()
	cache.release_prefab(null, PROBE_PATH)
	assert_eq(cache._instance_pools.size(), 0, "release de nulo não cria pool")
	cache.free()


func test_scene_is_loaded_once() -> void:
	var cache := _make_cache()
	var parent := _make_parent()
	var first := cache.acquire_prefab(PROBE_PATH, parent)
	cache.release_prefab(first, PROBE_PATH)
	cache.acquire_prefab(PROBE_PATH, parent)

	assert_eq(cache._packed_scenes.size(), 1, "PackedScene é carregada uma vez")
	_cleanup(cache, parent)
