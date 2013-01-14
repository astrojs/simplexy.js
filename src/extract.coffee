

extract = (hdu) ->
  console.log 'extract'
  
  # Reset high_water_mark
  astro.simplexy.parameters.high_water_mark = 0
  
  # Store a few variables describing the data
  data = hdu.data.data
  nx = hdu.header['NAXIS1']
  ny = hdu.header['NAXIS2']
  
  astro.simplexy.medsmooth(data, nx, ny)
  

@astro.simplexy.extract = extract