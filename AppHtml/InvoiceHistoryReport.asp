<!-- #include FILE="pagetop.inc.asp" -->
<% '
    '  InvoiceHistoryReport
    '
    ' Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL, RunReport
    Dim DebugMode, Index
    Dim StartRowId, EndRowId
    Dim SelStart1, SelStop1
    Dim SelStart2, SelStop2

    ' Initialize Standard Information

    MaxRecs = 50 ' maximum records per report
    ZoomURL = "InvoiceHistoryReportZoom.asp" ' name of zoom file. If blank none.
    RunReport = (Request ("RunReport") <> "")
    Index = 2 ' This Report uses a Fixed finding index
%>

<html>

    <head>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>Invoice History Report</title>
        <link rel="STYLESHEET" href="css/Print.css" type="text/css" />

        <!-- #include FILE="head.inc.asp" -->

    </head>

    <body topmargin="5" leftmargin="5">
        <!-- #include FILE="PMBodyTop.inc.asp" -->

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <%
            If RunReport Then '-------------run the report -------------
        %>

            <h3>Invoice History Report</h3>

            <% 
                StartRowId = Request ("Start")
                SelStart1 = Request ("SelStart1")
                SelStop1 = Request ("SelStop1")
                SelStart2 = Request ("SelStart2")
                SelStop2 = Request ("SelStop2")

                oInvoiceHistoryReport.Call "Msg_SetHRefName", ZoomUrl
                oInvoiceHistoryReport.Call "Msg_SetInvhdr_JobNumber", SelStart1, SelStart1
                oInvoiceHistoryReport.Call "Msg_SetInvhdr_Invoicedate", SelStart2, SelStop2
                oInvoiceHistoryReport.Call "Msg_SetInvhdr_Contactidno", sContactID

                EndRowId = oInvoiceHistoryReport.Call ("Get_RunInvoiceHistoryReport", Index, StartRowId, MaxRecs)
            %>
            <% If StartRowId <> "" Then %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
            <% End If %>

            <% If EndRowId <> "" Then %>
                <a href="InvoiceHistoryReport.asp?RunReport=1&Start=<% =EndRowId %>&Index=<% =Index %>&SelStart1=<% =SelStart1 %>&SelStop1=<% =SelStop1 %>&SelStart2=<% =SelStart2 %>&SelStop2=<% =SelStop2 %>">Next Page</a>
            <% End If %>

            <br />
            <a href="InvoiceHistoryReport.asp">New Report</a>

        <% Else  '-------------set up the report ------------- %>

            <h3>Invoice History Report</h3>

            <form action="InvoiceHistoryReport.asp" method="get">
                <blockquote>

                    <table border="0">
                        <tr>
                            <td class="Label" align="left">Job Number</td>
                            <td class="Label" align="right">from:</td>
                            <td>
                                <input type="text" size="8" name="SelStart1" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td class="Label" align="right">to:</td>
                            <td>
                                <input type="text" size="8" name="SelStop1" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Label" align="left">Invoice date</td>
                            <td class="Label" align="right">from:</td>
                            <td>
                                <input type="text" size="8" name="SelStart2" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td class="Label" align="right">to:</td>
                            <td>
                                <input type="text" size="8" name="SelStop2" value="" />
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

    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
    </body>
</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->
