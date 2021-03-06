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

	# Ajax fix test


	# The sacred api key
	apiKey = "AIzaSyBNbJt0Tunt5MEVt0x5TxZRNXcseci9TEk"
	commentsNextPageToken = false
	videoList = [] # This array will be populated with videos
	videoListByKey = {} # Same as videoList but with id as key

	# Input adjust width auto
	$(document).ready () ->
		searchFixedWidth = 690
		$("[data-search]").css("width", searchFixedWidth)
		$("[data-search]").css("height", searchFixedWidth)
		$("[data-search]").focus()
		$(document).on "keyup input", "[data-search]", (e) -> 
			# Make this input not "has-search"
			$(this).closest(".search").removeClass "has-searched"
			# If its empty set a fixed width
			if $(this).val().length is 0
				$(this).stop().animate(
					width: searchFixedWidth
					height: searchFixedWidth
				,
					duration: 200
				)
			else
				# Set size
				$span = $(this).siblings("span").first()
				$span.text($(this).val().replace(/ /g, "+"))
				$span.css("display", "inline-block")
				$inputSize = $span.outerWidth()
				$span.css("display", "")
				$(this).stop()
				# Animate or just change
				if $inputSize < $(this).outerWidth()
					$(this).animate(
						width: $inputSize
						height: $inputSize
					,
						duration: 200
					)
				else
					$(this).css
						width: $inputSize
						height: $inputSize

	# Input search
	$(document).on "keydown", "[data-search]", (event) -> 
		# Blur
		if event.which is 27
			$(this).blur()
		# Search
		if event.which is 13
			val = $(this).val()
			# Search
			search val, () ->
				$("[data-search]").blur() # Remove focus
				$("[data-search]").closest(".search").removeClass("first-search") # Clear first search
	$(document)
		.on "focus", "[data-search]", () ->
			$(this).closest(".search").removeClass "has-searched"
		.on "blur", "[data-search]", () ->
			$(this).closest(".search").addClass "has-searched"

	# Search and render result
	search = (query, callback) -> 
		# Resets
		videoList = [] # This array will be populated with videos
		videoListByKey = {} # Same as videoList but with id as key
		# Settings
		settings = "type=video&maxResults=50&order=relevance" #(maxResults = 8)
		$.ajax
			url: "https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{query}&#{settings}&key=#{apiKey}"
			#url: "https://www.googleapis.com/youtube/v3/search?forUsername=#{query}&part=snippet&order=date&maxResults=50&key=#{apiKey}"
			#url: "https://www.googleapis.com/youtube/v3/videos/getRating?id=6xIRT0huiuA&access_token=#{accessToken}"
			dataType: "jsonp"
			success: (data) ->
				items = data.items
				console.log "All videos: ", data
				# Loop through items and gather info
				$.each items, (index, val) -> 
					$.ajax
						url: "https://www.googleapis.com/youtube/v3/videos?id=#{val.id.videoId}&part=snippet,statistics&key=#{apiKey}"
						dataType: "jsonp"
						async: false
						success: (data) -> 
							# Add video to list
							videoListByKey[val.id.videoId] = data.items[0]
							videoList[index] = data.items[0]
							# Create video position
							pos = 
								state: false
								values: 
									top: 
										current: 0
										to: 0
									left: 
										current: -1000
										to: 0
									rotateX: 
										current: 0
										to: 0
									rotateY:
										current: 0
										to: 0
							MoveTo.add(pos)
							videoPositions[val.id.videoId] = pos

							# Add to progressbar
							$(".loading").addClass "active"
							$(".loading .progress").css "width", ((60/items.length) * videoList.length) + "%"

							# If this is the last result, run function that uses the videos
							if videoList.length is items.length
								useVideos(videoList)
								# Run callback
								callback()
		# Use videos
		useVideos = (videos) -> 
			# List videos in the ui
			$container = $(".items") # The container
			$container.html("") # Clear container

			# The sort/render function that will be run when all videos are done looping through and all ajaxes are done
			renderVideos = () ->
				# Sort before rendering
				###sortVideos = (a, b) ->
					return (b.custom.likeRatio - a.custom.likeRatio)
				videos.sort(sortVideos)###

				# Render
				data = 
					videos: videos
				# Get template
				template = $('[data-template="video-item"]').html()
				# Insert data
				output = Mustache.render(template, data)
				# Render output
				$container.append output

			# Loop through all videos
			videosAjaxLooped = 0 # How many ajaxes has finished
			$.each videos, (index, item) ->
				## Edit data before rendering
				videos[index].custom = {
					likeRatio: null
					likeRatioPercent: null
				}
				videos[index].statistics_formated = {}

				# Check if likes/dislike exists
				if !item.statistics.likeCount
					 item.statistics.likeCount = "0"
				if !item.statistics.dislikeCount
					 item.statistics.dislikeCount = "0"
				if !item.statistics.commentCount
					 item.statistics.commentCount = "0"

				# Calculate new data
				videos[index].custom.likeRatio = Math.round( item.statistics.likeCount / item.statistics.dislikeCount )
				if !videos[index].custom.likeRatio then videos[index].custom.likeRatio = "0"
				videos[index].custom.likeRatioPercent = (parseInt(item.statistics.likeCount) / (parseInt(item.statistics.likeCount) + parseInt(item.statistics.dislikeCount))) * 100

				# Make spaces in numbers
				videos[index].statistics_formated.viewCount = videos[index].statistics.viewCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
				videos[index].statistics_formated.likeCount = videos[index].statistics.likeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
				videos[index].statistics_formated.dislikeCount = videos[index].statistics.dislikeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
				videos[index].statistics_formated.commentCount = videos[index].statistics.commentCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")

				## Fix description
				# Add line breaks
				videos[index].custom.description = videos[index].snippet.description.replace(/\n/g,"<br>");;

				# Add user to the object
				$.ajax
					url: "https://www.googleapis.com/youtube/v3/channels?id=#{videos[index].snippet.channelId}&part=snippet&key=#{apiKey}"
					dataType: "jsonp"
					async: false # Must be run first
					success: (data) ->
						# Add user data
						videos[index].user = data
						console.log "User: ", data
						# Add to progressbar
						$(".loading .progress").css "width", 60 + ((40/videos.length) * videosAjaxLooped) + "%"
						# Check if this is the last ajax call
						videosAjaxLooped++
						if videosAjaxLooped is videos.length
							renderVideos()
							# Clear loading bar
							setTimeout () ->
								$(".loading").removeClass "active"
								$(".loading .progress").css "width", 0
							, 200

	## End search function

	# Video thumbnail hover
	$("body")
		.on "mousemove", ".video-item", (e) ->
			videoId = $(this).data("videoid")
			if $(this).attr("data-state") isnt "fullscreen"
				console.log "not full"
				videoPositions[videoId].values.rotateX.to = -(e.pageY - $(this).centerTop()) / 10
				videoPositions[videoId].values.rotateY.to = (e.pageX - $(this).centerLeft()) / 20
			else 
				videoPositions[videoId].values.rotateX.to = 0
				videoPositions[videoId].values.rotateY.to = 0
		.on "mouseleave", ".video-item", (e) ->
			videoId = $(this).data("videoid")
			videoPositions[videoId].values.rotateX.to = 0
			videoPositions[videoId].values.rotateY.to = 0


	# Video thumbnail click
	$("body").on "click", ".video-item", () -> 
		# Get video id
		videoId = $(this).data("videoid")

		# Show video instead of image
		$(".video-item")
			.removeClass("active")
			.css("z-index", "")
		$(this)
			.addClass("active")
			.css("z-index", 4000)

		# Set this state
		$(this).attr("data-state", "fullscreen")

		# Show other ui
		$("body").addClass("state-fullscreen")

		# Trigger mousemove event to remove 3d rotation
		$(this).mousemove()

		# Populate comment ui with comments
		$.ajax
			url: "https://www.googleapis.com/youtube/v3/commentThreads?videoId=#{videoId}&part=snippet,replies&order=relevance&maxResults=10&key=#{apiKey}"
			dataType: "jsonp"
			success: (data) ->
				console.log "Comments: ", data
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
				console.log comments
				# Get template
				template = $('[data-template="comments"]').html()
				# Insert data
				output = Mustache.render(template, comments)
				# Render output
				$(".comment-ui .comment-items").html output

				## Render info ui
				# Get template
				template = $('[data-template="info-ui"]').html()
				# Insert data
				output = Mustache.render(template, videoListByKey[videoId])
				# Render output
				$(".info-ui").html output

	$("body").on "click", ".video-item.active", () ->
		videoId = $(this).data("videoid")
		$(this).addClass("started-video")
		# Add youtube embed iframe 
		if $(this).find(".video-item-video").length is 0
			$iframe = $("<iframe/>",
						src: "https://www.youtube.com/embed/#{videoId}?autoplay=1"
						frameborder: 0
						allowfullscreen: true
						class: "video-item-video"
					)
		$(this).find(".video-item-thumbnail").after $iframe

	# Close fullscreen
	$(document).on "click", ".close-fullscreen", () ->
		$(".video-item").removeClass("active")
		$("body").removeClass("state-fullscreen")
		# Set current item z-index
		$('.video-item[data-state="fullscreen"]').css("z-index", 2000)
		# Set this state to normal
		$(".video-item").attr("data-state", false)
		# Make comment button available again
		$(".more-comments")
			.text("Load more comments")
			.removeClass("disabled")

	# Load more comments
	###
	commentsLoading = false
	autoloadComments = false # If comments should auto load
	$(document).ready () ->
		$(".comment-ui").scroll (e) ->
			if $(this).scrollTop() + $(this).innerHeight() >= $(this)[0].scrollHeight and commentsLoading is false and autoloadComments is true
				# Load new comments
				commentsLoading = true
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
						# Not loading anymore
						commentsLoading = false
	###

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
			#url: "https://www.googleapis.com/youtube/v3/commentThreads?videoId=#{videoId}&part=snippet&pageToken=#{commentsNextPageToken}&key=#{apiKey}"
			url: "https://www.googleapis.com/youtube/v3/commentThreads?videoId=#{videoId}&part=snippet,replies&order=relevance&maxResults=4&pageToken=#{commentsNextPageToken}&key=#{apiKey}"
			dataType: "jsonp"
			success: (data) ->
				## Set next page token
				commentsNextPageToken = data.nextPageToken
				## Correct comments
				comments = data
				$.each comments, (index, val) -> 
					comments[index] = val
				# Remove button because it will be re-rendered
				$(".more-comments").remove()
				## Render comments
				# Get template
				template = $('[data-template="comments"]').html()
				# Insert data
				output = Mustache.render(template, comments)
				# Render output
				$(".comment-ui .comment-items").append output


	## Function to position videos

	# All positions with index
	videoPositions = {}

	# Position video each frame
	MoveTo.addFrame () -> 
		# Loop through all items
		newTop = 0
		newLeft = 0
		newLeftCount = 0
		$(".video-item").each () ->
			$this = $(this)
			videoId = $this.data("videoid")
			pos = videoPositions[videoId]
			if $this.attr("data-state") is "fullscreen"
				## Position for fullscreen
				pos.values.top.to = $(".items").scrollTop()
				pos.values.left.to = 0
			else
				## Position for normal position
				# Set new top position to move towards
				pos.values.top.to = newTop
				pos.values.left.to = newLeft

			# Add new left
			newLeft += $(window).width() * 0.25
			# If left is more than a number, then add on height
			if newLeftCount is 3
				newLeft = 0
				newTop += $(window).width() * 0.25 * 0.5625
				newLeftCount = 0
			else
				newLeftCount++
			# Transform (3d rotate effect)
			trans = "perspective(1000px) "
			trans += "rotateX(#{pos.values.rotateX.current}deg) "
			trans += "rotateY(#{pos.values.rotateY.current}deg)"
			$this.find(".video-item-inner").css
				transform: trans
			# Position element
			$this.css
				top: pos.values.top.current
				left: pos.values.left.current
	## End frame

	# Notes
	# dislikes = item.statistics.dislikeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
	###

	###
) jQuery