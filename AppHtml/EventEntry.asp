<!-- #include FILE="pagetop.inc.asp" -->
<% ' user must be logged in
	If (bUserLoggedIn = False) Then
		Response.Redirect "Login.asp"
	End If
%>

<% '
    '  EventEntry
    '
    'Option Explicit ' Force explicit variable declaration.

    ' Declare variables

    Dim Index, RunReport
    Dim RowId
    Dim CheckFieldChange, DebugMode, FieldError

    ' Initialize Standard Information

    Index = Request("Index") ' The last selected Index number
    RowId = Request ("RowId") ' If a record Id was passed
    RunReport = (Request ("RunReport")<>"") ' If run report was selected
%>


<html>
<head>
	<title>EventEntry</title>
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

        <% CheckFieldChange=oEventEntry.Call("Get_peFieldMultiUser") %>
        <!-- #INCLUDE FILE="inc/SetChangedStates-script.inc" -->

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <h3>EventEntry</h3>

        <% 
            oEventEntry.Call "Set_pbReportErrors", 1 'Normally show any errors that occur
            'We either find a record, or clear the WBO
            If RowId <> "" Then
                Err = oEventEntry.RequestFindbyRowId( "Weather", RowId)
            Else 
                Err = oEventEntry.RequestClear("Weather",1)
            End If

            ' process various buttons that might have been pressed.
            ' only support Post submissions
            If Request ("Request_Method") = "POST" Then

                If Request ("Clear") <> "" Then
                    Err = oEventEntry.RequestClear("Weather",1)
                End If

                If Request ("Save") <> "" then
                    oEventEntry.Call "Set_pbReportErrors", 0
                    Err = oEventEntry.RequestSave("Weather")
                    If Err = 0 Then
                        Response.Write("<center><h4>Weather Record Saved</h4> </center>")
                    Else
                        Response.Write("<font color=""red"">")
                        Response.Write("<center><h4>Could not save changes. Errors Occurred</h4> </center>")
                        oEventEntry.Call "Msg_ReportAllErrors"
                        Response.Write("</font>")
                    End If
                End If


                ' note we use the Index variable we created above
                If Request("FindPrev") <> "" Then Err = oEventEntry.RequestFind("Weather", Index, LT)
                If Request("Find") <> "" Then Err = oEventEntry.RequestFind("Weather", Index, GE)
                If Request("FindNext") <> "" Then  Err = oEventEntry.RequestFind("Weather", Index, GT)
                If Request("FindFirst") <> "" Then  Err = oEventEntry.RequestFind("Weather", Index, FIRST_RECORD)
                If Request("FindLast") <> "" Then Err = oEventEntry.RequestFind("Weather", Index, LAST_RECORD)

            End If

            ' Create function To return selected String for design time find Index
            Function ShowSelected (Index , Item)
                If CStr (Index) = CStr (Item) Then 
                    ShowSelected = "selected=""selected"""
                Else
                    ShowSelected = ""
                End If
            End Function

        %>

        <form action="EventEntry.asp" method="post" name="Weather" OnSubmit="SetChangedStates(this)">

            <% ' You MUST have a hidden Rowid field for each DDO in your WBO %>
            <input type="hidden" size="15" name="Areas__RowId" value="<% =oEventEntry.DDValue("Areas.RowId") %>" />
            <input type="hidden" size="15" name="Weather__RowId" value="<% =oEventEntry.DDValue("Weather.RowId") %>" />

            <% ' This is needed if you need field level change state checking %>
            <input type="hidden" name="ChangedStates" value="" />

            <p class="Toolbar">
            <!--
                <input class="ActionButton" type="submit" name="FindFirst" value="&lt;&lt;" />
                <input class="ActionButton" type="submit" name="FindPrev" value="&lt;" />
                <input class="ActionButton" type="submit" name="Find" value="=" />
                <input class="ActionButton" type="submit" name="FindNext" value="&gt;" />
                <input class="ActionButton" type="submit" name="FindLast" value="&gt;&gt;" />
                <input class="ActionButton" type="submit" name="RunReport" value="List" />
            
                Order By 
                <select size="1" name="Index">
                    <option value="1" <%' =ShowSelected(Index,1) %> >WeatherId</option>
                    <option value="2" <% '=ShowSelected(Index,2) %> >AreaNumber</option>
                </select>
            
              -->  
                
                </center>
            </p>

            <blockquote class="EntryBlock">

                <table border="0" class="EntryTable">
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Areas.AreaNumber", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            AreaNumber
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data"> 
                        
                        
                        <select name="Areas__AreaNumber" size="1" >
                                ' The DDSEL in the following code returns " Selected " if field matches passed value
                                <option value="1" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"1") %> >Northwest</option>
                                <option value="2" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"2") %> >South</option>
                                <option value="3" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"3") %> >Southwest</option>
                                <option value="4" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"4") %> >Central</option>
                                <option value="5" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"5") %> >East</option>
                                <option value="6" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"6") %> >General Growth</option>
                                <option value="7" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"7") %> >-</option>
                                <option value="8" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"8") %> >Rochester</option>
                                <option value="9" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"9") %> >North</option>
                                <option value="10" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"10") %> >West</option>
                                <option value="11" <% =oEventEntry.DDValue("Areas.AreaNumber" ,DDSEL,"11") %> >Greater Chicago</option>
                            </select>
                        
                            
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Weather.EventDate", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            EventDate
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="6" title="" name="Weather__EventDate" value="<% =oEventEntry.DDValue("Weather.EventDate") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Weather.EventTime", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            EventTime
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="10" title="" name="Weather__EventTime" value="<% =oEventEntry.DDValue("Weather.EventTime") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Weather.WindVelocity", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            WindVelocity
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="4" title="" name="Weather__WindVelocity" value="<% =oEventEntry.DDValue("Weather.WindVelocity") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Weather.WindDirection", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            WindDirection
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <select name="Weather__WindDirection" size="1" >
                                ' The DDSEL in the following code returns " Selected " if field matches passed value
                                <option value="N" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"N") %> >N</option>
                                <option value="NNE" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"NNE") %> >NNE</option>
                                <option value="NE" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"NE") %> >NE</option>
                                <option value="ENE" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"ENE") %> >ENE</option>
                                <option value="E" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"E") %> >E</option>
                                <option value="ESE" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"ESE") %> >ESE</option>
                                <option value="SE" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"SE") %> >SE</option>
                                <option value="SSE" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"SSE") %> >SSE</option>
                                <option value="S" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"S") %> >S</option>
                                <option value="SSW" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"SSW") %> >SSW</option>
                                <option value="SW" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"SW") %> >SW</option>
                                <option value="WSW" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"WSW") %> >WSW</option>
                                <option value="W" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"W") %> >W</option>
                                <option value="WNW" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"WNW") %> >WNW</option>
                                <option value="NW" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"NW") %> >NW</option>
                                <option value="NNW" <% =oEventEntry.DDValue("Weather.WindDirection" ,DDSEL,"NNW") %> >NNW</option>
                            </select>
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Weather.AirTemperature", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            AirTemperature
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="4" title="" name="Weather__AirTemperature" value="<% =oEventEntry.DDValue("Weather.AirTemperature") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Weather.GndTemperature", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            GndTemperature
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="4" title="" name="Weather__GndTemperature" value="<% =oEventEntry.DDValue("Weather.GndTemperature") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Weather.SnowInches", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            SnowInches
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="8" title="" name="Weather__SnowInches" value="<% =oEventEntry.DDValue("Weather.SnowInches") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oEventEntry.DDValue("Weather.Description", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            Description
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <textarea title=""  name="Weather__Description" rows="5" cols="35"><% =oEventEntry.DDValue("Weather.Description") %></textarea>
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                </table>

            </blockquote>

 				<input class="ActionButton" type="submit" name="Save" value="Save" />
                <input class="ActionButton" type="submit" name="Clear" value="Clear" />
                <input class="ActionButton" type="reset" value="Reset Form" />


        </form>
  		<!-- #INCLUDE FILE="bodybottom.inc.asp" -->
        </body>
    </html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->