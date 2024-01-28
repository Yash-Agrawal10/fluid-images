use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

include my-gdrive("fluid-images-common.arr")
import liquify-memoization, liquify-dynamic-programming
from my-gdrive("fluid-images-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).

check "liquify-memoization with 0 seams removed":
  liquify-memoization(mixed-pixel, 0) is mixed-pixel
  liquify-memoization(mixed-square, 0) is mixed-square
  liquify-memoization(mixed-rect, 0) is mixed-rect
end
check "liquify-memoization removing single seams":
  liquify-memoization(black-square, 1) is 
  [image(1,2): color(0,0,0), color(0,0,0)]
  liquify-memoization(mixed-square, 1) is 
  [image(1, 2): color(0,0,100), color(200,0,0)]
  liquify-memoization(white-rect, 1) is 
  [image(1, 3): color(255,255,255), color(255,255,255), color(255,255,255)]
  liquify-memoization(mixed-rect, 1) is 
  [image(3, 2): color(255,0,0), color(0,255,0), color(0,0,255), 
    color(20,40,60), color(255,255,255), color(0,0,0)]
  liquify-memoization(mixed-square-3, 1) is 
  [image(2, 3): color(0,150,0), color(124,123,239), 
    color(200,0,0), color(20,210,50), 
    color(12,45,57), color(30,69,10)]
end
check "liquify-memoization removing multiple seams":
  liquify-memoization(mixed-square-3, 2) is
  [image(1, 3): color(0,150,0), color(200,0,0), color(30,69,10)]
  liquify-memoization(mixed-rect, 3) is 
  [image(1, 2): color(0,255,0), color(0,0,0)]
  liquify-memoization(mixed-square-5, 3) is 
  [image(2, 5): color(25,67,25), color(93,12,64), color(12,21,21), color(9,1,2),
    color(1,2,3), color(10,20,30), color(19,42,43), color(34,239,100),
    color(50,60,70), color(5,10,15)]
  liquify-memoization(mixed-square-5, 4) is 
  [image(1, 5): color(25,67,25), color(12,21,21), color(10,20,30), 
    color(19,42,43), color(5,10,15)]
end
check "liquify-memoization with tied seams":
  liquify-memoization(tied-rect, 1) is 
  [image(5, 2): color(200,0,0), color(0,255,255), color(255,0,255), 
    color(0,0,200), color(0,0,100), color(100,0,0), color(255,0,255), 
    color(0,255,255), color(0,0,100), color(0,0,200)]
  liquify-memoization(tied-rect, 2) is 
  [image(4, 2): color(200,0,0), color(0,255,255), color(255,0,255), 
    color(0,0,200),color(100,0,0), color(255,0,255), 
    color(0,255,255), color(0,0,100)]
  liquify-memoization(tied-rect, 3) is 
  [image(3, 2): color(0,255,255), color(255,0,255), 
    color(0,0,200), color(255,0,255), color(0,255,255), color(0,0,100)]
  liquify-memoization(tied-square, 1) is 
  [image(4, 5): color(20,30,40), color(4,6,8), color(255,255,255), color(8,6,4), 
    color(50,60,70), color(5,10,15), color(255,255,255), color(15,10,5), 
    color(0,255,255), color(255,0,255), color(255,255,0), color(0,0,255),
    color(50,60,70), color(5,10,15), color(255,255,255), color(15,10,5), 
    color(20,30,40), color(4,6,8), color(255,255,255), color(8,6,4)]
  liquify-memoization(tied-square, 2) is 
  [image(3, 5): color(20,30,40), color(4,6,8), color(8,6,4),
    color(50,60,70), color(5,10,15), color(15,10,5),
    color(0,255,255), color(255,0,255), color(0,0,255), 
    color(50,60,70), color(5,10,15), color(15,10,5), 
    color(20,30,40), color(4,6,8), color(8,6,4)]
  liquify-memoization(tied-square, 3) is 
  [image(2, 5): color(20,30,40), color(4,6,8), 
    color(50,60,70), color(5,10,15), 
    color(0,255,255), color(0,0,255), 
    color(50,60,70), color(5,10,15), 
    color(20,30,40), color(4,6,8)]
end
check "liquify-memoization with tied seams not at the top":
  liquify-memoization(tied-square-2, 1) is 
  [image(2, 3): color(100,0,0), color(0,0,100), 
    color(0,0,0), color(0,0,0),
    color(0,0,0), color(0,0,100)]
  liquify-memoization(tied-square-2, 2) is 
  [image(1, 3): color(0,0,100), color(0,0,0), color(0,0,0)]
  liquify-memoization(tied-rect-2, 1) is 
  [image(3, 3): color(1,2,3), color(3,2,1), color(255,255,250), 
    color(200,0,0), color(0,0,0), color(0,0,200), 
    color(5,10,15), color(3,2,1), color(15,10,5)]
  liquify-memoization(tied-rect-2, 2) is 
  [image(2, 3): color(3,2,1), color(255,255,250), 
    color(0,0,0), color(0,0,200), 
    color(5,10,15), color(15,10,5)]
end

check "liquify-dynamic-programming with 0 seams removed":
  liquify-dynamic-programming(mixed-pixel, 0) is mixed-pixel
  liquify-dynamic-programming(mixed-square, 0) is mixed-square
  liquify-dynamic-programming(mixed-rect, 0) is mixed-rect
end
check "liquify-dynamic-programming removing single seams":
  liquify-dynamic-programming(black-square, 1) is 
  [image(1,2): color(0,0,0), color(0,0,0)]
  liquify-dynamic-programming(mixed-square, 1) is 
  [image(1, 2): color(0,0,100), color(200,0,0)]
  liquify-dynamic-programming(white-rect, 1) is 
  [image(1, 3): color(255,255,255), color(255,255,255), color(255,255,255)]
  liquify-dynamic-programming(mixed-rect, 1) is 
  [image(3, 2): color(255,0,0), color(0,255,0), color(0,0,255), 
    color(20,40,60), color(255,255,255), color(0,0,0)]
  liquify-dynamic-programming(mixed-square-3, 1) is 
  [image(2, 3): color(0,150,0), color(124,123,239), 
    color(200,0,0), color(20,210,50), 
    color(12,45,57), color(30,69,10)]
end
check "liquify-dynamic-programming removing multiple seams":
  liquify-dynamic-programming(mixed-square-3, 2) is
  [image(1, 3): color(0,150,0), color(200,0,0), color(30,69,10)]
  liquify-dynamic-programming(mixed-rect, 3) is 
  [image(1, 2): color(0,255,0), color(0,0,0)]
  liquify-dynamic-programming(mixed-square-5, 3) is 
  [image(2, 5): color(25,67,25), color(93,12,64), color(12,21,21), color(9,1,2),
    color(1,2,3), color(10,20,30), color(19,42,43), color(34,239,100),
    color(50,60,70), color(5,10,15)]
  liquify-dynamic-programming(mixed-square-5, 4) is 
  [image(1, 5): color(25,67,25), color(12,21,21), color(10,20,30), 
    color(19,42,43), color(5,10,15)]
end
check "liquify-dynamic-programming with tied seams":
  liquify-dynamic-programming(tied-rect, 1) is 
  [image(5, 2): color(200,0,0), color(0,255,255), color(255,0,255), 
    color(0,0,200), color(0,0,100), color(100,0,0), color(255,0,255), 
    color(0,255,255), color(0,0,100), color(0,0,200)]
  liquify-dynamic-programming(tied-rect, 2) is 
  [image(4, 2): color(200,0,0), color(0,255,255), color(255,0,255), 
    color(0,0,200),color(100,0,0), color(255,0,255), 
    color(0,255,255), color(0,0,100)]
  liquify-dynamic-programming(tied-rect, 3) is 
  [image(3, 2): color(0,255,255), color(255,0,255), 
    color(0,0,200), color(255,0,255), color(0,255,255), color(0,0,100)]
  liquify-dynamic-programming(tied-square, 1) is 
  [image(4, 5): color(20,30,40), color(4,6,8), color(255,255,255), color(8,6,4), 
    color(50,60,70), color(5,10,15), color(255,255,255), color(15,10,5), 
    color(0,255,255), color(255,0,255), color(255,255,0), color(0,0,255),
    color(50,60,70), color(5,10,15), color(255,255,255), color(15,10,5), 
    color(20,30,40), color(4,6,8), color(255,255,255), color(8,6,4)]
  liquify-dynamic-programming(tied-square, 2) is 
  [image(3, 5): color(20,30,40), color(4,6,8), color(8,6,4),
    color(50,60,70), color(5,10,15), color(15,10,5),
    color(0,255,255), color(255,0,255), color(0,0,255), 
    color(50,60,70), color(5,10,15), color(15,10,5), 
    color(20,30,40), color(4,6,8), color(8,6,4)]
  liquify-dynamic-programming(tied-square, 3) is 
  [image(2, 5): color(20,30,40), color(4,6,8), 
    color(50,60,70), color(5,10,15), 
    color(0,255,255), color(0,0,255), 
    color(50,60,70), color(5,10,15), 
    color(20,30,40), color(4,6,8)]
end
check "liquify-dynamic-programming with tied seams not at the top":
  liquify-dynamic-programming(tied-square-2, 1) is 
  [image(2, 3): color(100,0,0), color(0,0,100), 
    color(0,0,0), color(0,0,0),
    color(0,0,0), color(0,0,100)]
  liquify-dynamic-programming(tied-square-2, 2) is 
  [image(1, 3): color(0,0,100), color(0,0,0), color(0,0,0)]
  liquify-dynamic-programming(tied-rect-2, 1) is 
  [image(3, 3): color(1,2,3), color(3,2,1), color(255,255,250), 
    color(200,0,0), color(0,0,0), color(0,0,200), 
    color(5,10,15), color(3,2,1), color(15,10,5)]
  liquify-dynamic-programming(tied-rect-2, 2) is 
  [image(2, 3): color(3,2,1), color(255,255,250), 
    color(0,0,0), color(0,0,200), 
    color(5,10,15), color(15,10,5)]
end
