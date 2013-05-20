
medsmooth = (image, nx, ny) ->
  params = astro.simplexy.parameters
  sp = params.halfbox
  nxgrid = parseInt(nx / sp + 2)
  
  # Allocate arrays
  xgrid = new Int16Array(nxgrid)
  xlo   = new Int16Array(nxgrid)
  xhi   = new Int16Array(nxgrid)
  
  xoff = (nx - 1 - (nxgrid - 3) * sp) / 2
  
  for i in [1..nxgrid - 2]
    xgrid[i] = (i - 1) * sp + xoff
    
  xgrid[0] = xgrid[1] - sp
  xgrid[nxgrid - 1] = xgrid[nxgrid - 2] + sp
  
  for i in [0..nxgrid - 1]
    xlo[i] = Math.max(xgrid[i] - sp, 0)
    xhi[i] = Math.min(xgrid[i] + sp, nx - 1)
    
  
  nygrid = parseInt(ny / sp + 2)
  
  # Allocate arrays
  ygrid = new Int16Array(nygrid)
  ylo   = new Int16Array(nygrid)
  yhi   = new Int16Array(nygrid)
  
  yoff = (ny - 1 - (nygrid - 3) * sp) / 2
  
  for i in [1..nygrid - 2]
    ygrid[i] = (i - 1) * sp + yoff
  
  ygrid[0] = ygrid[1] - sp
  ygrid[nygrid - 1] = ygrid[nygrid - 2] + sp
  
  for i in [0..nygrid - 1]
    ylo[i] = Math.max(ygrid[i] - sp, 0)
    yhi[i] = Math.min(ygrid[i] + sp, ny - 1)
  
  # The median-filtered image (subsampled on a grid)
  grid  = new Float32Array(nxgrid * nygrid)
  arr   = new Float32Array((sp * 2 + 5) * (sp * 2 + 5))
  
  for j in [0..nygrid - 1]
    for i in [0..nxgrid - 1]
      nb = 0
      for jp in [ylo[j]..yhi[j]]
        for ip in [xlo[i]..xhi[i]]
          arr[nb] = image[ip + jp * nx]
          nb++
      if (nb > 1)
        nm = parseInt(nb / 2)
        # FIXME: dselip is not returning the correct value
        grid[i + j * nxgrid] = astro.simplexy.dselip(nm, nb, arr)
      else
        # This code is not called with cutout.fits
        grid[i + j * nxgrid] = image[xlo[i] + ylo[j] * nx]
  
  # Free memory of some arrays
  xlo = null
  ylo = null
  xhi = null
  yhi = null
  arr = null
  
  smooth = new Float32Array(nx * ny)
  j = 0
  while j < nygrid
    jst = ygrid[j] - sp * 1.5
    jnd = ygrid[j] + sp * 1.5
    if jst < 0
      jst = 0
    if jnd > ny - 1
      jnd = ny - 1
    ypsize = sp
    ymsize = sp
    if j is 0
      ypsize = ygrid[1] - ygrid[0]
    if j is 1
      ymsize = ygrid[1] - ygrid[0]
    if j is nygrid - 2
      ypsize = ygrid[nygrid - 1] - ygrid[nygrid - 2]
    if j is nygrid - 1
      ymsize = ygrid[nygrid - 1] - ygrid[nygrid - 2]
    i = 0
    while i < nxgrid
      ist = xgrid[i] - sp * 1.5
      ind = xgrid[i] + sp * 1.5
      if ist < 0
        ist = 0
      if ind > nx - 1
        ind = nx - 1
      xpsize = sp
      xmsize = sp
      if i is 0
        xpsize = xgrid[1] - xgrid[0]
      if i is 1
        xmsize = xgrid[1] - xgrid[0]
      if i is nxgrid - 2
        xpsize = xgrid[nxgrid - 1] - xgrid[nxgrid - 2]
      if i is nxgrid - 1
        xmsize = xgrid[nxgrid - 1] - xgrid[nxgrid - 2]
      jp = jst
      while jp <= jnd
        dy = (jp - ygrid[j])
        ykernel = 0.
        if dy > -1.5 * ymsize and dy <= -0.5 * ymsize
          ykernel = 0.5 * (dy / ymsize + 1.5) * (dy / ymsize + 1.5)
        else if dy > -0.5 * ymsize and dy < 0.
          ykernel = -(dy * dy / ymsize / ymsize - 0.75)
        else if dy < 0.5 * ypsize and dy >= 0.
          ykernel = -(dy * dy / ypsize / ypsize - 0.75)
        else if dy >= 0.5 * ypsize and dy < 1.5 * ypsize
          ykernel = 0.5 * (dy / ypsize - 1.5) * (dy / ypsize - 1.5)
        ip = ist
        while ip <= ind
          dx = (ip - xgrid[i])
          xkernel = 0
          if dx > -1.5 * xmsize and dx <= -0.5 * xmsize
            xkernel = 0.5 * (dx / xmsize + 1.5) * (dx / xmsize + 1.5)
          else if dx > -0.5 * xmsize and dx < 0.
            xkernel = -(dx * dx / xmsize / xmsize - 0.75)
          else if dx < 0.5 * xpsize and dx >= 0.
            xkernel = -(dx * dx / xpsize / xpsize - 0.75)
          else if dx >= 0.5 * xpsize and dx < 1.5 * xpsize
            xkernel = 0.5 * (dx / xpsize - 1.5) * (dx / xpsize - 1.5)
          smooth[ip + jp * nx] += xkernel * ykernel * grid[i + j * nxgrid]
          ip++
        jp++
      i++
    j++
  
  return smooth


@astro.simplexy.medsmooth = medsmooth
