function enableTagAutoComplete(){
  var inputFields = $('.tag-autocomplete');
  inputFields.each(function(index, inputField){
    // Enabled Awesomplete on every fields with the class 'tag-autocomplete'
    var awesomepletedField = new Awesomplete(inputField, {
      minChars: 2,
      filter: function(text, input) {
        // Called to match the datalist to the input text and show suggestions
        // We want a suggestion only on the last element of the list and only if this one
        // has at least 2 characters
        var searchTerm = $.trim(input.match(/[^,]*$/)[0]);
        return (searchTerm.length > 1) && Awesomplete.FILTER_CONTAINS(text, searchTerm) ;
      },

      replace: function(text) {
        // Called when a value is selected.
        // It happends the value to the global string
        var before = this.input.value.match(/^.+,\s*|/)[0];
        this.input.value = before + text + ", ";
      }
    });

    // After a new key is pressed, we want to renew the content list
    // by calling the server to get new suggestions
    $(inputField).keyup(function(event){
      // Get the new search term (last word of the list)
      var searchTerm = $.trim($(this).val().match(/[^,]*$/)[0]);

      // Check that the searchTerm has at least 2 characters
      if(searchTerm.length > 1){

        // Check that the last query was not on the same searchTerm.
        // This avoid unnecessary queries, often if the user presses a key
        // like keydown, etc.
        if(searchTerm != $(inputField).data('last_searched_term')){
          $.ajax({
            url: '/autocomplete_search/tags.json?q=' + searchTerm,
            success: function(data, status){
              // Save last_searched_term
              $(inputField).data('last_searched_term', searchTerm);

              if(status == 'success' && Array.isArray(data)){
                awesomepletedField.list = data;
                awesomepletedField.evaluate();
              }
            },
            timeout: 3000
          });
        }
        // If the user press KeyDown and the suggestion list is closed,
        // we reevalute it to display potential suggestions
        else if ((event.keyCode == 40) && (awesomepletedField.opened != true)){
          awesomepletedField.evaluate();
        }
      }
    });
  });
};

$(document).on('turbolinks:load', enableTagAutoComplete);
