$(function(){
    // make the tables pretty
    $.tablesorter.defaults.widgets = ['zebra']; 
    $('.tablesorter').each(function() { 
        $(this).tablesorter({ 
            sortList: eval($(this).attr('data-sort')),
            textExtraction: "complex"
        });
    });
});