extends GutTest


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
  assert_eq(cells[0].number, 0)
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

  func test_click_to_selects_cell():
    var sudoku = add_child_autofree(Sudoku.new())
    var cells = sudoku.get_cells()
    _sender.mouse_left_button_down(Vector2.ZERO).hold_for(.2)
    await (_sender.idle)
    assert_eq(sudoku.selected_cell, cells[0])
