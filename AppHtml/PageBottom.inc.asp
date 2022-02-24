<%
    '   We abandon the ASP session here because the VDF debugger has problems 
    '   handling multiple sessions (the "Web Application Server session was 
    '   unexpectedly terminated." errors).
    Session.Abandon
%>