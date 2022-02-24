<% '
    '  PropertyManagerLocationList
    '
    ' Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL, RunReport
    Dim Index
    Dim StartRowId, EndRowId

    ' Initialize Standard Information

    MaxRecs = 0 ' maximum records per report
    ZoomURL = "PropertyManagerLocationListZoom.asp" ' name of zoom file. If blank none.
    RunReport = 1 '(Request ("RunReport") <> "")
    Index = 7 ' Request ("Index")' The last selected Index number

    ' Create function To return selected String for design time find Index
    Function ShowSelected (Index , Item)
        If CStr (Index) = CStr (Item) Then 
            ShowSelected = "selected=""selected"""
        Else
            ShowSelected = ""
        End If
    End Function


%>

<html>

    <head>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>Property Manager Location List</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
        
        
    </head>

    <body topmargin="5" leftmargin="5">


        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>

        <%
            If RunReport Then '-------------run the report -------------
        %>
            <% 
                StartRowId = Request ("Start")

                oPropertyManagerLocationList.Call "Msg_SetHRefName", ZoomUrl
                
                oPropertyManagerLocationList.Call "Msg_SetPropmgrIdno", sContactID

                EndRowId = oPropertyManagerLocationList.Call ("Get_RunPropertyManagerLocationList", Index, StartRowId, MaxRecs)
            %>
            <% If StartRowId <> "" Then %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
            <% End If %>

            <% If EndRowId <> "" Then %>
                <a href="PropertyManagerLocationList.asp?RunReport=1&Start=<% =EndRowId %>&Index=<% =Index %>">Next Page</a>
            <% End If %>

        <% Else  '-------------set up the report ------------- %>

            <form action="PropertyManagerLocationList.asp" method="get">
                <blockquote>


                </blockquote>

                <p>
                    <input class="ActionButton" type="submit" name="RunReport" value="Run Report" />
                    <input class="ActionButton" type="reset" value="Reset Form" />
                </p>
            </form>
        <% End If %>
    </body>
</html>
