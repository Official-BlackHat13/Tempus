<% '
    ' InvoiceHistoryReport (Zoom)
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
        <title>InvoiceHistoryReport Zoom</title>
        <link rel="STYLESHEET" href="css/Print.css" type="text/css" />
    </head>
    <body>


        <!-- #INCLUDE FILE="inc/ddValue_Constants.inc" -->

        <% ' DebugMode = 1 ' uncomment this for page get/post debug help %>
        <!-- #INCLUDE FILE="inc/DebugHelp.inc" -->

        <h3>InvoiceHistoryReport (Zoom)</h3>
        <% 
            RowId = Request("RowId")
            Err = oInvoiceHistoryReport.RequestFindByRowId("Invhdr", RowId)
        %>

        <table border="0" width="99%" class="ZoomTable">
            <tr>
                <th class="Header" width="20%">Field Name</th>
                <th class="Header">Value</th>
            </tr>
            <tr>
                <th class="Label" width="20%">Invoiceidno</th>
                <td class="Data">
                    <% = FormatNumber(oInvoiceHistoryReport.ddValue("Invhdr.Invoiceidno"),0) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Invoicedate</th>
                <td class="Data">
                    <% = oInvoiceHistoryReport.ddValue("Invhdr.Invoicedate") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Terms</th>
                <td class="Data">
                    <% = oInvoiceHistoryReport.ddValue("Invhdr.Terms") %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Totalamount</th>
                <td class="Data">
                    <% = FormatNumber(oInvoiceHistoryReport.ddValue("Invhdr.Totalamount"),2) %>
                </td>
            </tr>
            <tr>
                <th class="Label" width="20%">Jobnumber</th>
                <td class="Data">
                    <% = FormatNumber(oInvoiceHistoryReport.ddValue("Invhdr.Jobnumber"),0) %>
                </td>
            </tr>
        </table>

        <hr />

        <a href="#" onClick="history.go(-1);return false;">Previous Page</a>&nbsp;
        <br />
        <a href="InvoiceHistoryReport.asp">New Report</a>


    </body>
</html>
