(function($) {
  Messenger.options = {
    theme: 'block',
    messageDefaults: {
      hideAfter: 120,
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



  if($('body.about, body.thankyou').length < 1 ) {

    var stickerMsg = '<a href="http://devswag.com/products/sassmeister-stickers-4">\
  <h1>Swag Alert! </h1>\
  <p><img src="/images/sassmeister-detail-v02_medium.jpg"> ' + randomMsg() + '</p>\
</a>';


    // Add promo message to the control panel
    $('#promo .swag-promo').html(stickerMsg);


    // var stickerAlert = Messenger({ extraClasses: 'messenger-on-bottom swag-promo' }).post({ message: stickerMsg });





  }
})(jQuery);