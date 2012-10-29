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
    @videoCanvas.width = @width = w = 150
    @videoCanvas.height = @height = h = parseInt(w*3/4,10)

    navigator.getMedia({video: true, audio: true}, (localMediaStream)->
      url = window.URL || window.webkitURL
      self.video.src = url.createObjectURL(localMediaStream);

      self.stream = localMediaStream
      @videoTimer = setInterval(()->
        self.renderVideo()
      , 20)

      self.video.onloadedmetadata = (e)-> console.log(e)
    , (err)-> console.log("The following error occured: " + err))

  stopRender: ()->
    clearInterval @videoTimer

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
    @imgCanvas.width = w = 150
    @imgCanvas.height = h = w*@img.height/@img.width
    @imgCtx.drawImage @img, 0, 0, w, h
    data = @imgCtx.getImageData(0, 0, w, h).data
    container.innerHTML = @toString(data, w, h)

  toString: (d, width, height)->
    len = width*height-1
    str = ''
    for i in [0..len]
      do (i)->
        if (i%width is 0) then str += '<br>'
        rgb = [d[i=i*4], d[i+1], d[i+2]]
        hsv = rgbToHsv rgb
        val = hsv[2]
        #str += '<b style="color: rgb('+rgb.join(',')+')">'+getChar(val)+'</b>'
        str += getChar(val)
    str

rgbToHsv = (rgb)->
  r = rgb[0]/255
  g = rgb[1]/255
  b = rgb[2]/255
  v = max = Math.max(r, g, b)
  min = Math.min(r, g, b)
  d = max - min
  s = if max is 0 then 0 else d/max

  if(max is min)
    h = 0
  else
    if(max is r) then h = (g - b) / d + (g < b ? 6 : 0)
    else if(max is g) then h = (b - r) / d + 2
    else if(max is b) then h = (r - g) / d + 4
    h *= 60;
  [h, s, v]

getChar = (val)->
  return chars[parseInt val*charLen, 10]

chars = ['@','#','$','=','*','!',';',':','~','-',',','.','&nbsp;', '&nbsp;']
charLen = chars.length-1

window.Jscii = Jscii
