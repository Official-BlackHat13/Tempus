<head>
<title>Service Center Login</title>

<!-- #include FILE="head.inc.asp" -->

<link rel="stylesheet" href="Css/Login.css" type="text/css">

<script type="text/javascript">
    vdf.require("vdf.ajax.VdfCall");  // this line isn't working. it was supposed to add the pkg for the RMI

    //
    //  Sends the login request with the loginname, password en sessionkey.
    //
    function sendLogin(){
        //  Display loading instead of button
        document.getElementById("actions").style.display = "none";
        document.getElementById("loading").style.display = "";
        
        //  Send the request using the VdfRemoteMethodInvocation service
        var oRMI = new vdf.ajax.VdfCall("oSessionManager", "get_UserLogin", null);
        oRMI.bSuppressError = true;
        oRMI.addParameter(vdf.sys.cookie.get("vdfSessionKey"));
        oRMI.addParameter(document.frmUserLogin.LoginName.value);
        oRMI.addParameter(document.frmUserLogin.Password.value);
        
        oRMI.onFinished.addListener(handleLogin);
        oRMI.send(true);
		
        
        //  Return false to cancel the submit
        return false;
    }
    function LoadDAI(){
		
		var username = "hudson";
		var password = "hudson";
		document.getElementById('link').href="http://64.122.223.194:419/ai6/ai.asp?UID=" + username  + "&PW=" + password + "&DAI_R=1898";
	}
    //
    //  Handles the login response. Checks for errors and displays them, if no 
    //  errors it will make sure the welcome message is displayed.
    //
    //  Params:
    //      oRMI    The Remote Method Invocation object used for the request
    //
    function handleLogin(oEvent){
        var oRMI = oEvent.oSource, sError = null;
        reloadPage();
		
        if(oRMI.aErrors !== null && oRMI.aErrors.length > 0){
            sError = "" + oRMI.aErrors[0].iNumber + " : " + oRMI.aErrors[0].sErrorText;
        }else{
            if(parseInt(oRMI.getReturnValue()) > 0){
                sError = "Login failed, unknown error!";
            }
        }
        
        //  Update the display
		// Login successfull - refresh page
        if(sError == null){
            document.getElementById("userlogin__error").innerHTML = "";
            document.getElementById("loginform").style.display = "none";
            document.getElementById("successful").style.display = "";
			document.getElementById("select-location").style.display= "";
			document.getElementById("content-right").style.display= "";
			document.getElementById("mainmenu").style.display= "";
            document.getElementById("company-logo").innerHTML = " Logged in as: <b>" + document.frmUserLogin.LoginName.value + '</b> <a href="pmlogin.asp?action=logout">[logout]</a>';

        }else{
            document.getElementById("loginname").focus();
            document.getElementById("userlogin__error").innerHTML = sError;


        }
        document.getElementById("loading").style.display = "none";
        document.getElementById("actions").style.display = "";
		this.document.location.href = 'PMLogin.asp';
    }
    
    //
    //  Displays the loginform and hides the other document parts/
    //
    function displayLogin(){
        document.getElementById("successful").style.display = "none";
        document.getElementById("logoutsuccessful").style.display = "none";
        document.getElementById("loggedin").style.display = "none";
		document.getElementById("navigation").style.display= "none";
		document.getElementById("select-location").style.display= "none";
		document.getElementById("content-right").style.display= "none";
		document.getElementById("mainmenu").style.display= "none";
        document.getElementById("loginform").style.display = "";

    }
</script>

<script type="text/javascript">
function reloadPage()
  {
	//window.location = 'PropertyManagerLocations.asp';
	setTimeout(window.location.href = 'PropertyManagerLocations.asp', 1000);
  }
</script>

