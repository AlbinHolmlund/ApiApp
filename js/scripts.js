// Generated by CoffeeScript 1.9.2
(function() {
  (function($) {

    /*
    	 * The hash
    	theHash = window.location.hash.substr(1)
    
    	 * Split hash
    	splittedHash = theHash.split("&")
    
    	 * Obtain the token from url
    	accessToken = false
    	$.each splittedHash, (index, val) -> 
    		if val.indexOf("access_token") > -1
    			 * The token
    			accessToken = val.split("access_token=")[1]
    
    	 * Check if we have accesstoken
    	if accessToken is false
    		 * Redirect
    		utubeClientId = "923680594690-39qgo36bob9vd0roo5jpkj4pfdikcmcm.apps.googleusercontent.com"
    		utubeRedirectUri = "http://localhost/github/ApiApp/"
    		utubeScope = "https://www.googleapis.com/auth/youtube"
    		window.location.href = "https://accounts.google.com/o/oauth2/auth?client_id=#{utubeClientId}&redirect_uri=#{utubeRedirectUri}&scope=#{utubeScope}&response_type=token&pageId=none"
    
    	else
    		 * We have token! :D
     */
    var apiKey, commentsNextPageToken, search, videoList, videoListByKey, videoPositions;
    apiKey = "AIzaSyBNbJt0Tunt5MEVt0x5TxZRNXcseci9TEk";
    commentsNextPageToken = false;
    videoList = [];
    videoListByKey = {};
    $(document).ready(function() {
      var searchFixedWidth;
      searchFixedWidth = 690;
      $("[data-search]").css("width", searchFixedWidth);
      $("[data-search]").css("height", searchFixedWidth);
      $("[data-search]").focus();
      return $(document).on("keyup input", "[data-search]", function(e) {
        var $inputSize, $span;
        $(this).closest(".search").removeClass("has-searched");
        if ($(this).val().length === 0) {
          return $(this).stop().animate({
            width: searchFixedWidth,
            height: searchFixedWidth
          }, {
            duration: 200
          });
        } else {
          $span = $(this).siblings("span").first();
          $span.text($(this).val().replace(/ /g, "+"));
          $span.css("display", "inline-block");
          $inputSize = $span.outerWidth();
          $span.css("display", "");
          $(this).stop();
          if ($inputSize < $(this).outerWidth()) {
            return $(this).animate({
              width: $inputSize,
              height: $inputSize
            }, {
              duration: 200
            });
          } else {
            return $(this).css({
              width: $inputSize,
              height: $inputSize
            });
          }
        }
      });
    });
    $(document).on("keydown", "[data-search]", function(event) {
      var val;
      if (event.which === 27) {
        $(this).blur();
      }
      if (event.which === 13) {
        val = $(this).val();
        return search(val, function() {
          $("[data-search]").blur();
          return $("[data-search]").closest(".search").removeClass("first-search");
        });
      }
    });
    $(document).on("focus", "[data-search]", function() {
      return $(this).closest(".search").removeClass("has-searched");
    }).on("blur", "[data-search]", function() {
      return $(this).closest(".search").addClass("has-searched");
    });
    search = function(query, callback) {
      var settings, useVideos;
      videoList = [];
      videoListByKey = {};
      settings = "type=video&maxResults=50&order=relevance";
      $.ajax({
        url: "https://www.googleapis.com/youtube/v3/search?part=snippet&q=" + query + "&" + settings + "&key=" + apiKey,
        dataType: "jsonp",
        success: function(data) {
          var items;
          items = data.items;
          console.log("All videos: ", data);
          return $.each(items, function(index, val) {
            return $.ajax({
              url: "https://www.googleapis.com/youtube/v3/videos?id=" + val.id.videoId + "&part=snippet,statistics&key=" + apiKey,
              dataType: "jsonp",
              async: false,
              success: function(data) {
                var pos;
                videoListByKey[val.id.videoId] = data.items[0];
                videoList[index] = data.items[0];
                pos = {
                  state: false,
                  values: {
                    top: {
                      current: 0,
                      to: 0
                    },
                    left: {
                      current: -1000,
                      to: 0
                    },
                    rotateX: {
                      current: 0,
                      to: 0
                    },
                    rotateY: {
                      current: 0,
                      to: 0
                    }
                  }
                };
                MoveTo.add(pos);
                videoPositions[val.id.videoId] = pos;
                $(".loading").addClass("active");
                $(".loading .progress").css("width", ((60 / items.length) * videoList.length) + "%");
                if (videoList.length === items.length) {
                  useVideos(videoList);
                  return callback();
                }
              }
            });
          });
        }
      });
      return useVideos = function(videos) {
        var $container, renderVideos, videosAjaxLooped;
        $container = $(".items");
        $container.html("");
        renderVideos = function() {

          /*sortVideos = (a, b) ->
          					return (b.custom.likeRatio - a.custom.likeRatio)
          				videos.sort(sortVideos)
           */
          var data, output, template;
          data = {
            videos: videos
          };
          template = $('[data-template="video-item"]').html();
          output = Mustache.render(template, data);
          return $container.append(output);
        };
        videosAjaxLooped = 0;
        return $.each(videos, function(index, item) {
          videos[index].custom = {
            likeRatio: null,
            likeRatioPercent: null
          };
          videos[index].statistics_formated = {};
          if (!item.statistics.likeCount) {
            item.statistics.likeCount = "0";
          }
          if (!item.statistics.dislikeCount) {
            item.statistics.dislikeCount = "0";
          }
          if (!item.statistics.commentCount) {
            item.statistics.commentCount = "0";
          }
          videos[index].custom.likeRatio = Math.round(item.statistics.likeCount / item.statistics.dislikeCount);
          if (!videos[index].custom.likeRatio) {
            videos[index].custom.likeRatio = "0";
          }
          videos[index].custom.likeRatioPercent = (parseInt(item.statistics.likeCount) / (parseInt(item.statistics.likeCount) + parseInt(item.statistics.dislikeCount))) * 100;
          videos[index].statistics_formated.viewCount = videos[index].statistics.viewCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
          videos[index].statistics_formated.likeCount = videos[index].statistics.likeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
          videos[index].statistics_formated.dislikeCount = videos[index].statistics.dislikeCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
          videos[index].statistics_formated.commentCount = videos[index].statistics.commentCount.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
          videos[index].custom.description = videos[index].snippet.description.replace(/\n/g, "<br>");
          return $.ajax({
            url: "https://www.googleapis.com/youtube/v3/channels?id=" + videos[index].snippet.channelId + "&part=snippet&key=" + apiKey,
            dataType: "jsonp",
            async: false,
            success: function(data) {
              videos[index].user = data;
              console.log("User: ", data);
              $(".loading .progress").css("width", 60 + ((40 / videos.length) * videosAjaxLooped) + "%");
              videosAjaxLooped++;
              if (videosAjaxLooped === videos.length) {
                renderVideos();
                return setTimeout(function() {
                  $(".loading").removeClass("active");
                  return $(".loading .progress").css("width", 0);
                }, 200);
              }
            }
          });
        });
      };
    };
    $("body").on("mousemove", ".video-item", function(e) {
      var videoId;
      videoId = $(this).data("videoid");
      if ($(this).attr("data-state") !== "fullscreen") {
        console.log("not full");
        videoPositions[videoId].values.rotateX.to = -(e.pageY - $(this).centerTop()) / 10;
        return videoPositions[videoId].values.rotateY.to = (e.pageX - $(this).centerLeft()) / 20;
      } else {
        videoPositions[videoId].values.rotateX.to = 0;
        return videoPositions[videoId].values.rotateY.to = 0;
      }
    }).on("mouseleave", ".video-item", function(e) {
      var videoId;
      videoId = $(this).data("videoid");
      videoPositions[videoId].values.rotateX.to = 0;
      return videoPositions[videoId].values.rotateY.to = 0;
    });
    $("body").on("click", ".video-item", function() {
      var videoId;
      videoId = $(this).data("videoid");
      $(".video-item").removeClass("active").css("z-index", "");
      $(this).addClass("active").css("z-index", 4000);
      $(this).attr("data-state", "fullscreen");
      $("body").addClass("state-fullscreen");
      $(this).mousemove();
      return $.ajax({
        url: "https://www.googleapis.com/youtube/v3/commentThreads?videoId=" + videoId + "&part=snippet,replies&order=relevance&maxResults=10&key=" + apiKey,
        dataType: "jsonp",
        success: function(data) {
          var comments, output, template;
          console.log("Comments: ", data);
          if (data.nextPageToken) {
            commentsNextPageToken = data.nextPageToken;
          } else {
            commentsNextPageToken = false;
          }
          comments = data;
          $.each(comments, function(index, val) {
            return comments[index] = val;
          });
          console.log(comments);
          template = $('[data-template="comments"]').html();
          output = Mustache.render(template, comments);
          $(".comment-ui .comment-items").html(output);
          template = $('[data-template="info-ui"]').html();
          output = Mustache.render(template, videoListByKey[videoId]);
          return $(".info-ui").html(output);
        }
      });
    });
    $("body").on("click", ".video-item.active", function() {
      var $iframe, videoId;
      videoId = $(this).data("videoid");
      $(this).addClass("started-video");
      if ($(this).find(".video-item-video").length === 0) {
        $iframe = $("<iframe/>", {
          src: "https://www.youtube.com/embed/" + videoId + "?autoplay=1",
          frameborder: 0,
          allowfullscreen: true,
          "class": "video-item-video"
        });
      }
      return $(this).find(".video-item-thumbnail").after($iframe);
    });
    $(document).on("click", ".close-fullscreen", function() {
      $(".video-item").removeClass("active");
      $("body").removeClass("state-fullscreen");
      $('.video-item[data-state="fullscreen"]').css("z-index", 2000);
      $(".video-item").attr("data-state", false);
      return $(".more-comments").text("Load more comments").removeClass("disabled");
    });

    /*
    	commentsLoading = false
    	autoloadComments = false # If comments should auto load
    	$(document).ready () ->
    		$(".comment-ui").scroll (e) ->
    			if $(this).scrollTop() + $(this).innerHeight() >= $(this)[0].scrollHeight and commentsLoading is false and autoloadComments is true
    				 * Load new comments
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
    						 * Get template
    						template = $('[data-template="comments"]').html()
    						 * Insert data
    						output = Mustache.render(template, comments)
    						 * Render output
    						$(".comment-ui .comment-items").append output
    						 * Not loading anymore
    						commentsLoading = false
     */
    $(document).on("click", ".more-comments:not(.disabled)", function() {
      var $this, videoId;
      $this = $(this);
      $this.addClass("disabled");
      if (commentsNextPageToken) {
        $this.text("Loading comments...");
      } else {
        $this.text("There is no more comments to load");
        return false;
      }
      videoId = $(".video-item.active").data("videoid");
      return $.ajax({
        url: "https://www.googleapis.com/youtube/v3/commentThreads?videoId=" + videoId + "&part=snippet,replies&order=relevance&maxResults=4&pageToken=" + commentsNextPageToken + "&key=" + apiKey,
        dataType: "jsonp",
        success: function(data) {
          var comments, output, template;
          commentsNextPageToken = data.nextPageToken;
          comments = data;
          $.each(comments, function(index, val) {
            return comments[index] = val;
          });
          $(".more-comments").remove();
          template = $('[data-template="comments"]').html();
          output = Mustache.render(template, comments);
          return $(".comment-ui .comment-items").append(output);
        }
      });
    });
    videoPositions = {};
    return MoveTo.addFrame(function() {
      var newLeft, newLeftCount, newTop;
      newTop = 0;
      newLeft = 0;
      newLeftCount = 0;
      return $(".video-item").each(function() {
        var $this, pos, trans, videoId;
        $this = $(this);
        videoId = $this.data("videoid");
        pos = videoPositions[videoId];
        if ($this.attr("data-state") === "fullscreen") {
          pos.values.top.to = $(".items").scrollTop();
          pos.values.left.to = 0;
        } else {
          pos.values.top.to = newTop;
          pos.values.left.to = newLeft;
        }
        newLeft += $(window).width() * 0.25;
        if (newLeftCount === 3) {
          newLeft = 0;
          newTop += $(window).width() * 0.25 * 0.5625;
          newLeftCount = 0;
        } else {
          newLeftCount++;
        }
        trans = "perspective(1000px) ";
        trans += "rotateX(" + pos.values.rotateX.current + "deg) ";
        trans += "rotateY(" + pos.values.rotateY.current + "deg)";
        $this.find(".video-item-inner").css({
          transform: trans
        });
        return $this.css({
          top: pos.values.top.current,
          left: pos.values.left.current
        });
      });
    });

    /*
     */
  })(jQuery);

}).call(this);
