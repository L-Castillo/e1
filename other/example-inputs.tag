<example-inputs>
    <div class='input-container'>
        <span class='input-label'>Text:</span>
        <psych-input name="textBox"></psych-input>
    </div>

    <div class='input-container'>
        <span class='input-label'>Number:</span>
        <psych-input name="number" numeric="true"></psych-input>
    </div>

    <div class='input-container'>
        <span class='input-label'>Open:</span>
        <psych-input name="textarea" multiline="true" ref="openEnded"></psych-input>
    </div>

    <div class='input-container'>
        <span class='input-label'>Check:</span>
        <psych-input name="check" options="{['anOption']}"></psych-input>
    </div>

    <div class='input-container'>
        <span class='input-label'>Radio:</span>
        <psych-input name="radio" options="{['anOption', 'anotherOption']}"></psych-input>
    </div>

    <div class='input-container'>
        <span class='input-label'>Check many:</span>
        <psych-input name="checkMany" multiple="true" options="{['anOption', 'anotherOption', 'yet another', 'yet this']}" ></psych-input>
    </div>


    <div class='input-container'>
        <span class='input-label'>Select:</span>
        <psych-input prompt="Please Select" name="select" options="{['anOption', 'anotherOption', 'yet another']}"></psych-input>
    </div>

    <div class='input-container'>
        <span class='input-label'>Select randomised:</span>
        <psych-input name="selectRandom" options="{['anOption', 'anotherOption', 'yet another']}" randomise="true" ></psych-input>
    </div>

    <div class='input-container'>
        <span class='input-label'>List:</span>
        <psych-input name="list" visible="3" options="{['anOption', 'anotherOption', 'yet another']}"></psych-input>
    </div>


    <div class='input-container'>
        <span class='input-label'>Range:</span>
        <psych-input name="range" continuous="true"></psych-input>
    </div>

    <div class='input-container'>
        <span class='input-label'>Range with options:</span>
        <psych-input name="rangeOpt" continuous="true" options="{['no', 'maybe', 'yes']}" ></psych-input>
    </div>

    <!--This will be shown only when self.hasErrors is true -->
    <p class="psychErrorMessage" show="{hasErrors}">Please answer all questions</p>

    <style scoped>
        .input-container{
            margin: 20px;
        }
        .input-label{
            display: inline-block;
            vertical-align: top;
            width:200px;
            text-align: right;
            margin-right:5px;
        }
        psych-input{
            width: 400px;
            height:50px;
        }
        .psychErrorMessage{
            text-align: center;
            font-size: 18px;
        }
    </style>
    <script>
        var self= this;
        self.hasErrors = false;

        //By setting the name attribute of the psych-input, we can easily save its value
        //whenever the input value changes the respecting property will be updated
        //We initialize those properties below just to give default values (not necessary though).
        self.textBox = "";
        self.number = "";
        self.textarea = "";
        self.check = "";
        self.radio = "";
        self.checkMany = "";
        self.select = "";
        self.selectRandom = "";
        self.listbox = "";
        self.range = "";
        self.rangeOpt = "";

        //We overrride the canLeave function, do indicate whether the participant can navigate away from the page.
        //Should return true if all is good (e.g. no input is missing) and false otherwise
        //If the experiment is in debug (isDebug="{true}") and the flyThrough setting is set (flyThrough="{true}")
        //then this will be ignored, i.e. we'll be able to navigate away even if this returns false
        self.canLeave = function(){
            var canGo = true;
            //here we check the values of two of the inputs and decide that we can't continue unless both have some value
            if(self.textBox==="" || self.check==="") canGo = false;

            //usually we'll also want to show some error message if we don't allow user to leave
            self.hasErrors = !canGo; //in the HTML above the error will be shown only if the property hasErrors is true

            return canGo;
        };

        //We override the results function if we want this page to write something to the server.
        //It must return a string or a dictionary (associative array) with whatever we want to write
        self.results = function(){
            //here we'll write the user's input only for two of the inputs. The first will be written
            //under the column title someInput, and the second under the title someChoice
            return {someInput:self.textBox, someChoice: self.select};
        };


        //we override the onInit function if we want something to happen when the page is initialised,
        //i.e. after the condition is know, resources have been downloaded etc. The safest place for initialization code
        self.onInit = function(){
            // 1. When in HTML we define the ref property, we can access the dom element through self.refs.refName
            //( here, the textarea above, has its ref preporty set to openEnded, see above)
            // 2. Each psych-input element triggers a change message when it changes value, that we can capture
            // like so:
            self.refs.openEnded.on('change', function(newValue){
                alert('I have a new value: ' + newValue);
            })
            //Note: usually we care only for the value of the input when we leave the page, or in the results,
            //so the above is not used very often
        }

    </script>

</example-inputs>