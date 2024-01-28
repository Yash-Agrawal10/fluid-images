use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

provide: liquify-memoization, liquify-dynamic-programming end

include my-gdrive("fluid-images-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions)
# in this file.
include string-dict

fun image-to-brightness(img :: Image) -> List<List<Number>>:
  doc: ```consumes an image, produces a list of list of 
       numbers representing brightness padded with zeros```
  width = img.width
  pixels = img.pixels
  brightness = pixels.map(_.map(lam(col :: Color): 
      col.red + col.green + col.blue end))
  padded-rows = brightness.map({(row :: List<Number>):
      link(0, row + [list: 0])})
  zero-row = repeat(width + 2, 0)
  link(zero-row, padded-rows + [list: zero-row])
end

fun energy-helper(top :: List<Number>, middle :: List<Number>, 
    bottom :: List<Number>) -> List<Number>:
  doc: ```consumes 3 lists of non-negative numbers of equal length 
       representing brightness, returns middle's corresponding energy values 
       besides first and last item in the list```
  cases(List) top:
    | empty => empty
    | link(a, top-r) =>
      cases(List) top-r:
        | empty => empty
        | link(b, top-rr) =>
          cases(List) top-rr:
            | empty => empty
            | link(c, top-rrr) =>
              d = middle.get(0)
              f = middle.get(2)
              g = bottom.get(0)
              h = bottom.get(1)
              i = bottom.get(2)
              x-nrg = ((((a + (2 * d)) + g) - c) - (2 * f)) - i
              y-nrg = ((((a + (2 * b)) + c) - g) - (2 * h)) - i
              nrg = num-sqrt(num-sqr(x-nrg) + num-sqr(y-nrg))
              #middle and bottom are non-empty by docstring because top is
              link(nrg, energy-helper(top-r, middle.rest, bottom.rest))
          end
      end
  end
end

fun brightness-to-energy(brightness :: List<List<Number>>)
  -> List<List<Number>>:
  doc: ```consumes a list of list of numbers representing
       an images brightness values padded with zeros, produces a 
       list of list of numbers representing an images energy values```
  cases(List) brightness:
    | empty => empty
    | link(f, r) => 
      cases(List) r:
        | empty => empty
        | link(fr, rr) =>
          cases(List) rr:
            | empty => empty
            | link(frr, rrr) =>
              link(energy-helper(f, fr, frr), 
                brightness-to-energy(r))
          end
      end
  end
end

fun calc-min-seam(energies :: List<List<Number>>, 
    row :: Number, col :: Number) -> Number:
  doc: ```consumes a non-empty list of list of number representing energies
       and a row and column, produces the min total energy of a seam 
       from that point to the bottom row of the image```
  ask:
    | row == (energies.length() - 1) then: energies.get(row).get(col)
    | otherwise:
      cols = energies.get(0).length()
      ask:
        | col == 0 then:
          if cols == 1:
            energies.get(row).get(col) + 
            calc-min-seam(energies, row + 1, col)
          else:
            energies.get(row).get(col) + 
            num-min(calc-min-seam(energies, row + 1, col), 
              calc-min-seam(energies, row + 1, col + 1))
          end
        | col == (cols - 1) then:
          energies.get(row).get(col) + 
          num-min(calc-min-seam(energies, row + 1, col), 
            calc-min-seam(energies, row + 1, col - 1))
        | otherwise:
          energies.get(row).get(col) + 
          num-min(calc-min-seam(energies, row + 1, col + 1),
            num-min(calc-min-seam(energies, row + 1, col), 
              calc-min-seam(energies, row + 1, col - 1)))
      end
  end
end

fun memoize-3<T, A>(func :: (T, Number, Number -> A)) -> (T, Number, Number -> A):
  doc: ```memoizes a function of 1 any parameter and 2 numbers, 
       using the numbers for indexing in the memo table```
  memo-table = [mutable-string-dict: ]
  lam(a, n1 :: Number, n2 :: Number):
    s = num-to-string(n1) + num-to-string(n2)
    tv = memo-table.get-now(s)
    cases(Option) tv block:
      | some(v) => 
        v
      | none =>
        val = func(a, n1, n2)
        memo-table.set-now(s, val)
        val
    end
  end
end

fun get-min-index(indexes :: List<Number>, costs :: List<Number>) -> Number:
  doc: ```consumes a non-empty list of ascending consecutive indexes 
       and a list of non-negative costs of equal length, 
       returns the leftmost index associated with the min cost```
  fun get-min-index-helper(index-list :: List<Number>, cost-list :: List<Number>, 
      min-index :: Number, min-cost :: Option<Number>) -> Number:
    cases(List) index-list:
      | empty => min-index
      | link(fi, ri) =>
        cases(List) cost-list:
          | empty => raise("lists must be equal length")
          | link(fc, rc) =>
            cases(Option) min-cost:
              | none => get-min-index-helper(ri, rc, fi, some(fc))
              | some(val) =>
                if fc < val:
                  get-min-index-helper(ri, rc, fi, some(fc))
                else:
                  get-min-index-helper(ri, rc, min-index, min-cost)
                end
            end
        end
    end
  end
  get-min-index-helper(indexes, costs, -1, none)
end

fun min-seam(energies :: List<List<Number>>) -> List<Number>:
  doc: ```consumes a non-empty list of list of number representing energies
       produces a list of numbers representing the indexes in each row
       that produce the min seam```
  rows = energies.length()
  cols = energies.get(0).length()
  rec calc-min-seam-memoized = memoize-3(
    lam(energy-list :: List<List<Number>>, row :: Number, col :: Number): 
      ask:
        | row == (energy-list.length() - 1) then: energy-list.get(row).get(col)
        | otherwise:
          ask:
            | col == 0 then:
              if cols == 1:
                energy-list.get(row).get(col) + 
                calc-min-seam-memoized(energy-list, row + 1, col)
              else:
                energy-list.get(row).get(col) + 
                num-min(calc-min-seam-memoized(energy-list, row + 1, col), 
                  calc-min-seam-memoized(energy-list, row + 1, col + 1))
              end
            | col == (cols - 1) then:
              energy-list.get(row).get(col) + 
              num-min(calc-min-seam-memoized(energy-list, row + 1, col), 
                calc-min-seam-memoized(energy-list, row + 1, col - 1))
            | otherwise:
              energy-list.get(row).get(col) + 
              num-min(calc-min-seam-memoized(energy-list, row + 1, col + 1),
                num-min(calc-min-seam-memoized(energy-list, row + 1, col), 
                  calc-min-seam-memoized(energy-list, row + 1, col - 1)))
          end
      end
    end)
  fun min-seam-helper(energy-list :: List<List<Number>>, 
      col-list :: List<Number>, row :: Number) -> List<Number>:
    cases(List) energy-list:
      | empty => empty
      | link(f, r) =>
        min-seam-list = col-list.map(lam(col :: Number): 
          calc-min-seam-memoized(energies, row, col) end)
        min-index = get-min-index(col-list, min-seam-list)
        ask:
          | min-index == 0 then:
            new-col-list = 
              if cols == 1: [list: min-index] 
              else: [list: min-index, min-index + 1] 
              end
            link(min-index, min-seam-helper(r, new-col-list, row + 1))
          | min-index == (cols - 1) then:
            new-col-list = [list: min-index - 1, min-index]
            link(min-index, min-seam-helper(r, new-col-list, row + 1))
          | otherwise: 
            new-col-list = [list: min-index - 1, min-index, min-index + 1]
            link(min-index, min-seam-helper(r, new-col-list, row + 1))
        end
    end
  end
  min-seam-helper(energies, range(0, cols), 0)
end

fun liquify-memoization(input :: Image, n :: Number) -> Image:
  doc: ```consumes an image and a number n, produces a new image with 
       n min seams of energy removed using memoization```
  if n == 0:
    input
  else:
    brightness = image-to-brightness(input)
    energy = brightness-to-energy(brightness)
    min-seam-indexes = min-seam(energy)
    pixels = input.pixels
    width = input.width
    height = input.height
    new-pixels = map2(lam(row :: List<Number>, index :: Number):
      row.take(index) + row.drop(index + 1) end, pixels, min-seam-indexes)
    new-image = image-data-to-image(width - 1, height, new-pixels)
    liquify-memoization(new-image, n - 1)
  end
end

fun calc-min-seam-dp(energies :: List<List<Number>>) -> List<List<Number>> block:
  doc: ```consumes a list of list of numbers representing energy, 
       produces a list of list of numbers representing the min seam cost
       to get from a given point to the bottom row```
  rows = energies.length()
  row-last = energies.get(rows - 1)
  cols = row-last.length()
  min-seam-array = build-array(lam(n :: Number): array-of(-1, cols) end, rows)
  array-last = min-seam-array.get-now(rows - 1)
  for each(j from range(0, cols)):
    array-last.set-now(j, row-last.get(j))
  end
  for each(i from range(2, rows + 1)) block:
    index = rows - i
    row-index = energies.get(index)
    array-index = min-seam-array.get-now(index)
    array-below = min-seam-array.get-now(index + 1)
    array-index.set-now(0, row-index.get(0) + 
      num-min(array-below.get-now(0), array-below.get-now(1)))
    for each(j from range(1, cols - 1)) block:
      array-index.set-now(j, row-index.get(j) + 
        num-min(num-min(array-below.get-now(j - 1), array-below.get-now(j)), 
          array-below.get-now(j + 1)))
    end
    array-index.set-now(cols - 1, row-index.get(cols - 1) + 
      num-min(array-below.get-now(cols - 2), array-below.get-now(cols - 1)))
  end
  array-list = min-seam-array.to-list-now()
  array-list.map(_.to-list-now())
end

fun get-min-seam(costs :: List<List<Number>>) -> List<Number>:
  doc: ```consumes a list of list of numbers representing the min seam cost
       to get from a given point to the bottom row, produces a list of numbers
       representing the indices of the min seam```
  fun get-min-seam-helper(cost-list :: List<List<Number>>, 
      prev-index :: Option<Number>) -> List<Number>:
    cases(List) cost-list:
      | empty => empty
      | link(f, r) =>
        length = f.length()
        min-index = 
          cases(Option) prev-index:
            | none => get-min-index(range(0, length), f)       
            | some(val) => 
              ask:
                | val == 0 then: 
                  get-min-index([list: 0, 1], [list: f.get(0), f.get(1)])
                | val == (length - 1) then:
                  get-min-index([list: length - 2, length - 1], 
                    [list: f.get(length - 2), f.get(length - 1)])
                | otherwise:
                  get-min-index([list: val - 1, val, val + 1], 
                    [list: f.get(val - 1), f.get(val), f.get(val + 1)])
              end
          end
        link(min-index, get-min-seam-helper(r, some(min-index)))
    end
  end
  get-min-seam-helper(costs, none)
end

fun liquify-dynamic-programming(input :: Image, n :: Number) -> Image:
  doc: ```consumes an image and a number n, produces a new image with 
       n min seams of energy removed using dynamic programming```
  if n == 0:
    input
  else:
    brightness = image-to-brightness(input)
    energy = brightness-to-energy(brightness)
    costs = calc-min-seam-dp(energy)
    min-seam-indexes = get-min-seam(costs)
    pixels = input.pixels
    width = input.width
    height = input.height
    new-pixels = map2(lam(row :: List<Number>, index :: Number):
      row.take(index) + row.drop(index + 1) end, pixels, min-seam-indexes)
    new-image = image-data-to-image(width - 1, height, new-pixels)
    liquify-dynamic-programming(new-image, n - 1)
  end
end

#Testing
check "image-to-brightness on single pixels":
  image-to-brightness(black-pixel) is 
  [list: [list: 0, 0, 0], [list: 0, 0, 0], [list: 0 , 0, 0]]
  image-to-brightness(white-pixel) is 
  [list: [list: 0, 0, 0], [list: 0, 765, 0], [list: 0 , 0, 0]]
  image-to-brightness(red-pixel) is 
  [list: [list: 0, 0, 0], [list: 0, 255, 0], [list: 0 , 0, 0]]
  image-to-brightness(blue-pixel) is 
  [list: [list: 0, 0, 0], [list: 0, 255, 0], [list: 0 , 0, 0]]
  image-to-brightness(green-pixel) is 
  [list: [list: 0, 0, 0], [list: 0, 255, 0], [list: 0 , 0, 0]]
  image-to-brightness(mixed-pixel) is 
  [list: [list: 0, 0, 0], [list: 0, 300, 0], [list: 0 , 0, 0]]
end
check "image to brightness on square images":
  image-to-brightness(black-square) is 
  [list: [list: 0, 0, 0, 0], [list: 0, 0, 0, 0], 
    [list: 0, 0, 0, 0], [list: 0, 0, 0, 0]]
  image-to-brightness(white-square) is 
  [list: [list: 0, 0, 0, 0], [list: 0, 765, 765, 0], 
    [list: 0, 765, 765, 0], [list: 0, 0, 0, 0]]
  image-to-brightness(mixed-square) is 
  [list: [list: 0, 0, 0, 0], [list: 0, 100, 150, 0], 
    [list: 0, 200, 300, 0], [list: 0, 0, 0, 0]]
end
check "image to brightness on rectangular images":
  image-to-brightness(black-rect) is 
  [list: [list: 0, 0, 0, 0, 0], [list: 0, 0, 0, 0, 0], 
    [list: 0, 0, 0, 0, 0], [list: 0, 0, 0, 0, 0]]
  image-to-brightness(white-rect) is 
  [list: [list: 0, 0, 0, 0], [list: 0, 765, 765, 0], 
    [list: 0, 765, 765, 0], [list: 0, 765, 765, 0], [list: 0, 0, 0, 0]]
  image-to-brightness(mixed-rect) is 
  [list: [list: 0, 0, 0, 0, 0, 0], [list: 0, 0, 255, 255, 255, 0], 
    [list: 0, 300, 120, 765, 0, 0], [list: 0, 0, 0, 0, 0, 0]]
end

check "energy-helper when lists are less than length 3":
  energy-helper(empty, empty, empty) is empty
  energy-helper([list: 0, 0], [list: 0, 0], [list: 0, 0]) is empty
end
check "energy-helper for lists length 3":
  energy-helper([list: 0, 0, 0], [list: 0, 0, 0], [list: 0, 0, 0])
    is-roughly [list: 0]
  energy-helper([list: 0, 0, 0], [list: 0, 10000, 0], [list: 0, 0, 0])
    is-roughly [list: 0]
  energy-helper([list: 1, 2, 3], [list: 4, 5, 6], [list: 7, 8, 9])
    is-roughly [list: num-sqrt(640)]
end
check "energy-helper for lists longer than length 3":
  energy-helper([list: 0, 0, 0, 0, 0], [list: 0, 0, 0, 0 ,0], 
    [list: 0, 0, 0, 0 ,0]) is-roughly [list: 0, 0, 0]
  energy-helper([list: 1, 2, 3, 4, 5], [list: 6, 7, 8, 9, 10], 
    [list: 11, 12, 13, 14, 15]) is-roughly 
  [list: num-sqrt(1664), num-sqrt(1664), num-sqrt(1664)]
  energy-helper([list: 2, 6, 7, 2, 3], [list: 1, 4, 3, 2, 5], 
    [list: 6, 8, 0, 2, 1]) is-roughly 
  [list: num-sqrt(10), num-sqrt(340), num-sqrt(82)]
end

check "brightness-to-energy for single pixel":
  brightness-to-energy(image-to-brightness(black-pixel)) 
    is [list: [list: 0]]
  brightness-to-energy(image-to-brightness(white-pixel)) 
    is [list: [list: 0]]
  brightness-to-energy(image-to-brightness(mixed-pixel)) 
    is [list: [list: 0]]
end
check "brightness-to-energy for square images":
  brightness-to-energy(image-to-brightness(black-square)) is-roughly
  [list: [list: 0, 0], [list: 0, 0]]
  brightness-to-energy(image-to-brightness(white-square)) is-roughly
  [list: [list: 2295 * num-sqrt(2), 2295 * num-sqrt(2)], 
    [list: 2295 * num-sqrt(2), 2295 * num-sqrt(2)]]
  brightness-to-energy(image-to-brightness(mixed-square)) is-roughly
  [list: [list: num-sqrt(850000), num-sqrt(800000)], 
    [list: num-sqrt(685000), num-sqrt(410000)]]
end
check "brightness-to-energy for rectangular images":
  brightness-to-energy(image-to-brightness(black-rect)) is-roughly
  [list: [list: 0, 0, 0], [list: 0, 0, 0]]
  brightness-to-energy(image-to-brightness(white-rect)) is-roughly
  [list: [list: 2295 * num-sqrt(2), 2295 * num-sqrt(2)], 
    [list: 3060, 3060], [list: 2295 * num-sqrt(2), 2295 * num-sqrt(2)]]
  brightness-to-energy(image-to-brightness(mixed-rect)) is-roughly
  [list: [list: num-sqrt(915300), num-sqrt(2653650), 
      num-sqrt(2736900), num-sqrt(2210850)], 
    [list: num-sqrt(310050), num-sqrt(1989450), 
      num-sqrt(1098000), num-sqrt(3771450)]]
end

check "calc-min-seam on single pixels":
  calc-min-seam([list: [list: 0]], 0, 0) is 0
  calc-min-seam([list: [list: 1000]], 0, 0) is 1000
  calc-min-seam([list: [list: 1000000]], 0, 0) is 1000000
end
check "calc-min-seam on non-edge cases":
  calc-min-seam([list: [list: 10, 20, 30], 
      [list: 14, 18, 22]], 0, 1) is 34
  calc-min-seam([list: [list: 15, 20, 30], 
      [list: 100, 50, 25]], 0, 1) is 45
  calc-min-seam([list: [list: 1, 2, 3], 
      [list: 5, 4, 6], [list: 9, 8, 7]], 0, 1) is 13
  calc-min-seam([list: [list: 1, 2, 3], 
      [list: 5, 4, 6], [list: 9, 8, 7]], 1, 1) is 11
end
check "calc-min-seam on bottom row":
  calc-min-seam([list: [list: 10, 20, 30], 
      [list: 14, 18, 22]], 1, 2) is 22
  calc-min-seam([list: [list: 10, 20, 30], 
      [list: 14, 18, 22]], 1, 0) is 14
  calc-min-seam([list: [list: 15, 20, 30], 
      [list: 100, 50, 25]], 1, 1) is 50
  calc-min-seam([list: [list: 1, 2, 3], 
      [list: 5, 4, 6], [list: 9, 8, 7]], 2, 0) is 9
end
check "calc-min-seam on left edge":
  calc-min-seam([list: [list: 10, 20, 30], 
      [list: 14, 18, 22]], 0, 0) is 24
  calc-min-seam([list: [list: 15, 20, 30], 
      [list: 100, 50, 25]], 0, 0) is 65
  calc-min-seam([list: [list: 1, 2, 3], 
      [list: 5, 4, 6], [list: 9, 8, 7]], 0, 0) is 12
  calc-min-seam([list: [list: 1, 2, 3], 
      [list: 5, 4, 6], [list: 9, 8, 7]], 1, 0) is 13
end
check "calc-min-seam on right edge":
  calc-min-seam([list: [list: 10, 20, 30], 
      [list: 14, 18, 22]], 0, 2) is 48
  calc-min-seam([list: [list: 15, 20, 30], 
      [list: 100, 50, 25]], 0, 2) is 55
  calc-min-seam([list: [list: 1, 2, 3], 
      [list: 5, 4, 6], [list: 9, 8, 7]], 0, 2) is 14
  calc-min-seam([list: [list: 1, 2, 3], 
      [list: 5, 4, 6], [list: 9, 8, 7]], 1, 2) is 13
end
check "calc-min-seam works on single column images":
  calc-min-seam([list: [list: 1], [list: 2], 
      [list: 3]], 0, 0) is 6
  calc-min-seam([list: [list: 1], [list: 2], 
      [list: 3]], 1, 0) is 5
  calc-min-seam([list: [list: 1], [list: 2], 
      [list: 3]], 2, 0) is 3
end

rec bad-sum-memo = memoize-3(
  lam(random-string :: String, num-1 :: Number, num-2 :: Number):
    if random-string == "sum":
      if num-1 == 0:
        if num-2 == 0:
          0
        else:
          1 + bad-sum-memo(random-string, num-1, num-2 - 1)
        end
      else:
        1 + bad-sum-memo(random-string, num-1 - 1, num-2)
      end
    else:
      num-1 - num-2
    end
  end)
check "memoize-3 is the identity function for bad sum":
  bad-sum-memo("sum", 0, 0) is 0
  bad-sum-memo("sum", 0, 2) is 2
  bad-sum-memo("sum", 2, 0) is 2
  bad-sum-memo("sum", 2, 4) is 6
end
check "memoize-3 stores values for bad sum":
  bad-sum-memo("a", 0, 0) is 0
  bad-sum-memo("b", 0, 2) is 2
  bad-sum-memo("c", 2, 0) is 2
  bad-sum-memo("d", 2, 4) is 6
end

check "get-min-index on length 1 lists":
  get-min-index([list: 1], [list: 100000]) is 1
  get-min-index([list: 5], [list: 0]) is 5
  get-min-index([list: 3], [list: 1]) is 3
  get-min-index([list: 10000], [list: 0.123213]) is 10000
end
check "get-min-index on sorted costs":
  get-min-index([list: 1, 2, 3, 4, 5], 
    [list: 10, 20, 30, 40, 50]) is 1
  get-min-index([list: 4, 5, 6, 7], 
    [list: 0, 100, 1000, 1000]) is 4
  get-min-index([list: 2, 3, 4, 5], 
    [list: 0.1234, 2, 4.453, 13]) is 2
end
check "get-min-index on unsorted costs":
  get-min-index([list: 1, 2, 3], [list: 3, 2, 1]) is 3
  get-min-index([list: 3, 4, 5, 6], 
    [list: 34, 92, 12, 64]) is 5
  get-min-index([list: 7, 8, 9, 10], 
    [list: 4236.124, 123.214, 457457.123, 91.12]) is 10
end

check "min-seam on single pixel":
  min-seam([list: [list: 1]]) is [list: 0]
  min-seam([list: [list: 100]]) is [list: 0]
  min-seam([list: [list: 2075.1923]]) is [list: 0]
  1 is 1
end
check "min-seam on single column":
  min-seam([list: [list: 1], [list: 2], [list: 3]]) is [list: 0, 0, 0]
  min-seam([list: [list: 5], [list: 10], [list: 7]]) is [list: 0, 0, 0]
  min-seam([list: [list: 4], [list: 10000], [list: 1293], [list: 20], 
      [list: 123], [list: 12]]) is [list: 0, 0, 0, 0, 0, 0]
  1 is 1
end
check "min-seam on square images":
  min-seam([list: [list: 5, 10], [list: 20, 30]]) is [list: 0, 0]
  min-seam([list: [list: 10, 20], [list: 40, 30]]) is [list: 0, 1]
  min-seam([list: [list: 0, 1, 2], [list: 3, 1, 4], [list: 2, 3, 1]])
    is [list: 0, 1, 2]
  min-seam([list: [list: 1, 2, 3, 4, 5], [list: 20, 10, 1, 2, 3], 
      [list: 100, 50, 70, 60, 80], [list: 5, 4, 3, 2, 1], [list: 0, 50, 70, 20, 30]])
    is [list: 1, 2, 1, 1, 0]
end
check "min-seam on rectangular images":
  min-seam([list: [list: 1, 2, 3], [list: 10, 5, 0]]) is [list: 1, 2]
  min-seam([list: [list: 23.4, 65.2, 24.5], 
      [list: 135, 241.2, 102.8]]) is [list: 2, 2]
  min-seam([list: [list: 4, 10, 15 ,20], [list: 1, 2, 6, 8], 
      [list: 100, 92, 30, 10]]) is [list: 1, 2, 3]
end
check "min-seam with tied seams":
  min-seam([list: [list: 5, 5], [list: 5, 5]]) is [list: 0, 0]
  min-seam([list: [list: 5, 5], [list: 10, 5]]) is [list: 0, 1]
  min-seam([list: [list: 10, 5], [list: 5, 10]]) is [list: 1, 0]
  min-seam([list: [list: 5, 10, 15], [list: 5, 5, 0]]) is [list: 0, 0]  
end

check "calc-min-seam-dp on a single row":
  calc-min-seam-dp([list: [list: 1, 5]]) 
    is [list: [list: 1, 5]]
  calc-min-seam-dp([list: [list: 1, 2, 5, 4, 3]]) 
    is [list: [list: 1, 2, 5, 4, 3]]
  calc-min-seam-dp([list: [list: 1, 2.312, 5.42]]) 
    is [list: [list: 1, 2.312, 5.42]]
end
check "calc-min-seam-dp on squares":
  calc-min-seam-dp([list: [list: 1, 1], [list: 1, 1]])
    is [list: [list: 2, 2], [list: 1, 1]]
  calc-min-seam-dp([list: [list: 1, 2], [list: 3, 4]]) 
    is [list: [list: 4, 5], [list: 3, 4]]
  calc-min-seam-dp([list: [list: 3, 4], [list: 1, 2]])
    is [list: [list: 4, 5], [list: 1, 2]]
  calc-min-seam-dp([list: [list: 4, 3, 2, 1], [list: 3, 2, 1, 4], 
      [list: 1, 2, 3, 4], [list: 1, 2, 3, 4]])
    is [list: [list: 8, 7, 6, 5], [list: 5, 4, 4, 9], 
    [list: 2, 3, 5, 7], [list: 1, 2, 3, 4]]
  calc-min-seam-dp([list: [list: 5, 10, 15], [list: 5, 1, 8], [list: 1, 2, 3]])
    is [list: [list: 7, 12, 17], [list: 6, 2, 10], [list: 1, 2, 3]]
end
check "calc-min-seam-dp on rectangles":
  calc-min-seam-dp([list: [list: 1, 2, 3], [list: 6, 5, 4]])
    is [list: [list: 6, 6, 7], [list: 6, 5, 4]]
  calc-min-seam-dp([list: [list: 6, 10], [list: 1, 2], [list: 5, 4]])
    is [list: [list: 11, 15], [list: 5, 6], [list: 5, 4]]
  calc-min-seam-dp([list: [list: 1, 2, 3, 4, 5], [list: 9, 2, 3, 6, 1], 
      [list: 7, 2, 3, 7, 1]]) 
    is [list: [list: 5, 6, 7, 6, 7], 
    [list: 11, 4, 5, 7, 2], [list: 7, 2, 3, 7, 1]]
end

check "get-min-seam on a single row":
  get-min-seam([list: [list: 5, 1, 2, 7, 21]]) is [list: 1]
  get-min-seam([list: [list: 9.123, 8.2, 7.7, 6.5, 4.230]]) is [list: 4]
  get-min-seam([list: [list: 123, 315, 235, 357, 124]]) is [list: 0]
end
check "get-min-seam on squares":
  get-min-seam([list: [list: 3, 4], [list: 1, 2]]) is [list: 0, 0]
  get-min-seam([list: [list: 4, 3], [list: 2, 1]]) is [list: 1, 1]
  get-min-seam([list: [list: 3.2, 4.6], [list: 2.5, 1.1]]) is [list: 0, 1]
  get-min-seam([list: [list: 9, 8, 7], [list: 5, 4, 6], [list: 1, 2, 3]])
    is [list: 2, 1, 0]
  get-min-seam([list: [list: 92, 105, 20], [list: 70, 80, 10], [list: 1, 2, 3]])
    is [list: 2, 2, 1]
end
check "get-min-seam on rectangles":
  get-min-seam([list: [list: 9, 10, 15], [list: 9, 8, 7]]) 
    is [list: 0, 1]
  get-min-seam([list: [list: 5, 10], [list: 3, 2], [list: 1, 1.5]])
    is [list: 0, 1, 0]
  get-min-seam([list: [list: 19, 123, 32, 99, 100], [list: 10, 8, 6, 4, 2]])
    is [list: 0, 1]
end
check "get-min-seam on tied seams":
  get-min-seam([list: [list: 1, 1, 1]]) is [list: 0]
  get-min-seam([list: [list: 2, 2, 1, 1]]) is [list: 2]
  get-min-seam([list: [list: 3, 3, 3], [list: 2, 2, 2]]) is [list: 0, 0]
  get-min-seam([list: [list: 10, 3, 7], [list: 1, 0.5, 0.5]]) is [list: 1, 1]
  get-min-seam([list: [list: 20, 30, 40], [list: 15, 15, 10], [list: 10, 5, 10]])
    is [list: 0, 0, 1]
end

#|
check "bangalore dancers":
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/bangalore-dancers-s2.jpg", 
    liquify-memoization, 0) is 0
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/bangalore-dancers-s2.jpg", 
    liquify-memoization, 5) is 0
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/bangalore-dancers-s2.jpg", 
    liquify-memoization, 10) is 0
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/bangalore-dancers-s2.jpg", 
    liquify-memoization, 15) is 0
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/bangalore-dancers-s2.jpg", 
    liquify-memoization, 20) is 0
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/bangalore-dancers-s2.jpg", 
    liquify-memoization, 25) is 0
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/bangalore-dancers-s2.jpg", 
    liquify-memoization, 30) is 0
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/bangalore-dancers-s2.jpg", 
    liquify-memoization, 50) is 0
end

check "Nishka Pant images":
  run-on-url("https://cs.brown.edu/courses/csci0190/2023/nishka.png", 
    liquify-memoization, 1) is 0
end
|#