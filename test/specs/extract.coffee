
describe 'extract', ->

  it 'can extract source points from m101', ->
    fits = null
    
    xhr = new XMLHttpRequest()
    xhr.open('GET', 'data/cutout.fits')
    xhr.responseType = 'arraybuffer'
    xhr.onload = (e) =>
      fits = new astro.FITS.File(xhr.response)
    xhr.send()
    
    waitsFor -> return fits?
    
    runs ->
      dataunit = fits.getDataUnit()
      width = dataunit.width
      height = dataunit.height
      dataunit.getFrameAsync(undefined, (pixels) ->
        astro.simplexy.extract(pixels, width, height)
      )