navigator.getMedia = ( navigator.getUserMedia ||
                       navigator.webkitGetUserMedia ||
                       navigator.mozGetUserMedia ||
                       navigator.msGetUserMedia);

class Jscii
  constructor: (videoContainer)->
    self = @;
    @videoContainer = videoContainer
    @video = document.querySelector('video');

    @imgCanvas = document.createElement 'canvas'
    @imgCtx = @imgCanvas.getContext '2d'

    @videoCanvas = document.createElement 'canvas'
    @videoCtx = @videoCanvas.getContext '2d'
    @videoCanvas.width = @width = w = 100
    @videoCanvas.height = @height = h = 300/4

    navigator.getMedia({video: true, audio: true}, (localMediaStream)->
      url = window.URL || window.webkitURL
      self.video.src = url.createObjectURL(localMediaStream);

      self.stream = localMediaStream
      setInterval(()->
        self.renderVideo()
      , 10)

      self.video.onloadedmetadata = (e)-> console.log(e)
    , (err)-> console.log("The following error occured: " + err))

  renderVideo: ()->
    if(@stream)
      @videoCtx.drawImage @video, 0, 0, @width, @height
      @data = @videoCtx.getImageData(0, 0, @width, @height).data
      @videoContainer.innerHTML = @toString(@data, @width, @height)

  # pass in image object and container to render image's ascii in container
  renderImage: (img, container)->
    if(typeof container is 'string') then container = document.getElementById(container)
    if(typeof img is 'string')
      if (imgObj = document.getElementById(img)) and imgObj.tagName is 'IMG' then img = imgObj
    (@img = img).addEventListener 'load', ()=> @_imageLoaded(container)

  _imageLoaded: (container)->
    @imgCanvas.width = w = 100
    @imgCanvas.height = h = 100*@img.height/@img.width
    @imgCtx.drawImage @img, 0, 0, w, h
    data = @imgCtx.getImageData(0, 0, w, h).data
    container.innerHTML = @toString(data, w, h)

  toString: (d, width, height)->
    len = width*height-1
    str = ''
    for i in [0..len]
      do (i)->
        if (i%width is 0) then str += '<br>'
        hex = normalizeRgba(d[i=i*4], d[i+1], d[i+2]).toHex()
        hsva = color.hsva(hex).toArray()
        val = hsva[2]
        str += getChar(val)
    str

getChar = (val)->
  d = 1/13
  if 0 <= val < d then '@'
  else if d <= val < d*2 then '$'
  else if d*2 <= val < d*3 then '#'
  else if d*3 <= val < d*4 then '*'
  else if d*4 <= val < d*5 then '!'
  else if d*5 <= val < d*6 then '='
  else if d*6 <= val < d*7 then ';'
  else if d*7 <= val < d*8 then ':'
  else if d*8 <= val < d*9 then '~'
  else if d*9 <= val < d*10 then '-'
  else if d*10 <= val < d*11 then ','
  else if d*11 <= val < d*12 then '.'
  else '&nbsp;'

normalizeRgba = (rgb)->
  if arguments.length > 1 then rgb = [arguments[0], arguments[1], arguments[2]]
  color.rgba {r: rgb[0]/255, g: rgb[1]/255, b: rgb[2]/255}

window.Jscii = Jscii
