<!-- #include FILE="pagetop.inc.asp" -->
<% 
    Dim RowId
    RowId = Request("RowId")
    ' Response.Write RowId
    bEditRights = True
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

        function onSavedRecord(oEvent) {
            window.alert("Your message has been sent.");
            window.location = "PropertyManagerLocations.asp";
        }

        //  loads the location
        //
	    function initForm(oForm) {
	        var iRowId = "<%=RowId%>";
	        oForm.doFindByRowId("Order", iRowId );
            oForm.getDD("locnotes").onAfterSave.addListener(onSavedRecord);
        }

    </script>
</head>

<body>
    <!-- #include FILE="PMBodyTop.inc.asp" -->
    <form action="none" name="Locnotes_form" autocomplete="off" vdfControlType="form" vdfControlName="Locnotes_form" vdfMainTable="Locnotes" vdfServerTable="Locnotes" vdfWebObject="oLocationEmail" vdfInitializer="initForm">
        <!-- Status fields -->
        <input type="hidden" name="Customer__rowid" value="" />
        <input type="hidden" name="Areas__rowid" value="" />
        <input type="hidden" name="Location__rowid" value="" />
        <!--<input type="hidden" name="Project__rowid" value="" />-->
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
                </td>
            </tr>
            <tr>
                <td>
                    <div>
                        <table class="EntryTable">
                            <tr>
                                <td class="Label">Job Number</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Order__Jobnumber" title="Job Number." size="8" vdfSuggestSource="find" vdfNoEnter="True" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Location Name</td>
                                <td>
                                    <input name="Location__Name" type="text" class="Data" title="Location Name." value="" size="40" vdfNoEnter="True" />
                                </td>
                            </tr>
                            <<tr>
                                <td class="Label">Secondary Contact Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Locnotes__CallerName" title="Locnotes CallerName" size="30" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Secondary Contact Phone</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Locnotes__CallerPhone" title="Locnotes CallerPhone" size="30" />
                                </td>
                            </tr>
                            <tr>
                            <td class="Label">Secondary Contact Email</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Locnotes__CallerEmail" title="Locnotes Caller Email" size="30" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Request Type</td>
                                <td>
                                    <input class="Data" type="text" value="SERVICE" name="Reqtypes__Reqtypescode" title="Request Code." size="10" vdfSuggestSource="find" />
                                    <input class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oCallCenterCreateItem" vdfLookupTable="Reqtypes" vdfLookupFields="reqtypes__reqtypescode, reqtypes__description" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Message</td>
                                <td class="Data"><textarea class="text_data" name="Locnotes__Note" cols="70" rows="7" title="Message."></textarea></td>                                
                            </tr>
                            <tr>
								<td><input type="button" name="save" value="Send Email" onClick="vdf.core.findForm(this).doSave();" title="Send Email" /></td>
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
