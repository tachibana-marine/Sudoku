extends GutTest

var _scene = load("res://scene/main.tscn")


func test_main_scene_can_be_instantiated():
  var main = autofree(_scene.instantiate())
  assert_not_null(main)


func test_there_is_sudoku():
  var main = autofree(_scene.instantiate())
  assert_true(main.get_node("Sudoku") is Sudoku)


func test_main_scene_has_version_number():
  var main = add_child_autofree(_scene.instantiate())
  assert_eq(main.get_node("Version").text, Constants.VERSION_NUMBER)


func test_clear_window_shows_up_on_complete():
  var main = add_child_autofree(_scene.instantiate())
  assert_false(main.get_node("ClearWindow").is_visible())
  var sudoku = main.get_node("Sudoku")
  sudoku.reset_cells()
  sudoku.fill_grid()
  var cells = sudoku.get_cells()
  sudoku.cell_edited.emit(cells[0])
  assert_true(main.get_node("ClearWindow").is_visible())
