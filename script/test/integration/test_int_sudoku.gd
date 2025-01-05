extends GutTest

var _scene = load("res://scene/sudoku.tscn")


func test_sudoku_scene_can_be_instantiated():
  var sudoku = autofree(_scene.instantiate())
  assert_not_null(sudoku)


func test_sudoku_scene_is_sudoku():
  var sudoku = autofree(_scene.instantiate())
  assert_true(sudoku.get_node("Sudoku") is Sudoku)


func test_sudoku_scene_has_version_number():
  var sudoku = add_child_autofree(_scene.instantiate())
  await wait_frames(1)
  assert_eq(sudoku.get_node("Version").text, Constants.VERSION_NUMBER)
