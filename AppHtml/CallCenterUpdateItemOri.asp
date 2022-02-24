<!-- #include FILE="pagetop.inc.asp" -->
<html>
<head>
    <title>Call Center Item Update</title>

    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta name="GENERATOR" content="Visual DataFlex Studio">

    <!-- #include FILE="head.inc.asp" -->

    <!-- Global stylesheet -->
    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
    <link rel="stylesheet" media="print" href="Css/Print.css" type="text/css">

    <!-- #include File="VdfAjaxLib/2-0/Includes.inc.asp" -->

</head>

<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" name="Locnotes_form" autocomplete="off" vdfControlType="form" vdfControlName="Locnotes_form" vdfMainTable="Locnotes" vdfServerTable="Locnotes" vdfWebObject="oCallCenterUpdateItem">
        <!-- Status fields -->
        <input type="hidden" name="Customer__rowid" value="" />
        <input type="hidden" name="Areas__rowid" value="" />
        <input type="hidden" name="Location__rowid" value="" />
        <input type="hidden" name="Project__rowid" value="" />
        <input type="hidden" name="Order__rowid" value="" />
        <input type="hidden" name="Reqtypes__rowid" value="" />
        <input type="hidden" name="Locnotes__rowid" value="" />

        <table width="100%">
            <tr>
                <td>
                    <h3>Call Center Item Update</h3>
                </td>
            </tr>
            <tr>
                <td>
                    <!-- Include the toolbar for the Find buttons, etc -->
                    <!-- #Include FILE="VdfAjaxLib/2-0/Toolbar.inc.asp" -->
                </td>
            </tr>
            <tr>
                <td>
                    <div>
                        <table class="EntryTable">
                            <tr>
                                <td class="Label">Created</td>
                                <td class="Data"><input type="text" value="" name="Locnotes__Createddate" title="Created." size="10" /></td>
                            </tr>
                            <tr>
                                <td class="Label">Status</td>
                                <td class="Data"> <select title="Status." name="Locnotes__Status" /> </td>
                            </tr>
                            <tr>
                                <td class="Label">Location Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Location__Name" title="Location Name." size="50" vdfSuggestSource="find" />
                                    <input class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oCallCenterUpdateItem" vdfLookupTable="Location" vdfLookupFields="location__name, location__locationidno" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Request Type</td>
                                <td class="Data"><input type="text" value="" name="Reqtypes__Description" title="Request Type." size="50" /></td>
                            </tr>
                            <tr>
                                <td class="Label">Note</td>
                                <td Class="Data"><textarea name="Locnotes__Note" title="Note." cols="60" rows="5"></textarea></td>
                            </tr>
                            <tr>
                                <td class="Label">Assigned To</td>
                                <td class="Data"> <select title="Assigned To." name="Locnotes__Assignedto" /> </td>
                            </tr>
                            <tr>
                                <td class="Label">Resolution</td>
                                <td Class="Data"><textarea name="Locnotes__Resolution" title="Resolution." cols="60" rows="5"></textarea></td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>

    </form>

</body>

</html>
