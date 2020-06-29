<checking-training2>
    <style>
        button.psychButton:disabled {
            color: rgba(89, 159, 207, 0.5); /*Text transparent when button disabled*/
        }
        div#instructions{
            font-size: 22px;
            padding: 20px;
        }
        p#question {
            font-size: 22px;
            margin: 10px;
        }
        label {
            font-size: 20px;
            padding-bottom: 5px;
            margin: 5px;
        }
        input {
            margin: 5px;
        }
        .psychErrorMessage{ /*override style*/
            font-size: 23px;
            text-align: center;
        }

    </style>
    <div id = "instructions">{instructionText}</div>
    <br>
    <div style="width: 950px">
        <canvas width="950" height="400" style="border: solid black 2px" ref="myCanvas"></canvas> </div>
    <div>
        <button class="psychButton" onclick="{manageMoments}" style="float:right;" ref="btnAnimate">Check Answer</button> </div>
    <div style="width: 450px; margin: auto">
        <form ref = "radioCont">
            <p id = "question" ref="radioQuestions">{"In this animation, " + firstMovers[currentMoment] + " will start moving. What will happen next?"}</p>
            <input type="radio" id="radioA" name="1. What will happen next?" onclick="{enableActivateButton}" value="A" ref="radioA">
            <label for="radioA" id="labelradioA">{questions[currentMoment][0]}</label>
            <br>
            <input type="radio" id="radioB" name="1. What will happen next?" onclick="{enableActivateButton}" value="B" ref="radioB">
            <label for="radioB" id="labelradioB">{questions[currentMoment][1]}</label>
            <br>
            <input type="radio" id="radioC" name="1. What will happen next?" onclick="{enableActivateButton}" value="C" ref="radioC">
            <label for="radioC" id="labelradioC">{questions[currentMoment][2]}</label>
            <br>
        </form>
        <p class="psychErrorMessage" show="{hasErrors}">{errorText}</p>

        <p style="font-size: 23px; color: green" show="{feedbackTime}">{feedbackText}</p>
        <button ref="errorWatchBtn" onclick="{watchAgain}" class="psychButton" style="display: none;margin-left: 165px;"> Watch Again</button>


    </div>
    <script>
        function shuffleArray(array){
            for (let i = array.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [array[i], array[j]] = [array[j], array[i]];
            }
        }

        var self = this;

        // shuffle questions
        self.possibleMoments = [0, 1, 2, 3, 4];
        self.instructionText = "Please select an answer to the following questions, then press \"Check Answer\" to check your answer:";
        // shuffleArray(self.possibleMoments);
        self.currentIndex = 0;
        self.currentMoment = self.possibleMoments[self.currentIndex];

        self.firstMovers = ["Pink", "Red", "Red", "Blue", "the stick"]; // changes question

        // shuffle MCQ possible answers
        self.moment0Qs = ["Pink and Blue will move at the same time", "Pink will move but Blue will not", "Pink will move and then drag Blue"];
        self.moment1Qs = ["Red will move and push Blue", "Red will move and Blue will not", "Red and Blue will move at the same time"];
        self.moment2Qs = ["Red will move and push Pink with the stick", "Red will move and Pink will not", "Red and Pink will move at the same time"];
        self.moment3Qs = ["Pink and Blue will move at the same time", "Blue will move but Pink will not", "Blue will move and push Pink"];
        self.moment4Qs = ["The stick will move and push Blue", "The stick will go through Blue", "The stick and Blue will move at the same time"];
        self.questionsStandardOrder = [self.moment0Qs, self.moment1Qs, self.moment2Qs, self.moment3Qs, self.moment4Qs];
        self.questions = [];
        for (var i = 0; i < self.questionsStandardOrder.length; i++) {
            var qArray = self.questionsStandardOrder[i].slice();
            shuffleArray(qArray);
            self.questions.push(qArray);
        }

        // define correct answers
        self.answers = ["Pink will move and then drag Blue", "Red will move and push Blue", "Red will move and push Pink with the stick", "Blue will move and push Pink", "The stick will go through Blue"];

        self.feedbackTime = false;
        self.lockNext = true;
        self.pageResults = {0:[], 1:[], 2:[], 3:[], 4:[], "presentationOrder": self.possibleMoments, "totalErrors": 0};
        self.errorText;
        self.feedbackText;
        self.hasToWatchAgain = false;


        self.MovingDisplay = function (colours, mirroring, launchTiming, extraObjs, squareDimensions, canvas, slider = null, speed, showFlash = false) {
            // What's different about this Moving Display?
            // nothing
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
            display.animationEnded = false;
            display.flashState = false; // is the canvas flashing at the moment?
            display.animationTimer = []; // holds all the timeout ids so cancelling is easy
            display.durations = [];
            display.squareList = [];
            display.flashOnset = -1; // time when flash starts

            display.placeSquares();
            display.reset();
        };

        // override functions
        self.canLeave = function () {
            if (self.lockNext) {
                if (self.hasToWatchAgain) {
                    return false;
                }
                if (!self.anyRadiosClicked()) {
                    self.errorText = "Please answer all the questions before proceeding";
                } else if(self.rectangle.animationStarted === Infinity) {
                    self.errorText = "Please press Check Answer before proceeding";
                }
                self.hasErrors = true;
                return false;
            } else {
                self.pageResults["totalErrors"] = self.getTotalErrors();
                return true;
            }
        };

        self.onInit = function () {
            self.mirroring = self.experiment.condition.factors.mirroring;
            self.radios = [self.refs.radioA, self.refs.radioB, self.refs.radioC];
            self.refs.btnAnimate.disabled = true;
            self.setUpNextQuestion();
        };

        self.results = function () {
            return self.pageResults;
            // 0 - 4: what participants answered in each of these moments. e.g. if 0: 23 -> participant chose answer in self.moment0Qs with index 2
            // and that was wrong so they then chose answer with index 3. Last item is correct item by definition
            // presentationOrder = 2031 -> first watched moment 2, then moment 0, then moment 3, then moment 1 (see setUpNextQuestion for what each moment is)

        };



        // page specific functions
        self.animate = function () {
            self.refs.btnAnimate.disabled = true;
            self.rectangle.animate(0); // startAt = 0, not 1000 like usual
        };

        self.enableActivateButton = function () {
            self.refs.btnAnimate.disabled = false;
            self.hideMessages();

        };
        self.setUpNextQuestion = function () {
            if (self.currentIndex !== 0) {
                delete self.rectangle;
            }
            if (self.currentIndex === 5) {
                self.moveOn();
            } else {
                self.currentMoment = self.possibleMoments[self.currentIndex];

                self.uncheckRadios();
                self.hideMessages();
                self.refs.btnAnimate.disabled = true;

                if (self.currentMoment === 0) {
                    self.rectangle = new self.MovingDisplay(["hidden", "blue", "purple"], self.mirroring, "reversed", true, [50, 50], self.refs.myCanvas, null, 0.3, false);
                } else if (self.currentMoment === 1) {
                    self.rectangle = new self.MovingDisplay(["red", "blue", "hidden"], self.mirroring, "canonical", false, [50, 50], self.refs.myCanvas, null, 0.3, false);
                } else if (self.currentMoment === 2) {
                    self.rectangle = new self.MovingDisplay(["red", "hidden", "purple"], self.mirroring, "reversed", true, [50, 50], self.refs.myCanvas, null, 0.3, false);
                } else if (self.currentMoment === 3) {
                    self.rectangle = new self.MovingDisplay(["hidden", "blue", "purple"], self.mirroring, "canonical", false, [50, 50], self.refs.myCanvas, null, 0.3, false);
                } else if (self.currentMoment === 4) {
                    self.rectangle = new self.MovingDisplay(["red", "blue", "hidden"], self.mirroring, "reversed", true, [50, 50], self.refs.myCanvas, null, 0.3, false);
                    self.rectangle.squareList[1].finalPosition = self.rectangle.squareList[1].startPosition;
                    if (self.mirroring) {
                        self.rectangle.squareList[0].finalPosition[0] = self.rectangle.squareList[0].finalPosition[0] - 100;
                    } else {
                        self.rectangle.squareList[0].finalPosition[0] = self.rectangle.squareList[0].finalPosition[0] + 100;
                    }

                    self.rectangle.squareList[0].duration = Math.abs(self.rectangle.squareList[0].finalPosition[0] - self.rectangle.squareList[0].startPosition[0]) / self.rectangle.speed;
                    self.rectangle.squareList[1].duration = Math.abs(self.rectangle.squareList[1].finalPosition[0] - self.rectangle.squareList[1].startPosition[0]) / self.rectangle.speed;
                    self.rectangle.squareList[0].colour = "#ffffff"; // if
                    self.rectangle.reset();
                    self.rectangle.draw();

                    // self.rectangle = new self.MovingDisplay(["red", "blue", "hidden"], self.mirroring, "canonical", true, [50, 50], self.refs.myCanvas, null, 0.3, false);
                    // if (self.mirroring) {
                    //     self.rectangle.squareList[1].finalPosition[0] = self.rectangle.squareList[1].finalPosition[0] - 20;
                    // } else {
                    //     self.rectangle.squareList[1].finalPosition[0] = self.rectangle.squareList[1].finalPosition[0] + 20;
                    // }
                    // self.rectangle.squareList[1].duration = Math.abs(self.rectangle.squareList[1].finalPosition[0] - self.rectangle.squareList[1].startPosition[0]) / self.rectangle.speed;
                    // self.rectangle.reset();
                }
                self.update(); // this is needed to update display of radios and hide feedback
            }
        };

        self.uncheckRadios = function () {
            for (var i = 0; i < self.radios.length; i++) {
                self.radios[i].checked = false;
            }
        };

        self.manageMoments = function () {
            var radioInfo = self.anyRadiosClicked(true);
            var somethingChecked = radioInfo[0];
            var whatChecked = radioInfo[1];
            if (!somethingChecked) {
                self.hasErrors = true;
                self.errorText = "Please choose an option";
                return false;
            } else {
                var answerGiven = self.questions[self.currentMoment][whatChecked]; // get text of what's been answered
                var indexAnswer = self.questionsStandardOrder[self.currentMoment].indexOf(answerGiven); // find text in standard order
                self.pageResults[self.currentMoment].push(indexAnswer); // add standard index to results
                self.feedbackTime = true;
                if (self.questions[self.currentMoment][whatChecked] === self.answers[self.currentMoment]) {
                    self.hasErrors = false;
                    self.feedbackText = "Well done!";
                    self.currentIndex++;
                    self.animate();
                    window.setTimeout(self.setUpNextQuestion, 1250);
                    window.setTimeout(self.enableActivateButton, 1250);
                } else {
                    self.hasErrors = false;
                    self.feedbackText = 'Not correct, sorry. Press the "Watch again" button to watch again. This will help you answer correctly next time.';
                    self.hasToWatchAgain = true;
                    self.uncheckRadios();
                    self.refs.radioCont.style.display = "none";
                    self.refs.errorWatchBtn.style.display = "inline";
                    self.refs.btnAnimate.disabled = true;
                }
            }
        };

        self.anyRadiosClicked = function (what=false) {
            var somethingClicked = false;
            var whatChecked;
            for (var i = 0; i < self.radios.length; i++) {
                if (self.radios[i].checked) {
                    somethingClicked = true;
                    whatChecked = i
                }
            }
            if (!what) {
                return somethingClicked
            } else {
                returnList = [somethingClicked, whatChecked];
                return returnList;

            }
        };

        self.hideMessages = function () {
            self.hasErrors = false;
            self.feedbackTime = false;
        };

        self.moveOn = function () {
            self.lockNext = false;
            self.finish();
        };

        self.getTotalErrors = function () {
            var errors = 0;
            for (var i = 0; i < 5; i++) { // i < 5 because there are 5 moments
                errors += self.pageResults[i].length - 1
            }
            return errors;
        };

        self.watchAgain = function () {
            self.rectangle.animate(0);
            self.refs.errorWatchBtn.style.display = "none";
            window.setTimeout(self.setUpRetry, self.rectangle.getLastFinish() + 500);
        };

        self.setUpRetry = function () {
            self.feedbackText = "You can try again now.";
            self.hasToWatchAgain = false;
            self.refs.radioCont.style.display = "inline";
            self.rectangle.reset();
            self.rectangle.draw();
            self.update();
        };

    </script>

</checking-training2>
