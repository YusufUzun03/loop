extends SceneTree
## Minimal headless test runner.
## Run: godot --headless --path . -s tests/run_tests.gd
## A test file is tests/test_*.gd extending RefCounted. Methods named test_*
## return "" on pass or an error message on failure. Exit code is 1 on any failure.


func _init() -> void:
	var failures := 0
	var total := 0
	for file in _list_test_files():
		var script = load("res://tests/" + file)
		if script == null:
			printerr("FAIL load ", file)
			failures += 1
			continue
		var suite = script.new()
		for method in suite.get_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			total += 1
			var result = suite.call(method_name)
			if result is String and result == "":
				print("PASS ", file, "::", method_name)
			else:
				printerr("FAIL ", file, "::", method_name, " - ", result)
				failures += 1
	print("%d tests, %d failed" % [total, failures])
	quit(1 if failures > 0 else 0)


func _list_test_files() -> Array[String]:
	var files: Array[String] = []
	var dir := DirAccess.open("res://tests")
	if dir == null:
		return files
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd"):
			files.append(f)
	files.sort()
	return files
