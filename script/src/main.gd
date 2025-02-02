extends Node2D

@export var removed_cells: int = 20


func _ready() -> void:
  $Version.text = Constants.VERSION_NUMBER
  $Sudoku.fill_grid()
  # $Sudoku.randomly_reset_cells(removed_cells)
  $Sudoku.reset_as_much_as_possible_with_unique_solutions()
  $Sudoku.make_non_zero_cells_immutable()


func _on_complete():
  $ClearWindow.visible = true


func _on_sudoku_cell_edited(_cell: Cell):
  if $Sudoku.is_complete():
    _on_complete()
