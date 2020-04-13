<training1>
    <div>
        <canvas id="myCanvas" width="1000" height="400" style="border: solid black 2px"></canvas>
    </div>
    <button onclick="nextMoment()">Next</button>
    <script src="classes.js"></script>
    <script>
        var self = this;
        self.myCanvas = document.getElementById("myCanvas");
        self.moment = 0;
        self.window.myRectangle = new MovingDisplay(["red", "hidden", "purple"], false, ["reversed", 0, false, true], [50, 50], self.myCanvas, slider, 0.3, false);

        animateAgain();

        function animateAgain (){
            for (var i = 0; i < self.window.myRectangle.animationTimer.length; i++) {
                clearTimeout(self.window.myRectangle.animationTimer[i])
            }
            self.window.myRectangle.animationStarted = Infinity;
            self.window.myRectangle.animationEnded = false;
            self.window.myRectangle.resetSquares();
            self.window.myRectangle.draw();
            self.window.myRectangle.setTimeouts();
        }

        function nextMoment() {
            let animationsFinished = false;
            if (!self.window.myRectangle.animationEnded) {
                console.log("notEnded!");
            } else {
                self.moment++;
                delete self.window.myRectangle;
                if (self.moment === 1) {
                    self.window.myRectangle = new MovingDisplay(["hidden", "blue", "purple"], false, ["reversed", 0, false, true], [50, 50], self.myCanvas, null, 0.3, false);
                } else if (self.moment === 1) {
                    self.window.myRectangle = new MovingDisplay(["red", "blue", "hidden"], false, ["canonical", 0, false, false], [50, 50], self.myCanvas, null, 0.3, false);
                } else if (self.moment === 2) {
                    self.window.myRectangle = new MovingDisplay(["hidden", "blue", "purple"], false, ["canonical", 0, false, false], [50, 50], self.myCanvas, null, 0.3, false);
                } else if (self.moment === 3){
                    self.window.myRectangle = new MovingDisplay(["red", "blue", "hidden"], false, ["canonical", 0, false, true], [50, 50], self.myCanvas, null, 0.3, false);
                } else {
                    animationsFinished = true;
                }
                if (!animationsFinished){
                    animateAgain();
                } else {
                    window.location.href = "trainingTest.html"; // go to next page
                }
            }
        }

    </script>

</training1>
