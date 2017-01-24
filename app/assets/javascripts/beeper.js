var littleBeep = function() {
  console.log('Beep?');
};

var bigBeep = function() {
  $('#beep-sound')[0].play();
  console.log('BEEP!');
  // $('#beep-sound').toggle();
};


// EXPERIMENTS WITH BUTTONS

// Function should return the isbn
var quagga_isbn = function() {
  // DO stuff
  // Ensure this file is accessible
  console.log('quagga');
  // Ensure the vendor/assets folder is accessible
  var beeping = new Beeping();
  // Set up configuration of Quagga and run the camera
  var quagga = Quagga.init({
    inputStream : {
      name : "Live",
      type : "LiveStream",
      target: document.querySelector('#libris-isbn')   // querySelector returns the first element matching the ()-content
    },
    decoder : {
      readers : ["code_128_reader"]
    }
  }, function(err) {
      if (err) {
        console.log('There was a problem with the initialization of Quagga:');
        console.log(err);
        return
      }
      console.log("Initialization finished. Ready to start");
      Quagga.start();
  });
    // @TODO LISTEN CALLBACK
    Quagga.onProcessed(onDecoded);
    // Quagga.onProcessed(onDecoded();); // Which one is it?
};

var quagga_stop = function() {
  Quagga.stop();
  console.log('Camera disengaged');
};

// This does not seem correct
var onDecoded = function() {
  console.log('Decoded!');
  Quagga.stop();
};


// This one does not work
$('#run-quagga-button').click(function() {
  // do stuff
  console.log('quagga quagga');
});
