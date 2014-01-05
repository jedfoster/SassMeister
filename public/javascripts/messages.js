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
<h1>Swag message! </h1>\
<p><img src="/images/sassmeister-detail-v02_medium.jpg"> ' + randomMsg() + '</p>\
</a>';


  var messageCatalog = {
    'stickers': {
      visit_interval: 30,
      time_interval: 86400 * 7,
      content: stickerMsg,
      extraClasses: 'messenger-on-bottom swag-promo'
    }
  };  
    

  if($('body.about, body.thankyou').length < 1 ) {
    var messageStats = $.extend(true, {
      last_visit: Date.now(),
      visit_number: 0,
      messages: []
    }, JSON.parse(localStorage.getItem('messageStats')) );


    var messageQueue = {};


    var queueAddMessage = function(name, message) {
      messageQueue[name] = message;
    };


    // loop through messageCatalog and check if it is contained in messageStats.messages
    $.each(messageCatalog, function(name, message) {
      if((messageStats.last_visit < (Date.now() - message.time_interval * 1000) ) || (Number.isInteger(messageStats.visit_number / message.visit_interval))){
        // display a message
        queueAddMessage(name, message);
      }
    });


    // Clean up stored message info
    if(messageStats.messages) {
      $.each(messageStats.messages, function(messageName) {
        if(! messageCatalog[messageName]) { delete(messageStats.messages[messageName]) }
      });
    }

    messageStats.last_visit = Date.now();
    messageStats.visit_number++;

    localStorage.setItem('messageStats', JSON.stringify( messageStats ));


    // Add promo message to the control panel
    // This is an odd duck. Might want to consider setting this server-side
    $('#promo .swag-promo').html(stickerMsg);
    
    
    // Loop through queued messages and display them.
    // May need a refactor as I've only tested with a single message
    $.each(messageQueue, function(i, message) {      
      Messenger({ extraClasses: message.extraClasses }).post({ message: message.content });
    });
  }
})(jQuery);
