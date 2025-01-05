extends GutTest


func test_assert_cell_properties():
  var cell = autofree(Cell.new())
  assert_property(cell, "size", 10, 30)
  assert_property(cell, "border_width", 1, 2)
  assert_property(cell, "number", 0, 1)
  assert_property(cell, "font_size", 16, 32)


func test_number_is_betweeen_0_to_9():
  var cell = autofree(Cell.new())
  cell.number = -1
  assert_eq(cell.number, 0)
  cell.number = 10
  assert_eq(cell.number, 0)


func test_cell_has_label():
  var cell = autofree(Cell.new())
  var label = cell.get_node("Label")
  assert_not_null(label)
  assert_eq(label.get("theme_override_colors/font_color"), Color.BLACK)
  assert_eq(label.get("theme_override_font_sizes/font_size"), 16)


func test_label_text_is_same_as_number():
  var cell = autofree(Cell.new())
  var label = cell.get_node("Label")
  assert_eq(label.text, "")
  cell.number = 1
  assert_eq(label.text, "1")
  # erase the number
  cell.number = 0
  assert_eq(label.text, "")


func test_label_font_size_is_same_as_font_size():
  var cell = autofree(Cell.new())
  cell.font_size = 32
  var label = cell.get_node("Label")
  assert_eq(label.get("theme_override_font_sizes/font_size"), 32)


func test_draw():
  var cell = add_child_autofree(Cell.new())
  await wait_frames(1)
  assert_eq(cell.log_txt, "(0,0)(10,10)WHITE, (0,0)(10,10)BORDER")
  # redraw
  cell.number = 2
  await wait_frames(1)
  assert_eq(cell.log_txt, "NUMBER=2 FONT_SIZE=16, (0,0)(10,10)WHITE, (0,0)(10,10)BORDER")
  cell.size = 20
  await wait_frames(1)
  assert_eq(cell.log_txt, "NUMBER=2 FONT_SIZE=16, (0,0)(20,20)WHITE, (0,0)(20,20)BORDER")
