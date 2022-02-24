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
			document.getElementById("navigation").style.display= "";
            document.getElementById("company-logo").innerHTML = " Logged in as: <b>" + document.frmUserLogin.LoginName.value + '</b> <a href="pmlogin.asp?action=logout">[logout]</a>';

			
			
			
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
		document.getElementById("navigation").style.display= "none";
        document.getElementById("loginform").style.display = "";
    }

</script>

</head>

<div id="Table">
    <div id="header">
        <div id="header-main">
        </div>
        
        <div id="company-logo" style="color:#FFF">
            <% If (bUserLoggedIn) Then %>
                <div id="login-box">Logged in as: <b><%=sLoginName%></b> <a href="PMLogin.asp?action=logout">[logout]</a></div>
                	<div id="navigation" <% If(iDisplay = 1) Then %> style="display: none"<% End If %>>
  						<div vdfControlType="vdf.gui.CustomMenu">
          	
                            <ul class="mainmenu">
                            <!--<li vdfElement="item"><a href="PMLogin.asp"><div>Login</div></a></li>-->
                            <li vdfElement="item"><a href="PropertyManagerLocations.asp"><div>My Properties</div></a></li>
                            <li vdfElement="item"><a href="PropertyManagerLocationList.asp"><div>List</div></a></li>
                            <!--<li vdfElement="item" vdfSubMenu="reports"><a href="javascript: vdf.sys.nothing();"><div>Reporting</div></a></li>
                            </ul>
                                <ul vdfElement="menu" vdfName="reports" class="submenu" style="display:none">
                                    <li vdfElement="item"><a href="PropertyManagerLocations.asp">Managed Properties</a></li>
                                    <li vdfElement="item"><a href="InvoiceHistoryReport.asp">Invoice History</a></li>-->
                            </ul>
                        </div>
                    </div>
            <% Else %>
               	<div id="login-box"><a style="padding-right:5px; color:#FFFFFF;" href="PMLogin.asp">Login</a>
                
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
    
   
	
    
