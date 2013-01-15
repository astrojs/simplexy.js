
medsmooth = (image, nx, ny) ->
  console.log 'medsmooth'
  
  # LOGGING
  l = new astro.Log('medsmooth2')
  
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
  
  # NOTE: xgrid and ygrid OK
  # NOTE: xlo and xhi OK
  # NOTE: ylo and yhi OK

  # The median-filtered image (subsampled on a grid)
  grid  = new Float32Array(nxgrid * nygrid)
  arr   = new Float32Array((sp * 2 + 5) * (sp * 2 + 5))
  
  j = 0
  while j < nygrid
    i = 0
    while i < nxgrid
      nb = 0
      jp = ylo[j]
      while jp <= yhi[j]
        ip = xlo[i]
        while ip <= xhi[i]
          arr[nb] = image[ip + jp * nx]
          nb++
          ip++
        jp++
      if nb > 1
        nm = parseInt(nb / 2)
        grid[i + j * nxgrid] = astro.simplexy.dselip(nm, nb, arr)
      else
        grid[i + j * nxgrid] = image[xlo[i] + (ylo[j]) * nx]
      i++
    j++
  
  # arr looks good right here.
  # TODO: fix grid, something doesn't match from C implementation
  # console.log grid
  
  l.writeArray(grid)
  l.finish()
  
  # TODO: free xlo, ylo, xhi, yhi, arr
  return
  
  smooth = new Float32Array(nx * ny)
  j = 0
  while j < nygrid
    jst = (ygrid[j] - sp * 1.5)
    jnd = (ygrid[j] + sp * 1.5)
    jst = 0  if jst < 0
    jnd = ny - 1 if jnd > ny - 1
    ypsize = sp
    ymsize = sp
    ypsize = ygrid[1] - ygrid[0] if j is 0
    ymsize = ygrid[1] - ygrid[0] if j is 1
    ypsize = ygrid[nygrid - 1] - ygrid[nygrid - 2] if j is nygrid - 2
    ymsize = ygrid[nygrid - 1] - ygrid[nygrid - 2] if j is nygrid - 1
    i = 0
    while i < nxgrid
      ist = (xgrid[i] - sp * 1.5)
      ind = (xgrid[i] + sp * 1.5)
      ist = 0 if ist < 0
      ind = nx - 1 if ind > nx - 1
      xpsize = sp
      xmsize = sp
      xpsize = xgrid[1] - xgrid[0] if i is 0
      xmsize = xgrid[1] - xgrid[0] if i is 1
      xpsize = xgrid[nxgrid - 1] - xgrid[nxgrid - 2] if i is nxgrid - 2
      xmsize = xgrid[nxgrid - 1] - xgrid[nxgrid - 2] if i is nxgrid - 1
      jp = jst
      while jp <= jnd
        dy = (jp - ygrid[j])
        ykernel = 0
        if dy > -1.5 * ymsize and dy <= -0.5 * ymsize
          ykernel = 0.5 * (dy / ymsize + 1.5) * (dy / ymsize + 1.5)
        else if dy > -0.5 * ymsize and dy < 0.
          ykernel = -(dy * dy / ymsize / ymsize - 0.75)
        else if dy < 0.5 * ypsize and dy >= 0.
          ykernel = -(dy * dy / ypsize / ypsize - 0.75)
        else ykernel = 0.5 * (dy / ypsize - 1.5) * (dy / ypsize - 1.5) if dy >= 0.5 * ypsize and dy < 1.5 * ypsize
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
          else xkernel = 0.5 * (dx / xpsize - 1.5) * (dx / xpsize - 1.5) if dx >= 0.5 * xpsize and dx < 1.5 * xpsize
          smooth[ip + jp * nx] += xkernel * ykernel * grid[i + j * nxgrid]
          ip++
        jp++
      i++
    j++
  
  return smooth
  
@astro.simplexy.medsmooth = medsmooth
