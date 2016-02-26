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
		settings = "type=video&maxResults=5"
		apiKey = "AIzaSyBcN17dQgPoR3pAfZsFDiorljShq2lcpXI"
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
							videoList.push data.items[0]
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
				# Item setup
				$item = $("<div/>")
				# Video
				$video = $("<iframe/>",
							width: 640
							height: 360
							src: "https://www.youtube.com/embed/#{item.id}"
							frameborder: 0
							allowfullscreen: true
							css:
								display: "none"
						)
				# Thumbnail
				$image = $("<div/>",
							css: 
								backgroundImage: "url(#{item.snippet.thumbnails.standard.url})"
								backgroundSize: "cover"
								backgroundPosition: "center"
								width: 640
								height: 360
								cursor: "pointer"
						)
				$image.click () ->
					# Show video instead of image
					$(this).remove()
					$video.css("display", "")
				# List info
				likes = item.statistics.likeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
				dislikes = item.statistics.dislikeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ")
				$info = $("<div/>")
				$info.append "<strong>#{item.snippet.title}</strong>"
				$info.append "<p>Likes: #{likes}</p>"
				$info.append "<p>Dislikes: #{dislikes}</p>"

				# Appends
				$item.append $image # Image into item
				$item.append $video # Video into item
				$item.append $info # Info into item
				$container.append $item # Add item to container
	## End search function
) jQuery