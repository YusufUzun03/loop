extends RefCounted
## Smoke test: proves the project loads and the test runner works.


func test_project_name() -> String:
	var project_name = ProjectSettings.get_setting("application/config/name")
	if project_name != "loop":
		return "unexpected project name: %s" % project_name
	return ""
