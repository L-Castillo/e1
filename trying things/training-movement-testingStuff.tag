<training-movement-testingStuff>
    <style>
        div#instructions{
            font-size: 22px;
            padding: 20px;
        }
        .psychErrorMessage{ /*override style*/
            font-size: 23px;
            text-align: center;
        }
        button.psychButton:disabled {
            color: rgba(89, 159, 207, 0.5); /*Text transparent when button disabled*/
        }
    </style>
    <div id = "instructions">
        Please press "Play Animation" to watch how these objects interact.
        You can press it as many times you need to re-watch the clip.
        Make sure you understand how the objects interact before pressing "Next"
    </div>
    <br>
    <div style = "width: 950px; height: 400px; border: solid black 2px">
        <canvas width="950" height="200" style="" ref="myCanvas1"></canvas>
        <canvas width="950" height="200" style="" ref="myCanvas2"></canvas>
        <button class="psychButton" onclick="{animate}" style="float:right" ref="btnAnimate">Play animation</button>
        <p class="psychErrorMessage" show="{hasErrors}" style="margin: auto; text-align: center">{errorText}</p>
    </div>

    <script>
        function shuffleArray(array){
            for (let i = array.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [array[i], array[j]] = [array[j], array[i]];
            }
        }

        var self = this;

        self.possibleMoments = [4];
        self.timesWatched = [0];
        shuffleArray(self.possibleMoments);
        self.currentIndex = 0;
        self.currentMoment = self.possibleMoments[self.currentIndex];

        self.errorText;

        // define what a moving display is - common to all .tags (see inner starting comments for minor changes according to tag needs)
        self.MovingDisplay = function (colours, mirroring, launchTiming, extraObjs, squareDimensions, canvas, slider = null, speed, showFlash = false) {
            // What's different about this Moving Display?
            // endAnimation counts times watched
            // endAnimation enables the Play Animation button (the button disables itself upon press)
            var display = this;

            // def functions

            display.Square = function (colour, dimensions) {
                var sq = this;
                // colour
                sq.colourName = colour;
                switch (sq.colourName) {
                    case "red":
                        sq.colour = "#FF0000";
                        break;
                    case "green":
                        sq.colour = "#00FF00";
                        break;
                    case "blue":
                        sq.colour = "#0000FF";
                        break;
                    case "black":
                        sq.colour = "#000000";
                        break;
                    case "hidden":
                        sq.colour = "#FFFFFF";
                        break;
                    case "purple":
                        sq.colour = "#ec00f0";
                        break;
                }
                // geometry
                sq.dimensions = dimensions;
                sq.startPosition = [0, 0];
                sq.finalPosition = [0, 0];
                sq.moveAt = 0;
                sq.movedAt = -1; // the time it actually moved
                sq.position = [0, 0];
                sq.duration = 0;

                sq.animationTimer = 0;
                sq.pixelsPerStep = [0, 0];



                sq.draw = function (canvas, step) {
                    var myStep = Math.max(0, step - sq.moveAt);

                    if (myStep < sq.duration) {
                        sq.position[0] = sq.startPosition[0] + sq.pixelsPerStep[0] * myStep;
                        sq.position[1] = sq.startPosition[1] + sq.pixelsPerStep[1] * myStep;
                    } else {
                        sq.position[0] = sq.finalPosition[0];
                        sq.position[1] = sq.finalPosition[1];
                    }

                    sq.obedientDraw(canvas);


                    if (sq.movedAt === -1 && myStep > 0) {
                        sq.movedAt = step;
                    }
                };

                sq.obedientDraw = function (canvas) {
                    // draws sq in its position, without asking questions! useful sometimes
                    var ctx = canvas.getContext("2d");
                    ctx.fillStyle = sq.colour;
                    ctx.fillRect(sq.position[0], sq.position[1], sq.dimensions[0], sq.dimensions[1]);
                };


                sq.reset = function () {
                    sq.movedAt = -1;
                    sq.position = sq.startPosition.slice();
                    sq.pixelsPerStep = [(sq.finalPosition[0] - sq.startPosition[0]) / sq.duration,
                        (sq.finalPosition[1] - sq.startPosition[1]) / sq.duration];
                };

            };

            display.placeSquares = function () {
                for (var i = 0; i < 3; i++) {
                    var newSquare, squareColour;
                    squareColour = display.colours[i];
                    newSquare = new display.Square(squareColour, display.squareDimensions);
                    display.squareList.push(newSquare);
                }
                display.setUp();
            };

            display.setUp = function () {
                var canvasMargin = display.canvas.width / 4;

                for (var i = 0; i < 3; i++) {
                    // start/end positions
                    var square = display.squareList[i];
                    var startPosition, endPosition;
                    if (i === 0) {
                        startPosition = display.mirrored ? canvasMargin + 5 * display.squareDimensions[0] : canvasMargin;
                        endPosition = display.mirrored ? startPosition - 2.5 * display.squareDimensions[0] : canvasMargin + 2.5 *
                            display.squareDimensions[0];
                    } else {
                        var distanceTravelled = display.squareDimensions[0] + 2 * display.squareDimensions[0] * (i - 1);
                        startPosition = display.mirrored ?
                            display.squareList[0].finalPosition[0] - distanceTravelled : // if mirrored travel left from A
                            display.squareList[0].finalPosition[0] + distanceTravelled; // if not travel right
                        endPosition = display.mirrored ?
                            startPosition - display.squareDimensions[0] : // same idea
                            startPosition + display.squareDimensions[0];
                    }
                    square.startPosition = [startPosition, 100];
                    square.finalPosition = [endPosition, 100];

                    // duration
                    square.duration = Math.abs(endPosition - startPosition) / display.speed;
                    display.durations.push(square.duration);
                }
                display.draw();

                // give "move At" instructions
                if (display.launchTiming === "canonical") {
                    display.squareList[0].moveAt = 0;
                    display.squareList[1].moveAt = display.squareList[0].duration;
                    display.squareList[2].moveAt = display.squareList[1].moveAt + display.squareList[1].duration;
                } else {
                    display.squareList[0].moveAt = 0;
                    display.squareList[2].moveAt = display.squareList[0].duration;
                    display.squareList[1].moveAt = display.squareList[2].moveAt + display.squareList[2].duration;
                }
            };
            display.reset = function () {
                // reset squares to startPosition
                for (var i = 0; i < 3; i++) {
                    display.squareList[i].reset();
                }
                // reset other animation markers
                display.flashOnset = -1;
                display.animationStarted = Infinity;
                display.animationEnded = false;
            };

            display.startAnimation = function () {
                display.animationStarted = Date.now();
                window.requestAnimationFrame(display.draw.bind(display));
            };
            display.endAnimation = function () {
                display.animationEnded = Date.now();

                self.refs.btnAnimate.disabled = false;
                self.timesWatched[self.currentMoment]++
            };

            display.animate = function (startAt = 1000) {
                // stop timeouts
                for (var i = 0; i < display.animationTimer.length; i++) {
                    clearTimeout(display.animationTimer[i])
                }
                //
                // these two put everything back to start
                display.reset();
                display.draw();
                // and this starts the timing
                display.setTimeouts(startAt);
            };

            display.getLastFinish = function () {
                // get list of when each sq finishes moving
                var finishTimings = [];
                for (var i = 0; i < 3; i++) {
                    if (display.squareList[i].colourName !== "hidden") {
                        finishTimings.push((display.squareList[i].moveAt + display.squareList[i].duration));
                    }
                };
                // and what time is last
                return Math.max.apply(null, finishTimings);
            };

            display.setTimeouts = function (startInstructions = 1000) {
                var lastFinish = display.getLastFinish();
                var startAt = startInstructions; // some external callings may want no delay when starting (e.g. check training tags). 1000ms lets page load up
                var timeoutId;  //  start timeouts for start and end and add to a list (which allows to stop everything if animation restarted, see self.animate())
                timeoutId = setTimeout(display.startAnimation.bind(display), startAt);
                display.animationTimer.push(timeoutId);
                timeoutId = setTimeout(display.endAnimation.bind(display), startAt + lastFinish);
                display.animationTimer.push(timeoutId);
                // timings for flash
                if (display.showFlash) {
                    var animationSpace = lastFinish + 1000; // add 1000s so one can set flash 500ms after lastFinish
                    var flashTime =  startAt - 750 + animationSpace / 200 * display.slider.value; // if slider.value == 0 flash 750ms before red starts moving (250ms after animation start).
                    // 0 ----------------------- 250 --------------------- 1000 ---------------------------- lastFinish ---------------- lastFinish + 1000 -----> // time arrow (ms)
                    //(animationStart) --- (earliestPossibleFlash) ------(startAt: red starts moving) -----(lastSquare stops moving) --(last possible Flash) --->
                    timeoutId = setTimeout(display.displayFlash.bind(display), flashTime);
                    display.animationTimer.push(timeoutId);
                    timeoutId = setTimeout(display.displayFlash.bind(display), flashTime + 25); // this makes the flash 25ms long
                    display.animationTimer.push(timeoutId);
                }
            };
            display.draw = function () {
                // empty canvas
                var ctx = display.canvas.getContext("2d");
                ctx.clearRect(0, 0, display.canvas.width, display.canvas.height);

                // draw squares
                var step = Date.now() - display.animationStarted;
                for (var i = 0; i < display.squareList.length; i++) {
                    display.squareList[i].draw(display.canvas, step);
                }

                // draw the hole for middle third of the B square
                if (display.squareList[1].colourName !== "hidden") {
                    ctx.fillStyle = display.holeColour;
                    ctx.fillRect(
                        display.squareList[1].position[0],
                        display.squareList[1].position[1] + 1 / 3 * display.squareList[1].dimensions[1],
                        display.squareList[1].dimensions[0],
                        1 / 3 * display.squareList[1].dimensions[1]
                    );
                }

                if (display.extraObjs) {
                    display.drawExtraObjects()
                }

                if (display.myPause === true) {
                    display.drawPause();
                } else if (display.myPause === false) {
                    display.drawPlay();
                }

                if (!display.animationEnded) {
                    window.requestAnimationFrame(display.draw.bind(display));
                }
            };

            display.drawExtraObjects = function () {
                var ctx = display.canvas.getContext('2d');
                // some vars to make more legible
                var squareA = display.squareList[0];
                var squareB = display.squareList[1];
                var squareC = display.squareList[2];

                // stick
                if (display.squareList[0].colourName !== "hidden") {
                    var stickSize = squareA.dimensions[0] * 2;

                    var startX, endX;
                    if (display.mirrored) {
                        startX = squareA.position[0];
                        endX = startX - stickSize;
                    } else {
                        startX = squareA.position[0] + squareA.dimensions[0];
                        endX = startX + stickSize;
                    }

                    // horizontal line
                    ctx.beginPath();
                    ctx.moveTo(startX, squareA.position[1] + 0.5 * squareA.dimensions[1]);
                    ctx.lineTo(endX,squareA.position[1] + 0.5 * squareA.dimensions[1]);
                    ctx.stroke();
                    // vertical line
                    ctx.beginPath();
                    ctx.moveTo(endX, squareA.position[1] + 0.5 * squareA.dimensions[1] - 5);
                    ctx.lineTo(endX, squareA.position[1] + 0.5 * squareA.dimensions[1] + 5);
                    ctx.stroke();
                }

                // draw chain
                if (display.squareList[1].colourName !== "hidden" && display.squareList[2].colourName !== "hidden") {
                    var squareBMiddleX, squareBY, squareCMiddleX, squareBY;
                    squareBMiddleX = squareB.position[0] + squareB.dimensions[0] * 1 / 2;
                    squareCMiddleX = squareC.position[0] + squareC.dimensions[0] * 1 / 2;
                    squareBY = squareB.position[1] + squareB.dimensions[1] * 9 / 10;
                    squareBY = squareC.position[1] + squareC.dimensions[1] * 9 / 10;

                    var distanceBetweenSquares, squareMiddlePoint;
                    distanceBetweenSquares = Math.abs(squareBMiddleX - squareCMiddleX);
                    squareMiddlePoint = display.mirrored ?
                        distanceBetweenSquares / 2 + squareCMiddleX :
                        distanceBetweenSquares / 2 + squareBMiddleX;

                    var controlPointY = squareB.position[1] + squareB.dimensions[1] + 120 - 0.75 * distanceBetweenSquares;

                    // chain is Q bezier curve defined by points (squareBMiddleX, squareBY), (squareMiddlePoint, controlPointY) and (squareCMiddleX, squareBY)
                    ctx.beginPath();
                    ctx.moveTo(squareBMiddleX, squareBY);
                    ctx.quadraticCurveTo(squareMiddlePoint, controlPointY, squareCMiddleX, squareBY);
                    ctx.stroke();
                }
            };
            display.displayFlash = function () {
                if (display.showFlash === true) {
                    if (display.flashState === false) {
                        display.flashOnset = Date.now();
                        display.canvas.style.backgroundColor = "black";
                        display.flashState = true;

                        // make squares black if they are hidden
                        for (var i = 0; i < display.squareList.length; i++) {
                            if (display.squareList[i].colourName === "hidden") {
                                display.squareList[i].colour = "#000000";
                                display.squareList[i].obedientDraw(display.canvas);
                            }
                        }
                    } else {
                        display.canvas.style.backgroundColor = "white";
                        display.flashState = false;
                        // make squares white again if they are hidden
                        for (var i = 0; i < display.squareList.length; i++) {
                            if (display.squareList[i].colourName === "hidden") {
                                display.squareList[i].colour = "#FFFFFF";
                                display.squareList[i].obedientDraw(display.canvas);
                            }
                        }
                    }
                    display.draw(); // avoids funky lines if animation has ended
                }
            };

            display.drawPlay = function () {
                var ctx = display.canvas.getContext('2d');
                ctx.beginPath();
                ctx.moveTo(50, 100);
                ctx.lineTo(50, 150);
                ctx.lineTo(75, 125);
                ctx.fillStyle = "#166629";
                ctx.fill();
            };

            display.drawPause = function () {
                var ctx = display.canvas.getContext('2d');
                ctx.beginPath();
                ctx.moveTo(50, 100);
                ctx.lineTo(50, 150);
                ctx.lineTo(60, 150);
                ctx.lineTo(60, 100);
                ctx.fillStyle = "#166629";
                ctx.fill();

                ctx.beginPath();
                ctx.moveTo(70, 100);
                ctx.lineTo(70, 150);
                ctx.lineTo(80, 150);
                ctx.lineTo(80, 100);
                ctx.fillStyle = "#166629";
                ctx.fill();

            };

            display.pauseChange = function (newState) {
                display.myPause = newState;
            };

            // initialize attributes
            display.colours = colours; // expressed in ABC order
            display.mirrored = mirroring;
            display.launchTiming = launchTiming;
            display.extraObjs = extraObjs;
            display.squareDimensions = squareDimensions;
            display.canvas = canvas;
            display.slider = slider;
            display.speed = speed;
            display.showFlash = showFlash;

            display.holeColour = "#d9d2a6";
            display.pauseColour = "#408040";
            display.animationStarted = Infinity;
            display.animationEnded = true;
            display.flashState = false; // is the canvas flashing at the moment?
            display.myPause = undefined;
            display.animationTimer = []; // holds all the timeout ids so cancelling is easy
            display.durations = [];
            display.squareList = [];
            display.flashOnset = -1; // time when flash starts

            display.placeSquares();
            display.reset();
        };


        // overwrite funcs
        self.canLeave = function () {
            if (self.rectangle.animationStarted === Infinity) {
                self.hasErrors = true;
                self.errorText = "Please watch the animation";
                return false;
            } else if (!self.rectangle.animationEnded) {
                self.hasErrors = true;
                self.errorText = "Please finish the animation before continuing";
                return false;
            } else {
                self.currentIndex++;
                if (self.currentIndex < 5){
                    self.currentMoment = self.possibleMoments[self.currentIndex];
                    self.hasErrors = false;
                    delete self.rectangle;
                    self.updateCanvas();
                    return false;
                } else {
                    return true;
                }
            }
        };

        self.onInit = function () {
            self.mirroring = self.experiment.condition.factors.mirroring;
            self.updateCanvas();
        };

        self.results = function () {
            return {"presentationOrder": self.possibleMoments, "watchTimes": self.timesWatched};
            // presentationOrder = 2031 -> first watched moment 2, then moment 0, then moment 3, then moment 1 (see updateCanvas for what each moment is)
            // watchTimes = 2413 -> moment 0 was watched twice, moment 1 watched 4 times, and so on.
        };

        // page specific functions
        self.animate = function () {
            self.refs.btnAnimate.disabled = true;
            self.hasErrors = false;
            self.rectangle.animate(500);
            self.rectangle.pauseChange(false);
            window.setTimeout(self.rectangle.pauseChange.bind(self.rectangle, true), self.rectangle.getLastFinish() + 400);
            if (self.rectangle2) {
                self.rectangle2.animate(500);
            }

        };


        self.updateCanvas = function () {
            if (self.currentMoment === 0) {
                self.rectangle = new self.MovingDisplay(["red", "hidden", "purple"], self.mirroring, "reversed", true, [50, 50], self.refs.myCanvas1, null, 0.3, false);
            } else if (self.currentMoment === 1) {
                self.rectangle = new self.MovingDisplay(["hidden", "blue", "purple"], self.mirroring, "reversed", true, [50, 50], self.refs.myCanvas1, null, 0.3, false);
            } else if (self.currentMoment === 2) {
                self.rectangle = new self.MovingDisplay(["red", "blue", "hidden"], self.mirroring, "canonical", false, [50, 50], self.refs.myCanvas1, null, 0.3, false);
            } else if (self.currentMoment === 3) {
                self.rectangle = new self.MovingDisplay(["hidden", "blue", "purple"], self.mirroring, "canonical", false, [50, 50], self.refs.myCanvas1, null, 0.3, false);
            } else if (self.currentMoment === 4) {
                // self.rectangle = new self.MovingDisplay(["red", "blue", "hidden"], self.mirroring, "reversed", true, [50, 50], self.refs.myCanvas1, null, 0.3, false);
                // self.rectangle.squareList[1].finalPosition = self.rectangle.squareList[1].startPosition;
                // if (self.mirroring) {
                //     self.rectangle.squareList[0].finalPosition[0] = self.rectangle.squareList[0].finalPosition[0] - 100;
                // } else {
                //     self.rectangle.squareList[0].finalPosition[0] = self.rectangle.squareList[0].finalPosition[0] + 100;
                // }
                //
                // self.rectangle.squareList[0].duration = Math.abs(self.rectangle.squareList[0].finalPosition[0] - self.rectangle.squareList[0].startPosition[0]) / self.rectangle.speed;
                // self.rectangle.squareList[1].duration = Math.abs(self.rectangle.squareList[1].finalPosition[0] - self.rectangle.squareList[1].startPosition[0]) / self.rectangle.speed;
                // self.rectangle.squareList[0].colour = "#ffffff";
                // self.rectangle.reset();
                // self.rectangle.draw();

                self.rectangle = new self.MovingDisplay(["red", "blue", "hidden"], self.mirroring, "canonical", true, [50, 50], self.refs.myCanvas1, null, 0.3, false);
                console.log(self.rectangle.squareList[0].finalPosition[0] - self.rectangle.squareList[0].startPosition[0]);
                if (self.mirroring) {
                    self.rectangle.squareList[0].finalPosition[0] = self.rectangle.squareList[0].finalPosition[0] + 25;
                    self.rectangle.squareList[0].startPosition[0] = self.rectangle.squareList[0].startPosition[0] + 50;
                } else {
                    self.rectangle.squareList[0].finalPosition[0] = self.rectangle.squareList[0].finalPosition[0] - 25;
                    self.rectangle.squareList[0].startPosition[0] = self.rectangle.squareList[0].startPosition[0] - 50;
                }
                console.log(self.rectangle.squareList[0].finalPosition[0] - self.rectangle.squareList[0].startPosition[0]);

                self.rectangle.squareList[1].finalPosition = self.rectangle.squareList[1].startPosition;
                self.rectangle.squareList[0].duration = Math.abs(self.rectangle.squareList[0].finalPosition[0] - self.rectangle.squareList[0].startPosition[0]) / self.rectangle.speed;



                self.rectangle2 = new self.MovingDisplay(["red", "hidden", "purple"], self.mirroring, "canonical", true, [50, 50], self.refs.myCanvas2, null, 0.3, false);
                self.rectangle2.squareList[2].startPosition = self.rectangle2.squareList[1].startPosition;
                self.rectangle2.squareList[2].finalPosition = self.rectangle2.squareList[1].finalPosition;
                if (!self.mirroring) {
                    self.rectangle2.squareList[2].finalPosition[0] = self.rectangle2.squareList[2].finalPosition[0] + 100;
                } else {
                    self.rectangle2.squareList[2].finalPosition[0] = self.rectangle2.squareList[2].finalPosition[0] - 100;
                }

                if (self.mirroring) {
                    self.rectangle2.squareList[0].finalPosition[0] = self.rectangle2.squareList[0].startPosition[0] - 25;
                    self.rectangle2.squareList[0].startPosition[0] = self.rectangle2.squareList[0].startPosition[0] + 50;
                    self.rectangle2.squareList[2].finalPosition[0] = self.rectangle2.squareList[2].startPosition[0] - 75;
                } else {
                    self.rectangle2.squareList[0].finalPosition[0] = self.rectangle2.squareList[0].startPosition[0] + 25;
                    self.rectangle2.squareList[0].startPosition[0] = self.rectangle2.squareList[0].startPosition[0] - 50;
                    self.rectangle2.squareList[2].finalPosition[0] = self.rectangle2.squareList[2].startPosition[0] + 75;
                }
                self.rectangle2.squareList[0].duration = Math.abs(self.rectangle2.squareList[0].finalPosition[0] - self.rectangle2.squareList[0].startPosition[0]) / self.rectangle2.speed;
                self.rectangle2.squareList[2].duration = Math.abs(self.rectangle2.squareList[2].finalPosition[0] - self.rectangle2.squareList[2].startPosition[0]) / self.rectangle2.speed;
                console.log(self.rectangle2.squareList[2].finalPosition[0] - self.rectangle2.squareList[2].startPosition[0]);

                console.log(self.rectangle.squareList[0].duration);
                console.log(self.rectangle2.squareList[2].duration);
                self.rectangle2.squareList[2].moveAt = (75) / self.rectangle2.speed;
                self.rectangle.reset();
                self.rectangle.draw();
                self.rectangle2.reset();
                self.rectangle2.draw();
            }
        };





    </script>

</training-movement-testingStuff>
