@tool
class_name Cell
extends Area2D

signal on_click

@export var size: int = 10:
  get():
    return size
  set(value):
    size = value
    _set_label_pos()
    _set_collision_properties()
    queue_redraw()

@export var border_width: int = 1:
  get():
    return border_width
  set(value):
    border_width = value
    queue_redraw()

@export var number: int = 0:  # 0 for empty
  get():
    return number
  set(value):
    if value >= 0 and value <= 9:
      number = value
      queue_redraw()
      if value != 0:
        $Label.text = str(value)
      else:
        $Label.text = ""

@export var font_size: int = 16:
  get():
    return font_size
  set(value):
    font_size = value
    $Label.set("theme_override_font_sizes/font_size", value)

var log_txt: String = "":
  get():
    return log_txt

var color: Color = Color.WHITE:
  get():
    return color
  set(value):
    color = value
    queue_redraw()


func _set_label_pos():
  $Label.position = Vector2(size / 3.0, 0)


func _set_collision_properties():
  $Collision.shape.size = Vector2(size, size)
  $Collision.position = Vector2(size / 2.0, size / 2.0)


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
  if event is InputEventMouseButton:
    if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
      on_click.emit(self)
      queue_redraw()


func _init() -> void:
  input_pickable = true
  clip_children = ClipChildrenMode.CLIP_CHILDREN_AND_DRAW
  var label = Label.new()
  label.name = "Label"
  label.text = ""
  label.set("theme_override_font_sizes/font_size", 16)
  label.set("theme_override_colors/font_color", Color.BLACK)
  add_child(label)
  _set_label_pos()

  var collision = CollisionShape2D.new()
  var rect = RectangleShape2D.new()
  collision.name = "Collision"
  collision.shape = rect
  add_child(collision)
  _set_collision_properties()


func _draw() -> void:
  log_txt = ""
  if number > 0:
    var fsize = $Label.get("theme_override_font_sizes/font_size")
    log_txt = log_txt + "NUMBER={0} FONT_SIZE={1}, ".format([number, fsize])
  draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), color)
  log_txt = log_txt + "({0},{0})({1},{1})#{2}, ".format([0, size, color.to_html()])
  draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), Color.BLACK, false, border_width)
  log_txt = log_txt + "({0},{0})({1},{1})BORDER".format([0, size])
