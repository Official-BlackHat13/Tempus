<!-- #include FILE="pagetop.inc.asp" -->
<%
    Dim iErr
    iErr = oAreaStandards.RequestClear("areas",1)
%>

<html>

<head>
    <title>Tempus - Area Standards</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <!-- #include FILE="head.inc.asp" -->
</head>

<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" autocomplete="off" name="Areas_form" vdfControlName="Areas_form" vdfWebServiceUrl="webservice.wso" vdfControlType="form" vdfMainTable="Areas" vdfServerTable="Areas" vdfWebObject="oAreaStandards" >
    <!-- Status fields -->
    <input type="hidden" size="15" name="areas__rowid" value="" />

    <table width="100%">
        <tr>
            <td>
                <% If (bEditRights) then %><h3>Areas Entry and Maintenance</h3>
                <% else %><h3>Areas Query</h3><% end if %>
            </td>
        </tr>
        <tr>
            <td>
<!-- #INCLUDE FILE="toolbar.inc.asp" -->
            </td>
        </tr>
        <tr>
            <td>
                <!-- Entry fields -->
                <blockquote class="EntryBlock">
                    <table class="EntryTable">
                        <tr>
                            <td class="Label">Area number</td>
                            <td class="Data">
                                <input type="text" name="Areas__Areanumber"  style="width:4em;" />
                                <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oAreaStandards" vdfLookupTable="Areas" vdfLookupFields="areas__name, areas__areanumber, areas__manager" />
                            </td>
                            <td Class="Error" id="Areas__Areanumber__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Name</td>
                            <td class="Data">
                                <input type="text" name="Areas__Name" vdfSuggestSource="find" style="width:30em;" />
                                <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oAreaStandards" vdfLookupTable="Areas" vdfLookupFields="areas__name, areas__areanumber, areas__manager" />
                            </td>
                            <td Class="Error" id="Areas__Name__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Manager</td>
                            <td class="Data">
                                <input type="text" name="Areas__Manager" vdfSuggestSource="find" style="width:30em;" />
                                <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oAreaStandards" vdfLookupTable="Areas" vdfLookupFields="areas__manager, areas__areanumber" />
                            </td>
                            <td Class="Error" id="Areas__Manager__error"></td>
                        </tr>
                    </table>
                </blockquote>
            </td>
        </tr>
    </table>
    </form>
    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
</body>

</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->
