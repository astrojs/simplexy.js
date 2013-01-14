// Generated by CoffeeScript 1.4.0
(function() {
  var dselip, extract, medsmooth, simplexy;

  if (this.astro == null) {
    this.astro = {};
  }

  simplexy = {};

  simplexy.version = '0.0.1';

  simplexy.parameters = {
    dpsf: 1.0,
    plim: 8.0,
    dlim: 1.0,
    saddle: 5.0,
    maxper: 1000,
    maxnpeaks: 10000,
    maxsize: 2000,
    halfbox: 100,
    high_water_mark: 0,
    past_data: null
  };

  this.astro.simplexy = simplexy;

  dselip = function(k, n, arr) {
    var newk, sorted;
    sorted = new Float32Array(arr);
    sorted = radixsort()(sorted);
    newk = arr.length - n + k;
    return sorted[newk];
  };

  this.astro.simplexy.dselip = dselip;

  medsmooth = function(image, nx, ny) {
    var arr, dx, dy, grid, i, ind, ip, ist, j, jnd, jp, jst, nb, nm, nxgrid, nygrid, params, smooth, sp, xgrid, xhi, xkernel, xlo, xmsize, xoff, xpsize, ygrid, yhi, ykernel, ylo, ymsize, yoff, ypsize, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3;
    console.log('medsmooth');
    params = astro.simplexy.parameters;
    sp = params.halfbox;
    nxgrid = parseInt(nx / sp + 2);
    xgrid = new Int16Array(nxgrid);
    xlo = new Int16Array(nxgrid);
    xhi = new Int16Array(nxgrid);
    xoff = (nx - 1 - (nxgrid - 3) * sp) / 2;
    for (i = _i = 1, _ref = nxgrid - 2; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      xgrid[i] = (i - 1) * sp + xoff;
    }
    xgrid[0] = xgrid[1] - sp;
    xgrid[nxgrid - 1] = xgrid[nxgrid - 2] + sp;
    for (i = _j = 0, _ref1 = nxgrid - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
      xlo[i] = Math.max(xgrid[i] - sp, 0);
      xhi[i] = Math.min(xgrid[i] + sp, nx - 1);
    }
    nygrid = parseInt(ny / sp + 2);
    ygrid = new Int16Array(nygrid);
    ylo = new Int16Array(nygrid);
    yhi = new Int16Array(nygrid);
    yoff = (ny - 1 - (nygrid - 3) * sp) / 2;
    for (i = _k = 1, _ref2 = nygrid - 2; 1 <= _ref2 ? _k <= _ref2 : _k >= _ref2; i = 1 <= _ref2 ? ++_k : --_k) {
      ygrid[i] = (i - 1) * sp + yoff;
    }
    ygrid[0] = ygrid[1] - sp;
    ygrid[nygrid - 1] = ygrid[nygrid - 2] + sp;
    for (i = _l = 0, _ref3 = nygrid - 1; 0 <= _ref3 ? _l <= _ref3 : _l >= _ref3; i = 0 <= _ref3 ? ++_l : --_l) {
      ylo[i] = Math.max(ygrid[i] - sp, 0);
      yhi[i] = Math.min(ygrid[i] + sp, ny - 1);
    }
    grid = new Float32Array(nxgrid * nygrid);
    arr = new Float32Array((sp * 2 + 5) * (sp * 2 + 5));
    j = 0;
    while (j < nygrid) {
      i = 0;
      while (i < nxgrid) {
        nb = 0;
        jp = ylo[j];
        while (jp <= yhi[j]) {
          ip = xlo[i];
          while (ip <= xhi[i]) {
            arr[nb] = image[ip + jp * nx];
            nb++;
            ip++;
          }
          jp++;
        }
        if (nb > 1) {
          nm = parseInt(nb / 2);
          grid[i + j * nxgrid] = astro.simplexy.dselip(nm, nb, arr);
        } else {
          grid[i + j * nxgrid] = image[xlo[i] + ylo[j] * nx];
        }
        i++;
      }
      j++;
    }
    return;
    smooth = new Float32Array(nx * ny);
    j = 0;
    while (j < nygrid) {
      jst = ygrid[j] - sp * 1.5;
      jnd = ygrid[j] + sp * 1.5;
      if (jst < 0) {
        jst = 0;
      }
      if (jnd > ny - 1) {
        jnd = ny - 1;
      }
      ypsize = sp;
      ymsize = sp;
      if (j === 0) {
        ypsize = ygrid[1] - ygrid[0];
      }
      if (j === 1) {
        ymsize = ygrid[1] - ygrid[0];
      }
      if (j === nygrid - 2) {
        ypsize = ygrid[nygrid - 1] - ygrid[nygrid - 2];
      }
      if (j === nygrid - 1) {
        ymsize = ygrid[nygrid - 1] - ygrid[nygrid - 2];
      }
      i = 0;
      while (i < nxgrid) {
        ist = xgrid[i] - sp * 1.5;
        ind = xgrid[i] + sp * 1.5;
        if (ist < 0) {
          ist = 0;
        }
        if (ind > nx - 1) {
          ind = nx - 1;
        }
        xpsize = sp;
        xmsize = sp;
        if (i === 0) {
          xpsize = xgrid[1] - xgrid[0];
        }
        if (i === 1) {
          xmsize = xgrid[1] - xgrid[0];
        }
        if (i === nxgrid - 2) {
          xpsize = xgrid[nxgrid - 1] - xgrid[nxgrid - 2];
        }
        if (i === nxgrid - 1) {
          xmsize = xgrid[nxgrid - 1] - xgrid[nxgrid - 2];
        }
        jp = jst;
        while (jp <= jnd) {
          dy = jp - ygrid[j];
          ykernel = 0;
          if (dy > -1.5 * ymsize && dy <= -0.5 * ymsize) {
            ykernel = 0.5 * (dy / ymsize + 1.5) * (dy / ymsize + 1.5);
          } else if (dy > -0.5 * ymsize && dy < (0..ykernel = -(dy * dy / ymsize / ymsize - 0.75))) {

          } else if (dy < 0.5 * ypsize && dy >= (0..ykernel = -(dy * dy / ypsize / ypsize - 0.75))) {

          } else {
            if (dy >= 0.5 * ypsize && dy < 1.5 * ypsize) {
              ykernel = 0.5 * (dy / ypsize - 1.5) * (dy / ypsize - 1.5);
            }
          }
          ip = ist;
          while (ip <= ind) {
            dx = ip - xgrid[i];
            xkernel = 0;
            if (dx > -1.5 * xmsize && dx <= -0.5 * xmsize) {
              xkernel = 0.5 * (dx / xmsize + 1.5) * (dx / xmsize + 1.5);
            } else if (dx > -0.5 * xmsize && dx < (0..xkernel = -(dx * dx / xmsize / xmsize - 0.75))) {

            } else if (dx < 0.5 * xpsize && dx >= (0..xkernel = -(dx * dx / xpsize / xpsize - 0.75))) {

            } else {
              if (dx >= 0.5 * xpsize && dx < 1.5 * xpsize) {
                xkernel = 0.5 * (dx / xpsize - 1.5) * (dx / xpsize - 1.5);
              }
            }
            smooth[ip + jp * nx] += xkernel * ykernel * grid[i + j * nxgrid];
            ip++;
          }
          jp++;
        }
        i++;
      }
      j++;
    }
    return smooth;
  };

  this.astro.simplexy.medsmooth = medsmooth;

  extract = function(hdu) {
    var data, nx, ny;
    console.log('extract');
    astro.simplexy.parameters.high_water_mark = 0;
    data = hdu.data.data;
    nx = hdu.header['NAXIS1'];
    ny = hdu.header['NAXIS2'];
    return astro.simplexy.medsmooth(data, nx, ny);
  };

  this.astro.simplexy.extract = extract;

}).call(this);