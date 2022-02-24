<% '
    '  Employee Transaction History
    '
    Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL
    Dim RowId, StartRowId, EndRowId
    Dim DebugMode

    ' Initialize Standard Information

    MaxRecs = 25 ' maximum records per report
    ZoomURL = "" ' name of zoom file. If blank none.
    RowId = Request ("RowId") ' if non-zero, only run report for this Id
    StartRowId = Request ("Start") ' if running for all, where to start at
%>

<html>

    <head>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>EmployeeTransactionHistory</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
    </head>

    <body topmargin="5" leftmargin="5">

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <%
            If RowId <> "" Then
        %>

            <h3>Employee Transaction History</h3>

            <%
                EndRowId = oEmployeeHistory.Call("Get_RunEmployeeHistory", RowId)
            %>

            <a href="#" onClick="history.go(-1);return false;">Previous Page</a> &nbsp;

        <%
            Else
        %>
            <h3>Employee Transaction History</h3>

            <%
                EndRowId = oEmployeeHistory.Call("Get_RunAllEmployeeHistory", StartRowId, MaxRecs)
            %>

            <%
                If StartRowId <> "" Then
            %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a> &nbsp;
            <%
                End If
            %>

            <%
                If EndRowId <> "" Then
            %>
                <a href="EmployeeTransactionHistory.asp?RunReport=1&Start=<%=EndRowId%>">Next Page</a>
            <%
                End If
            %>

        <%
            End If
        %>

    </body>
</html>
