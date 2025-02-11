class_name Main
extends Node2D

@export var removed_cells: int = 20


func _ready() -> void:
  $Version.text = Constants.VERSION_NUMBER
  $Progress.progress_text = Progress.STATUS_FILLING
  $Sudoku.create_grid()


func _on_grid_generated():
  $Progress.hide()
  $Sudoku.show()


func _on_sudoku_grid_filled():
  $Progress.progress_text = Progress.STATUS_REMOVING


func _on_sudoku_cell_edited(_cell: Cell):
  if $Sudoku.is_complete():
    $ClearWindow.visible = true
