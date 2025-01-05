extends GutTest


func test_sudoku_exists():
  var sudoku = autofree(Sudoku.new())
  assert_not_null(sudoku)


func test_sudoku_has_9x9_cells():
  var sudoku = autofree(Sudoku.new())
  var cells = sudoku.get_cells()
  assert_eq(cells.size(), 81)


func test_sudoku_can_change_cell_size():
  var sudoku = autofree(Sudoku.new())
  assert_property(sudoku, "cell_size", 10, 90)
  var cells = sudoku.get_cells()
  assert_eq(cells[0].size, 90)


func test_sudoku_cells_has_proper_position():
  var sudoku = autofree(Sudoku.new())
  sudoku.cell_size = 20
  var cells = sudoku.get_cells()
  assert_eq(cells[0].position, Vector2.ZERO)
  assert_eq(cells[0].number, 0)
  assert_eq(cells[80].position, Vector2(8 * sudoku.cell_size, 8 * sudoku.cell_size))


func test_sudoku_has_9_boxes():
  var sudoku = autofree(Sudoku.new())
  var boxes = sudoku.get_boxes()
  assert_eq(boxes.size(), 9)


func test_sudoku_box_border_has_proper_properties():
  var sudoku = autofree(Sudoku.new())
  sudoku.cell_size = 20
  var boxes = sudoku.get_boxes()
  # position
  assert_eq(boxes[0].position, Vector2.ZERO)
  assert_eq(boxes[8].position, Vector2(20 * 6, 20 * 6))
  # size
  assert_eq(boxes[0].size, 20 * 3)
