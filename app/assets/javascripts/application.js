//= require jquery
//= require ahoy
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require lib/awesomplete
//= require autocomplete


function application_ready(){
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

function startNewSearch(){
  $(document).on( "click", "a.start_new_search", function(event) {
    event.stopPropagation();
    $('input#q').focus().select();
    return false;
  });
}

function socialShare(){
  $(document).on( "click", "a.social_share", function(event) {
    event.stopPropagation();
    var socialMedia = $(this).data('social-media');
    socialMedia = socialMedia.charAt(0).toUpperCase() + socialMedia.slice(1);
    window.open($(this).attr('href'), 'Wundermarks - Share your bookmark on ' + socialMedia,'width=600,height=400,scrollbars=yes,status=no,titlebar=no,toolbar=no');void(0);
    return false;
  });
}

$(document).on('turbolinks:load', application_ready);
