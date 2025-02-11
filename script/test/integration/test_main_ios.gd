extends GutTest

var _main_scene = load("res://scene/main_ios.tscn")


func test_complete_game():
  var main = add_child_autoqfree(_main_scene.instantiate())
  var sudoku = main.get_node("Sudoku")
  # assert version number
  assert_eq(main.get_node("Version").text, Constants.VERSION_NUMBER_IOS)

  await sudoku.grid_created
  # sudoku is visible
  assert_true(sudoku.is_visible())

  # ClearWindow is not visible
  assert_false(main.get_node("ClearWindow").is_visible())

  # force complete the grid
  sudoku.reset_cells()
  sudoku.set_cell_numbers(SudokuUtilTest.filled_grid)
  var cells = sudoku.get_cells()
  sudoku.cell_edited.emit(cells[0])

  # ClearWindow is visible
  assert_true(main.get_node("ClearWindow").is_visible())
