class Jscii
  constructor: (img, ready)->
    @ready = ready
    @load(img)

  load: (img)->
    if(typeof img is 'string')
      if (imgObj = document.getElementById(img)) and imgObj.tagName is 'IMG' then img = imgObj
    (@img = img).addEventListener 'load', ()=> @_imageLoaded()

  _imageLoaded: ()->
    @canvas = document.createElement 'canvas'

    #@canvas.width = @width = w = @img.width
    #@canvas.height = @height = h = @img.height
    @canvas.width = @width = w = 100
    @canvas.height = @height = h = 100*@img.height/@img.width

    @ctx = @canvas.getContext '2d'
    @ctx.drawImage @img, 0, 0, w, h
    @data = @ctx.getImageData(0, 0, w, h).data
    @ready.call @

  toString: ()->
    d = @data
    width = @width
    len = width*@height-1
    str = ''
    for i in [0..len]
      do (i)->
        if (i%width is 0)
          str += '<br>'
        hex = normalizeRgba(d[i=i*4], d[i+1], d[i+2]).toHex()
        hsva = color.hsva(hex).toArray()
        val = hsva[2]
        str += getChar(val)
    str

getChar = (val)->
  console.log(val)
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
