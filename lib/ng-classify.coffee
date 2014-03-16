url = require 'url'
querystring = require 'querystring'
NgClassifyView = require './ng-classify-view'

module.exports =
	configDefaults:
		grammars: [
			'source.coffee'
			'source.litcoffee'
		]

	activate: ->
		atom.workspaceView.command 'ng-classify:compile', =>
			@display()

		atom.workspace.registerOpener (uriToOpen) ->
			{protocol, host, pathname} = url.parse uriToOpen
			pathname = querystring.unescape(pathname) if pathname

			return unless protocol is 'ngclassify:'

			new NgClassifyView(pathname.substr(1))

	display: ->
		editor = atom.workspace.getActiveEditor()
		activePane = atom.workspace.getActivePane()

		return unless editor?

		grammars = atom.config.get('ng-classify.grammars') or []

		unless (grammar = editor.getGrammar().scopeName) in grammars
			console.warn("Cannot compile non-CoffeeScript to JavaScript")

			return

		uri = "ngclassify://editor/#{editor.id}"

		# If a pane with the uri
		pane = atom.workspace.paneContainer.paneForUri uri
		# If not, always split right
		pane ?= activePane.splitRight()

		atom.workspace.openUriInPane(uri, pane, {}).done (ngClassifyView) ->
			if ngClassifyView instanceof NgClassifyView
				ngClassifyView.renderCompiled()