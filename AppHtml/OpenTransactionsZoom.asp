<% '
    ' Open Transactions (Zoom)
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
        <title>OpenTransactions Zoom</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
    </head>
    <body>


        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <h3>Open Transactions (Zoom)</h3>
        <% 
            RowId = Request("RowId")
            Err = oOpenTransactions.RequestFindByRowId("Trans", RowId)
        %>

        <table border="0" width="99%" class="ZoomTable">
            <tr>
                <th class="Header" width="20%">Field Name</th>
                <th class="Header">Value</th>
            </tr>
            <tr>
                <th class="Label" width="20%">Employeeidno</th>
                <td class="Data">
                    <% = FormatNumber(oOpenTransactions.ddValue("Trans.Employeeidno"),0) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Startdate</th>
                <td class="Data">
                    <% = oOpenTransactions.ddValue("Trans.Startdate") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Starttime</th>
                <td class="Data">
                    <% = oOpenTransactions.ddValue("Trans.Starttime") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Equipmentid</th>
                <td class="Data">
                    <% = oOpenTransactions.ddValue("Trans.Equipmentid") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Phone</th>
                <td class="Data">
                    <% = oOpenTransactions.ddValue("Trans.Callerid") %>
                </td>
            </tr>
        </table>

        <hr />

        <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
        <br />
        <a href="OpenTransactions.asp">New Report</a>

    </body>
</html>
