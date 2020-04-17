<clip-page id="clipPage" style="position: relative;overflow: hidden;margin-top: 10px">
    <div style="font-size: 21px;float: right;">{opts.index}</div>
    <canvas width="958" height="350" style="border: 1px solid" ref="canvas">
        <p>Unfortunately, your browser does not support this experiment.</p>
    </canvas>

    <div style="height:210px">
        <div show="{showQuestion}">
            <p> Do you think the {opts.colours[0]} square made the {opts.colours[1]} square move or did {opts.colours[1]} move on its own? </p>

            <div style="margin-top: 25px;border: 1px solid #cecece;padding: 26px;">
                <psych-input style="width:910px" ref="flashSlider" options="{[opts.colours[0] + ' made ' + opts.colours[1] + ' move',opts.colours[1] + ' moved on its own']}" continuous="{true}" name="response" min="0" max="100"></psych-input>
            </div>
            <p class="psychErrorMessage" show="{showError}" style="text-align: center;font-size: 20px;">
                Please answser the question by clicking/dragging the slider.
            </p>

        </div>
    </div>



    <style scoped>
        p, label{
            font-size: 19px;
        }
    </style>

    <script>
        var self = this;
        self.objWidth = 30;
        self.objHeight = 30;
        self.speed =0.2;
        self.eventSequence = {};//the actual order of events
        self.response = -1;
        self.showQuestion = false;
        self.showError = false;
        self.restart = function(){
            for (var i = 0; i < self.objects.length; i++) {
                self.objects[i].reset();
            }
            self.startAnimation();
        };
        self.nextVisible = false;

        self.canLeave = function(){
            var ok = !self.opts.test || self.response!==-1;
            if(!ok){
                self.showError=true;
            }
            return ok;
        };

        self.startAnimation = function () {
            // console.log(self.results());
            self.animationStarted = Date.now();
            window.requestAnimationFrame(self.draw);

        };
        self.endAnimation = function () {
            self.animationEnded = Date.now();
            if(self.opts.test) {
                self.showQuestion = true;
                self.nextVisible = true;
                self.experiment.update();//will show button
            }
            else{
                self.finish();
            }
        };


        self.draw = function(){
            if(!self.animationEnded) {
                self.canvas.getContext('2d').clearRect(0, 0, self.canvas.width, self.canvas.height);
                var step = Date.now() - self.animationStarted;

                for (var i = 0; i < self.objects.length; i++) {
                    self.objects[i].draw(self.canvas, step);
                }
                window.requestAnimationFrame(self.draw);
            }
        };




        self.results = function () {
            var actualTimings = self.objects.map(function(o){return o.movedAt;});

            return {test:self.opts.test, response:self.response, aPosition:self.objects[0].startPosition, objects:self.objects.length, actualTimings: actualTimings, colours:self.opts.colours, mirrored:self.mirrored, objectWidth: self.objWidth, objectHeight: self.objHeight};
        };


        self.onShown = function () {
            self.mirrored = self.opts.mirrored;

            self.colour = self.opts.colours[2];
            self.textStyle = {color:self.colour,'font-weight': 'bold'};

            self.canvas = self.refs.canvas;


            self.setup();
            self.experiment.screenShot = self.canvas.toDataURL();
            var finishTimings = self.objects.map(function(obj){return obj.moveAt+ obj.duration});

            var startAt = 1500;
            setTimeout(self.startAnimation, startAt);
            setTimeout(self.endAnimation, startAt+ Math.max.apply(null, finishTimings)+1000);
        };

        self.setup = function () {
            var colours = self.opts.colours;// [self.opts.colours[0],self.opts.colours[1]];

            var hasThreeObjects = self.opts.objects==3;

            var hideA = false;//!hasThreeObjects && syncWith==='withC';
            var hideC = false;//!hasThreeObjects && syncWith==='withB';

            var objA = new Square("objA", colours[0], [self.objWidth, self.objHeight]);
            var objB = new Square("objB", colours[1], [self.objWidth, self.objHeight]);
            var objC = new Square("objC", colours[2], [self.objWidth, self.objHeight]);

            var objects;
            if(self.opts.test){
                objects = self.experiment.condition.name()==="control" ? self.setupControlTest(objA, objB) : self.setupTest(objA, objB); //===exp1
                // objects = self.setupControlTest(objA, objB);
            }
            else{
                objects = self.setupExperimental(objA, objB, objC);
            }

            var clipStarts =0;
            for (var i = 0; i < objects.length; i++) objects[i].moveAt += clipStarts;


            self.objects = objects;
            // self.objectTimings = [objects[1].moveAt];
            // self.objects = [objects[1]];
            // if(self.opts.test){
            //     self.objectTimings.unshift(objects[0].moveAt);
            //     self.objects.unshift(objects[0])
            // }
            // else{
            //     self.objectTimings.push(objects[2].moveAt);
            //     self.objects.push(objects[2]);
            // }

            for (var i = 0; i < self.objects.length; i++) {
                self.objects[i].reset(self.canvas,0);
                self.objects[i].draw(self.canvas,0);
            }
        };

        self.setupTest = function(objA, objB){

            var startX = self.mirrored ? 800 : 160, startY = 150, distance = 200;
            var mirrorFactor = self.mirrored ? -1 : 1;

            var isPerceptual = self.experiment.condition.name()==="perceptual";

            if(isPerceptual)
                objA.startPosition = [startX, startY];
            else{
                // objA.startPosition = [Math.randomInt(50, self.canvas.width-distance-50), Math.randomInt(50, self.canvas.height-50)];
                objA.startPosition = [Math.randomInt(50, self.canvas.width-distance-50), startY];
            }

            objA.finalPosition = [objA.startPosition[0] + mirrorFactor * distance, objA.startPosition[1]];
            var objADistance = Math.abs(objA.finalPosition[0] - objA.startPosition[0]);
            objA.duration = objADistance / self.speed;

            objB.startPosition = [startX + mirrorFactor * (distance + self.objWidth), startY];
            objB.finalPosition = [objB.startPosition[0] + mirrorFactor * self.objWidth, objB.startPosition[1]];
            var objBDistance = Math.abs(objB.finalPosition[0] - objB.startPosition[0]);
            objB.duration = objBDistance / self.speed;



            objA.moveAt = 0;
            objB.moveAt = isPerceptual ?  objA.duration : Math.random() * objA.duration;

            return [objA, objB];

        };
        self.setupControlTest = function(objA, objB){
            var startX = self.mirrored ? 800 : 160, distance = 200;
            var mirrorFactor = self.mirrored ? -1 : 1;


            var yPositions = [100, 100+2*self.objWidth, 100+4*self.objWidth].shuffle();

            objA.startPosition = [startX, yPositions[0]];
            objA.finalPosition = [objA.startPosition[0] + mirrorFactor * distance, objA.startPosition[1]];
            objA.duration = Math.abs(objA.finalPosition[0] - objA.startPosition[0]) / self.speed;

            objB.startPosition = [startX, yPositions[1]];
            objB.finalPosition = [objB.startPosition[0] + mirrorFactor * distance, objB.startPosition[1]];
            objB.duration = Math.abs(objB.finalPosition[0] - objB.startPosition[0]) / self.speed;


            objA.moveAt = 0;
            objB.moveAt = Math.random() * objA.duration;


            return [objA, objB];

        };
        self.setupExperimental = function(objA, objB, objC){
            var isReordered = self.opts.reordered;
            // self.speed = self.experiment.condition.factors.speed == 'slow' ? 0.2 : 0.4;

            var startX = self.mirrored ? 800 : 160, startY = 150, distance = 200;
            var mirrorFactor = self.mirrored ? -1 : 1;
            objA.startPosition = [startX, startY];
            objA.finalPosition = [objA.startPosition[0] + mirrorFactor * distance, objA.startPosition[1]];
            var objADistance = Math.abs(objA.finalPosition[0] - objA.startPosition[0]);
            objA.duration = objADistance / self.speed;

            objB.startPosition = [startX + mirrorFactor * (distance + self.objWidth), startY];
            objB.finalPosition = [objB.startPosition[0] + mirrorFactor * self.objWidth, objB.startPosition[1]];
            var objBDistance = Math.abs(objB.finalPosition[0] - objB.startPosition[0]);
            objB.duration = objBDistance / self.speed;

            objC.startPosition = [objB.startPosition[0] + mirrorFactor * 2 * self.objWidth, startY];
            objC.finalPosition = [objB.startPosition[0] + mirrorFactor * (2 * self.objWidth + distance), objB.startPosition[1]];
            var objCDistance = Math.abs(objC.finalPosition[0] - objC.startPosition[0]);
            objC.duration = objCDistance / self.speed;


            objA.moveAt = 0;
            objB.moveAt = (isReordered ? (objA.duration + 150) : objA.duration);
            objC.moveAt = (isReordered ? objA.duration : (objA.duration + objB.duration));

            return [objA, objB, objC];
        };


        function Square(name, colourName, dimensions) {
            var self = this;
            self.colourName = colourName;
            switch (self.colourName) {
                case "red":
                    self.colour = "#FF0000";
                    break;
                case "green":
                    self.colour = "#00FF00";
                    break;
                case "blue":
                    self.colour = "#0000FF";
                    break;
                case "black":
                    self.colour = "#000000";
                    break;
                case "hidden":
                    self.colour = "#FFFFFF";
                    break;
                case "purple":
                    self.colour = "#ec00f0";
                    break;
            }

            self.name = name;
            self.dimensions = dimensions;

            self.startPosition = [0, 0];
            self.finalPosition = [0, 0];
            self.moveAt = 0;
            self.movedAt =-1;//the time it actually moved

            self.duration = 400;

            self.animationTimer;

            self.pixelsPerStep;


            self.draw = function (canvas, step) {
                myStep = Math.max(0, step - self.moveAt);
                var ctx = canvas.getContext("2d");
                ctx.fillStyle = self.colour;

                if(myStep<self.duration) {
                    self.position[0] = self.startPosition[0] + self.pixelsPerStep[0] * myStep;
                    self.position[1] = self.startPosition[1] + self.pixelsPerStep[1] * myStep;
                }
                else{
                    self.position[0] = self.finalPosition[0];
                    self.position[1] = self.finalPosition[1];
                }

                ctx.fillRect( self.position[0],  self.position[1], self.dimensions[0], self.dimensions[1]);

                if(self.movedAt ===-1 && myStep>0) {
                    self.movedAt = step;
                    // console.log(self.name + ' moved at ' + self.movedAt);
                }

            };

            self.reset = function(canvas){
                self.movedAt=-1;
                self.position = self.startPosition.slice();
                self.pixelsPerStep = [(self.finalPosition[0] - self.startPosition[0]) / self.duration, (self.finalPosition[1] - self.startPosition[1]) / self.duration];

            };


        }

        // Date.prototype.timeNow = function () {
        //     return ((this.getHours() < 10)?"0":"") + this.getHours() +":"+ ((this.getMinutes() < 10)?"0":"") + this.getMinutes() +":"+ ((this.getSeconds() < 10)?"0":"") + this.getSeconds() +"."+ ((this.getMilliseconds() < 10)?"0":"") + this.getMilliseconds();
        // }
    </script>
</clip-page>
