// Observ field function

(function( $ ){

  jQuery.fn.observe_field = function(frequency, callback) {

    frequency = frequency * 100; // translate to milliseconds

    return this.each(function(){
      var $this = $(this);
      var prev = $this.val();

      var check = function() {
        if(removed()){ // if removed clear the interval and don't fire the callback
          if(ti) clearInterval(ti);
          return;
        }

        var val = $this.val();
        if(prev != val){
          prev = val;
          $this.map(callback); // invokes the callback on $this
        }
      };

      var removed = function() {
        return $this.closest('html').length == 0
      };

      var reset = function() {
        if(ti){
          clearInterval(ti);
          ti = setInterval(check, frequency);
        }
      };

      check();
      var ti = setInterval(check, frequency); // invoke check periodically

      // reset counter after user interaction
      $this.bind('keyup click mousemove', reset); //mousemove is for selects
    });

  };

  $.fn.insertAtCaret = function (myValue) {

    return this.each(function() {

      //IE support
      if (document.selection) {

        this.focus();
        sel = document.selection.createRange();
        sel.text = myValue;
        this.focus();

      } else if (this.selectionStart || this.selectionStart == '0') {

        //MOZILLA / NETSCAPE support
        var startPos = this.selectionStart;
        var endPos = this.selectionEnd;
        var scrollTop = this.scrollTop;
        this.value = this.value.substring(0, startPos)+ myValue+ this.value.substring(endPos,this.value.length);
        this.focus();
        this.selectionStart = startPos + myValue.length;
        this.selectionEnd = startPos + myValue.length;
        this.scrollTop = scrollTop;

      } else {

        this.value += myValue;
        this.focus();
      }
    });
  };


})( jQuery );

function selectAllOptions(id) {
  var select = $('#'+id);
  select.children('option').attr('selected', true);
}

function submit_query_form(id) {
  selectAllOptions("selected_columns");
  $('#'+id).submit();
}


var cmsPagesOldToggleFilter = window.toggleFilter;

window.toggleFilter = function(field) {
  cmsPagesOldToggleFilter(field);
  return cmsPagesTagsToSelect2(field);
}

function cmsPagesTagsToSelect2(field){
  initialized_select2 = $('#tr_' + field + ' .values .select2');
  if (field == 'cms_page_tags' && initialized_select2.size() == 0) {
    $('#tr_' + field + ' .toggle-multiselect').hide();
    $('#tr_' + field + ' .values .value').attr('multiple', 'multiple');
    $('#tr_' + field + ' .values .value').select2({
      ajax: {
        url: '/auto_completes/cms_page_tags',
        dataType: 'json',
        delay: 250,
        data: function (params) {
          return { q: params.term };
        },
        processResults: function (data, params) {
          return { results: data };
        },
        cache: true
      },
      placeholder: ' '
    });
  }
}
