{print} = require 'util'
{spawn} = require 'child_process'

task 'build', 'Build JavaScript production files from coffee source', ->
	coffee = spawn 'coffee', ['-j', 'jscii.js', '-c', '-o', 'lib', 'src']
	coffee.stderr.on 'data', (data) ->
		process.stderr.write data.toString()
	coffee.stdout.on 'data', (data) ->
		print data.toString()
	coffee.on 'exit', (code) ->
		spawn 'uglifyjs', ['--overwrite', 'lib/jscii.js']
		callback?() if code is 0

task 'watch', 'Watch src/ for changes', ->
	coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
	coffee.stderr.on 'data', (data) ->
		process.stderr.write data.toString()
	coffee.stdout.on 'data', (data) ->
		print data.toString()
