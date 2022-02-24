<% '
    ' EventOverview (Zoom)
    '
    'Option Explicit

    ' Declare Variables

    Dim DebugMode, Err
    Dim RowId
%>

<html>
    <head>
        <meta http-equiv="content-type"
        content="text/html;charset=iso-8859-1" />
        <meta name="generator" content="Visual DataFlex Studio" />
        <title>EventOverview Zoom</title>
        <link rel="STYLESHEET" href="css/WebApp.css" type="text/css" />
    </head>
    <body>


        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <h3>EventOverview (Zoom)</h3>
        <% 
            RowId = Request("RowId")
            Err = oEventOverview.RequestFindByRowId("Weather", RowId)
        %>

        <table border="0" width="99%" class="ZoomTable">
            <tr>
                <th class="Header" width="20%">Field Name</th>
                <th class="Header">Value</th>
            </tr>
            <tr>
                <th class="Label" width="20%">WeatherId</th>
                <td class="Data">
                    <% = FormatNumber(oEventOverview.ddValue("Weather.WeatherId"),0) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">AreaNumber</th>
                <td class="Data">
                    <% = FormatNumber(oEventOverview.ddValue("Weather.AreaNumber"),0) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">EventDate</th>
                <td class="Data">
                    <% = oEventOverview.ddValue("Weather.EventDate") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">EventTime</th>
                <td class="Data">
                    <% = oEventOverview.ddValue("Weather.EventTime") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">WindVelocity</th>
                <td class="Data">
                    <% = FormatNumber(oEventOverview.ddValue("Weather.WindVelocity"),0) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">WindDirection</th>
                <td class="Data">
                    <% = oEventOverview.ddValue("Weather.WindDirection" ,DDDESC) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">AirTemperature</th>
                <td class="Data">
                    <% = FormatNumber(oEventOverview.ddValue("Weather.AirTemperature"),0) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">GndTemperature</th>
                <td class="Data">
                    <% = FormatNumber(oEventOverview.ddValue("Weather.GndTemperature"),0) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">SnowInches</th>
                <td class="Data">
                    <% = FormatNumber(oEventOverview.ddValue("Weather.SnowInches"),0) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Description</th>
                <td class="Data">
                    <% = oEventOverview.ddValue("Weather.Description") %>
                </td>
            </tr>
        </table>

        <hr />

        <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
        <br />
        <a href="EventOverview.asp">New Report</a>


    </body>
</html>
