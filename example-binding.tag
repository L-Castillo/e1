<example-binding>
    <!-- In JavaScript we'll define a property self.myText. Whenever that property changes,
         the contents of the <p> will be updated. Notice the curly braces!-->
    <p>{myText}</p>

    <!-- here we bind to two properties: self.someOtherText for the contents, a self.clicked
         for the function that will be triggered when the user clicks this paragraph element-->
    <p onclick="{clicked}">{someOtherText}</p>

    <button onclick="{btnClicked}">You have clicked me {buttonClicked} times</button>

    <!-- This will be updated by a timer -->
    <div>Seconds elapsed: {seconds}</div>
    <script>
        var self = this;//we do this always at the beginning of the script and then use properties through self...

        self.myText = "Just some text";
        self.someOtherText = "Some more text";
        self.seconds = 0;
        self.clicked = function(){
            //by updating this property we update the HTML content of the tag that binds to this property
            //this updating happens automatically after user interactions (e.g. click),
            // otherwise we need to call self.update() -- see below
            self.someOtherText = "When I'm clicked my text changes";
        };


        self.buttonClicked = 0;//how many times the user has clicked the button

        self.btnClicked = function(){
            self.buttonClicked++;
        };

        //we override the page's onShown function if we want something to happen when the page is shown
        self.onShown = function(){
            self.timer = setInterval(function(){
                self.seconds++;
                // the seconds property is not changed by a user action, therefore we need to explicitly
                // call the page's update function, to see the change reflected in HTML
                self.update();
            },1000);
        };

        //we override the page's onHidden function if we want something to happen when the page is hidden (navigate away)
        self.onHidden = function(){
            clearTimeout(self.timer);
        };

    </script>


</example-binding>