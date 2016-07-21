//= require jquery
//= require ahoy
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require lib/awesomplete
//= require autocomplete


function application_ready(){
  trackClicks();
  start_new_search();
}

// Track clicks to external links for analytics
function trackClicks() {
  $(document).on( "click", "a._track_click", function() {
    ahoy.track("$click", $(this).data('infos'));
  });
}

function start_new_search(){
  $(document).on( "click", "a.start_new_search", function(event) {
    event.stopPropagation();
    $('input#q').focus().select();
    return false;
  });
}

$(document).on('turbolinks:load', application_ready);
