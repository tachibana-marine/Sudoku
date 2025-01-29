@tool
class_name Cell
extends Area2D

signal on_click

@export var size: int = 10:
  get():
    return size
  set(value):
    size = value
    if is_inside_tree():
      _set_label_pos()
      _set_collision_properties()
      queue_redraw()

@export var border_width: int = 1:
  get():
    return border_width
  set(value):
    border_width = value
    if is_inside_tree():
      queue_redraw()

@export var font_size: int = 16:
  get():
    return font_size
  set(value):
    font_size = value
    if is_inside_tree():
      $Label.set("theme_override_font_sizes/font_size", value)

var normal_font = load("res://theme/normal_font.tres")
var bold_font = load("res://theme/bold_font.tres")

var log_txt: String = "":
  get():
    return log_txt

var color: Color = Color.WHITE:
  get():
    return color
  set(value):
    color = value
    queue_redraw()

@onready var is_immutable: bool = false:
  get():
    return is_immutable
  set(value):
    is_immutable = value
    if value:
      $Label.set_theme(bold_font)
    else:
      $Label.set_theme(normal_font)

@onready var number: int = 0:  # 0 for empty
  get():
    return number
  set(value):
    if is_immutable:
      return
    if value >= 0 and value <= 9:
      number = value
      queue_redraw()
      if value != 0:
        $Label.text = str(value)
      else:
        $Label.text = ""


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


func _ready() -> void:
  input_pickable = true
  clip_children = ClipChildrenMode.CLIP_CHILDREN_AND_DRAW
  _set_label_pos()
  _set_collision_properties()


func _draw() -> void:
  log_txt = ""
  draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), color)
  log_txt = log_txt + "({0},{0})({1},{1})#{2}, ".format([0, size, color.to_html()])
  draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), Color.BLACK, false, border_width)
  log_txt = log_txt + "({0},{0})({1},{1})BORDER".format([0, size])
