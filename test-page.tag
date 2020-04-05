<test-page>
	<h1> Normal html here</h1>
	<div>This is bound: {canBeBound}</div>
	<button onclick={callMe}>Bound function</button>
	
	<div ref="someDiv">To refer to a dom element without binding, give it a ref attribute, and then refer to it by self.refs.attrName. </div>
	
	<script>
		var self = this;
		self.canBeBound = "look";
		
		self.callMe = function(){
			self.canBeBound = "Calling the function via a user interaction (click, input, etc), will update the dom immediately";
			
			self.refs.someDiv.innerHTML = "Changed by ref";
		}
		
		
		
		
		/*****************************************predefined functions that will be called by the framework****************************/
		//called when ready to leave the page (via clicking next, or calling self.finish())
		self.canLeave = function(){
			return true;//if we return false, then we stay in the page and can show some error message
		}
		
		//called when ready to write results to server
		self.results = function(){
			return "simple";
			//can also return a dictionary, e.g. {result1: value, result2: other Value}
		}
		
		//called when the page is shown
		 self.onShown = function(){
            
        };

        //called when the page is hidden
        self.onHidden = function(){
        };

		
	
		
		
	</script>



</test-page>