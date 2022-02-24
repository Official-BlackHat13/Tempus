<!-- #include FILE="pagetop.inc.asp" -->

<html>

<head>
    <title>Tempus - Area Standards</title>
    
    <meta name="GENERATOR" content=Visual DataFlex Studio">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <!-- Include all necessary Java Script libraries for the source code -->
    <!-- #Include FILE="./VdfAjaxLib/2-3/includes.inc.asp" -->

    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
</head>

<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" autocomplete="off" name="Areas_form" vdfControlName="Areas_form" vdfWebServiceUrl="webservice.wso" vdfControlType="form" vdfMainTable="Areas" vdfServerTable="Areas" vdfWebObject="oAreaStandards" >

        <!-- Include the toolbar for the Find buttons, etc -->
        <!-- #Include FILE="VdfAjaxLib/2-3/Toolbar.inc.asp" -->

        <table>
            <tr>
                <td>Areanumber</td>
                <td>
                    <input name="Areas__Areanumber"  style="width:4em;" />
                    <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oAreaStandards" vdfLookupTable="Areas" vdfLookupFields="areas__name, areas__areanumber" />
                    <span id="Areas__Areanumber__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Name</td>
                <td>
                    <input name="Areas__Name" vdfSuggestSource="find" style="width:50em;" />
                    <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oAreaStandards" vdfLookupTable="Areas" vdfLookupFields="areas__name, areas__areanumber" />
                    <span id="Areas__Name__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Manager</td>
                <td>
                    <input name="Areas__Manager" vdfSuggestSource="find" style="width:50em;" />
                    <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oAreaStandards" vdfLookupTable="Areas" vdfLookupFields="areas__manager, areas__areanumber" />
                    <span id="Areas__Manager__error" Class="Error" />
                </td>
            </tr>
        </table>
    </form>
    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
</body>

</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->
