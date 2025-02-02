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


func test_get_box_cell():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  var expected_cells = [
    cells[3],
    cells[4],
    cells[5],
    cells[12],
    cells[13],
    cells[14],
    cells[21],
    cells[22],
    cells[23],
  ]
  var box_cells = sudoku.get_cells_in_box(1)
  assert_eq(expected_cells, box_cells)


func test_get_column_cells():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  var expected_cells = [
    cells[1],
    cells[10],
    cells[19],
    cells[28],
    cells[37],
    cells[46],
    cells[55],
    cells[64],
    cells[73],
  ]
  var column_cells = sudoku.get_cells_in_column(1)
  assert_eq(expected_cells, column_cells)


func test_get_row_cells():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  var expected_cells = [
    cells[9],
    cells[10],
    cells[11],
    cells[12],
    cells[13],
    cells[14],
    cells[15],
    cells[16],
    cells[17],
  ]
  var box_cells = sudoku.get_cells_in_row(1)
  assert_eq(expected_cells, box_cells)


func test_fill_grid():
  var sudoku = add_child_autofree(Sudoku.new())
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


func test_reset_cells():
  var sudoku = add_child_autofree(Sudoku.new())
  sudoku.set_state(400)
  sudoku.fill_grid()
  sudoku.reset_cells()
  var cells = sudoku.get_cells()
  assert_eq(cells[10].number, 0)
  assert_eq(cells[10].is_immutable, false)


func test_randomly_reset_cells():
  var sudoku = add_child_autofree(Sudoku.new())
  sudoku.set_state(100)
  sudoku.fill_grid()
  sudoku.set_state(1000)
  sudoku.randomly_reset_cells(50)
  var cells = sudoku.get_cells()
  var zero_count = 0
  for cell in cells:
    if cell.number == 0:
      zero_count += 1
  assert_eq(50, zero_count)


func test_make_non_zero_cells_immutable():
  var sudoku = add_child_autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  cells[1].number = 1
  sudoku.make_non_zero_cells_immutable()
  assert_false(cells[0].is_immutable)
  assert_true(cells[1].is_immutable)


func test_cannot_reset_cells_more_than_81():
  var sudoku = add_child_autofree(Sudoku.new())
  sudoku.set_state(100)
  sudoku.fill_grid()
  sudoku.set_state(1000)
  sudoku.randomly_reset_cells(82)
  var cells = sudoku.get_cells()
  var zero_count = 0
  for cell in cells:
    if cell.number == 0:
      zero_count += 1
  # nothing happens
  assert_eq(0, zero_count)


func test_reset_as_much_as_possible_with_unique_solutions():
  var sudoku = add_child_autofree(Sudoku.new())
  sudoku.set_state(100)
  sudoku.fill_grid()
  sudoku.set_state(200)
  sudoku.reset_as_much_as_possible_with_unique_solutions()
  var cells = sudoku.get_cells()
  var zero_count = 0
  for cell in cells:
    if cell.number == 0:
      zero_count += 1
  assert_ne(zero_count, 0)
  assert_eq(SudokuUtil.backtrack_cell(cells, 0, 0), 1)


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
