@astro = {} unless @astro?

simplexy = {}
simplexy.version = '0.0.1'
simplexy.parameters =
  dpsf: 1.0
  plim: 8.0
  dlim: 1.0
  saddle: 5.0
  maxper: 1000
  maxnpeaks: 10000
  maxsize: 2000
  halfbox: 100


@astro.simplexy = simplexy