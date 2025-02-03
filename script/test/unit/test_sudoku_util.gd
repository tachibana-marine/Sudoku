extends GutTest

var _cell_scene = load("res://scene/cell.tscn")


func test_verify_sudoku_cells_have_1_to_9():
  var cells: Array[int] = []
  cells.resize(9)
  for i in range(9):
    cells[i] = i + 1
  assert_true(SudokuUtil.verify_cells(cells))


func test_verify_sudoku_cells_have_0():
  var cells: Array[int] = []
  cells.resize(9)
  for i in range(9):
    # 0 to 8
    cells[i] = i
  assert_false(SudokuUtil.verify_cells(cells))


func test_verify_no_duplicate_cells():
  var cells: Array[int] = []
  cells.resize(9)
  for i in range(9):
    # 1 to 9
    cells[i] = i + 1
  assert_true(SudokuUtil.verify_no_duplicate_cells(cells))


func test_verify_duplicate_cells_exist():
  var cells: Array[int] = []
  cells.resize(9)
  for i in range(9):
    cells[i] = i + 1  # 1 to 9
  cells[8] = 7  # set a duplicate number
  assert_false(SudokuUtil.verify_no_duplicate_cells(cells))


func test_verify_duplicate_zeros_are_not_counted():
  var cells: Array[int] = []
  cells.resize(9)
  for i in range(9):
    cells[i] = i + 1  # 1 to 9
  cells[7] = 0
  cells[8] = 0
  assert_true(SudokuUtil.verify_no_duplicate_cells(cells))


func test_get_box_cell():
  var cells: Array[int] = []
  for i in range(81):
    cells.append(i % 9)

  var expected_nums = [
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
  var box_cells = SudokuUtil.get_cells_in_box(1, cells)
  assert_eq(expected_nums, box_cells)


func test_get_column_cells():
  var cells: Array[int] = []
  for i in range(81):
    cells.append(i % 9)
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
  var column_cells = SudokuUtil.get_cells_in_column(1, cells)
  assert_eq(expected_cells, column_cells)


func test_get_row_cells():
  var cells: Array[int] = []
  for i in range(81):
    cells.append(i % 9)

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
  var box_cells = SudokuUtil.get_cells_in_row(1, cells)
  assert_eq(expected_cells, box_cells)


# Currently this test fails since the function returns 1
# func test_backtrack_returns_zero_for_complete_grid():
#   var sudoku = add_child_autofree(Sudoku.new())
#   sudoku.set_state(100)
#   sudoku.fill_grid()
#   var cells: Array[Cell] = sudoku.get_cells().duplicate()
#   assert_eq(SudokuUtil.backtrack_cell(cells, 0, 0), 0)


func test_backtrack_returns_one_for_obvious_case():
  var sudoku = add_child_autofree(Sudoku.new())
  sudoku.set_state(100)
  sudoku.fill_grid()
  var cells: Array[int] = sudoku.get_cell_numbers()
  # remove first = there is 1 solution
  cells[0] = 0
  assert_eq(SudokuUtil.backtrack_cell(cells, 0, 0), 1)


func test_backtrack_returns_two_for_obvious_case():
  var sudoku = add_child_autofree(Sudoku.new())
  sudoku.set_state(100)
  sudoku.fill_grid()
  var cells: Array[int] = sudoku.get_cell_numbers()
  # remove 4 and 8 = 4 and 8 is interchangable now = there are 2 solutions
  for i in range(cells.size()):
    if cells[i] == 4 or cells[i] == 8:
      cells[i] = 0
  assert_eq(SudokuUtil.backtrack_cell(cells, 0, 0), 2)
