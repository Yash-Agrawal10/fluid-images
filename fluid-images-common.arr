use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both
# fluid-images-code.arr and fluid-images-tests.arr

#image url stuff
#|
import image-url,
  image-width,
  image-height,
  image-to-color-list,
  color-list-to-image
  from image
import image-structs as I
fun run-on-url(url :: String, func :: (Image, Number -> Image), n :: Number):
  doc: ```Runs one of your Fluid Images implementations on an image
       downloaded from a url```
  fl-image :: Image =
    let raw-image = image-url(url),
      width       = image-width(raw-image),
      height      = image-height(raw-image),
      image-data  = image-to-color-list(raw-image):
      image-data.map({(c):color(c.red, c.green, c.blue)})
        ^ builtins.raw-array-from-list
        ^ image(width,height).make
    end
  liquified = func(fl-image, n)
  im-list = lists.fold({(acc, cur): acc.append(cur)}, empty, liquified.pixels)
  im-list-colors = im-list.map({(e): I.color(e.red, e.green, e.blue, 1)})
  color-list-to-image(im-list-colors, liquified.width, liquified.height, 0, 0)
end
|#

#images for testing
black-pixel = [image(1, 1): color(0,0,0)]
white-pixel = [image(1, 1): color(255,255,255)]
red-pixel = [image(1, 1): color(255,0,0)]
green-pixel = [image(1, 1): color(0,255,0)]
blue-pixel = [image(1, 1): color(0,0,255)]
mixed-pixel = [image(1, 1): color(50,100,150)]

black-square = [image(2,2):
  color(0,0,0), color(0,0,0),
  color(0,0,0), color(0,0,0)]
white-square = [image(2,2):
  color(255,255,255), color(255,255,255),
  color(255,255,255), color(255,255,255)]
mixed-square = [image(2,2):
  color(0,0,100), color(0,150,0),
  color(200,0,0), color(100,100,100)]
mixed-square-3 = [image(3,3):
  color(0,0,100), color(0,150,0), color(124,123,239), 
  color(200,0,0), color(100,100,100), color(20,210,50), 
  color(12,45,57), color(12,129,123), color(30,69,10)]
mixed-square-5 = [image(5, 5):
  color(14,12,23), color(25,67,25), color(93,12,64), color(13,12,32), color(12,23,12), 
  color(12,21, 21), color(9,8,10), color(213,80,91), color(9,1,2), color(1,0,0),
  color(201,239,90), color(1,2,3), color(3,2,1), color(81,10,239), color(10,20,30),
  color(32,4,2), color(10,29,39), color(93,2,12), color(19,42,43), color(34,239,100), 
  color(30,40,50), color(90,85,75), color(4,5,6), color(50,60,70), color(5,10,15)]

black-rect = [image(3,2):
  color(0,0,0), color(0,0,0), color(0,0,0),
  color(0,0,0), color(0,0,0), color(0,0,0)]
white-rect = [image(2,3):
  color(255,255,255), color(255,255,255),
  color(255,255,255), color(255,255,255), 
  color(255,255,255), color(255,255,255)]
mixed-rect = [image(4, 2):
  color(0,0,0), color(255,0,0), color(0,255,0), color(0,0,255),
  color(100,100,100), color(20,40,60), color(255,255,255), color(0,0,0)]

tied-rect = [image(6, 2): 
  color(100,0,0), color(200,0,0), color(0,255,255), 
  color(255,0,255),color(0,0,200), color(0,0,100), 
  color(200,0,0), color(100,0,0), color(255,0,255), 
  color(0,255,255), color(0,0,100), color(0,0,200)]
tied-square = [image(5, 5):
  color(20,30,40), color(4,6,8), color(255,255,255), color(8,6,4), color(40,30,20),
  color(50,60,70), color(5,10,15), color(255,255,255), color(15,10,5), color(70,60,50),
  color(0,255,255), color(255,0,255), color(255,255,0), color(0,0,255), color(255,0,0), 
  color(50,60,70), color(5,10,15), color(255,255,255), color(15,10,5), color(70,60,50),
  color(20,30,40), color(4,6,8), color(255,255,255), color(8,6,4), color(40,30,20)]

tied-rect-2 = [image(4, 3): 
  color(250,255,255), color(1,2,3), color(3,2,1), color(255,255,250), 
  color(200,0,0), color(0,0,0), color(0,0,0), color(0,0,200), 
  color(5,10,15), color(1,2,3), color(3,2,1), color(15,10,5)]
tied-square-2 = [image(3, 3): 
  color(100,0,0), color(0,100,0), color(0,0,100), 
  color(0,0,0), color(0,100,0), color(0,0,0), 
  color(100,0,0), color(0,0,0), color(0,0,100)]

#functions for testing memoize
fun bad-sum(random-string :: String, num-1 :: Number, num-2 :: Number):
  doc: "terrible way to sum non-negative integers to test memoize-3"
  if random-string == "sum":
    if num-1 == 0:
      if num-2 == 0:
        0
      else:
        1 + bad-sum(random-string, num-1, num-2 - 1)
      end
    else:
      1 + bad-sum(random-string, num-1 - 1, num-2)
    end
  else:
    num-1 - num-2
  end
where:
  bad-sum("sum", 0, 0) is 0
  bad-sum("sum", 0, 2) is 2
  bad-sum("sum", 2, 0) is 2
  bad-sum("sum", 2, 4) is 6
  
  bad-sum("a", 0, 0) is 0
  bad-sum("b", 0, 2) is -2
  bad-sum("c", 2, 0) is 2
  bad-sum("d", 2, 4) is -2
end