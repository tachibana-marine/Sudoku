extends GutTest

var _main_scene = load("res://scene/main.tscn")


func test_complete_game():
  var main = add_child_autoqfree(_main_scene.instantiate())
  var sudoku = main.get_node("Sudoku")
  # assert version number
  assert_eq(main.get_node("Version").text, Constants.VERSION_NUMBER)

  # sudoku is hidden
  assert_false(sudoku.is_visible())

  # progress window is visible
  var progress = main.get_node("Progress")
  assert_true(progress.is_visible())
  await sudoku.grid_created
  # waiting a few frames for the visibility to change
  wait_frames(10)
  # progress window is hidden after the grid is ready
  assert_false(progress.is_visible())

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
