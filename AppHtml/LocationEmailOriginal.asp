<!-- #include FILE="pagetop.inc.asp" -->
<% 
    Dim RowId
    RowId = Request("RowId")
    Response.Write RowId
%>

<html>

<head>
    <title>Contact us by email</title>

    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta name="GENERATOR" content="Visual DataFlex Studio">

    <!-- #include FILE="head.inc.asp" -->

    <!-- Global stylesheet -->
    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
    <link rel="stylesheet" media="print" href="Css/Print.css" type="text/css">

    <script type="text/javascript">
        //
        //  loads the location
        //
        function initForm(){
            var iRowId = "<%=RowId%>";
            vdf.getControl("Locnotes_form").doFindByRowId("Order", iRowId );
        }
    </script>
</head>

<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" name="Locnotes_form" autocomplete="off" vdfControlType="form" vdfControlName="Locnotes_form" vdfMainTable="Locnotes" vdfServerTable="Locnotes" vdfWebObject="oLocationEmail">
        <!-- Status fields -->
        <input type="hidden" name="Customer__rowid" value="" />
        <input type="hidden" name="Areas__rowid" value="" />
        <input type="hidden" name="Location__rowid" value="" />
        <input type="hidden" name="Project__rowid" value="" />
        <input type="hidden" name="Order__rowid" value="" />
        <input type="hidden" name="Locnotes__rowid" value="" />
        <input type="hidden" name="sUserId" value=<%=sUserId%> />

        <table width="100%">
            <tr>
                <td>
                    <h3>Send email to Interstate Removal</h3>
                </td>
            </tr>
            <tr>
                <td>
<!-- #INCLUDE FILE="toolbarnofind.inc.asp" -->
                </td>
            </tr>
            <tr>
                <td>
                    <div>
                        <table class="EntryTable">
                            <tr>
                                <td class="Label">Job Number</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Order__Jobnumber" title="Job Number." size="8" vdfSuggestSource="find" />
                                    <input class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oLocationEmail" vdfLookupTable="Order" vdfLookupFields="order__jobnumber, location__name" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Location Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Location__Name" title="Location Name." size="40" readonly="readonly" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Message</td>
                                <td Class="Data"><textarea name="Locnotes__Note" title="Message." cols="70" rows="15"></textarea></td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>

    </form>
    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
</body>

</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->
