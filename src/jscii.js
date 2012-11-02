!function() {

	navigator.getMedia = navigator.getUserMedia ||
		navigator.webkitGetUserMedia ||
		navigator.mozGetUserMedia ||
		navigator.msGetUserMedia;

	var imgCanvas = document.createElement('canvas');
	var imgCtx = imgCanvas.getContext('2d');
	var videoCanvas = document.createElement('canvas');
	var videoCtx = videoCanvas.getContext('2d');

	var videoWidth, videoHeight, video, container, stream, videoTimer;

	/**
	 * value to character mapping from dark to light
	 * add more characters and they will be accounted for automatically
	 * note: the extra &nbsp; is to account for the value range inclusive of 100%
	 */
	var chars = ['@','#','$','=','*','!',';',':','~','-',',','.','&nbsp;', '&nbsp;'];
	var charLen = chars.length-1;
	function getChar(val) { return chars[parseInt(val*charLen, 10)]; }

	/**
	 * log when getUserMedia or when video metadata loading fail
	 */
	function logError(err) { if(console && console.log) console.log('Error!', err); return false; }

	/**
	 * Sets the video dimension (and subsequently ASCII string dimension)
	 */
	function setVideoDimension(width, height) {
		videoCanvas.width = videoWidth = width;
		videoCanvas.height = videoHeight = height;
	}

	/**
	 * given a video object and DOM element, render the ASCII string inside element
	 */
	function renderVideo(videoEl, containerEl) {
		if(typeof navigator.getMedia !== 'function') {
			var msg = 'Error: browser does not support getUserMedia';
			containerEl.innerHTML = msg;
			return logError(msg);
		}

		video = videoEl;
		container = containerEl;
		navigator.getMedia({video: true, audio: true}, function(localMediaStream){
			stream = localMediaStream;
			var url = window.URL || window.webkitURL;
			video.src = url.createObjectURL(localMediaStream);

			startRender(15);
			video.onloadedmetadata = logError;
		}, logError);
		return true;
	}

	/**
	 * gets video image data, perform ascii conversion, append string to container
	 */
	function startRender(interval) {
		if(typeof interval !== 'number') interval = 20;
		videoTimer = setInterval(function(){
			if(stream) {
				var w = videoWidth, h = videoHeight;
				videoCtx.drawImage(video, 0, 0, w, h);
				var data = videoCtx.getImageData(0, 0, w, h).data;
				container.innerHTML = getAsciiString(data, w, h);
			}
		}, interval);
	}

	/**
	 * Allow pause and play for ascii rendering
	 */
	function stopRender() { if(videoTimer) clearInterval(videoTimer); }

	/**
	 * given an image object and DOM element, render the ASCII string inside element
	 */
	function renderImage(image, container) {
		image.addEventListener('load', function(){
			var ratio = image.width/image.height;
			imgCanvas.width = w = 150;
			imgCanvas.height = h = w/ratio;
			imgCtx.drawImage(image, 0, 0, w, h);
			data = imgCtx.getImageData(0, 0, w, h).data;
			container.innerHTML = getAsciiString(data, w, h);
		});
	}

	/**
	 * helper function to retrieve rgb value from pixel data
	 * (pixel data is a 1-dimensional array of rgba sequence)
	 */
	function getRGB(d, i) { return [d[i=i*4], d[i+1], d[i+2]]; }

	/**
	 * given a picture/frame's pixel data and a defined width and height
	 * return the ASCII string representing the image
	 */
	function getAsciiString(d, width, height) {
		var len = width*height-1, str = '';
		for(var i=0; i<len; i++) {
			if(i%width === 0) str += '<br>';
			var rgb = getRGB(d, i);
			var val = Math.max(rgb[0], rgb[1], rgb[2])/255;
			//str += '<b style="color: rgb('+rgb.join(',')+')">'+getChar(val)+'</b>';
			str += getChar(val);
		}
		return str;
	}

	/**
	 * default video dimension at 150 width and a 4:3 ratio
	 */
	setVideoDimension(150, parseInt(150*3/4, 10));

	window.Jscii = {
		setVideoDimension: setVideoDimension,
		renderVideo: renderVideo,
		startRender: startRender,
		stopRender: stopRender,
		renderImage: renderImage
	};

}();
