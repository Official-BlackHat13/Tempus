<!-- #include FILE="pagetop.inc.asp" -->
<%

    Dim iDisplay
    
    '   If get request with action=logout parameter and the user is logged in
    If(Request("REQUEST_METHOD") = "GET" and Request("action") = "logout" and bUserLoggedIn) Then
        
        '   Create new session (Logout creates new session so the activity under
        '   the last account always stays visible in the session table)
        sSessionKey = oSessionManager.call("get_CreateSession", Request.ServerVariables("REMOTE_ADDR"))
        Response.Cookies("vdfSessionKey") = sSessionKey
        
        '   Reset page globals
        bUserLoggedIn = False
        sLoginName = ""
        bEditRights = False
        
        '   Choose display (3 = Logged out) 
        iDisplay = 3
    ElseIf (bUserLoggedIn) Then
        '   Choose display (2 = Already logged in) 
        iDisplay = 2
    Else
        '   Choose display (1 = Login form) 
        iDisplay = 1
    End If
    
    
%>
<html>
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
    
    //
    //  Handles the login response. Checks for errors and displays them, if no 
    //  errors it will make sure the welcome message is displayed.
    //
    //  Params:
    //      oRMI    The Remote Method Invocation object used for the request
    //
    function handleLogin(oEvent){
        var oRMI = oEvent.oSource, sError = null;
        
        if(oRMI.aErrors !== null && oRMI.aErrors.length > 0){
            sError = "" + oRMI.aErrors[0].iNumber + " : " + oRMI.aErrors[0].sErrorText;
        }else{
            if(parseInt(oRMI.getReturnValue()) > 0){
                sError = "Login failed, unknown error!";
            }
        }
        
        //  Update the display
        if(sError == null){
            document.getElementById("userlogin__error").innerHTML = "";
            document.getElementById("loginform").style.display = "none";
            document.getElementById("successful").style.display = "";
            document.getElementById("company-logo").innerHTML = " Logged in as: <b>" + document.frmUserLogin.LoginName.value + '</b> <a href="login.asp?action=logout">[logout]</a>';
        }else{
            document.getElementById("loginname").focus();
            document.getElementById("userlogin__error").innerHTML = sError;
        }
        document.getElementById("loading").style.display = "none";
        document.getElementById("actions").style.display = "";
    }
    
    //
    //  Displays the loginform and hides the other document parts/
    //
    function displayLogin(){
        document.getElementById("successful").style.display = "none";
        document.getElementById("logoutsuccessful").style.display = "none";
        document.getElementById("loggedin").style.display = "none";
        document.getElementById("loginform").style.display = "";
    }

</script>

</head>

<body<% If(iDisplay = 1) Then %> onload="document.getElementById('loginname').focus();"<% End If %>>

<!-- #include FILE="PMBodyTop.inc.asp" -->

<table width="100%">
  <tr>
    <td id="loginform" <% If(iDisplay <> 1) Then %> style="display: none"<% End If %>>
        <h3>Please login to the system</h3>
        <blockquote>
            <div>
				Welcome to the Interstate Companies Service Center.
				You will need to log into the system.
		    </div>
		</blockquote>
        <blockquote class="Error" id="userlogin__error">
            <div></div>        
        </blockquote>
        <form name="frmUserLogin" action="none" onsubmit="return sendLogin();">
          <blockquote>
            <table border="0" class="EntryTable">
              <tr>
                <td class="Label">Enter User Name:</td>
                <td><input type="text" size="10" name="LoginName" id="loginname" value=""></td>
              </tr>
              <tr>
                <td class="Label">Enter Password:</td>
                <td><input type="password" size="10" name="Password" value=""></td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td id="actions"><input class="ButtonNormal" type="submit" value="Ok"></td>
                <td id="loading" style="display: none;">Loading..</td>
              </tr>
            </table>
		  </blockquote>
        </form>
	</td>
   </tr>
   <tr id="successful" style="display: none">
    <td>
        <h3>Login successful</h3>
        <blockquote>
            <div>
                Welcome, you are successfully logged in to our system. You should now be able to
                manipulate data according to your privileges!
            </div>
        </blockquote>
    </td>
  </tr>
  <tr id="logoutsuccessful" <% If(iDisplay <> 3) Then %> style="display: none"<% End If %>>
    <td>
        <h3>Logout successful</h3>
        <blockquote>
            <div>
                You have successfully logged out of our system.
            </div>
        </blockquote>
    </td>
  </tr>
  <tr id="loggedin" <% If(iDisplay <> 2) Then %> style="display: none"<% End If %>>
    <td>
        <h3>Already logged in</h3>
        <blockquote>
            <div>
                You are already logged in and should already be able to manipulate data according 
                to your privileges! You can <a href="login.asp?action=logout">logout</a> and 
                login again with another account.
            </div>
        </blockquote>
    </td>
  </tr>
</table>

<!-- #INCLUDE FILE="bodybottom.inc.asp" -->

</body>
</html>

<!-- #INCLUDE FILE="pagebottom.inc.asp" -->