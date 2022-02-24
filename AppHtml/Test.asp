<!-- #include FILE="pagetop.inc.asp" -->

<% '
    '  Test
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
        <meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>Test</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
         <!-- #include FILE="head.inc.asp" -->
    </head>

    <body topmargin="5" leftmargin="5">
		<!-- #include FILE="PMBodyTop.inc.asp" -->
        <% CheckFieldChange=oTest.Call("Get_peFieldMultiUser") %>
        <!-- #INCLUDE FILE="inc/SetChangedStates-script.inc" -->

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <h3>Test</h3>

        <% 
            oTest.Call "Set_pbReportErrors", 1 'Normally show any errors that occur
            'We either find a record, or clear the WBO
            If RowId <> "" Then
                Err = oTest.RequestFindbyRowId( "Employee", RowId)
            Else 
                Err = oTest.RequestClear("Employee",1)
            End If

            ' process various buttons that might have been pressed.
            ' only support Post submissions
            If Request ("Request_Method") = "POST" Then

                If Request ("Clear") <> "" Then
                    Err = oTest.RequestClear("Employee",1)
                End If

                If Request ("Save") <> "" then
                    oTest.Call "Set_pbReportErrors", 0
                    Err = oTest.RequestSave("Employee")
                    If Err = 0 Then
                        Response.Write("<center><h4>Employee Record Saved</h4> </center>")
                    Else
                        Response.Write("<font color=""red"">")
                        Response.Write("<center><h4>Could not save changes. Errors Occurred</h4> </center>")
                        oTest.Call "Msg_ReportAllErrors"
                        Response.Write("</font>")
                    End If
                End If

                If Request("Delete") <> "" Then
                    oTest.Call "Set_pbReportErrors", 0
                    Err = oTest.RequestDelete("Employee")
                    If Err = 0 Then
                        Response.Write("<center><h4>The record has been deleted.</h4></center>")
                    Else
                        Response.Write("<font color=""red"">")
                        Response.Write("<center><h4>The record could not be deleted.</h4></center>")
                        oTest.Call "Msg_ReportAllErrors"
                        Response.Write("</font>")
                    End If
                End If

                ' note we use the Index variable we created above
                If Request("FindPrev") <> "" Then Err = oTest.RequestFind("Employee", Index, LT)
                If Request("Find") <> "" Then Err = oTest.RequestFind("Employee", Index, GE)
                If Request("FindNext") <> "" Then  Err = oTest.RequestFind("Employee", Index, GT)
                If Request("FindFirst") <> "" Then  Err = oTest.RequestFind("Employee", Index, FIRST_RECORD)
                If Request("FindLast") <> "" Then Err = oTest.RequestFind("Employee", Index, LAST_RECORD)

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

        <form action="Test.asp" method="post" name="Employee" OnSubmit="SetChangedStates(this)">

            <% ' You MUST have a hidden Rowid field for each DDO in your WBO %>
            <input type="hidden" size="15" name="Employer__RowId" value="<% =oTest.DDValue("Employer.RowId") %>" />
            <input type="hidden" size="15" name="Employee__RowId" value="<% =oTest.DDValue("Employee.RowId") %>" />

            <% ' This is needed if you need field level change state checking %>
            <input type="hidden" name="ChangedStates" value="" />

            <p class="Toolbar">
                Find 
                <input class="ActionButton" type="submit" name="FindFirst" value="&lt;&lt;" />
                <input class="ActionButton" type="submit" name="FindPrev" value="&lt;" />
                <input class="ActionButton" type="submit" name="Find" value="=" />
                <input class="ActionButton" type="submit" name="FindNext" value="&gt;" />
                <input class="ActionButton" type="submit" name="FindLast" value="&gt;&gt;" />
                 By 
                <select size="1" name="Index">
                    <option value="1" <% =ShowSelected(Index,1) %> >EmployeeIdno</option>
                    <option value="2" <% =ShowSelected(Index,2) %> >LastName</option>
                    <option value="3" <% =ShowSelected(Index,3) %> >ChangedFlag</option>
                    <option value="4" <% =ShowSelected(Index,4) %> >CallCenterFlag</option>
                </select>

            &nbsp;&nbsp;
                <input class="ActionButton" type="submit" name="Clear" value="Clear" />
            </p>

            <blockquote class="EntryBlock">

                <table border="0" class="EntryTable">
                    <tr>
                        <% FieldError=oTest.DDValue("Employee.FirstName", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            FirstName
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="30" title="" name="Employee__FirstName" value="<% =oTest.DDValue("Employee.FirstName") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oTest.DDValue("Employee.LastName", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            LastName
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="30" title="" name="Employee__LastName" value="<% =oTest.DDValue("Employee.LastName") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oTest.DDValue("Employee.Address1", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            Address1
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="50" title="" name="Employee__Address1" value="<% =oTest.DDValue("Employee.Address1") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oTest.DDValue("Employee.City", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            City
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="35" title="" name="Employee__City" value="<% =oTest.DDValue("Employee.City") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oTest.DDValue("Employee.State", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            State
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="2" title="" name="Employee__State" value="<% =oTest.DDValue("Employee.State") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oTest.DDValue("Employee.Zip", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            Zip
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="10" title="" name="Employee__Zip" value="<% =oTest.DDValue("Employee.Zip") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                    <tr>
                        <% FieldError=oTest.DDValue("Employee.EmailAddress", DDFIELDERROR) %>
                        <td class="Label">
                            <% If FieldError <> "" Then Response.Write ("<font color=""red"">") %>
                            EmailAddress
                            <% If FieldError <> "" Then Response.Write ("</font>") %>
                        </td>
                        <td class="Data">
                            <input type="text" size="50" title="" name="Employee__EmailAddress" value="<% =oTest.DDValue("Employee.EmailAddress") %>" />
                        </td>
                        <% If FieldError <> "" Then %>
                            <td class="Error">
                                <% =FieldError %>
                            </td>
                        <% End If %>
                    </tr>
                </table>

            </blockquote>

        </form>
    	<!-- #INCLUDE FILE="bodybottom.inc.asp" -->
        </body>
    </html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->