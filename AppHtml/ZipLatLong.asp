<% '
    '  ZipLatLong
    '
    Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL, RunReport
    Dim DebugMode, Index
    Dim StartRowId, EndRowId
    Dim SelStart1, SelStop1

    ' Initialize Standard Information

    MaxRecs = 5000 ' maximum records per report
    ZoomURL = "" ' name of zoom file. If blank none.
    RunReport = (Request ("RunReport") <> "")
    Index = Request ("Index")' The last selected Index number

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
        <title>ZipLatLong</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
    </head>

    <body topmargin="5" leftmargin="5">

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <%
            If RunReport Then '-------------run the report -------------
        %>

            <h3>ZipLatLong</h3>

            <% 
                StartRowId = Request ("Start")
                SelStart1 = Request ("SelStart1")
                SelStop1 = Request ("SelStop1")

                oZipLatLong.Call "Msg_SetZipGeo_ZipCode", SelStart1, SelStop1

                EndRowId = oZipLatLong.Call ("Get_RunZipLatLong", Index, StartRowId, MaxRecs)
            %>
            <% If StartRowId <> "" Then %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
            <% End If %>

            <% If EndRowId <> "" Then %>
                <a href="ZipLatLong.asp?RunReport=1&Start=<% =EndRowId %>&Index=<% =Index %>&SelStart1=<% =SelStart1 %>&SelStop1=<% =SelStop1 %>">Next Page</a>
            <% End If %>

            <br />
            <a href="ZipLatLong.asp">New Report</a>

        <% Else  '-------------set up the report ------------- %>

            <h3>ZipLatLong</h3>

            <form action="ZipLatLong.asp" method="get">
                <blockquote>

                    <table border="0">
                        <tr>
                            <td class="Label" align="left">ZipCode:</td>
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
                        <tr>
                            <td class="Label" align="right">Report Order</td>
                            <td>&nbsp;</td>
                            <td>
                                <select size="1" name="Index">
                                    <option value="1" <% =ShowSelected(Index,1) %> >ZipCode</option>
                                </select>
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
