class_name SudokuUtil


# verify given cells contains 1 to 9
static func verify_cells(cells: Array[int]):
  var count = []
  count.resize(9)
  count.fill(0)
  for cell in cells:
    if cell == 0:
      return false
    count[cell - 1] = 1
  if count.all(func(num): return num == 1):
    return true
  return false


# verify there is no duplicate cells (cells with number=0 are not counted)
static func verify_no_duplicate_cells(cells: Array[int]):
  var count = []
  count.resize(9)
  count.fill(0)
  for cell in cells:
    if cell == 0:
      continue
    count[cell - 1] += 1
  if count.all(func(num): return num <= 1):
    return true
  return false


# return numbers in the given box. The index starts with 0.
static func get_cells_in_box(index: int, cells: Array[int]) -> Array[int]:
  var x = index % 3
  var y = int(index / 3.0)  # silence the linter
  # get index of the top left cell of the box
  var start_index = x * 3 + y * 9 * 3
  var cells_in_box: Array[int] = []
  for j in range(3):
    for i in range(3):
      var cell_index = start_index + i + j * 9
      cells_in_box.append(cells[cell_index])
  return cells_in_box


# return cells in the given row. The index starts with 0.
static func get_cells_in_row(index: int, cells: Array[int]) -> Array[int]:
  var start_index = index * 9
  var cells_in_row: Array[int] = []
  for i in range(9):
    cells_in_row.append(cells[start_index + i])
  return cells_in_row


# return cells in the given column. The index starts with 0
static func get_cells_in_column(index: int, cells: Array[int]) -> Array[int]:
  var cells_in_column: Array[int] = []
  for i in range(9):
    cells_in_column.append(cells[index + i * 9])
  return cells_in_column


# print row
static func print_row(index: int, cells: Array[int]):
  var nums = get_cells_in_row(index, cells)
  print(nums)


# return if the grid is complete or not
static func is_complete(cells: Array[int]) -> bool:
  for i in range(9):
    var cells_in_row = get_cells_in_row(i, cells)
    if not verify_cells(cells_in_row):
      return false

  for i in range(9):
    var cells_in_box = get_cells_in_box(i, cells)
    if not verify_cells(cells_in_box):
      return false

  for i in range(9):
    var cells_in_column = get_cells_in_column(i, cells)
    if not verify_cells(cells_in_column):
      return false

  return true


# create filled grid
static func create_filled_grid(random: RandomNumberGenerator) -> Array[int]:
  print("create_filled_grid state: ", random.state)
  var cell_numbers: Array[int] = []
  cell_numbers.resize(81)
  cell_numbers.fill(0)

  var i = 0
  while i < 81:
    var x = i % 9
    var y = int(i / 9.0)
    var nums = _find_nums(x, y, cell_numbers)

    var num = 0
    if nums.size() > 0:
      # pick random
      num = nums[random.randi_range(0, nums.size() - 1)]

    if num == 0:
      # reset to the start
      for k in range(i):
        cell_numbers[i - k - 1] = 0
      i = 0
      continue
    cell_numbers[i] = num
    i += 1
  return cell_numbers


# count solutions.
static func backtrack_cell(_cells: Array[int], index: int, count: int) -> int:
  var cells = _cells.duplicate()
  var verify_sudoku = func() -> bool:
    for row in range(9):
      var cells_in_row = get_cells_in_row(row, cells)
      if not verify_no_duplicate_cells(cells_in_row):
        return false
    for column in range(9):
      var cells_in_column = get_cells_in_column(column, cells)
      if not verify_no_duplicate_cells(cells_in_column):
        return false
    for box in range(9):
      var cells_in_box = get_cells_in_box(box, cells)
      if not verify_no_duplicate_cells(cells_in_box):
        return false
    return true

  if count > 1:
    # early break
    return count

  if not cells[index] == 0:
    # the cell is filled
    if index == cells.size() - 1:
      return count + 1
    return backtrack_cell(cells, index + 1, count)

  for i in range(9):
    cells[index] = i + 1
    #print("=--------------------------------=")
    for j in range(9):
      #print_row(j, cells)
      pass
    if verify_sudoku.call():
      if index == cells.size() - 1:
        return count + 1
      count = backtrack_cell(cells, index + 1, count)
  cells[index] = 0
  return count


# find valid numbers of the given coord
# assuming the grid is filled from top-left to bottom-right
static func _find_nums(x: int, y: int, cells: Array[int]) -> Array[int]:
  # numbers can be in there
  var int_pool: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  var box = int(x / 3.0) + int(y / 3.0) * 3
  int_pool = _subtract_array(int_pool, SudokuUtil.get_cells_in_box(box, cells))
  int_pool = _subtract_array(int_pool, SudokuUtil.get_cells_in_column(x, cells))
  int_pool = _subtract_array(int_pool, SudokuUtil.get_cells_in_row(y, cells))

  if int_pool.size() == 0:
    return []
  return int_pool


# remove numbers in array2 from array1
static func _subtract_array(array1: Array, array2: Array) -> Array:
  var array1_copy = array1.duplicate()
  for num in array2:
    if num in array1_copy:
      array1_copy.erase(num)
  return array1_copy
