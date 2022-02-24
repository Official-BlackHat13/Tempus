<% '
    ' PropertyManagerNavigation (Zoom)
    '
    Option Explicit

    ' Declare Variables

    Dim DebugMode, Err
    Dim RowId
%>

<html>
    <head>
        <meta http-equiv="content-type"
        content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>PropertyManagerNavigation Zoom</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
    </head>
    <body>


        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <h3>PropertyManagerNavigation (Zoom)</h3>
        <% 
            RowId = Request("RowId")
            Err = oPropertyManagerNavigation.RequestFindByRowId("Customer", RowId)
        %>

        <table border="0" width="99%" class="ZoomTable">
            <tr>
                <th class="Header" width="20%">Field Name</th>
                <th class="Header">Value</th>
            </tr>
            <tr>
                <th class="Label" width="20%">ContactName</th>
                <td class="Data">
                    <% = oPropertyManagerNavigation.ddValue("Customer.ContactName") %>
                </td>
            </tr>
        </table>

        <hr />

        <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
        <br />
        <a href="PropertyManagerNavigation.asp">New Report</a>


    </body>
</html>
