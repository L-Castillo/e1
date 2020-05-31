<moving-display-template>

    <script>
        // moving display w/ faces
        self.MovingDisplay = function (colours, mirroring, launchTiming, extraObjs, squareDimensions, canvas, slider = null, speed, facesBool, showFlash = false) {

            var display = this;

            // def functions

            display.Square = function (colour, dimensions, face) {
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
                    var face, newSquare, squareColour;
                    squareColour = display.colours[i];
                    if (display.faces === true) {
                        face = display.mirrored ? display.faceNamesR[i] : display.faceNames[i];
                        newSquare = new display.Square(squareColour, display.squareDimensions, face);
                    } else {
                        newSquare = new display.Square(squareColour, display.squareDimensions, display.faces);
                    }
                    display.squareList.push(newSquare);
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

            display.startAnimation = function () {
                display.animationStarted = Date.now();
                window.requestAnimationFrame(display.draw.bind(display));
            };
            display.endAnimation = function () {
                display.animationEnded = Date.now();
            };

            display.animate = function () {
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
            display.setTimeouts = function (startInstructions = null) {
                display.flashOnset = -1;
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
                timeoutId = setTimeout(display.endAnimation.bind(display), startAt + lastFinish);
                display.animationTimer.push(timeoutId);
                var animationSpace = lastFinish + 1000;
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
                display.canvas.getContext('2d').clearRect(0, 0, display.canvas.width, display.canvas.height);
                var step = Date.now() - display.animationStarted;

                for (var i = 0; i < display.squareList.length; i++) {
                    display.squareList[i].draw(display.canvas, step);
                }
                // draw the hole for middle
                if (display.squareList[1].colourName !== "hidden") {
                    let ctx = display.canvas.getContext("2d");
                    ctx.fillStyle = display.holeColour;
                    ctx.fillRect(display.squareList[1].position[0], display.squareList[1].position[1] + 1 / 3 *
                        display.squareList[1].dimensions[1], display.squareList[1].dimensions[0], 1 / 3 * display.squareList[1].dimensions[1]);
                }

                if (display.extraObjs) {
                    display.drawObjects()
                }
                if (!display.animationEnded) {
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
                    if (display.squareList[0].colourName !== "hidden") {
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
                    if (display.squareList[0].colourName !== "hidden") {
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
                        display.flashOnset = Date.now();
                        display.canvas.style.backgroundColor = "black";
                        display.flashState = true;
                        for (var i = 0; i < display.squareList.length; i++) {
                            if (display.squareList[i].colourName === "hidden") {
                                display.squareList[i].colour = "#000000";
                                display.squareList[i].drawMe(display.canvas);
                            }
                        }
                    } else {
                        display.canvas.style.backgroundColor = "white";
                        display.flashState = false;
                        for (var i = 0; i < display.squareList.length; i++) {
                            if (display.squareList[i].colourName === "hidden") {
                                display.squareList[i].colour = "#FFFFFF";
                                display.squareList[i].drawMe(display.canvas);
                            }
                        }
                        // if (display.animationStarted === Infinity) {
                        //     display.earlyFlash = true;
                        // } else {
                        //     // display.flashOnset = display.flashOnset - display.animationStarted;
                        //     // self.resultDict["flashedAt"] = display.flashOnset;
                        // }
                    }
                    display.draw(); // avoids funky lines if animation has ended
                }
            };


            // initialize
            display.colours = colours; // expressed in ABC order
            display.mirrored = mirroring;
            display.launchTiming = launchTiming;
            display.extraObjs = extraObjs;
            display.squareDimensions = squareDimensions;
            display.canvas = canvas;
            display.slider = slider;
            display.speed = speed;
            display.faces = facesBool;

            display.squareNames = ["A", "B", "C"];
            display.faceNames = ["angry", "love", "surprise"];
            display.faceNamesR = ["angry", "loveR", "surprise"];
            display.holeColour = "#d9d2a6";
            display.animationStarted = Infinity;
            display.animationEnded = false;
            display.flashState = false;
            display.animationTimer = [];
            display.durations = [];
            display.showFlash = showFlash;
            display.squareList = [];
            display.flashOnset = -1;

            display.placeSquares();
            display.resetSquares();
        };

    </script>
</moving-display-template>