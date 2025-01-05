@tool
class_name Cell
extends Node2D

@export var size: int = 10:
  get():
    return size
  set(value):
    size = value
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


func _init() -> void:
  clip_children = ClipChildrenMode.CLIP_CHILDREN_AND_DRAW
  var label = Label.new()
  label.name = "Label"
  label.text = ""
  label.set("theme_override_font_sizes/font_size", 16)
  label.set("theme_override_colors/font_color", Color.BLACK)
  add_child(label)


func _draw() -> void:
  log_txt = ""
  if number > 0:
    var fsize = $Label.get("theme_override_font_sizes/font_size")
    log_txt = log_txt + "NUMBER={0} FONT_SIZE={1}, ".format([number, fsize])
  draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), Color.WHITE)
  log_txt = log_txt + "({0},{0})({1},{1})WHITE, ".format([0, size])
  draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), Color.BLACK, false, border_width)
  log_txt = log_txt + "({0},{0})({1},{1})BORDER".format([0, size])
