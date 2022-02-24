<!-- #include FILE="pagetop.inc.asp" -->
<% '
    '  Open Transactions
    '
    ' Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL, RunReport
    Dim DebugMode, Index
    Dim StartRowId, EndRowId
    Dim SelStart1, SelStop1
	Dim SelEmployer
	Dim SelJobNo

    ' Initialize Standard Information

	If (bUserLoggedIn = False) Then
		Response.Redirect "Login.asp"
	End If

    MaxRecs = 25 ' maximum records per report
    ZoomURL = "CloseTransaction.asp" ' "OpenTransactionsZoom.asp" ' name of zoom file. If blank none.
    RunReport = (Request ("RunReport") <> "")
    Index = 2 ' This Report uses a Fixed finding index
%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>Tempus - Open Employee Transactions</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />

        <!-- #include FILE="head.inc.asp" -->
    </head>
    <body topmargin="5" leftmargin="5">
        <!-- #include FILE="bodytop.inc.asp" -->

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <%
            If RunReport Then '-------------run the report -------------
        %>

            <h3>Open Transactions</h3>

            <% 
                StartRowId = Request ("Start")
                SelStart1 = Request ("SelStart1")
                SelStop1 = Request ("SelStop1")
				SelEmployer = Request ("SelEmployer")
				SelJobNo = Request ("SelJobNo")

				oOpenTransactions.Call "Msg_SetTrans_EmployerIdno", SelEmployer
				oOpenTransactions.Call "Msg_SetTrans_JobNo", SelJobNo
                oOpenTransactions.Call "Msg_SetHRefName", ZoomUrl
                oOpenTransactions.Call "Msg_SetTrans_Areanumber", SelStart1, SelStop1
				

                EndRowId = oOpenTransactions.Call ("Get_RunOpenTransactions", Index, StartRowId, MaxRecs)
            %>
            <% If StartRowId <> "" Then %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
            <% End If %>

            <% If EndRowId <> "" Then %>
                <a href="OpenTransactions.asp?RunReport=1&Start=<% =EndRowId %>&Index=<% =Index %>&SelStart1=<% =SelStart1 %>&SelStop1=<% =SelStop1 %>&SelJobNo=<% =SelJobNo %>&SelEmployer=<% =SelEmployer %>">Next Page</a>
            <% End If %>

            <br />
            <a href="OpenTransactions.asp">New Report</a>

        <% Else  '-------------set up the report ------------- %>

            <h3>Open Transactions</h3>

            <form action="OpenTransactions.asp" method="get">
                <blockquote>

                    <table border="0">
                        <tr>
                            <td class="Label" align="left">Area:</td>
                            <td>
                                <input type="text" size="4" name="SelStart1" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Label" align="left">Employer:</td>
                            <td>
                                <input type="text" size="4" name="SelEmployer" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Label" align="left">JobNo:</td>
                            <td>
                                <input type="text" size="4" name="SelJobNo" value="" />
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
