<!-- #include FILE="pagetop.inc.asp" -->
		<script type="text/javascript">
		function loadPagePM() {
	  	this.document.location.href = 'PMLogin.asp';
  		}
		</script>
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
        iDisplay = 3%>
       	<script type="text/javascript">
	    loadPagePM(); 
        </script>
<%

    ElseIf (bUserLoggedIn) Then
        '   Choose display (2 = Already logged in) 
        iDisplay = 2
		
    Else
        '   Choose display (1 = Login form) 
        iDisplay = 1

    End If
    
    
%>
<html>


<body<% If(iDisplay = 1) Then %> onLoad="document.getElementById('loginname').focus();"<% End If %>>

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
        
	</td>
   </tr>
  <tr id="successful" style="display: none" >
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
  <tr id="loggedin" <% If(iDisplay <> 0) Then %> style="display: none"<% End If %>>
    <td>
     <h3>Already logged in</h3>
        <blockquote>
            <div>
                You are already logged in and should already be able to manipulate data according 
                to your privileges! You can <a href="PMlogin.asp?action=logout">logout</a> and 
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