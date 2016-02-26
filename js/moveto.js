
// II : MoveTo Code
MoveTo = {
  defaults: {
    speed: 20 // More is slower
  },
  objs: [], // The variable objects to animate value of
  frames: [] // Functions to run each frame
};
MoveTo.add = function (obj){
  MoveTo.objs.push(obj);
}
MoveTo.addFrame = function (callback){
  MoveTo.frames.push(callback);
}
MoveTo.render = function (){
  // Each object to animate
  for (var key in MoveTo.objs) {
    if (MoveTo.objs.hasOwnProperty(key)) {
      // Current object
      var obj = MoveTo.objs[key],
          ran = 0; // How many times an variable has been changed this frame

      // All vars to animate in the curret object
      for (var key in obj['values']) {
        if (obj['values'].hasOwnProperty(key)) {
          // Current var
          var value = obj['values'][key],
              speed = value.speed || MoveTo.defaults.speed;
          
          // If not a small value, we can save power by rounding and not replaying if they are almost even
          if (!value.smallValue){
            if(value.current !== value.to){
              ran++;
              // Increment towards new value
              value.current += (value.to - value.current) / speed;

              // Even our the variable, so it doesnt go on forever
              var compareValue = value.current;
              if (value.to > value.current){
                compareValue = Math.ceil(value.current);
              } else if (value.to < value.current){
                compareValue = Math.floor(value.current);
              }

              // Round up if they are very close to each other
              if (Math.round(compareValue) === Math.round(value.to))
                value.current = value.to;
            }
          } else {
            // If it is set to small value, it will always keep on going
            ran++;
            // Increment towards new value
            value.current += (value.to - value.current) / speed;
          }
        }
      }

      // Run callback (for example to position an element based on variable)
      if (ran > 0 &&
          obj.frame)
        obj.frame();
    }
  }
  
  // Run all frame functions
  for (var i = 0; i < MoveTo.frames.length; i++){
    MoveTo.frames[i]();
  }
  
  // Rerender
  requestAnimFrame(MoveTo.render);
};
MoveTo.render();

// Helpers
$.fn.centerLeft = function() {
    return this.offset().left + this.outerWidth()/2;
};
$.fn.centerTop = function() {
    return this.offset().top + this.outerHeight()/2;
};
