extends GutTest

var _cell_scene = load("res://scene/cell.tscn")

var _cell_size: int


func before_all():
  var cell = add_child_autofree(_cell_scene.instantiate())
  _cell_size = cell.size


func test_sudoku_has_9x9_cells():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  assert_eq(cells.size(), 81)


func test_sudoku_has_9_boxes():
  var sudoku = add_child_autofree(Sudoku.new())
  var boxes = sudoku.get_boxes()
  assert_eq(boxes.size(), 9)


func test_sudoku_cells_has_proper_position():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  assert_eq(cells[0].position, Vector2.ZERO)
  assert_eq(cells[80].position, Vector2(8 * _cell_size, 8 * _cell_size))


func test_sudoku_box_border_has_proper_properties():
  var sudoku = add_child_autofree(Sudoku.new())
  var boxes = sudoku.get_boxes()
  # position
  assert_eq(boxes[0].position, Vector2.ZERO)
  assert_eq(boxes[8].position, Vector2(_cell_size * 6, _cell_size * 6))
  # size
  assert_eq(boxes[0].size, _cell_size * 3)


func test_sudoku_cell_changes_color_on_click():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  assert_null(sudoku.selected_cell)
  sudoku._on_click_cell(cells[3])
  assert_eq(sudoku.selected_cell, cells[3])
  assert_eq(cells[3].color, sudoku.selected_cell_color)


func test_sudoku_resets_color_on_click_cell():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  sudoku._on_click_cell(cells[3])
  sudoku._on_click_cell(cells[4])
  assert_eq(sudoku.selected_cell, cells[4])
  assert_eq(cells[3].color, sudoku.default_cell_color)
  assert_eq(cells[4].color, sudoku.selected_cell_color)


func test_fill_grid():
  var sudoku = add_child_autofree(Sudoku.new())
  watch_signals(sudoku)
  sudoku.set_state(894789547401239051)
  sudoku.fill_grid()

  for i in range(9):
    var cells_in_row = sudoku.get_cells_in_row(i)
    assert_true(SudokuUtil.verify_cells(cells_in_row))

  for i in range(9):
    var cells_in_box = sudoku.get_cells_in_box(i)
    assert_true(SudokuUtil.verify_cells(cells_in_box))

  for i in range(9):
    var cells_in_column = sudoku.get_cells_in_column(i)
    assert_true(SudokuUtil.verify_cells(cells_in_column))
  assert_signal_emitted(sudoku, "grid_filled")


func test_reset_cells():
  var sudoku = add_child_autofree(Sudoku.new())
  sudoku.set_cell_numbers(SudokuUtilTest.filled_grid)
  sudoku.reset_cells()
  var cells = sudoku.get_cell_numbers()
  assert_true(cells.all(func(num): return num == 0))


func test_make_non_zero_cells_immutable():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  cells[1].number = 1
  sudoku.make_non_zero_cells_immutable()
  assert_false(cells[0].is_immutable)
  assert_true(cells[1].is_immutable)


func test_create_grid():
  var sudoku = add_child_autofree(Sudoku.new())
  watch_signals(sudoku)
  await sudoku.create_grid()
  assert_signal_emitted(sudoku, "grid_filled")
  assert_signal_emitted(sudoku, "cells_removed")


func test_reset_as_much_as_possible_with_unique_solutions():
  var sudoku = add_child_autofree(Sudoku.new())
  watch_signals(sudoku)
  sudoku.set_cell_numbers(SudokuUtilTest.filled_grid)
  sudoku.set_state(200)
  sudoku.reset_as_much_as_possible_with_unique_solutions()
  var cells = sudoku.get_cell_numbers()
  var zero_count = 0
  for cell in cells:
    if cell == 0:
      zero_count += 1
  assert_ne(zero_count, 0)
  assert_eq(SudokuUtil.backtrack_cell(cells, 0, 0), 1)
  # assert_signal_emitted(sudoku, "cells_removed")


func test_change_cell_number():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  sudoku.set_number_of_cell(cells[10], 3)
  assert_eq(cells[10].number, 3)


func test_game_completes():
  var sudoku = add_child_autofree(Sudoku.new())
  watch_signals(sudoku)
  sudoku.set_state(2000)
  sudoku.fill_grid()
  assert_true(sudoku.is_complete())


class TestSudokuInput:
  extends GutTest

  var _sender = InputSender.new(Input)

  func before_all():
    _sender.mouse_warp = true

  func after_each():
    _sender.release_all()
    _sender.clear()

  func should_skip_script():
    if DisplayServer.get_name() == "headless":
      return "Skip Input tests when running headless"

  func test_select_and_change_number_of_a_cell():
    var sudoku = add_child_autofree(Sudoku.new())
    var cells = sudoku.get_cells()
    watch_signals(sudoku)

    _sender.mouse_left_button_down(Vector2.ZERO).hold_for(.2)
    await (_sender.idle)
    assert_eq(sudoku.selected_cell, cells[0])

    _sender.key_down(KEY_7).hold_for(.2)
    await (_sender.idle)
    assert_eq(sudoku.selected_cell.number, 7)
    assert_signal_emitted_with_parameters(sudoku, "cell_edited", [cells[0]])
