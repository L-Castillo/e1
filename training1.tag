<training1>
    <div>
        <canvas id="myCanvas" width="1000" height="400" style="border: solid black 2px"></canvas>
    </div>
    <button onclick="nextMoment()">Next</button>
    <script src="classes.js"></script>
    <script>
        var myCanvas = document.getElementById("myCanvas");
        var moment = 0;
        window.myRectangle = new MovingDisplay(["red", "hidden", "purple"], false, ["reversed", 0, false, true], [50, 50], myCanvas, slider, 0.3, false);

        animateAgain();

        function animateAgain (){
            for (var i = 0; i < window.myRectangle.animationTimer.length; i++) {
                clearTimeout(window.myRectangle.animationTimer[i])
            }
            window.myRectangle.animationStarted = Infinity;
            window.myRectangle.animationEnded = false;
            window.myRectangle.resetSquares();
            window.myRectangle.draw();
            window.myRectangle.setTimeouts();
        }

        function nextMoment() {
            let animationsFinished = false;
            if (!window.myRectangle.animationEnded) {
                console.log("notEnded!");
            } else {
                moment++;
                delete window.myRectangle;
                if (moment === 1) {
                    window.myRectangle = new MovingDisplay(["hidden", "blue", "purple"], false, ["reversed", 0, false, true], [50, 50], myCanvas, null, 0.3, false);
                } else if (moment === 1) {
                    window.myRectangle = new MovingDisplay(["red", "blue", "hidden"], false, ["canonical", 0, false, false], [50, 50], myCanvas, null, 0.3, false);
                } else if (moment === 2) {
                    window.myRectangle = new MovingDisplay(["hidden", "blue", "purple"], false, ["canonical", 0, false, false], [50, 50], myCanvas, null, 0.3, false);
                } else if (moment === 3){
                    window.myRectangle = new MovingDisplay(["red", "blue", "hidden"], false, ["canonical", 0, false, true], [50, 50], myCanvas, null, 0.3, false);
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
