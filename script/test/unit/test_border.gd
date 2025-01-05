extends GutTest


func test_border_exists():
  var border = autofree(Border.new())
  assert_not_null(border)
  assert_property(border, "size", 10, 20)
  assert_property(border, "border_width", 1, 2)


func test_border_draw_log():
  var border = add_child_autofree(Border.new())
  assert_eq(border.log_txt, "")
  await wait_frames(1)
  assert_eq(border.log_txt, "(0,0)(10,10)BORDER WIDTH=1")
  # redraw on width change
  border.border_width = 2
  await wait_frames(1)
  assert_eq(border.log_txt, "(0,0)(10,10)BORDER WIDTH=2")
  # redraw on size change
  border.size = 20
  await wait_frames(1)
  assert_eq(border.log_txt, "(0,0)(20,20)BORDER WIDTH=2")
