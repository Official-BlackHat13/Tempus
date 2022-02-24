<!-- #include FILE="pagetop.inc.asp" -->
<% ' user must be logged in
	If (bUserLoggedIn = False) Then
		Response.Redirect "Login.asp"
	End If
%>
<% '
    '  EventOverview
    '
    'Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim MaxRecs, ZoomURL, RunReport
    Dim DebugMode, Index
    Dim StartRowId, EndRowId
    Dim SelStart1, SelStop1
    Dim SelStart2, SelStop2
    Dim SelStart3, SelStop3

    ' Initialize Standard Information

    MaxRecs = 50 ' maximum records per report
    ZoomURL = "EventOverviewZoom.asp" ' name of zoom file. If blank none.
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
    <title>EventOverview</title>
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        
        
         <!-- #include FILE="head.inc.asp" -->
        
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
        <link rel="stylesheet" media="print" href="Css/Print.css" type="text/css">
            <script type="text/javascript">
        //
        // sets the defaults
        //
        function initForm(oForm){
            oForm.doClear();
        }
    </script>   

    </head>

    <body>
        <!-- #include FILE="bodytop.inc.asp" -->

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <%
            If RunReport Then '-------------run the report -------------
        %>

            <h3>EventOverview</h3>

            <% 
                StartRowId = Request ("Start")
                SelStart1 = Request ("SelStart1")
                SelStop1 = Request ("SelStop1")
                SelStart2 = Request ("SelStart2")
                SelStop2 = Request ("SelStop2")
                SelStart3 = Request ("SelStart3")
                SelStop3 = Request ("SelStop3")

                oEventOverview.Call "Msg_SetHRefName", ZoomUrl
                oEventOverview.Call "Msg_SetWeather_AreaNumber", SelStart1, SelStop1
                oEventOverview.Call "Msg_SetWeather_EventDate", SelStart2, SelStop2
                oEventOverview.Call "Msg_SetAreas_Manager", SelStart3, SelStop3

                EndRowId = oEventOverview.Call ("Get_RunEventOverview", Index, StartRowId, MaxRecs)
            %>
            <% If StartRowId <> "" Then %>
                <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
            <% End If %>

            <% If EndRowId <> "" Then %>
                <a href="EventOverview.asp?RunReport=1&Start=<% =EndRowId %>&Index=<% =Index %>&SelStart1=<% =SelStart1 %>&SelStop1=<% =SelStop1 %>&SelStart2=<% =SelStart2 %>&SelStop2=<% =SelStop2 %>&SelStart3=<% =SelStart3 %>&SelStop3=<% =SelStop3 %>">Next Page</a>
            <% End If %>

            <br />
            <a href="EventOverview.asp">New Report</a>

        <% Else  '-------------set up the report ------------- %>

            <h3>EventOverview</h3>

            <form action="EventOverview.asp" method="get">
                <blockquote>

                    <table border="0">
                        <tr>
                            <td class="Label" align="left">AreaNumber:</td>
                            <td class="Label" align="right">from:</td>
                            <td>
                                <input type="text" size="4" name="SelStart1" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td class="Label" align="right">to:</td>
                            <td>
                                <input type="text" size="4" name="SelStop1" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Label" align="left">EventDate:</td>
                            <td class="Label" align="right">from:</td>
                            <td>
                                <input type="text" size="6" name="SelStart2" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td class="Label" align="right">to:</td>
                            <td>
                                <input type="text" size="6" name="SelStop2" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Label" align="left">Manager:</td>
                            <td class="Label" align="right">from:</td>
                            <td>
                                <input type="text" size="50" name="SelStart3" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td class="Label" align="right">to:</td>
                            <td>
                                <input type="text" size="50" name="SelStop3" value="" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Label" align="right">Report Order</td>
                            <td>&nbsp;</td>
                            <td>
                                <select size="1" name="Index">
                                    <option value="1" <% =ShowSelected(Index,1) %> >WeatherId</option>
                                    <option value="2" <% =ShowSelected(Index,2) %> >AreaNumber</option>
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
  		<!-- #INCLUDE FILE="bodybottom.inc.asp" -->
    </body>
    
</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->