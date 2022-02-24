<% '
    '  Employee Transaction History
    '
    Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL, RunReport
    Dim DebugMode, Index
    Dim StartRowId, EndRowId
    Dim SelStart1, SelStop1
    Dim SelStart2, SelStop2

    ' Initialize Standard Information

    MaxRecs = 25 ' maximum records per report
    ZoomURL = "" ' name of zoom file. If blank none.
    RunReport = (Request ("RunReport") <> "")
    Index = 3' This Report uses a Fixed finding index
%>

<html>

    <head>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>Employee History</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
    </head>

    <body topmargin="5" leftmargin="5">

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <%
            If RunReport Then '-------------run the report -------------
        %>

            <h3>Employee Transaction History</h3>

            <% 
                StartRowId = Request ("Start")
                SelStart1  = Request ("SelStart1")
                SelStart2  = Request ("SelStart2")
                SelStop2   = Request ("SelStop2")

                oEmployeeHistoryReport.Call "Msg_SetTrans_Employeeidno", SelStart1, SelStart1
                oEmployeeHistoryReport.Call "Msg_SetTrans_Startdate", SelStart2, SelStop2

                EndRowId = oEmployeeHistoryReport.Call ("Get_RunEmployeeHistory", Index, StartRowId, MaxRecs)
            %>
            <% If StartRowId <> "" Then %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
            <% End If %>

            <% If EndRowId <> "" Then %>
                <a href="EmployeeHistory.asp?RunReport=1&Start=<% =EndRowId %>&Index=<% =Index %>&SelStart1=<% =SelStart1 %>&SelStop1=<% =SelStop1 %>&SelStart2=<% =SelStart2 %>&SelStop2=<% =SelStop2 %>">Next Page</a>
            <% End If %>

            <br />
            <a href="EmployeeHistory.asp">New Report</a>

        <% Else  '-------------set up the report ------------- %>

            <h3>Employee Transaction History</h3>

            <form action="EmployeeHistory.asp" method="get">
                <blockquote>

                    <table border="0">
                        <tr>
                            <td class="Label" align="left">Employee ID:</td>
                            <td>
                                <input type="text" size="4" name="SelStart1" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Label" align="left">Start date:</td>
                            <td>
                                <input type="text" size="10" name="SelStart2" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Label" align="left">Stop date:</td>
                            <td>
                                <input type="text" size="10" name="SelStop2" value="" />
                            </td>
                        </tr>
                    </table>

                </blockquote>

                <p>
                    <input class="ActionButton" type="submit" name="RunReport" value="Run Report" />
                    <input class="ActionButton" type="reset" value="Reset Form" />
                </p>
            </form>
        <% End If %>

    </body>
</html>
