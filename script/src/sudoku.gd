@tool
class_name Sudoku
extends Node2D

signal cell_edited
signal grid_filled
signal grid_created

@export var is_thread_available: bool = true
@export var default_cell_color: Color = Color.WHITE
@export var selected_cell_color: Color = Color.ORANGE

var selected_cell: Cell = null:
  get():
    return selected_cell

var _cell_scene = load("res://scene/cell.tscn")

var _cells: Array[Cell] = []
var _boxes: Array[Border] = []

var _random: RandomNumberGenerator = RandomNumberGenerator.new()

var _thread: Thread


# set state
func set_state(state: int):
  _random.set_state(state)


# return cells as an array ordered from top left to bottom right
func get_cells():
  return _cells


# return cells as an int array
func get_cell_numbers() -> Array[int]:
  var nums: Array[int] = []
  for cell in _cells:
    nums.append(cell.number)
  return nums


# set number of cells
# The array size should be 81
func set_cell_numbers(nums: Array[int]):
  for i in range(nums.size()):
    _cells[i].number = nums[i]


# return boxes as an array ordered from top left to bottom right
func get_boxes():
  return _boxes


# return cells in the given box. The index starts with 0.
func get_cells_in_box(index: int) -> Array[int]:
  return SudokuUtil.get_cells_in_box(index, get_cell_numbers())


# return cells in the given row. The index starts with 0.
func get_cells_in_row(index: int) -> Array[int]:
  return SudokuUtil.get_cells_in_row(index, get_cell_numbers())


# return cells in the given column. The index starts with 0
func get_cells_in_column(index: int) -> Array[int]:
  return SudokuUtil.get_cells_in_column(index, get_cell_numbers())


# change number of a cell and emit cell_edited
func set_number_of_cell(cell: Cell, number: int):
  cell.number = number
  cell_edited.emit(cell)


# return if the grid is complete or not
func is_complete() -> bool:
  for i in range(9):
    var cells_in_row = get_cells_in_row(i)
    if not SudokuUtil.verify_cells(cells_in_row):
      return false

  for i in range(9):
    var cells_in_box = get_cells_in_box(i)
    if not SudokuUtil.verify_cells(cells_in_box):
      return false

  for i in range(9):
    var cells_in_column = get_cells_in_column(i)
    if not SudokuUtil.verify_cells(cells_in_column):
      return false

  return true


# fill the whole grid
# emits grid_filled
func fill_grid():
  var cell_numbers = SudokuUtil.create_filled_grid(_random)
  for index in range(cell_numbers.size()):
    _cells[index].number = cell_numbers[index]
  for k in range(9):
    _print_row(k)
  grid_filled.emit()


# Reset all cells
func reset_cells():
  for cell in _cells:
    cell.is_immutable = false
    cell.number = 0


# make non zero cells immutable
# other cells become mutable
func make_non_zero_cells_immutable():
  for cell in _cells:
    if cell.number == 0:
      cell.is_immutable = false
    else:
      cell.is_immutable = true


func create_grid():
  if is_thread_available:
    _thread.start(_create_grid.bind())
  else:
    _create_grid()


func _create_grid():
  var cell_numbers = SudokuUtil.create_filled_grid(_random)
  call_deferred("emit_signal", "grid_filled")
  var remove_pos = []
  # FIXME: soooooo inefficient.
  for i in range(_cells.size()):
    var pos
    while true:
      pos = _random.randi_range(0, 80)
      if pos not in remove_pos:
        remove_pos.append(pos)
        break

  for index in remove_pos:
    var num = cell_numbers[index]
    cell_numbers[index] = 0
    if SudokuUtil.backtrack_cell(cell_numbers, 0, 0) > 1:
      cell_numbers[index] = num
      break
  call_deferred("emit_signal", "grid_created")
  call_deferred("set_cell_numbers", cell_numbers)


# return true if the grid has only one solution, otherwise return false.
func _has_unique_solution() -> bool:
  var cells_copy = _cells.duplicate()
  if SudokuUtil.backtrack_cell(cells_copy, 0, 0) == 1:
    return true
  return false


# print row
func _print_row(i: int):
  SudokuUtil.print_row(i, get_cell_numbers())


func _adjust_cell_properties(x, y):
  var cell = _cells[y * 9 + x]
  cell.position = Vector2(x * cell.size, y * cell.size)


func _adjust_box_properties(x, y):
  var box = _boxes[y * 3 + x]
  var cell = _cells[0]
  box.size = cell.size * 3
  box.position = Vector2(x * cell.size * 3, y * cell.size * 3)


func _on_click_cell(cell):
  if selected_cell:
    selected_cell.color = default_cell_color
  selected_cell = cell
  cell.color = selected_cell_color


func _input(event: InputEvent) -> void:
  if event is InputEventKey:
    if event.is_pressed:
      var number = int(OS.get_keycode_string(event.keycode))
      if selected_cell and number >= 0:
        set_number_of_cell(selected_cell, number)


func _ready() -> void:
  if is_thread_available:
    _thread = Thread.new()
  for j in range(9):
    for i in range(9):
      var cell = _cells[j * 9 + i]
      if not cell.is_inside_tree():
        await cell.ready
      cell.number = 0
      cell.on_click.connect(_on_click_cell)
      _adjust_cell_properties(i, j)


func _init() -> void:
  _random.randomize()
  var cell_holder = Node2D.new()
  cell_holder.name = "CellHolder"
  add_child(cell_holder)

  var box_holder = Node2D.new()
  box_holder.name = "BoxHolder"
  add_child(box_holder)

  for j in range(9):
    for i in range(9):
      var cell = _cell_scene.instantiate()
      $CellHolder.add_child(cell)
      _cells.append(cell)

  for i in range(3):
    for j in range(3):
      var box_border = Border.new()
      box_border.border_width = 7
      $BoxHolder.add_child(box_border)
      _boxes.append(box_border)
      _adjust_box_properties(j, i)


func _exit_tree() -> void:
  if is_thread_available and _thread.is_started():
    _thread.wait_to_finish()
