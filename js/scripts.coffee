(($) -> 
	###
	# The hash
	theHash = window.location.hash.substr(1)

	# Split hash
	splittedHash = theHash.split("&")

	# Obtain the token from url
	accessToken = false
	$.each splittedHash, (index, val) -> 
		if val.indexOf("access_token") > -1
			# The token
			accessToken = val.split("access_token=")[1]

	# Check if we have accesstoken
	if accessToken is false
		# Redirect
		utubeClientId = "923680594690-39qgo36bob9vd0roo5jpkj4pfdikcmcm.apps.googleusercontent.com"
		utubeRedirectUri = "http://localhost/github/ApiApp/"
		utubeScope = "https://www.googleapis.com/auth/youtube"
		window.location.href = "https://accounts.google.com/o/oauth2/auth?client_id=#{utubeClientId}&redirect_uri=#{utubeRedirectUri}&scope=#{utubeScope}&response_type=token&pageId=none"

	else
		# We have token! :D
	###

	# The sacred api key
	apiKey = "AIzaSyBcN17dQgPoR3pAfZsFDiorljShq2lcpXI"
	commentsNextPageToken = false

	# Input adjust width auto
	$(document).ready () ->
		searchFixedWidth = 690
		$("[data-search]").css("width", searchFixedWidth)
		$(document).on "keyup input", "[data-search]", (e) -> 
			# Make this input not "has-search"
			$(this).closest(".search").removeClass "has-searched"
			# If its empty set a fixed width
			if $(this).val().length is 0
				$(this).stop().animate(
					width: searchFixedWidth
				,
					duration: 200
				)
			else
				# Set size
				$span = $(this).siblings("span").first()
				$span.text($(this).val())
				$span.css("display", "inline-block")
				$inputSize = $span.outerWidth()
				$span.css("display", "")
				$(this).stop()
				$(this).css("width", $inputSize)

	# Input search
	$(document).on "keydown", "[data-search]", (event) -> 
		if event.which is 13
			val = $(this).val()
			# Search
			search val, () ->
				$("[data-search]").closest(".search").addClass "has-searched"

	# Search and render result
	search = (query, callback) -> 
		settings = "type=video&maxResults=5&order=relevance"
		$.ajax
			url: "https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{query}&#{settings}&key=#{apiKey}"
			#url: "https://www.googleapis.com/youtube/v3/videos/getRating?id=6xIRT0huiuA&access_token=#{accessToken}"
			dataType: "jsonp"
			success: (data) ->
				items = data.items
				# console.log items # For testing
				videoList = {} # This array will be populated with videos
				# Loop through items and gather info
				$.each items, (index, val) -> 
					$.ajax
						url: "https://www.googleapis.com/youtube/v3/videos?id=#{val.id.videoId}&part=snippet,statistics&key=#{apiKey}"
						dataType: "jsonp"
						success: (data) -> 
							# Add video to list
							videoList[val.id.videoId] = data.items[0]
							# If this is the last result, run function that uses the videos
							if Object.keys(videoList).length is items.length
								useVideos(videoList)
								# Run callback
								callback()
		# Use videos
		useVideos = (videos) -> 
			console.log videos # For testing
			# List videos in the ui
			$container = $(".items") # The container
			$container.html("") # Clear container
			# Loop through all videos
			$.each videos, (index, item) ->
				## Edit data before rendering
				videos[index].custom = {
					likeRatio: null
				}

				# Calculate new data
				videos[index].custom.likeRatio = item.statistics.likeCount / item.statistics.dislikeCount

				## Render item
				# Get template
				template = $('[data-template="video-item"]').html()
				# Insert data
				output = Mustache.render(template, item)
				# Render output
				$container.append output

	## End search function

	# Video thumbnail click
	$("body").on "click", ".video-item", () -> 
		# Show video instead of image
		$(".video-item").removeClass("active")
		$(this).addClass("active")

		# Show other ui
		$("body").addClass("state-fullscreen");

		# Populate comment ui with comments
		videoId = $(this).data("videoid");
		$.ajax
			url: "https://www.googleapis.com/youtube/v3/commentThreads?videoId=#{videoId}&part=snippet&key=#{apiKey}"
			dataType: "jsonp"
			success: (data) ->
				# For testing
				console.log data
				## Set next page token
				if data.nextPageToken
					commentsNextPageToken = data.nextPageToken
				else
					commentsNextPageToken = false
				## Correct comments
				comments = data
				$.each comments, (index, val) -> 
					comments[index] = val
				## Render comments
				# Get template
				template = $('[data-template="comments"]').html()
				# Insert data
				output = Mustache.render(template, comments)
				# Render output
				$(".comment-ui .comment-items").html output

	# Close fullscreen
	$(document).on "click", ".close-fullscreen", () ->
		$(".video-item").removeClass("active")
		$("body").removeClass("state-fullscreen");

	# Load more comments
	$(document).on "click", ".more-comments:not(.disabled)", () ->
		$this = $(this)
		$this.addClass("disabled")

		if commentsNextPageToken
			$this.text("Loading comments...")
		else
			$this.text("There is no more comments to load")
			return false

		videoId = $(".video-item.active").data("videoid")
		$.ajax
			url: "https://www.googleapis.com/youtube/v3/commentThreads?videoId=#{videoId}&part=snippet&pageToken=#{commentsNextPageToken}&key=#{apiKey}"
			dataType: "jsonp"
			success: (data) ->
				## Set next page token
				commentsNextPageToken = data.nextPageToken
				## Correct comments
				comments = data
				$.each comments, (index, val) -> 
					comments[index] = val
				## Render comments
				# Get template
				template = $('[data-template="comments"]').html()
				# Insert data
				output = Mustache.render(template, comments)
				# Render output
				$(".comment-ui .comment-items").append output
				# Make button available again
				$(".more-comments")
					.text("Load more comments")
					.removeClass("disabled")

	# Function to position videos
	setInterval () ->
		top = 0
		$(".video-item").each () ->
			$this = $(this)
			if !$this.hasClass("active")
				$this.css "top", top
				top += $this.height()
			else
				$this.css "top", 0
	, 1000/60

	# Notes
	# dislikes = item.statistics.dislikeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
	###

	###
) jQuery