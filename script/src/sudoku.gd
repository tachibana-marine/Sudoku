@tool
class_name Sudoku
extends Node2D

signal cell_edited

@export var default_cell_color: Color = Color.WHITE
@export var selected_cell_color: Color = Color.ORANGE

var selected_cell: Cell = null:
  get():
    return selected_cell

var _cell_scene = load("res://scene/cell.tscn")

var _cells: Array[Cell] = []
var _boxes: Array[Border] = []

var _random: RandomNumberGenerator = RandomNumberGenerator.new()


# verify given cells contains 1 to 9
static func verify_cells(cells: Array[Cell]):
  var count = []
  count.resize(9)
  count.fill(0)
  for cell in cells:
    if cell.number == 0:
      return false
    count[cell.number - 1] = 1
  if count.all(func(num): return num == 1):
    return true
  return false


# verify there is no duplicate cells (cells with number=0 are not counted)
static func verify_no_duplicate_cells(cells: Array[Cell]):
  var count = []
  count.resize(9)
  count.fill(0)
  for cell in cells:
    if cell.number == 0:
      continue
    count[cell.number - 1] += 1
  if count.all(func(num): return num <= 1):
    return true
  return false


# set state
func set_state(state: int):
  _random.set_state(state)


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


# return cells in the given column. The index starts with 0
func get_cells_in_column(index: int) -> Array[Cell]:
  var cells_in_column: Array[Cell] = []
  for i in range(9):
    cells_in_column.append(_cells[index + i * 9])
  return cells_in_column


# change number of a cell
func set_number_of_cell(cell: Cell, number: int):
  cell.number = number
  cell_edited.emit(cell)


# return if the grid is complete or not
func is_complete() -> bool:
  for i in range(9):
    var cells_in_row = get_cells_in_row(i)
    if not Sudoku.verify_cells(cells_in_row):
      return false

  for i in range(9):
    var cells_in_box = get_cells_in_box(i)
    if not Sudoku.verify_cells(cells_in_box):
      return false

  for i in range(9):
    var cells_in_column = get_cells_in_column(i)
    if not Sudoku.verify_cells(cells_in_column):
      return false

  return true


# fill the whole grid (in the future)
func fill_grid():
  print("fill_grid state: ", _random.state)
  var i = 0
  while i < 81:
    var x = i % 9
    var y = int(i / 9.0)
    var num = _find_num(x, y)
    if num == 0:
      # reset to the start
      for k in range(i):
        _cells[i - k - 1].number = 0
      i = 0
      continue
    _cells[i].number = num
    i += 1
    if i >= 9 * 9:
      # early break for now
      break
  for k in range(9):
    _print_row(k)


# Reset all cells
func reset_cells():
  for cell in _cells:
    cell.is_immutable = false
    cell.number = 0


# Randomly reset <num> cells to zero
func randomly_reset_cells(num: int):
  print("randomly_reset_cells state: ", _random.state)
  if num > 81:
    return
  var remove_pos = []
  for i in range(num):
    while true:
      var pos = _random.randi_range(0, 80)
      if pos not in remove_pos:
        remove_pos.append(pos)
        break
  print(remove_pos)
  for pos in remove_pos:
    _cells[pos].number = 0


# make non zero cells immutable
# other cells become mutable
func make_non_zero_cells_immutable():
  for cell in _cells:
    if cell.number == 0:
      cell.is_immutable = false
    else:
      cell.is_immutable = true


# find valid num of the given coord
# assuming the grid is filled from top-left to bottom-right
func _find_num(x: int, y: int):
  # numbers can be in there
  var int_pool = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  var box = int(x / 3.0) + int(y / 3.0) * 3
  int_pool = _subtract_array(int_pool, _get_numbers_from_cells(get_cells_in_box(box)))
  int_pool = _subtract_array(int_pool, _get_numbers_from_cells(get_cells_in_column(x)))
  int_pool = _subtract_array(int_pool, _get_numbers_from_cells(get_cells_in_row(y)))

  if int_pool.size() == 0:
    return 0
  var num = _pop_some_random_numbers(int_pool, 1)[0]
  return num


# print row
func _print_row(i: int):
  var cells = get_cells_in_row(i)
  var nums = []
  for cell in cells:
    nums.append(cell.number)
  print(nums)


# get first three numbers of an array
func _get_first_some_cells_num(cells: Array[Cell], num = 3):
  var first_three_nums = []
  for i in range(num):
    first_three_nums.append(cells[i].number)
  return first_three_nums


# remove numbers in array2 from array1
func _subtract_array(array1: Array, array2: Array) -> Array:
  var array1_copy = array1.duplicate()
  for num in array2:
    if num in array1_copy:
      array1_copy.erase(num)
  return array1_copy


# pop some numbers from an array
func _pop_some_random_numbers(numbers: Array, amount = 3):
  var three_numbers = []
  for i in range(amount):
    var index = _random.randi_range(0, numbers.size() - 1)
    var num = numbers[index]
    numbers.erase(num)
    three_numbers.append(num)
  return three_numbers


# get numbers other than zero from cells in an array
func _get_numbers_from_cells(cells: Array[Cell]) -> Array[int]:
  var nums: Array[int] = []
  for cell in cells:
    if cell.number != 0:
      nums.append(cell.number)
  return nums


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
