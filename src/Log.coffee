
class Log
  logSize: 5 * 1024 * 1024  # 5MBs
  data: []
  
  constructor: (@fname) ->
    
    # Get the native file system object
    window.requestFileSystem = window.requestFileSystem or window.webkitRequestFileSystem
    window.requestFileSystem(window.TEMPORARY, @logSize, @initialize, @errorHandler)
    
    # Boolean to check if writer is ready
    @ready = false
    
    # Create a DOM element that will be used for custom event
    @domId = "#{@fname}-#{Math.floor(new Date() / 1000)}"
    
    @el = document.createElement('div')
    @el.setAttribute('id', @domId)
    
    # Custom event for when Log is ready to write
    @readyEvt = document.createEvent("HTMLEvents")
    @readyEvt.initEvent("log:ready", false, true)
  
  # Initialize the FileSystem object
  initialize: (fs) =>
    
    fs.root.getFile(@fname, {create: true}, (fileEntry) =>
      
      # Set up file writer on the file entry object
      fileEntry.createWriter((fileWriter) =>
        
        # Error function in case a write does not work
        fileWriter.onerror = (e) ->
          console.log "ERROR: #{e.toString()}"
        
        # Store the write function on the object for later abstraction
        @fileWriter = fileWriter
        
        @fileWriter.addEventListener("writeend", =>
          
          link = document.createElement('a')
          link.setAttribute('href', fileEntry.toURL())
          link.setAttribute('download', "#{@fname}")
          link.innerHTML = "Download Log"
          link.style.color = '#0071E5'
          link.style.fontSize = '11px'
          link.style.textDecoration = 'none'
          link.style.border = '1px solid #0071E5'
          link.style.padding = '2px 6px'
          
          div = document.createElement('div')
          div.appendChild(link)
          div.style.position = 'absolute'
          div.style.bottom = '10px'
          div.style.left = '10px'
          
          document.body.appendChild(div)
        , false)
        
        # Flip it.
        @ready = true
        
        # Broadcast that writer is ready
        @el.dispatchEvent(@readyEvt)
        
      , @errorHandler)
    , @errorHandler)
    
  # Generic error handler
  errorHandler: (e) ->
    msg = ""
    switch e.code
      when FileError.QUOTA_EXCEEDED_ERR
        msg = "QUOTA_EXCEEDED_ERR"
      when FileError.NOT_FOUND_ERR
        msg = "NOT_FOUND_ERR"
      when FileError.SECURITY_ERR
        msg = "SECURITY_ERR"
      when FileError.INVALID_MODIFICATION_ERR
        msg = "INVALID_MODIFICATION_ERR"
      when FileError.INVALID_STATE_ERR
        msg = "INVALID_STATE_ERR"
      else
        msg = "Unknown Error"
    console.log "Error: " + msg
  
  write: (line) =>
    @data.push(line)
  
  writeArray: (arr) =>
    @write(val) for val in arr
  
  finish: =>
    if @ready
      @toFile()
    else
      @el.addEventListener('log:ready', =>
        
        # Remove the listener since the code below should only be executed once
        @el.removeEventListener('log:ready', arguments.callee, false)
        
        @toFile()
      , false)
  
  toFile: =>
    blob = new Blob([@data.join('\r\n')], {type: 'text/plain'})
    @fileWriter.write(blob)


@astro = {} unless @astro?
@astro.Log = Log