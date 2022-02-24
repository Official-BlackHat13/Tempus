<!-- #include FILE="pagetop.inc.asp" -->
<% '
    ' PropertyManagerLocationList (Zoom)
    '
    ' Option Explicit

    ' Declare Variables

    Dim DebugMode, Err
    Dim RowId
%>

<html>
    <head>
        <meta http-equiv="content-type"
        content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>PropertyManagerLocationList Zoom</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
        <!-- #include FILE="head.inc.asp" -->
    </head>
    <body>
        <!-- #include FILE="PMBodyTop.inc.asp" -->

        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <h3>PropertyManagerLocationList (Zoom)</h3>
        <% 
            RowId = Request("RowId")
            Err = oPropertyManagerLocationList.RequestFindByRowId("Location", RowId)
        %>

        <table border="0" width="50%" class="ZoomTable">
            <tr>
                <th class="Header" width="20%">Field Name</th>
                <th class="Header">Value</th>
            </tr>
            <tr>
                <th class="Label" width="20%">Name</th>
                <td class="Data">
                    <% = oPropertyManagerLocationList.ddValue("Location.Name") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Address1</th>
                <td class="Data">
                    <% = oPropertyManagerLocationList.ddValue("Location.Address1") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">City</th>
                <td class="Data">
                    <% = oPropertyManagerLocationList.ddValue("Location.City") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">State</th>
                <td class="Data">
                    <% = oPropertyManagerLocationList.ddValue("Location.State") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Zip</th>
                <td class="Data">
                    <% = oPropertyManagerLocationList.ddValue("Location.Zip") %>
                </td>
            </tr>
        </table>

        <hr />

        <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
        <br />
        <a href="PropertyManagerLocationList.asp">New Report</a>


    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
    </body>
</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->