extends GutTest

var _cell_scene = load("res://scene/cell.tscn")


func test_cell_collision():
  var cell = add_child_autofree(_cell_scene.instantiate())
  cell.size = 20
  var collision = cell.get_node("Collision")
  assert_eq(collision.shape.size, Vector2(20, 20))
  assert_eq(collision.position, Vector2(10, 10))


func test_number_is_betweeen_0_to_9():
  var cell = autofree(_cell_scene.instantiate())
  cell.number = 0
  cell.number = -1
  assert_eq(cell.number, 0)
  cell.number = 10
  assert_eq(cell.number, 0)


func test_cell_has_label():
  # you have to add cell to the scene tree
  # to move the child element
  var cell = add_child_autofree(_cell_scene.instantiate())
  var label = cell.get_node("Label")
  assert_not_null(label)
  assert_almost_eq(label.position, Vector2(cell.size / 3.0, 0), Vector2(0.001, 0))


func test_label_text_is_same_as_number():
  var cell = add_child_autofree(_cell_scene.instantiate())
  cell.number = 0
  var label = cell.get_node("Label")
  assert_eq(label.text, "")
  cell.number = 1
  assert_eq(label.text, "1")
  # erase the number
  cell.number = 0
  assert_eq(label.text, "")


func test_label_font_size_is_same_as_font_size():
  var cell = add_child_autofree(_cell_scene.instantiate())
  cell.font_size = 32
  var label = cell.get_node("Label")
  assert_eq(label.get("theme_override_font_sizes/font_size"), 32)


func test_immutable_property():
  var cell = add_child_autofree(_cell_scene.instantiate())
  var label = cell.get_node("Label")
  cell.number = 1
  assert_eq(label.get_theme().get_path(), "res://theme/normal_font.tres")
  cell.is_immutable = true
  cell.number = 2
  assert_eq(1, cell.number)
  assert_eq(label.get_theme().get_path(), "res://theme/bold_font.tres")


func test_draw():
  var cell = add_child_autofree(_cell_scene.instantiate())
  cell.number = 0
  cell.size = 10
  await wait_frames(1)
  assert_eq(cell.log_txt, "(0,0)(10,10)#ffffffff, (0,0)(10,10)BORDER")
  # redraw
  cell.size = 20
  await wait_frames(1)
  assert_eq(cell.log_txt, "(0,0)(20,20)#ffffffff, (0,0)(20,20)BORDER")


class TestCellInput:
  extends GutTest

  var _sender = InputSender.new(Input)
  # Ignore the linter error.
  # ref:https://github.com/Scony/godot-gdscript-toolkit/issues/254
  var _input_cell_scene = load("res://scene/cell.tscn")

  func before_all():
    _sender.mouse_warp = true

  func after_each():
    _sender.release_all()
    _sender.clear()

  func should_skip_script():
    if DisplayServer.get_name() == "headless":
      return "Skip Input tests when running headless"

  func test_cell_emits_on_click():
    var cell = add_child_autofree(_input_cell_scene.instantiate())
    watch_signals(cell)
    _sender.mouse_left_button_down(Vector2(4, 4)).hold_for(.2)
    await (_sender.idle)
    assert_signal_emitted_with_parameters(cell, "on_click", [cell])
