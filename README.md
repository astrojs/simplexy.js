# image2xy

Point source extraction for astronomical images.

## Testing against Astrometry.net's implementation of simplexy

    cd astrometry.net-0.40/blind
    make simplexy

There are a few components to simplexy.  Each should be tested against the original C implementation.

## Usage?
    var sources = astro.image2xy(arr)
    
    sources = [
      {x: X, y: Y, flux: FLUX, background: BACKGROUND},
      ...
      {x: X, y: Y, flux: FLUX, background: BACKGROUND}
    ]