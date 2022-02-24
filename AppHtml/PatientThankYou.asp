<%

response.expires = 0

' When we log in we will set some cookies that can be used by
' ASP files within this application. These cookies will disappear
' when the browser is exited.
' We want to store the following cookies:
'   Rights = 0 | -1 | 1
'   Patient[Client] = Patient's client number, from querystring
'   Patient[PIN]    = user PIN
'   Patient[Name]   = Patient name, from datafile
'   Patient[County] = County name, from datafile
'   Patient[SessId] = Patient session ID established at login
'   Patient[SSN]    = last 4 digits of patient's SSN
'   Patient[RecId]  = Patient.Recnum

    ' clear cookies.
    response.cookies("Patient")("Number") = ""
    response.cookies("Patient")("Name")   = ""
    response.cookies("Patient")("County") = ""
    response.cookies("Patient")("SessId") = ""
    response.cookies("Patient")("SSN")    = ""
	response.cookies("Patient")("RecId")  = ""
    response.cookies("Rights")            = ""

%>

<html>
<head>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Microsoft FrontPage 6.0" />
        <title>PatientMaintenance</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />

<script>
var cot_loc0=(window.location.protocol == "https:")? "https://secure.comodo.net/trustlogo/javascript/cot.js" :
"http://www.trustlogo.com/trustlogo/javascript/cot.js";
document.writeln('<script language="JavaScript" src="'+cot_loc0+'" type="text\/javascript"><\/script>');
</script>

</head>

<body bgproperties="fixed" background="images/Gray Marble.gif">

<h1 align="center"><font size="6">Thank you for using the EMS Billing Credit Card Payment Center<br>
</font></h1>

<h1 align="center"><a href="index2.html"><img src="big_tree2.gif"
alt="[ Click To Enter ]" border="0" width="160" height="110"></a></h1>


<!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

<% If Rights = "1" then %>

<% ' If Rights is 1, login was ok. Display welcome message  %>

<%else%>

<%end if%>

<%
%>
<script language="JavaScript">COT("http://www.emsbillingsc.com/Images/secure_site.gif", "SC2", "none");</script>

</body>

</html>
