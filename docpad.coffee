# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		# Specify some site properties
		site:
			# The production url of our website
			# If not set, will default to the calculated site URL (e.g. http://localhost:9778)
			url: "http://www.squadracoppi.us"

						# Here are some old site urls that you would like to redirect from
			oldUrls: [
				'http://www.squadracoppi.us',
				'website.herokuapp.com'
			]

			# The default title of our website
			title: "Squadra Coppi"

			# The website description (for SEO)
			description: """
				Squadra Coppi is an Arlington, VA based bicycle racing team. Famous for our esprit de corps, Coppi riders are well-known for supporting their own on and off the bike.
				"""

			# The website keywords (for SEO) separated by commas
			keywords: """
				Squadra Coppi, Arlington, VA, bicycle, bike, racing, team
				"""

			# The website's styles
			styles: [
				'/vendor/normalize.css'
				'/vendor/h5bp.css'
			]

			# The website's scripts
			scripts: [
				"""
				<!-- jQuery -->
				<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>
				<script>window.jQuery || document.write('<script src="/vendor/jquery.js"><\\/script>')</script>
				"""

				'/vendor/log.js'
				'/vendor/modernizr.js'
				'/scripts/script.js'
			]


		# -----------------------------
		# Helper Functions

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')

		getPageUrlWithHostname: ->
			"#{@site.url}#{@document.url}"

		getIdForDocument: (document) ->
			hostname = url.parse(@site.url).hostname
			date = document.date.toISOString().split('T')[0]
			path = document.url
			"tag:#{hostname},#{date},#{path}"

		fixLinks: (content) ->
			baseUrl = @site.url
			regex = /^(http|https|ftp|mailto):/

#			$ = cheerio.load(content)
			$('img').each ->
				$img = $(@)
				src = $img.attr('src')
				$img.attr('src', baseUrl + src) unless regex.test(src)
			$('a').each ->
				$a = $(@)
				href = $a.attr('href')
				$a.attr('href', baseUrl + href) unless regex.test(href)
			$.html()
# DocPad Configuration File
# http://docpad.org/docs/config

#		moment: require('moment')

	# =================================
	# Collections

	# Here we define our custom collections
	# What we do is we use findAllLive to find a subset of documents from the parent collection
	# creating a live collection out of it
	# A live collection is a collection that constantly stays up to date
	# You can learn more about live collections and querying via
	# http://bevry.me/queryengine/guide

	collections:
		# Create a collection called posts
		# That contains all the documents that will be going to the out path posts
		news: ->
			@getCollection('documents').findAllLive({relativeOutDirPath:'news'},[date:-1])
		races: ->
			@getCollection('documents').findAllLive({relativeOutDirPath:'races'})
		rides: ->
			@getCollection('documents').findAllLive({relativeOutDirPath:'rides'})
		team: ->
			@getCollection('documents').findAllLive({relativeOutDirPath:'team'})


	# =================================
	# Environments
	# DocPad's default environment is the production environment
	# The development environment, actually extends from the production environment
	# the Development environment is ignored if the site is generated with 
	# > docpad -e static generate

	# The following overrides the posts collection to include draft posts 

	# The following also overrides our production url in our development environment with false
	# This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
	# This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in

	environments:
		development:
			templateData:
				site:
					url: false

	environments:
		development:
	    	collections:
           		posts: ->
               		@getCollection('documents').findAllLive({relativeDirPath: {'$in' : ['posts', 'drafts']}}, [relativeDirPath: 1,  date: -1])					

	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki

	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()

	# =================================
	# DocPad plugins

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki

	plugins:
	    associatedfiles:
	        # The paths for the associated files.
	        associatedFilesPath: 'associated-files'

	        # Whether to use relative base paths for the document. This would
	        # use associated-files/subfolder/myarticle/image.jpg instead of
	        # associated-files/myarticle/image.jpg.
	        useRelativeBase: false
}					

# Export the DocPad Configuration
module.exports = docpadConfig