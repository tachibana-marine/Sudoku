extends GutTest

var _cell_scene = load("res://scene/cell.tscn")


func test_sudoku_has_9x9_cells():
  var sudoku = autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  assert_eq(cells.size(), 81)


func test_sudoku_has_9_boxes():
  var sudoku = autofree(Sudoku.new())
  var boxes = sudoku.get_boxes()
  assert_eq(boxes.size(), 9)


func test_sudoku_can_change_cell_size():
  var sudoku = autofree(Sudoku.new())
  assert_property(sudoku, "cell_size", 10, 90)
  var cells = sudoku.get_cells()
  assert_eq(cells[0].size, 90)


func test_cell_properties():
  var sudoku = autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  assert_eq(cells[0].font_size, Sudoku.CELL_FONT_SIZE)
  assert_eq(cells[0].color, Sudoku.DEFAULT_CELL_COLOR)


func test_sudoku_cells_has_proper_position():
  var sudoku = autofree(Sudoku.new())
  sudoku.cell_size = 20
  var cells = sudoku.get_cells()
  assert_eq(cells[0].position, Vector2.ZERO)
  assert_eq(cells[80].position, Vector2(8 * sudoku.cell_size, 8 * sudoku.cell_size))


func test_sudoku_box_border_has_proper_properties():
  var sudoku = autofree(Sudoku.new())
  sudoku.cell_size = 20
  var boxes = sudoku.get_boxes()
  # position
  assert_eq(boxes[0].position, Vector2.ZERO)
  assert_eq(boxes[8].position, Vector2(20 * 6, 20 * 6))
  # size
  assert_eq(boxes[0].size, 20 * 3)


func test_sudoku_cell_changes_color_on_click():
  var sudoku = autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  assert_null(sudoku.selected_cell)
  sudoku._on_click_cell(cells[3])
  assert_eq(sudoku.selected_cell, cells[3])
  assert_eq(cells[3].color, Sudoku.SELECTED_CELL_COLOR)


func test_sudoku_resets_color_on_click_cell():
  var sudoku = autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  sudoku._on_click_cell(cells[3])
  sudoku._on_click_cell(cells[4])
  assert_eq(sudoku.selected_cell, cells[4])
  assert_eq(cells[3].color, Sudoku.DEFAULT_CELL_COLOR)
  assert_eq(cells[4].color, Sudoku.SELECTED_CELL_COLOR)


func test_verify_sudoku_cells_have_1_to_9():
  var cells: Array[Cell] = []
  cells.resize(9)
  for i in range(9):
    var cell = autofree(_cell_scene.instantiate())
    cell.number = i + 1  # 1 to 9
    cells[i] = cell
  assert_true(Sudoku.verify_cells(cells))


func test_verify_sudoku_cells_have_0():
  var cells: Array[Cell] = []
  cells.resize(9)
  for i in range(9):
    var cell = autofree(_cell_scene.instantiate())
    cell.number = i  # 0 to 8
    cells[i] = cell
  assert_false(Sudoku.verify_cells(cells))


func test_verify_no_duplicate_cells():
  var cells: Array[Cell] = []
  cells.resize(9)
  for i in range(9):
    var cell = autofree(_cell_scene.instantiate())
    cell.number = i + 1  # 1 to 9
    cells[i] = cell
  assert_true(Sudoku.verify_cells(cells))


func test_verify_duplicate_cells_exist():
  var cells: Array[Cell] = []
  cells.resize(9)
  for i in range(9):
    var cell = autofree(_cell_scene.instantiate())
    cell.number = i + 1  # 1 to 9
    cells[i] = cell
  cells[8].number = 7  # set a duplicate number
  assert_false(Sudoku.verify_no_duplicate_cells(cells))


func test_verify_duplicate_zeros_are_not_counted():
  var cells: Array[Cell] = []
  cells.resize(9)
  for i in range(9):
    var cell = autofree(_cell_scene.instantiate())
    cell.number = i + 1  # 1 to 9
    cells[i] = cell
  cells[7].number = 0
  cells[8].number = 0
  assert_true(Sudoku.verify_no_duplicate_cells(cells))


func test_get_box_cells():
  var sudoku = autofree(Sudoku.new())
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
  var sudoku = autofree(Sudoku.new())
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
  var sudoku = autofree(Sudoku.new())
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


func test_fill_first_three_rows():
  var sudoku = autofree(Sudoku.new())
  sudoku.set_state(894789547401239051)
  sudoku.fill_grid()

  for i in range(9):
    var cells_in_row = sudoku.get_cells_in_row(i)
    assert_true(Sudoku.verify_cells(cells_in_row))

  for i in range(9):
    var cells_in_box = sudoku.get_cells_in_box(i)
    assert_true(Sudoku.verify_cells(cells_in_box))

  for i in range(9):
    var cells_in_column = sudoku.get_cells_in_column(i)
    assert_true(Sudoku.verify_cells(cells_in_column))


func test_randomly_reset_cells():
  var sudoku = autofree(Sudoku.new())
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


func test_cannot_reset_cells_more_than_81():
  var sudoku = autofree(Sudoku.new())
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


# func test_fill_the_first_box():
#   var sudoku = autofree(Sudoku.new())
#   sudoku.fill_first_box()
#   var cells = sudoku.get_cells_in_box(0)
#   assert_true(Sudoku.verify_cells(cells))

# func test_fill_the_first_row_of_second_and_third_box():
#   # I won't test the randomness.
#   for _i in range(10):
#     # Test multiple times just to be sure
#     var sudoku = autofree(Sudoku.new())
#     sudoku.fill_first_row_of_second_and_third_box()
#     var cells = sudoku.get_cells_in_row(0)
#     assert_true(Sudoku.verify_cells(cells))

# func test_fill_the_second_row_of_second_and_third_box():
#   # I won't test the randomness.
#   for _i in range(10):
#     # Test multiple times just to be sure
#     var sudoku = autofree(Sudoku.new())
#     sudoku.fill_second_row_of_second_and_third_box()
#     var cells = sudoku.get_cells_in_row(1)
#     assert_true(Sudoku.verify_cells(cells))
#     assert_true(Sudoku.verify_no_duplicate_cells(sudoku.get_cells_in_box(1)))
#     assert_true(Sudoku.verify_no_duplicate_cells(sudoku.get_cells_in_box(2)))

# func test_sudoku_creates_complete_sudoku_grid():
#   var sudoku = autofree(Sudoku.new())
#   sudoku.populate_grid()
#   var rows = sudoku.get_rows()
#   var columns = sudoku.get_columns()
#   var boxes = sudoku.get_boxes()

#   assert_eq(rows.size(), 9)
#   assert_eq(columns.size(), 9)
#   assert_eq(boxes.size(), 9)

#   assert_true(rows.all(check_if_sudoku_cells_contains_1_to_9))
#   assert_true(columns.all(check_if_sudoku_cells_contains_1_to_9))
#   assert_true(boxes.all(check_if_sudoku_cells_contains_1_to_9))


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
    _sender.mouse_left_button_down(Vector2.ZERO).hold_for(.2)
    await (_sender.idle)
    assert_eq(sudoku.selected_cell, cells[0])

    _sender.key_down(KEY_7).hold_for(.2)
    await (_sender.idle)
    assert_eq(sudoku.selected_cell.number, 7)
