
dselip = (k, n, arr) ->
  sorted = new Float32Array(arr)
  sorted = radixsort()(sorted)
  newk = arr.length - n + k
  return sorted[newk]

@astro.simplexy.dselip = dselip