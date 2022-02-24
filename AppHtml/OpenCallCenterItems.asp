<!-- #include FILE="pagetop.inc.asp" -->
<% '
    '  Open Call Center Items
    '
    ' Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL, RunReport
    Dim DebugMode, Index
    Dim StartRowId, EndRowId
    Dim SelStart1, SelStop1

    ' Initialize Standard Information

	If (bUserLoggedIn = False) Then
		Response.Redirect "Login.asp"
	End If

    MaxRecs = 50 ' maximum records per report
    ZoomURL = "CallCenterUpdateItem.asp" ' name of zoom file. If blank none.
    RunReport = 1 ' (Request ("RunReport") <> "")
    Index = 4 ' This Report uses a Fixed finding index
%>

<html>

    <head>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>OpenCallCenterItems</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />

        <!-- #include FILE="head.inc.asp" -->

    </head>

    <body topmargin="5" leftmargin="5">
        <!-- #include FILE="BodyTop.inc.asp" -->

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <%
            If RunReport Then '-------------run the report -------------
        %>

            <h3>Open Call Center Items</h3>

            <% 
                StartRowId = Request ("Start")
                SelStart1 = Request ("SelStart1")
                SelStop1 = Request ("SelStop1")

                oOpenCallCenterItems.Call "Msg_SetHRefName", ZoomUrl
                oOpenCallCenterItems.Call "Msg_SetLocnotes_Closeddate", SelStart1, SelStop1

                EndRowId = oOpenCallCenterItems.Call ("Get_RunOpenCallCenterItems", Index, StartRowId, MaxRecs)
            %>
            <% If StartRowId <> "" Then %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
            <% End If %>

            <% If EndRowId <> "" Then %>
                <a href="OpenCallCenterItems.asp?RunReport=1&Start=<% =EndRowId %>&Index=<% =Index %>&SelStart1=<% =SelStart1 %>&SelStop1=<% =SelStop1 %>">Next Page</a>
            <% End If %>

            <br />
            <a href="OpenCallCenterItems.asp">New Report</a> &nbsp; &nbsp; <a href="CallCenterCreateItem.asp">Item Creation</a>

        <% Else  '-------------set up the report ------------- %>

            <h3>Open Call Center Items</h3>

            <form action="OpenCallCenterItems.asp" method="get">
                <blockquote>

                    <table border="0">
                        <tr>
                            <td class="Label" align="left">Closeddate:</td>
                            <td class="Label" align="right">from:</td>
                            <td>
                                <input type="text" size="6" name="SelStart1" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td class="Label" align="right">to:</td>
                            <td>
                                <input type="text" size="6" name="SelStop1" value="" />
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
