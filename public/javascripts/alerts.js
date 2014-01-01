// Number.isInteger() polyfill
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/isInteger#Polyfill
if (!Number.isInteger) {
  Number.isInteger = function isInteger (nVal) {
    return typeof nVal === "number" && isFinite(nVal) && nVal > -9007199254740992 && nVal < 9007199254740992 && Math.floor(nVal) === nVal;
  };
}


(function($) {
  Messenger.options = {
    theme: 'block',
    messageDefaults: {
      hideAfter: 6,
      showCloseButton: true
    }
  };

  var randomMsg = function() {
    msgs = [
      'Show off your sassy side with a SassMeister sticker.',
      'Get sweet, sassy stickers &amp; help support SassMeister.'
    ];

    return msgs[Math.floor(Math.random() * msgs.length)];
  };
  
 
  var stickerMsg = '<a href="http://devswag.com/products/sassmeister-stickers-4">\
<h1>Swag Alert! </h1>\
<p><img src="/images/sassmeister-detail-v02_medium.jpg"> ' + randomMsg() + '</p>\
</a>';


  var alertCatalog = {
    'stickers': {
      visit_interval: 30,
      time_interval: 86400 * 7,
      content: stickerMsg,
      extraClasses: 'messenger-on-bottom swag-promo'
    }
  };  
    

  if($('body.about, body.thankyou').length < 1 ) {
    var alertStats = $.extend(true, {
      last_visit: Date.now(),
      visit_number: 0,
      alerts: []
    }, JSON.parse(localStorage.getItem('alertStats')) );


    var alertQueue = {};


    var queueAddAlert = function(name, message) {
      alertQueue[name] = message;
    };


    // loop through alertCatalog and check if it is contained in alertStats.alerts
    $.each(alertCatalog, function(name, message) {
      if((alertStats.last_visit < (Date.now() - message.time_interval * 1000) ) || (Number.isInteger(alertStats.visit_number / message.visit_interval))){
        // display an alert
        queueAddAlert(name, message);
        console.log('ALERT! A');
      }
    });


    // Clean up stored alert info
    if(alertStats.alerts) {
      $.each(alertStats.alerts, function(alertName) {
        if(! alertCatalog[alertName]) { delete(alertStats.alerts[alertName]) }
      });
    }

    alertStats.last_visit = Date.now();
    alertStats.visit_number++;

    localStorage.setItem('alertStats', JSON.stringify( alertStats ));


    // Add promo message to the control panel
    // This is an odd duck. Might want to consider setting this server-side
    $('#promo .swag-promo').html(stickerMsg);
    
    
    // Loop through queued alerts and display them.
    // May need a refactor as I've only tested with a single alert
    $.each(alertQueue, function(i, message) {      
      Messenger({ extraClasses: message.extraClasses }).post({ message: message.content });
    });
  }
})(jQuery);