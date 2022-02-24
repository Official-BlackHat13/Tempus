<!-- #include FILE="pagetop.inc.asp" -->

<html>

<head>
    <title>AJAX Web Application</title>
    
    <meta name="GENERATOR" content=Visual DataFlex Studio">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <!-- Include all necessary Java Script libraries for the source code -->
    <!-- #Include FILE="./VdfAjaxLib/2-0/includes.inc.asp" -->

    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
</head>

<body>
    <form action="none" autocomplete="off" name="Order_form" vdfControlName="Order_form" vdfWebServiceUrl="webservice.wso" vdfControlType="form" vdfMainTable="Order" vdfServerTable="Order" vdfWebObject="oLocationNotes" >
    <!-- Status fields -->
    <input type="hidden" size="15" name="sUserId" value=<%=sUserId%> />

        <!-- Include the toolbar for the Find buttons, etc -->
        <!-- #Include FILE="VdfAjaxLib/2-0/Toolbar.inc.asp" -->

        <table>
            <tr>
                <td>Jobnumber</td>
                <td>
                    <input name="Locnotes__Jobnumber"  style="width:8em;" />
                    <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oLocationNotes" vdfLookupTable="Order" vdfLookupFields="Locnotes__jobnumber" />
                    <span id="Locnotes__Jobnumber__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Notedate</td>
                <td>
                    <input name="Locnotes__Notedate"  style="width:10em;" />
                    <span id="Locnotes__Notedate__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Note</td>
                <td>
                    <textarea name="Locnotes__Note" title="Additional Comments and Notes." cols="50" rows="10"></textarea>
                    <span id="Locnotes__Note__error" Class="Error" />
                </td>
            </tr>
        </table>
    </form>
</body>

</html>


        



