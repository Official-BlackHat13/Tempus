<!-- #include FILE="pagetop.inc.asp" -->
<% 
    Dim RowId
    RowId = Request("RowId")
    Response.Write RowId
%>
<html>

<head>
    <title>Tempus - Contact Us</title>
    
    <meta name="GENERATOR" content=Visual DataFlex Studio">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <!-- #include FILE="head.inc.asp" -->

    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">

    <script type="text/javascript">
        //
        //  loads the Order
        //
        function initForm(){
            var iRowId = "<%=RowId%>";
            vdf.getControl("Locnotes_form").doFindByRowId("Order", iRowId );
        }
    </script>
</head>

<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" autocomplete="off" name="Locnotes_form" vdfControlName="Locnotes_form" vdfWebServiceUrl="webservice.wso" vdfControlType="form" vdfMainTable="Locnotes" vdfServerTable="Locnotes" vdfWebObject="oLocationEmail" vdfAutoClearDeoState="false" >
    <!-- Status fields -->
    <input type="hidden" size="15" name="sUserId" value=<%=sUserId%> />

        <!-- Include the toolbar for the Find buttons, etc -->
        <!-- #Include FILE="VdfAjaxLib/2-0/Toolbar.inc.asp" -->

        <table>
            <tr>
                <td>Note date</td>
                <td>
                    <input type="text" value="" name="Locnotes__Notedate" size="10"/>
                    <input class="CalendarButton" type="button" vdfControlType="PopupCalendar" vdfFieldName="locnotes__notedate" title="Pick a date" tabindex="-1" />
                    <span id="Locnotes__Notedate__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Job Number</td>
                <td>
                    <input name="Order__Jobnumber"  style="width:6em;" />
                    <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oLocationNotes" vdfLookupTable="Order" vdfLookupFields="order__jobnumber, location__name" />
                    <span id="Order__Jobnumber__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Location Name</td>
                <td>
                    <input name="Location__Name" readonly="readonly" style="width:25em;" />
                    <span id="Location__Name__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Note</td>
                <td>
                    <textarea name="Locnotes__Note" title="Additional Comments and Notes." cols="70" rows="18"></textarea>
                    <span id="Locnotes__Note__error" Class="Error" />
                </td>
            </tr>
        </table>
    </form>
    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
</body>

</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->
