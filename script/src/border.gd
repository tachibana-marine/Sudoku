class_name Border
extends Node2D

var size: int = 10:
  get():
    return size
  set(value):
    size = value
    queue_redraw()

var border_width: int = 1:
  get():
    return border_width
  set(value):
    border_width = value
    queue_redraw()

var log_txt: String = "":
  get():
    return log_txt


func _draw():
  log_txt = ""
  log_txt = log_txt + "({0},{0})({1},{1})BORDER WIDTH={2}".format([0, size, border_width])
  draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), Color.BLUE, false, border_width)
