//= require jquery
//= require ahoy
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require lib/awesomplete
//= require autocomplete

// Track clicks to external links for analytics
$(document).ready(function() {
  $(document).on( "click", "a._track_click", function() {
    ahoy.track("$click", $(this).data('infos'));
  });
});
