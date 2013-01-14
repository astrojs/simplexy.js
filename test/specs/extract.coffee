
describe 'extract', ->

  it 'can extract source points from m101', ->
    fits = null
    
    xhr = new XMLHttpRequest()
    xhr.open('GET', 'data/m101.fits')
    xhr.responseType = 'arraybuffer'
    xhr.onload = (e) =>
      fits = new astro.FITS.File(xhr.response)
    xhr.send()
    
    waitsFor -> return fits?
    
    runs ->
      fits.getData()
      astro.simplexy.extract(fits.getHDU())