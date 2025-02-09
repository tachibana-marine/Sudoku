class_name Main
extends Node2D

@export var removed_cells: int = 20


func _ready() -> void:
  $Version.text = Constants.VERSION_NUMBER
  $Sudoku.create_grid()


func _on_complete():
  $ClearWindow.visible = true


func _on_grid_generated():
  $Progress.hide()
  $Sudoku.show()


func _on_sudoku_cell_edited(_cell: Cell):
  if $Sudoku.is_complete():
    _on_complete()
