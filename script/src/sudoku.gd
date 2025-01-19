@tool
class_name Sudoku
extends Node2D

const CELL_FONT_SIZE = 42
const DEFAULT_CELL_COLOR = Color.WHITE
const SELECTED_CELL_COLOR = Color.PURPLE

@export var cell_size: int = 10:
  get():
    return cell_size
  set(value):
    cell_size = value
    for y in range(9):
      for x in range(9):
        _adjust_cell_properties(x, y)
    for y in range(3):
      for x in range(3):
        _adjust_box_properties(x, y)

var selected_cell: Cell = null:
  get():
    return selected_cell

var _cells: Array[Cell] = []
var _boxes: Array[Border] = []


# verify given cells contains 1 to 9
static func verify_cells(cells: Array[Cell]):
  var count = []
  count.resize(9)
  count.fill(0)
  for cell in cells:
    if cell.number < 1 or cell.number > 9:
      return false
    count[cell.number - 1] = 1
  if count.all(func(num): return num == 1):
    return true
  return false


# return cells as an array ordered from top left to bottom right
func get_cells():
  return _cells


# return boxes as an array ordered from top left to bottom right
func get_boxes():
  return _boxes


# return cells in the given box. The index starts with 0.
func get_cells_in_box(index: int) -> Array[Cell]:
  var x = index % 3
  var y = int(index / 3.0)  # silence the linter
  # get index of the top left cell of the box
  var start_index = x * 3 + y * 9 * 3
  var cells_in_box: Array[Cell] = []
  for j in range(3):
    for i in range(3):
      var cell_index = start_index + i + j * 9
      cells_in_box.append(_cells[cell_index])
  return cells_in_box


# return cells in the given row. The index starts with 0.
func get_cells_in_row(index: int) -> Array[Cell]:
  var start_index = index * 9
  var cells_in_row: Array[Cell] = []
  for i in range(9):
    cells_in_row.append(_cells[start_index + i])
  return cells_in_row


func fill_first_box():
  var cells_in_first_box = get_cells_in_box(0)
  var index = 1
  for cell in cells_in_first_box:
    cell.number = index
    index += 1


func fill_first_row():
  var cells_in_first_row = get_cells_in_row(0)
  var index = 1
  for cell in cells_in_first_row:
    cell.number = index
    index += 1


func _adjust_cell_properties(x, y):
  var cell = _cells[y * 9 + x]
  cell.size = cell_size
  cell.position = Vector2(x * cell_size, y * cell_size)


func _adjust_box_properties(x, y):
  var box = _boxes[y * 3 + x]
  box.size = cell_size * 3
  box.position = Vector2(x * cell_size * 3, y * cell_size * 3)


func _on_click_cell(cell):
  if selected_cell:
    selected_cell.color = DEFAULT_CELL_COLOR
  selected_cell = cell
  cell.color = SELECTED_CELL_COLOR


func _input(event: InputEvent) -> void:
  if event is InputEventKey:
    if event.is_pressed:
      var number = int(OS.get_keycode_string(event.keycode))
      if selected_cell and number > 0:
        print(number)
        selected_cell.number = number


func _init() -> void:
  var cell_holder = Node2D.new()
  cell_holder.name = "CellHolder"
  add_child(cell_holder)

  var box_holder = Node2D.new()
  box_holder.name = "BoxHolder"
  add_child(box_holder)

  for i in range(9):
    for j in range(9):
      var cell = Cell.new()
      $CellHolder.add_child(cell)
      _cells.append(cell)
      _adjust_cell_properties(j, i)
      cell.border_width = 3
      cell.number = 1
      cell.font_size = CELL_FONT_SIZE
      cell.color = DEFAULT_CELL_COLOR
      cell.on_click.connect(_on_click_cell)

  for i in range(3):
    for j in range(3):
      var box_border = Border.new()
      box_border.border_width = 7
      $BoxHolder.add_child(box_border)
      _boxes.append(box_border)
      _adjust_box_properties(j, i)

  fill_first_box()
  fill_first_row()
