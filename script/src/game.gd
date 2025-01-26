extends Node2D


func _ready() -> void:
  $Version.text = Constants.VERSION_NUMBER
  $Sudoku.fill_grid()
  $Sudoku.randomly_reset_cells(50)
