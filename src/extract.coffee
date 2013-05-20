

extract = (pixels, width, height) ->
  astro.simplexy.medsmooth(pixels, width, height)


@astro.simplexy.extract = extract