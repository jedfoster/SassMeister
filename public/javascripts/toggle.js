var toggleHandler = function(toggle) {
    var radio = $(toggle).find("input");

    var checkToggleState = function() {
        if (radio.eq(0).is(":checked")) {
            $(toggle).removeClass("toggle-off");
        } else {
            $(toggle).addClass("toggle-off");
        }
    };

    checkToggleState();

    radio.click(function() {
        $(toggle).toggleClass("toggle-off");
        // console.log($(toggle).find('.toggle-radio:last-of-type'));
        var width = $(toggle).width();
        
        //console.log($(toggle).find('.toggle-radio:first-child').css({'left': width - 35}));
       // console.log($(toggle).find('.toggle-radio:last-child').css({'right': 400}));
    });
  
  $(toggle).find('.knob').click(function() {
    $(toggle).toggleClass("toggle-off");
  });
};

$(document).ready(function() {
    $(".toggle").each(function(index, toggle) {
        toggleHandler(toggle);
       
    });
});
