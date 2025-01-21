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


# fill the whole grid (in the future)
func fill_grid():
  print("fill_grid state: ", _random.state)
  _fill_first_box()
  _fill_first_row_of_second_and_third_box()
  _fill_second_row_of_second_and_third_box()
  _fill_third_row_of_second_and_third_box()
  _print_row(0)
  _print_row(1)
  _print_row(2)


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


# fill a cell with random, but correct number
# Too tedious to write the algorithm
# func _fill_a_cell(x: int, y: int) -> void:
#   var box_index = int(x / 3.0) + int(y / 3.0) * 3
#   var row_cells = get_cells_in_row(y)
#   var column_cells = get_cells_in_column(x)
#   var box_cells = get_cells_in_box(box_index)

#   var int_pool = []
#   var exclude_nums = []
#   exclude_nums.append_array(_get_numbers_from_cells(row_cells))
#   exclude_nums.append_array(_get_numbers_from_cells(column_cells))
#   exclude_nums.append_array(_get_numbers_from_cells(box_cells))

#   int_pool = _subtract_array(int_pool, exclude_nums)
#   print(int_pool)
#   _cells[x + y * 9].number = int_pool[_random.randi_range(0, int_pool.size() - 1)]
#   print(_cells[x + y * 9].number)


# fill the first box with 1 to 9 in order.
func _fill_first_box():
  var cells_in_first_box = get_cells_in_box(0)
  var index = 1
  for cell in cells_in_first_box:
    cell.number = index
    index += 1


# fill the first row of the second and the third box randomly
func _fill_first_row_of_second_and_third_box():
  var int_pool = [4, 5, 6, 7, 8, 9]
  var cells_in_first_row = get_cells_in_row(0)
  var index = 0
  for cell in cells_in_first_row:
    index += 1
    if index < 4:
      continue
    var num = _pop_some_random_numbers(int_pool, 1)[0]
    cell.number = num


# Fill the second row of the second and third box randomly
func _fill_second_row_of_second_and_third_box():
  var int_pool = [1, 2, 3, 7, 8, 9]
  var nums_in_second_box = _get_numbers_from_cells(get_cells_in_box(1))
  var nums_in_third_box = _get_numbers_from_cells(get_cells_in_box(2))

  var int_pool_second_box = []
  var int_pool_third_box = []

  # add numbers which must be in the second box =
  # numbers in the third box except for the ones which aare already in the first box
  int_pool_second_box = _subtract_array(nums_in_third_box, [4, 5, 6])
  var tmp = _subtract_array(int_pool, nums_in_second_box)
  tmp = _subtract_array(tmp, int_pool_second_box)
  int_pool_second_box.append(_pop_some_random_numbers(tmp, 1)[0])
  print(int_pool_second_box)
  int_pool_third_box = _subtract_array(int_pool, int_pool_second_box)

  int_pool = []
  for i in range(3):
    int_pool.append(_pop_some_random_numbers(int_pool_second_box, 1)[0])
  for i in range(3):
    int_pool.append(_pop_some_random_numbers(int_pool_third_box, 1)[0])

  var index = 3
  var cells_in_second_row = get_cells_in_row(1)
  for i in range(6):
    cells_in_second_row[index + i].number = int_pool[i]


# Fill the third row of the second and third box randomly
func _fill_third_row_of_second_and_third_box():
  var int_pool = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  var nums_in_second_box = _get_numbers_from_cells(get_cells_in_box(1))
  var nums_in_third_box = _get_numbers_from_cells(get_cells_in_box(2))

  var int_pool_second_box = []
  var int_pool_third_box = []

  int_pool_second_box = _subtract_array(int_pool, nums_in_second_box)
  int_pool_third_box = _subtract_array(int_pool, nums_in_third_box)

  int_pool = []
  for i in range(3):
    int_pool.append(_pop_some_random_numbers(int_pool_second_box, 1)[0])
  for i in range(3):
    int_pool.append(_pop_some_random_numbers(int_pool_third_box, 1)[0])

  var index = 3
  var cells_in_third_row = get_cells_in_row(2)
  for i in range(6):
    cells_in_third_row[index + i].number = int_pool[i]


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
        selected_cell.number = number


func _init() -> void:
  _random.randomize()
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
      cell.number = 0
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
