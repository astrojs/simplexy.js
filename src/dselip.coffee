# FIXME: There is a bug in this function, probably related to the implementation of radix sort
# Seems to be stability issues with sorting algorithms.  The radix sort does not match with the C
# implementation, nor does the native sort.
dselip = (k, n, arr) ->
  # Copy and sort the array
  sorted = new Float32Array(arr)
  sorted = radixsort()(sorted)
  
  # Slice array for nonzero values
  for value, index in sorted
    break if value isnt 0
  sorted = sorted.subarray(index)
  
  # # This is probably the bug
  # newk = arr.length - n + k
  
  return sorted[k]

@astro.simplexy.dselip = dselip