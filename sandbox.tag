<sandbox>
    <style>
        div#instructions{
            font-size: 22px;
            padding: 20px;
        }
        .psychErrorMessage{ /*override style*/
            font-size: 23px;
            text-align: center;
        }
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
        }
    </style>
    <div id = "instructions">
        SANDBOX <br>
    </div>
    <br>
    <div>
        <canvas width="950" height="400" style="border: solid black 2px" ref="myCanvas"></canvas>
    </div>
    <button class="psychButton" ref="animateBtn" onclick="{animate}"> Animate </button>

    <p class="psychErrorMessage" show="{hasErrors}">{errorText}</p>
    <table style="width: 60%; height: 50px; margin: auto">
        <tr>
            <th>Red</th>
            <th colspan="2">Blue and Pink</th>
        </tr>
        <tr>
            <td><button onclick="{respondBtn.bind(event)}">Red</button></td>
            <td><button onclick="{respondBtn.bind(event)}">Blue</button></td>
            <td><button onclick="{respondBtn.bind(event)}">Pink</button></td>
        </tr>
        <tr>
            <td><button onclick="{respondBtn.bind(event)}">Red with Stick</button></td>
            <td colspan="2"><button onclick="{respondBtn.bind(event)}">Blue and Pink (with chain)</button></td>
        </tr>

    </table>



    <script>
        var self = this;

        self.hasErrors = false;
        self.resultDict = {};
        self.redState = "";
        self.bluePinkState = "";


        // test vars that can be changed
        self.colours = ["red", "blue", "purple"];
        self.squareDimensions = [50, 50];
        self.speed = 0.3;
        self.showFlash = true;


        // define what a moving display is - common to all .tags (see inner starting comments for minor changes according to tag needs)
        self.MovingDisplay = function (colours, mirroring, launchTiming, extraObjs, squareDimensions, canvas, slider = null, speed, showFlash = false) {
            // What's different about this Moving Display?
            // extraObjs is an array (stick and chain)
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
                    if (sq.colourName !== "hidden") {
                        ctx.fillStyle = sq.colour;
                        ctx.fillRect(sq.position[0], sq.position[1], sq.dimensions[0], sq.dimensions[1]);

                    }
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
            display.setTimeouts = function (startInstructions = 1000) {
                // get list of when each sq finishes moving
                var finishTimings = display.squareList.map(function (obj) {
                    return obj.moveAt + obj.duration
                });
                var lastFinish = Math.max.apply(null, finishTimings); // and what time is last
                var startAt = startInstructions; // some external callings may want no delay when starting (e.g. check training tags). 1000ms lets page load up
                var timeoutId;  //  start timeouts for start and end and add to a list (which allows to stop everything if animation restarted, see self.animate())
                timeoutId = setTimeout(display.startAnimation.bind(display), startAt);
                display.animationTimer.push(timeoutId);
                timeoutId = setTimeout(display.endAnimation.bind(display), startAt + lastFinish);
                display.animationTimer.push(timeoutId);
                // timings for flash
                if (display.showFlash) {
                    var animationSpace = lastFinish + 1000; // add 1000s so one can set flash after lastFinish
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
                if (display.squareList[0].colourName !== "hidden" && display.stick) {
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
                if (display.squareList[1].colourName !== "hidden" && display.squareList[2].colourName !== "hidden" && display.chain) {
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


            // initialize attributes
            display.colours = colours; // expressed in ABC order
            display.mirrored = mirroring;
            display.launchTiming = launchTiming;
            display.extraObjs = extraObjs;
            if (display.extraObjs) {
                display.stick = display.extraObjs[0];
                display.chain = display.extraObjs[1];
            }
            display.squareDimensions = squareDimensions;
            display.canvas = canvas;
            display.slider = slider;
            display.speed = speed;
            display.showFlash = showFlash;

            display.holeColour = "#d9d2a6";
            display.animationStarted = Infinity;
            display.animationEnded = true;
            display.flashState = false; // is the canvas flashing at the moment?
            display.animationTimer = []; // holds all the timeout ids so cancelling is easy
            display.durations = [];
            display.squareList = [];
            display.flashOnset = -1; // time when flash starts

            display.placeSquares();
            display.reset();
        };

        // overwrite funcs
        self.onInit = function () {
            // get condition info + mirroring
            self.mirroring = self.experiment.condition.factors.mirroring;
            self.launchTiming = self.experiment.condition.factors.order;
            self.extraObjs = (self.experiment.condition.factors.altExplanation === "present");



        };

        self.onShown = function () {
        };

        self.canLeave = function () {

        };

        self.results = function () {

        };

        // page-specific funcs
        self.respondBtn = function (ev) {
            if (ev.target.innerText.search("Red") !== -1) {
                if (self.redState === ev.target.innerText) {
                    self.redState = "";
                } else {
                    self.redState = ev.target.innerText;
                }
            } else if (ev.target.innerText.search("chain") !== -1) {
                if (self.bluePinkState === "chain") {
                    self.bluePinkState = "";
                } else {
                    self.bluePinkState = "chain";
                }
            } else if (ev.target.innerText.search("Blue") !== -1) {
                if (self.bluePinkState === "chain" || self.bluePinkState === "both") {
                    self.bluePinkState = "pink";
                } else if (self.bluePinkState === "blue") {
                    self.bluePinkState = "";
                } else if (self.bluePinkState === "pink") {
                    self.bluePinkState = "both";
                } else {
                    self.bluePinkState = "blue";
                }
            } else {
                if (self.bluePinkState === "chain" || self.bluePinkState === "both") {
                    self.bluePinkState = "blue";
                } else if (self.bluePinkState === "pink") {
                    self.bluePinkState = "";
                } else if (self.bluePinkState === "blue") {
                    self.bluePinkState = "both";
                } else {
                    self.bluePinkState = "pink";
                }
            }
            self.updateRectangle();
        };

        self.updateRectangle = function () {
            self.refs.myCanvas.getContext("2d").clearRect(0, 0, self.refs.myCanvas.width, self.refs.myCanvas.height);
            if (self.rectangle) {
                delete self.rectangle;
            }
            var ASq, BSq, CSq, stick, chain;
            if (self.redState === "Red") {
                ASq = "red";
                stick = false;
            } else if (self.redState === "Red with Stick") {
                ASq = "red";
                stick = true;
            } else {
                ASq = "hidden";
                stick = false;
            }
            if (self.bluePinkState === "chain") {
                BSq = "blue";
                CSq = "purple";
                chain = true;
            } else if (self.bluePinkState === "both") {
                BSq = "blue";
                CSq = "purple";
                chain = false;
            } else if (self.bluePinkState === "blue") {
                BSq = "blue";
                CSq = "hidden";
                chain = false;
            } else if (self.bluePinkState === "pink") {
                BSq = "hidden";
                CSq = "purple";
                chain = false;
            } else {
                BSq = "hidden";
                CSq = "hidden";
                chain = false;
            }
            var colours = [ASq, BSq, CSq];
            var objs = (stick || chain) ? [stick, chain] : false;
            self.rectangle = new self.MovingDisplay(colours, self.mirroring, "canonical", objs, self.squareDimensions, self.refs.myCanvas, null, self.speed, null);
            self.update();
            // self.rectangle.draw();
            self.determineTimings(colours, objs)
        };

        self.determineTimings = function (cols, objs) {
            var sqBools = cols.map(function (col) {
                return (col !== "hidden");
            });
            if (sqBools[0] && objs[0]) {
                if (objs[1] || (objs[0] && cols[2] && !cols[1])) {
                    self.rectangle.launchTiming = "reversed";
                    self.rectangle.setUp();
                } else if (sqBools[1] && sqBools[2]) {
                    self.rectangle.squareList[2].moveAt = self.rectangle.squareList[1].moveAt;
                }
            } else if (sqBools[0]) {
                if (sqBools[2] && !sqBools[1]) {
                    self.rectangle.squareList[0].finalPosition = self.rectangle.squareList[1].finalPosition;
                    self.rectangle.squareList[0].duration = Math.abs(self.rectangle.squareList[0].finalPosition[0] - self.rectangle.squareList[0].startPosition[0]) / self.rectangle.speed;
                    self.rectangle.squareList[2].moveAt = self.rectangle.squareList[0].moveAt + self.rectangle.squareList[0].duration;

                    self.rectangle.reset();
                }
            } else {
                if (objs[1]) {
                    self.rectangle.launchTiming = "reversed";
                    self.rectangle.setUp();
                }
            }
        };

        self.animate = function () {
            self.rectangle.animate();
            self.switchBtn();
            window.setTimeout(self.switchBtn, 2000);
        };

        self.switchBtn = function () {
            if (self.refs.animateBtn.disabled) {
                self.refs.animateBtn.disabled = false;
            } else {
                self.refs.animateBtn.disabled = true;
            }
        };
    </script>
</sandbox>