<!-- Ben - Added 07/10/2012 - Script for Java Clock -->    
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
		<script type="text/javascript" src="raphael-min.js"></script> 
		<script type="text/javascript">
 
			function draw_clock(width, fillColor, strokeWidth, strokeColor, pinWidth, pinColor, hourHandLengh, hourHandColor, minuteHandLengh, minuteHandColor, secondHandLengh, secondHandExceeding, secondHandColor){
			canvas = Raphael("clock",width,width);
			var clock = canvas.circle(width/2,width/2,45);
			clock.attr({"fill":fillColor,"stroke":strokeColor,"stroke-width":strokeWidth});
			var hour_sign;
			for(i=0;i<12;i++){
			var start_x = width/2+Math.round(35*Math.cos(30*i*Math.PI/180));
			var start_y = width/2+Math.round(35*Math.sin(30*i*Math.PI/180));
			var end_x = width/2+Math.round(40*Math.cos(30*i*Math.PI/180));
			var end_y = width/2+Math.round(40*Math.sin(30*i*Math.PI/180));
			hour_sign = canvas.path("M"+start_x+" "+start_y+"L"+end_x+" "+end_y);
			}
			hour_hand = canvas.path("M"+width/2+" "+width/2+"L"+width/2+" "+((width/2)-hourHandLengh)+"");
			hour_hand.attr({stroke: hourHandColor, "stroke-width": 2});
			minute_hand = canvas.path("M"+width/2+" "+width/2+"L"+width/2+" "+((width/2)-minuteHandLengh)+"");
			minute_hand.attr({stroke: minuteHandColor, "stroke-width": 2});
			second_hand = canvas.path("M"+width/2+" "+((width/2)+secondHandExceeding)+"L"+width/2+" "+((width/2)-secondHandLengh)+"");
			second_hand.attr({stroke: secondHandColor, "stroke-width": 1});
			var pin = canvas.circle(width/2, width/2, pinWidth);
			pin.attr("fill", pinColor);
			update_clock(width);
			setInterval("update_clock("+width+")",1000);
			}
 
			function update_clock(width){
					var now = new Date();
					var offset = now.getTimezoneOffset();
					var hours = now.getUTCHours()-(6);
					var minutes = now.getUTCMinutes();
					var seconds = now.getUTCSeconds();
					hour_hand.rotate(30*hours+(minutes/2), width/2, width/2);
					minute_hand.rotate(6*minutes, width/2, width/2);
					second_hand.rotate(6*seconds, width/2, width/2);
					}

 
		</script>
 
</head>

<div id="Table">
    <div id="header">
        <div id="header-main">
        <div id="navigationmenu">
       		<div id="navitem"><a href="PropertyManagerLocations.asp">View Managed Properties</a></div>

        <div id="navitem" style="display:none"><a href="#" onclick="LoadDAI();" id="link" >Invoices</a></div>
        </div>
        
        </div>
          
        <div id="clock">
        <div id="clock-box"><strong>Minneapolis</strong></div>
		<script>draw_clock(90, "#f5f5f5", 5, "##f5f5f5", 4, "#000000", 25, "#444444", 32, "#444444", 35, 8, "#444444")</script>
      	</div>  <!-- #clock -->          
        <div id="company-logo" style="color:#FFF">
            <% If (bUserLoggedIn) Then %>
                <div id="login-box">Logged in as: <b><%=sLoginName%></b> <a href="PMLogin.asp?action=logout">[logout]</a></div>
                	
            <% Else %>
               	<div id="login-box"><a style="padding-right:5px;" href="PMLogin.asp">Login</a>
                
                     <form name="frmUserLogin" action="none" onSubmit="return sendLogin();">
                      <blockquote>
                        <table border="0" class="EntryTable">
                          <tr>
                            <td class="Label">User Name:</td>
                            <td><input type="text" size="15" name="LoginName" id="loginname" value=""></td>
                          </tr>
                          <tr>
                            <td class="Label">Password:</td>
                            <td><input type="password" size="15" name="Password" value=""></td>
                          </tr>
                          <tr>
                            <td>&nbsp;</td>
                            <td id="actions"><input class="ButtonNormal" type="submit" value="Ok"></td>
                            <td id="loading" style="display: none;">Loading..</td>
                          </tr>
                        </table>
                      </blockquote>
                    </form>
                </div> <%'Login-Box'%>
                
            <% End If %>
        </div>
        
    </div>
    <div id="content">


    
        
        
    
