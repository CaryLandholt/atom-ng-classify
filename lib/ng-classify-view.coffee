{$, $$$, EditorView, ScrollView} = require 'atom'
_                                = require 'underscore-plus'
ngClassify                       = require 'ng-classify'
path                             = require 'path'

module.exports =
class NgClassifyView extends ScrollView
	@content: ->
		@div class: 'ng-classify native-key-bindings', tabindex: -1, =>
			@div class: 'editor editor-colors', =>
				@div outlet: 'compiledCode', class: 'lang-coffeescript lines'

	constructor: ({@editorId, @editor}) ->
		super

		if @editorId? and not @editor
			editor = @getEditor @editorId

		if @editor?
			@trigger 'title-changed'
			@bindEvents()

	destroy: ->
		@unsubscribe()

	bindEvents: ->
		@subscribe atom.syntax, 'grammar-updated', _.debounce((=> @renderCompiled()), 250)
		@subscribe this, 'core:move-up', => @scrollUp()
		@subscribe this, 'core:move-down', => @scrollDown()

	getEditor: (id) ->
		for editor in atom.workspace.getEditors()
			return editor if editor.id?.toString() is id.toString()

		null

	getSelectedCode: ->
		range = @editor.getSelectedBufferRange()

		code =
			if range.isEmpty()
				@editor.getText()
			else
				@editor.getTextInBufferRange range

		code

	compile: (code) ->
		ngClassify code

	renderCompiled: (callback) ->
		code = @getSelectedCode()

		try
			text = @compile code
		catch e
			text = e.stack

		grammar = atom.syntax.selectGrammar 'hello.coffee', text

		@compiledCode.empty()

		for tokens in grammar.tokenizeLines(text)
			attributes = class: 'line'

			@compiledCode.append(EditorView.buildLineHtml({tokens, text, attributes}))

		# Match editor styles
		@compiledCode.css
			fontSize: atom.config.get('editor.fontSize') or 12
			fontFamily: atom.config.get('editor.fontFamily')
			
		callback?()

	getTitle: ->
		if @editor?
			"Compiled #{@editor.getTitle()}"
		else
			"Compiled CoffeeScript"

	getUri: -> "ngclassify://editor/#{@editorId}"

	getPath: -> @editor?.getPath() or ''