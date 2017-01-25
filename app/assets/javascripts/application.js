//= require jquery
//= require ahoy
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require lib/bootstrap-toolkit
//= require lib/awesomplete
//= require lib/nprogress
//= require autocomplete

// Should be executed each time the page is loaded by turbolinks
function pageLoaded(){
  ajustViewport();
  activateTooltips();
}

// Should be executed only once, when the application boostrap.
// It contains listeners global to the application staying active even
// when the page is reloaded with turbolinks
function documentReady(){
  trackClicks();
  startNewSearch();
  socialShare();
  validateUsernameAvailability();
  bookmarkAttributeLength();
  uploadAvatar();
}

// Track clicks to external links for analytics
function trackClicks() {
  $(document).on( "click", "a._track_click", function() {
    ahoy.track("$click", $(this).data('infos'));
  });
}

// When user click on 'start new search', it focus on the search field
// and select the content
function startNewSearch(){
  $(document).on( "click", ".start_new_search", function(event) {
    event.stopPropagation();
    $('input#q').focus().select();
    return false;
  });
}

// Open sharing popup when the user click on a social media icon
function socialShare(){
  $(document).on( "click", "a.social-share", function(event) {
    event.stopPropagation();
    var socialMedia = $(this).data('social-media');
    socialMedia = socialMedia.charAt(0).toUpperCase() + socialMedia.slice(1);
    window.open($(this).attr('href'), 'Wundermarks - Share your bookmark on ' + socialMedia,'width=600,height=400,scrollbars=yes,status=no,titlebar=no,toolbar=no');void(0);
    return false;
  });
}

// Ajust the body viewport class on window.resize
// Use https://github.com/maciej-gurban/responsive-bootstrap-toolkit
function ajustViewport(){
  (function($, viewport){

    // Turbolink removes the div responsive-bootstrap-toolkit necessary
    // to get the viewport. We re-add it manually.
    if($('div.responsive-bootstrap-toolkit').length < 1){
      $('<div class="responsive-bootstrap-toolkit"></div>').appendTo('body');
      viewport.use('bootstrap');
    }

    // Set the viewport data attribute
    function updateViewportClass(newViewport){
      if($.inArray(newViewport, ['xs', 'sm', 'md', 'lg']) >= 0){
        $('body').data('viewport', newViewport);
        $('body').removeClass('viewport-xs viewport-sm viewport-md viewport-lg');
        $('body').addClass('viewport-' + newViewport);
      }
    }

    // Update viewport class on page load
    updateViewportClass(viewport.current());

    // Update viewport class on window resize
    $(window).resize(
      viewport.changed(function() {
        updateViewportClass(viewport.current());
      })
    );
  })(jQuery, ResponsiveBootstrapToolkit);
}

// Validate that the username is available while user is typing it
function validateUsernameAvailability(){
  // Make the AJAX request to validate the username
  function checkUsername(username){
    var input = $("#user_profile_username");
    var username = input.val();

    if(username.length > 0){
      $.ajax({
        url: '/autocomplete_search/username_available.json?q=' + username,
        success: function(data, status){
          if(data){
            // Update message
            $("#user_profile_username_help .validation_message").html(data.message + '<br/>');

            // Update form-group classes to update colors
            if(data.valid == true){
              input.parents('.form-group').removeClass('has-error').addClass('has-success');
            }
            else{
              input.parents('.form-group').removeClass('has-success').addClass('has-error');
            }
          }
        },
        timeout: 3000
      });
    }
    else{
      // If the username is empty, empty validation
      $("#user_profile_username_help .validation_message").html('');
      input.parents('.form-group').removeClass('has-error has-success');
    }
  }

  // Check when the user click the check button
  $(document).on("click", "body.c-user_profiles button.user_name_check", function(event){
    checkUsername();
  });

  // Check while user is typing. Launched 200ms after the last keyup
  $(document).on("keyup", "body.c-user_profiles #user_profile_username", function(event){
    clearTimeout(window.checkUsernameTimer);
    window.checkUsernameTimer = setTimeout(checkUsername, 200);
  });
}

// Count Title and Description length on Bookmark#new
function bookmarkAttributeLength(){
  $(document).on("keyup", ".c-bookmarks.a-new #bookmark_title", function(event){
    $("#bookmark_title_help .title-length").text($(this).val().length);
  });

  $(document).on("keyup", ".c-bookmarks.a-new #bookmark_description", function(event){
    $("#bookmark_description_help .description-length").text($(this).val().length);
  });
}

// Activate bootstrap tooltips
function activateTooltips(){
  // Remove existing tooltips. Some of them can be stuck by using turbolinks
  $('div.tooltip').remove();
  // Enable tooltip
  $('[data-toggle="tooltip"]').tooltip({delay: { "show": 500, "hide": 100 }});
}

// Upload avatar when click on the image
function uploadAvatar(){
  // Open file selector when user click on the image
  $(document).on("click", ".avatar-container .upload", function(){
    $("#user_profile_avatar").focus().click();
  });

  // When an image has been selected, display a preview
  $(document).on("change", "#user_profile_avatar", function(){
    var input = $(this)[0];
    if (input.files && input.files[0]) {
      var picture = input.files[0];
      var file_type = picture.type;

      // Check that the file type is correct
      if (['image/png', 'image/jpeg'].indexOf(file_type) > -1){

        // Display a preview
        var reader = new FileReader();

        reader.onload = function (e) {
          $('.avatar-container .image').css('background-image', 'url(' + e.target.result + ')');
        }

        reader.readAsDataURL(picture);
      }
      else{
        // File type is incorrect, remove the file from the upload field
        input.value = "";
      }
    }
  });
}

$(document).ready(documentReady);
$(document).on('turbolinks:load', pageLoaded);


// Activate NProgress on turbolinks change
$(document).on('turbolinks:click', function() {
  NProgress.start();
});
$(document).on('turbolinks:render', function() {
  NProgress.done();
  NProgress.remove();
});
