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
	apiKey = "AIzaSyBNbJt0Tunt5MEVt0x5TxZRNXcseci9TEk"
	commentsNextPageToken = false

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
				$(this).css("width", $inputSize)
				$(this).css("height", $inputSize)

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
				$("[data-search]").blur()
	$(document)
		.on "focus", "[data-search]", () ->
			$(this).closest(".search").removeClass "has-searched"
		.on "blur", "[data-search]", () ->
			$(this).closest(".search").addClass "has-searched"


	# Search and render result
	search = (query, callback) -> 
		settings = "type=video&maxResults=50&order=relevance" #(maxResults = 8)
		$.ajax
			url: "https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{query}&#{settings}&key=#{apiKey}"
			#url: "https://www.googleapis.com/youtube/v3/videos/getRating?id=6xIRT0huiuA&access_token=#{accessToken}"
			dataType: "jsonp"
			success: (data) ->
				items = data.items
				# console.log items # For testing
				videoList = [] # This array will be populated with videos
				# Loop through items and gather info
				$.each items, (index, val) -> 
					$.ajax
						url: "https://www.googleapis.com/youtube/v3/videos?id=#{val.id.videoId}&part=snippet,statistics&key=#{apiKey}"
						dataType: "jsonp"
						success: (data) -> 
							console.log "hey"
							# Add video to list
							videoList.push(data.items[0])
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

							# If this is the last result, run function that uses the videos
							if videoList.length is items.length
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
					likeRatioPercent: null
				}
				videos[index].statistics_formated = {}

				# Check if likes/dislike exists
				if !item.statistics.likeCount
					 item.statistics.likeCount = 0
				if !item.statistics.dislikeCount
					 item.statistics.dislikeCount = 0
				if !item.statistics.commentCount
					 item.statistics.commentCount = 0

				# Calculate new data
				videos[index].custom.likeRatio = Math.ceil( item.statistics.likeCount / item.statistics.dislikeCount )
				videos[index].custom.likeRatioPercent = (parseInt(item.statistics.likeCount) / (parseInt(item.statistics.likeCount) + parseInt(item.statistics.dislikeCount))) * 100

				# Make spaces in numbers
				videos[index].statistics_formated.viewCount = videos[index].statistics.viewCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
				videos[index].statistics_formated.likeCount = videos[index].statistics.likeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
				videos[index].statistics_formated.dislikeCount = videos[index].statistics.dislikeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
				videos[index].statistics_formated.commentCount = videos[index].statistics.commentCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")

			# Sort before rendering
			sortVideos = (a, b) ->
				return (b.custom.likeRatio - a.custom.likeRatio)
			videos.sort(sortVideos)

			# Render
			data = 
				videos: videos
			# Get template
			template = $('[data-template="video-item"]').html()
			# Insert data
			output = Mustache.render(template, data)
			# Render output
			$container.append output

	## End search function

	# Video thumbnail hover
	$("body")
		.on "mousemove", ".video-item", (e) ->
			videoId = $(this).data("videoid")
			console.log videoId
			videoPositions[videoId].values.rotateX.to = -(e.pageY - $(this).centerTop()) / 10
			videoPositions[videoId].values.rotateY.to = (e.pageX - $(this).centerLeft()) / 20
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
			.addClass("active started-video")
			.css("z-index", 4000)

		# Add youtube embed iframe 
		if $(this).find(".video-item-video").length is 0
			$iframe = $("<iframe/>",
						src: "https://www.youtube.com/embed/#{videoId}"
						frameborder: 0
						allowfullscreen: true
						class: "video-item-video"
					)
		$(this).find(".video-item-thumbnail").after $iframe

		# Set this state
		$(this).attr("data-state", "fullscreen")

		# Show other ui
		$("body").addClass("state-fullscreen")

		# Populate comment ui with comments
		$.ajax
			url: "https://www.googleapis.com/youtube/v3/commentThreads?videoId=#{videoId}&part=snippet&key=#{apiKey}"
			dataType: "jsonp"
			success: (data) ->
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
		$("body").removeClass("state-fullscreen")
		# Set current item z-index
		$('.video-item[data-state="fullscreen"]').css("z-index", 2000)
		# Set this state to normal
		$(".video-item").attr("data-state", false)

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
				pos.values.rotateX.to = 0
				pos.values.rotateY.to = 0
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
			# Transform
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