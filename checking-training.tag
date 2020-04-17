<checking-training>
    <div style="font-size: large; padding: 20px">
        Please select an answer to the following questions:
    </div>
    <br>
    <div>
        <canvas width="950" height="400" style="border: solid black 2px" ref="myCanvas"></canvas>
        <p>What will happen next?<br>
            <input type="radio" id="radioA" name="1. What will happen next?" value="A" ref="radioA">
            <label for="radioA" id="labelradioA">{questions[currentMoment][0]}</label>
            <br>
            <input type="radio" id="radioB" name="1. What will happen next?" value="B" ref="radioB">
            <label for="radioB" id="labelradioB">{questions[currentMoment][1]}</label>
            <br>
            <input type="radio" id="radioC" name="1. What will happen next?" value="C" ref="radioC">
            <label for="radioC" id="labelradioC">{questions[currentMoment][2]}</label>
            <br>
            <input type="radio" id="radioD" name="1. What will happen next?" value="D" ref="radioD">
            <label for="radioD" id="labelradioD">{questions[currentMoment][3]}</label>
            <br>

        </p>
        <p class="psychErrorMessage" show="{hasErrors}">{errorText}</p>
        <p show="{feedbackTime}">{feedbackText}</p>

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
        self.possibleMoments = [0, 1, 2, 3];
        shuffleArray(self.possibleMoments);
        self.currentIndex = 0;
        self.currentMoment = self.possibleMoments[self.currentIndex];

        // shuffle MCQ possible answers
        self.moment0Qs = ["Blue will move and push Pink", "Blue will move but Pink will not", "Pink will move but Blue will not", "Pink will move and drag Blue"];
        self.moment1Qs = ["Red will move and push Blue", "Red will move and Blue will not", "Blue will move but Red will not", "Blue will move and drag Blue"];
        self.moment2Qs = ["Red will move and push Pink", "Red will move and Pink will not", "Pink will move but Red will not", "Pink will move and drag Red"];
        self.moment3Qs = self.moment0Qs.slice();
        self.questions = [self.moment0Qs, self.moment1Qs, self.moment2Qs, self.moment3Qs];
        for (var i = 0; i < self.questions.length; i++) {
            shuffleArray(self.questions[i])
        }
        // define correct answers
        self.answers = ["Pink will move and drag Blue", "Red will move and push Blue", "Red will move and push Pink", "Blue will move and push Pink"];

        self.feedbackTime = false;
        self.lockNext = false;
        self.pageResults = {0:[], 1:[], 2:[], 3:[]};
        self.errorText;
        self.feedbackText;
        // define what a moving display is - common to many .tags
        self.MovingDisplay = function (colours, mirroring, launchingType, stickAndHole, squareDimensions, canvas, slider=null, speed, facesBool) {
            // What's different about this Moving Display?
            // - finishing an animation leads to setUpNext (display.endAnimation)
            // - animating locks next Button (display.startAnimation and display.endAnimation)
            // def functions
            var display = this;

            display.Square = function (name, colour, dimensions, face) {
                var sq = this;
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
                sq.name = name;
                sq.dimensions = dimensions;
                sq.startPosition = [0, 0];
                sq.finalPosition = [0, 0];
                sq.moveAt = 0;
                sq.movedAt = -1; //the time it actually moved
                sq.position = [0, 0];
                sq.duration = 200;

                sq.animationTimer = 0;
                sq.pixelsPerStep = [0, 0];

                sq.hasFace = face;
                if (sq.hasFace !== false) {
                    sq.facePic = new Image();
                    switch (sq.hasFace) {
                        case "angry":
                            sq.facePic.src = "Angry.png";
                            break;
                        case "love":
                            sq.facePic.src = "Love.png";
                            break;
                        case "loveR":
                            sq.facePic.src = "LoveR.png";
                            break;
                        case "surprise":
                            sq.facePic.src = "Surprise.png";
                            break;
                    }
                }


                sq.draw = function (canvas, step) {
                    // var canvas = document.getElementById("MyCanvas");
                    var myStep = Math.max(0, step - sq.moveAt);

                    if (myStep < sq.duration) {
                        sq.position[0] = sq.startPosition[0] + sq.pixelsPerStep[0] * myStep;
                        sq.position[1] = sq.startPosition[1] + sq.pixelsPerStep[1] * myStep;
                    } else {
                        sq.position[0] = sq.finalPosition[0];
                        sq.position[1] = sq.finalPosition[1];
                    }

                    sq.drawMe(canvas);


                    if (sq.movedAt === -1 && myStep > 0) {
                        sq.movedAt = step;
                        // console.log(sq.name + ' moved at ' + sq.movedAt);
                    }
                };

                sq.drawMe = function (canvas) {
                    var ctx = canvas.getContext("2d");
                    ctx.fillStyle = sq.colour;
                    ctx.fillRect(sq.position[0], sq.position[1], sq.dimensions[0], sq.dimensions[1]);

                    if (sq.hasFace !== false && sq.colourName !== "hidden") {
                        ctx.drawImage(sq.facePic, sq.position[0], sq.position[1], sq.dimensions[0], sq.dimensions[1])
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
                    var squareColour = (display.hideA && i === 0) ? "hidden" : display.colours[i];
                    var face, newSquare;
                    if (display.faces === true) {
                        face = display.mirrored ? display.faceNamesR[i] : display.faceNames[i];
                        newSquare = new display.Square(display.squareNames[i], squareColour, display.squareDimensions, face);
                    } else {
                        newSquare = new display.Square(display.squareNames[i], squareColour, display.squareDimensions, display.faces);
                    }
                    display.squareList.push(newSquare);
                }
                if (display.hideA === true) {
                    display.squareList[0].colourName = "hidden";
                }
                display.setUp();
            };
            display.setUp = function () {
                var canvasMargin = display.canvas.width / 4;
                // give start/end positions
                for (var i = 0; i < 3; i++) {
                    var square = display.squareList[i];
                    var startPosition, endPosition;
                    if (i === 0) {
                        startPosition = display.mirrored ? canvasMargin + 5 * display.squareDimensions[0] : canvasMargin;
                        endPosition = display.mirrored ? startPosition - 2.5 * display.squareDimensions[0] : canvasMargin + 2.5 *
                            display.squareDimensions[0];
                    } else {
                        startPosition = display.mirrored ? display.squareList[0].finalPosition[0] - display.squareDimensions[0] - 2 *
                            display.squareDimensions[0] * (i - 1) : display.squareList[0].finalPosition[0] + display.squareDimensions[0] +
                            2 * display.squareDimensions[0] * (i - 1);
                        endPosition = display.mirrored ? startPosition - display.squareDimensions[0] : startPosition +
                            display.squareDimensions[0];
                    }
                    square.startPosition = [startPosition, 100];
                    square.finalPosition = [endPosition, 100];
                    var duration = (endPosition - startPosition) / display.speed; //(pix p step)
                    duration = display.mirrored ? duration * -1 : duration;
                    square.duration = duration;
                    display.durations.push(duration);

                    display.draw();
                }

                // give "move At" instructions
                if (display.launchingType === "canonical") {
                    display.squareList[0].moveAt = 0;
                    display.squareList[1].moveAt = display.squareList[0].duration;
                    display.squareList[2].moveAt = display.squareList[1].moveAt + display.squareList[1].duration;
                } else {
                    display.squareList[0].moveAt = 0;
                    display.squareList[2].moveAt = display.squareList[0].duration;
                    display.squareList[1].moveAt = display.squareList[2].moveAt + display.squareList[2].duration;
                }
            };
            display.animateAgain = function () {
                for (var i = 0; i < display.animationTimer.length; i++) {
                    clearTimeout(display.animationTimer[i])
                }
                display.animationStarted = Infinity;
                display.animationEnded = false;
                display.resetSquares();
                display.draw();
                display.setTimeouts();
            };
            display.resetSquares = function () {
                for (var i = 0; i < 3; i++) {
                    display.squareList[i].reset();
                }
            };
            display.startAnimation = function () {
                self.lockNext = true;
                display.animationStarted = Date.now();
                window.requestAnimationFrame(display.draw.bind(display));
            };
            display.endAnimation = function () {
                self.lockNext = false;
                display.animationEnded = Date.now();
                self.setUpNextQuestion();
                /*if(display.opts.test) {
                display.showQuestion = true;
                display.nextVisible = true;
                display.experiment.update();//will show button
                }
                else{
                display.finish();
                }*/
            };
            display.setTimeouts = function (startInstructions = null) {

                // display.mirrored = display.opts.mirrored;
                //
                // display.colour = display.opts.colours[2];
                // display.textStyle = {color:display.colour,'font-weight': 'bold'};
                //
                // display.canvas = display.refs.canvas;
                //
                //
                // display.setup();
                // display.experiment.screenShot = display.canvas.toDataURL();
                // var finishTimings = display.objects.map(function(obj){return obj.moveAt+ obj.duration});
                var finishTimings = display.squareList.map(function (obj) {
                    return obj.moveAt + obj.duration
                });
                var lastFinish = Math.max.apply(null, finishTimings);
                var startAt;
                if (startInstructions === null) {
                    startAt = 1000;
                } else {
                    startAt = startInstructions;
                }
                var timeoutId;
                timeoutId = setTimeout(display.startAnimation.bind(display), startAt);
                display.animationTimer.push(timeoutId);
                timeoutId = setTimeout(display.endAnimation.bind(display), startAt + lastFinish + 500);
                display.animationTimer.push(timeoutId);
                var animationSpace = lastFinish + 500;
                if (display.showFlash) {
                    var flashTime = animationSpace / 200 * display.slider.value + 750;
                    timeoutId = setTimeout(display.flashOn.bind(display), flashTime);
                    display.animationTimer.push(timeoutId);
                    timeoutId = setTimeout(display.flashOn.bind(display), flashTime + 25);
                    display.animationTimer.push(timeoutId);
                }
                return lastFinish;
            };
            display.draw = function () {
                if (!display.animationEnded) {
                    display.canvas.getContext('2d').clearRect(0, 0, display.canvas.width, display.canvas.height);
                    var step = Date.now() - display.animationStarted;

                    for (var i = 0; i < display.squareList.length; i++) {
                        display.squareList[i].draw(display.canvas, step);
                    }
                    // draw the whole for middle
                    if (display.squareList[1].colourName !== "hidden") {
                        let ctx = display.canvas.getContext("2d");
                        ctx.fillStyle = display.holeColour;
                        ctx.fillRect(display.squareList[1].position[0], display.squareList[1].position[1] + 1 / 3 *
                            display.squareList[1].dimensions[1], display.squareList[1].dimensions[0], 1 / 3 * display.squareList[1].dimensions[1]);
                    }

                    if (display.stickAndHole) {
                        display.drawObjects()
                    }
                    window.requestAnimationFrame(display.draw.bind(display));
                }
            };
            display.drawObjects = function () {
                var ctx = display.canvas.getContext('2d');
                var squareA = display.squareList[0];
                var squareB = display.squareList[1];
                var squareC = display.squareList[2];
                var stickSize = squareA.dimensions[0] * 2;
                if (display.mirrored) {

                    // draw stick
                    if (!display.hideA) {
                        ctx.beginPath();
                        ctx.moveTo(squareA.position[0], squareA.position[1] + 1 / 2 * squareA.dimensions[1]);
                        ctx.lineTo(squareA.position[0] - stickSize, squareA.position[1] + 1 / 2 * squareA.dimensions[1]);
                        ctx.stroke();
                        // vertical
                        ctx.beginPath();
                        ctx.moveTo(squareA.position[0] - stickSize, squareA.position[1] + 1 / 2 * squareA.dimensions[1] - 5);
                        ctx.lineTo(squareA.position[0] - stickSize, squareA.position[1] + 1 / 2 * squareA.dimensions[1] + 5);
                        ctx.stroke();
                    }

                } else {

                    // draw stick
                    // horizontal
                    if (!display.hideA) {
                        ctx.beginPath();
                        ctx.moveTo(squareA.position[0] + squareA.dimensions[0], squareA.position[1] + 1 / 2 * squareA.dimensions[1]);
                        ctx.lineTo(squareA.position[0] + squareA.dimensions[0] + stickSize, squareA.position[1] + 1 / 2 *
                            squareA.dimensions[1]);
                        ctx.stroke();
                        // vertical
                        ctx.beginPath();
                        ctx.moveTo(squareA.position[0] + squareA.dimensions[0] + stickSize, squareA.position[1] + 1 / 2 *
                            squareA.dimensions[1] - 5);
                        ctx.lineTo(squareA.position[0] + squareA.dimensions[0] + stickSize, squareA.position[1] + 1 / 2 *
                            squareA.dimensions[1] + 5);
                        ctx.stroke();
                    }
                }
                // draw chain
                if (display.squareList[1].colourName !== "hidden" && display.squareList[2].colourName !== "hidden") {
                    ctx.beginPath();
                    var squareBMiddleX, squareBChosenY, squareCMiddleX, squareCChosenY;
                    squareBMiddleX = squareB.position[0] + squareB.dimensions[0] * 1 / 2;
                    squareBChosenY = squareB.position[1] + squareB.dimensions[1] * 9 / 10;
                    squareCMiddleX = squareC.position[0] + squareC.dimensions[0] * 1 / 2;
                    squareCChosenY = squareC.position[1] + squareC.dimensions[1] * 9 / 10;

                    var distanceBetweenSquares, squareMiddlePoint;
                    distanceBetweenSquares = Math.abs(squareBMiddleX - squareCMiddleX);
                    squareMiddlePoint = display.mirrored ? distanceBetweenSquares / 2 + squareCMiddleX : distanceBetweenSquares / 2 +
                        squareBMiddleX;

                    var chosenCPY = squareB.position[1] + squareB.dimensions[1] + 120 - 0.75 * distanceBetweenSquares;
                    ctx.moveTo(squareBMiddleX, squareBChosenY);
                    ctx.quadraticCurveTo(squareMiddlePoint, chosenCPY, squareCMiddleX, squareCChosenY);
                    ctx.stroke();
                }

            };
            display.flashOn = function () {
                if (display.showFlash === true) {
                    if (display.flashState === false) {
                        display.canvas.style.backgroundColor = "black";
                        display.flashState = true;
                        if (display.hideA === true) {
                            display.squareList[0].colour = "#000000";
                            display.squareList[0].drawMe(display.canvas);
                        }
                    } else {
                        display.canvas.style.backgroundColor = "white";
                        display.flashState = false;
                        if (display.hideA === true) {
                            display.squareList[0].colour = "#FFFFFF";
                            display.squareList[0].drawMe(display.canvas);
                        }
                    }
                }
            };

            // initialize
            display.colours = colours; // expressed in ABC order
            display.mirrored = mirroring;
            display.launchingType = launchingType;
            display.hideA = display.colours[0] === "hidden";
            display.stickAndHole = stickAndHole;
            display.squareDimensions = squareDimensions;
            display.canvas = canvas;
            display.slider = slider;
            display.speed = speed;
            display.faces = facesBool;

            display.squareNames = ["A", "B", "C"];
            display.faceNames = ["angry", "love", "surprise"];
            display.faceNamesR = ["angry", "loveR", "surprise"];
            display.holeColour = "#d9d2a6";
            display.participantCanLeave = false;
            display.animationStarted = Infinity;
            display.animationEnded = false;
            display.flashState = false;
            display.animationTimer = [];
            display.durations = [];
            display.showFlash = false;
            display.squareList = [];

            display.placeSquares();
            display.resetSquares();
            // display.animateAgain();
        };

        // override functions
        self.canLeave = function () {
            if (self.lockNext){
                return false;
            }
            if (self.currentIndex > 3) {
                return true;
            } else {
                var somethingChecked = false;
                var whatChecked;
                for (var i = 0; i < self.radios.length; i++) {
                    if (self.radios[i].checked) {
                        somethingChecked = true;
                        whatChecked = i;
                    }
                }
                if (!somethingChecked) {
                    self.hasErrors = true;
                    self.errorText = "Please choose an option";
                    return false;
                } else {
                    self.pageResults[self.currentMoment].push(self.questions[self.currentMoment][whatChecked]);
                    self.feedbackTime = true;
                    if (self.questions[self.currentMoment][whatChecked] === self.answers[self.currentMoment]) {
                        self.hasErrors = false;
                        self.feedbackText = "Well done!";
                        self.currentIndex++;
                        // if (self.currentIndex < 4){
                        //     self.currentMoment = self.possibleMoments[self.currentIndex];
                        // }
                        self.animate();
                    } else{
                        self.hasErrors = false;
                        self.feedbackText = "Not correct, sorry. Try again!";
                    }
                }
            }
        };

        self.onInit = function () {
            self.radios = [self.refs.radioA, self.refs.radioB, self.refs.radioC, self.refs.radioD];
            self.setUpNextQuestion();
        };
        self.results = function () {
            return self.pageResults;
        };
        self.onHidden = function () {
            // stop binding. How?
        };



        // page specific functions
        self.animate = function () {
            self.rectangle.setTimeouts(0);
        };

        self.setUpNextQuestion = function () {
            if (self.currentIndex !== 0) {
                delete self.rectangle;
            }
            if (self.currentIndex === 4) {
                self.finish();
            } else {
                self.currentMoment = self.possibleMoments[self.currentIndex];

                self.uncheckRadios();
                self.feedbackTime = false;

                if (self.currentMoment === 0) {
                    self.rectangle = new self.MovingDisplay(["hidden", "blue", "purple"], false, "reversed", true, [50, 50], self.refs.myCanvas, null, 0.3, false);
                } else if (self.currentMoment === 1) {
                    self.rectangle = new self.MovingDisplay(["red", "blue", "hidden"], false, "canonical", false, [50, 50], self.refs.myCanvas, null, 0.3, false);
                } else if (self.currentMoment === 2) {
                    self.rectangle = new self.MovingDisplay(["red", "hidden", "purple"], false, "reversed", true, [50, 50], self.refs.myCanvas, null, 0.3, false);
                } else if (self.currentMoment === 3) {
                    self.rectangle = new self.MovingDisplay(["hidden", "blue", "purple"], false, "canonical", false, [50, 50], self.refs.myCanvas, null, 0.3, false);
                }

                self.update(); // this is needed to update display of radios and hide feedback
            }
        };

        self.uncheckRadios = function () {
            for (var i = 0; i < self.radios.length; i++) {
                self.radios[i].checked = false;
            }
        }
    </script>

</checking-training>
