extends Node2D

@export var removed_cells: int = 20


func _ready() -> void:
  $Version.text = Constants.VERSION_NUMBER


func _on_scene_loaded() -> void:
  await $Sudoku.fill_grid()
  await $Sudoku.reset_as_much_as_possible_with_unique_solutions()
  await $Sudoku.make_non_zero_cells_immutable()


func _on_complete():
  $ClearWindow.visible = true


func _on_sudoku_cell_edited(_cell: Cell):
  if $Sudoku.is_complete():
    _on_complete()
