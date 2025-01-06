extends GutTest


func test_assert_cell_properties():
  var cell = autofree(Cell.new())
  assert_property(cell, "size", 10, 30)
  assert_property(cell, "border_width", 1, 2)
  assert_property(cell, "number", 0, 1)
  assert_property(cell, "font_size", 16, 32)
  assert_property(cell, "color", Color.WHITE, Color.BLUE)


func test_cell_collision():
  var cell = autofree(Cell.new())
  cell.size = 20
  var collision = cell.get_node("Collision")
  assert_eq(collision.shape.size, Vector2(20, 20))
  assert_eq(collision.position, Vector2(10, 10))


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
  assert_eq(label.position, Vector2(cell.size / 3.0, 0))


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
  assert_eq(cell.log_txt, "(0,0)(10,10)#ffffffff, (0,0)(10,10)BORDER")
  # redraw
  cell.number = 2
  await wait_frames(1)
  assert_eq(cell.log_txt, "NUMBER=2 FONT_SIZE=16, (0,0)(10,10)#ffffffff, (0,0)(10,10)BORDER")
  cell.size = 20
  await wait_frames(1)
  assert_eq(cell.log_txt, "NUMBER=2 FONT_SIZE=16, (0,0)(20,20)#ffffffff, (0,0)(20,20)BORDER")
  cell.color = Color.BLACK
  await wait_frames(1)
  assert_eq(cell.log_txt, "NUMBER=2 FONT_SIZE=16, (0,0)(20,20)#000000ff, (0,0)(20,20)BORDER")


class TestCellInput:
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

  func test_cell_emits_on_click():
    var cell = add_child_autofree(Cell.new())
    watch_signals(cell)
    _sender.mouse_left_button_down(Vector2(4, 4)).hold_for(.2)
    await (_sender.idle)
    assert_signal_emitted_with_parameters(cell, "on_click", [cell])
