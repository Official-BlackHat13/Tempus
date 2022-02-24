<!-- #include FILE="pagetop.inc.asp" -->
<% '
    '  Property Manager Locations
    '
    'Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL, RunReport
    Dim DebugMode, Index
    Dim StartRowId, EndRowId

    ' Initialize Standard Information

    MaxRecs = 0 ' maximum records per report
    ZoomURL = "" ' name of zoom file. If blank none.
    RunReport = 1 ' (Request ("RunReport") <> "")
    Index = 7' This Report uses a Fixed finding index
%>

<html>

    <head>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>Managed Locations</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />


    </head>
<!-- #include FILE="PMBodyTop.inc.asp" -->
    <body topmargin="5" leftmargin="5">



        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <%
            If RunReport Then '-------------run the report -------------
        %>

            <h3>Property Locations</h3>

            <% 
                StartRowId = Request ("Start")

                oPropertyManagerLocations.Call "Msg_SetPropmgrIdno", sContactID

                EndRowId = oPropertyManagerLocations.Call ("Get_RunPropertyManagerLocations", Index, StartRowId, MaxRecs)
            %>
            <% If StartRowId <> "" Then %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
            <% End If %>

            <% If EndRowId <> "" Then %>
                <a href="PropertyManagerLocations.asp?RunReport=1&Start=<% =EndRowId %>&Index=<% =Index %>">Next Page</a>
            <% End If %>

            <br />

        <% Else  '-------------set up the report ------------- %>

            <h3>Property Locations</h3>

            <form action="PropertyManagerLocations.asp" method="get">
                <blockquote>


                </blockquote>

                <p>
                    <input class="ActionButton" type="submit" name="RunReport" value="Run Report" />
                    <input class="ActionButton" type="reset" value="Reset Form" />
                </p>
            </form>
        <% End If %>
    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
    </body>
</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->
