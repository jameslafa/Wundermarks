//= require jquery
//= require ahoy
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require lib/bootstrap-toolkit
//= require lib/awesomplete
//= require autocomplete

// Should be executed each time the page is loaded by turbolinks
function pageLoaded(){
  ajustViewport();
}

// Should be executed only once, when the application boostrap.
// It contains listeners global to the application staying active even
// when the page is reloaded with turbolinks
function documentReady(){
  showBookmarkDetailsOnMobile();
  trackClicks();
  startNewSearch();
  socialShare();
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
  $(document).on( "click", "a.start_new_search", function(event) {
    event.stopPropagation();
    $('input#q').focus().select();
    return false;
  });
}

// Open sharing popup when the user click on a social media icon
function socialShare(){
  $(document).on( "click", "a.social_share", function(event) {
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

// Track click, on mobile, on the bookmark title to display the details
function showBookmarkDetailsOnMobile(){
  $(document).on("click", "body.viewport-xs .bookmark .title, body.viewport-sm .bookmark .title", function(event){
    event.stopPropagation();
    $(this).parent('.bookmark').toggleClass('open');
    return false;
  });
}

$(document).ready(documentReady);
$(document).on('turbolinks:load', pageLoaded);
