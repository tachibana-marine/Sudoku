class_name SudokuUtilTest
extends GutTest

static var _readable_filled_grid: Array[Array] = [
  [5, 6, 9, 3, 4, 2, 1, 8, 7],
  [7, 3, 8, 9, 1, 5, 6, 4, 2],
  [4, 2, 1, 8, 6, 7, 5, 9, 3],
  [8, 5, 7, 1, 2, 4, 9, 3, 6],
  [9, 1, 6, 5, 8, 3, 7, 2, 4],
  [3, 4, 2, 7, 9, 6, 8, 5, 1],
  [2, 7, 4, 6, 5, 8, 3, 1, 9],
  [1, 8, 3, 2, 7, 9, 4, 6, 5],
  [6, 9, 5, 4, 3, 1, 2, 7, 8]
]

static var filled_grid: Array[int] = _unpack_rows(_readable_filled_grid)


static func _unpack_rows(grid_with_rows: Array[Array]) -> Array[int]:
  var cells: Array[int] = []
  for row in grid_with_rows:
    for num in row:
      cells.append(num)
  return cells


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


func test_is_complete():
  assert_true(SudokuUtil.is_complete(filled_grid))


func test_create_filled_grid():
  var rng = RandomNumberGenerator.new()
  rng.set_state(1000)
  var created_filled_grid = SudokuUtil.create_filled_grid(rng)
  assert_true(SudokuUtil.is_complete(created_filled_grid))


func test_backtrack_returns_one_for_obvious_case():
  var cells: Array[int] = filled_grid.duplicate()
  # remove first = there is 1 solution
  cells[0] = 0
  assert_eq(SudokuUtil.backtrack_cell(cells, 0, 0), 1)


func test_backtrack_returns_two_for_obvious_case():
  var cells: Array[int] = filled_grid.duplicate()
  # remove 4 and 8 = 4 and 8 is interchangable now = there are 2 solutions
  for i in range(cells.size()):
    if cells[i] == 4 or cells[i] == 8:
      cells[i] = 0
  for k in range(9):
    SudokuUtil.print_row(k, cells)
  assert_eq(SudokuUtil.backtrack_cell(cells, 0, 0), 2)
