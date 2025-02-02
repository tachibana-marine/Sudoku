class_name SudokuUtil


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


# return cells in the given box. The index starts with 0.
static func get_cells_in_box(index: int, cells: Array[Cell]) -> Array[Cell]:
  var x = index % 3
  var y = int(index / 3.0)  # silence the linter
  # get index of the top left cell of the box
  var start_index = x * 3 + y * 9 * 3
  var cells_in_box: Array[Cell] = []
  for j in range(3):
    for i in range(3):
      var cell_index = start_index + i + j * 9
      cells_in_box.append(cells[cell_index])
  return cells_in_box


# return cells in the given row. The index starts with 0.
static func get_cells_in_row(index: int, cells: Array[Cell]) -> Array[Cell]:
  var start_index = index * 9
  var cells_in_row: Array[Cell] = []
  for i in range(9):
    cells_in_row.append(cells[start_index + i])
  return cells_in_row


# return cells in the given column. The index starts with 0
static func get_cells_in_column(index: int, cells: Array[Cell]) -> Array[Cell]:
  var cells_in_column: Array[Cell] = []
  for i in range(9):
    cells_in_column.append(cells[index + i * 9])
  return cells_in_column


# print row
static func print_row(index: int, cells: Array[Cell]):
  var nums: Array[int] = []
  for cell in get_cells_in_row(index, cells):
    nums.append(cell.number)
  print(nums)


# count solutions
static func backtrack_cell(cells: Array[Cell], index: int, count: int) -> int:
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

  if not cells[index].number == 0:
    # the cell is filled
    if index == cells.size() - 1:
      return count + 1
    return backtrack_cell(cells, index + 1, count)

  for i in range(9):
    cells[index].number = i + 1
    if verify_sudoku.call():
      if index == cells.size() - 1:
        return count + 1
      count = backtrack_cell(cells, index + 1, count)
  cells[index].number = 0
  return count
