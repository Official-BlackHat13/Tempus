<!-- #include FILE="pagetop.inc.asp" -->
<% 
    Dim RowId
    RowId = Request("RowId")
    ' Response.Write RowId
    bEditRights = True
%>
<html>
<head>
    <title>Call Center Item Update</title>

    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta name="GENERATOR" content="Visual DataFlex Studio">

    <!-- #include FILE="head.inc.asp" -->

    <!-- Global stylesheet -->
    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
    <link rel="stylesheet" media="print" href="Css/Print.css" type="text/css">

    <!-- #include File="VdfAjaxLib/2-3/Includes.inc.asp" -->

    <script type="text/javascript">

        function onSavedRecord(oEvent) {
            window.alert("Your update has been saved.");
            window.location = "OpenCallCenterItems.asp";
        }

        function onClearedRecord(oEvent) {
            window.location = "CallCenterCreateItem.asp";
        }

		function doConfirmClose(oEvent){
		    if (!confirm("Close this item?")) {
		        oEvent.stop(); // Stopping the event cancels the delete action
		    }
		}

        function onDeletedRecord(oEvent) {
        	if (oEvent.bError) {
        	}
        	else {
	            window.location = "OpenCallCenterItems.asp";
			}
        }

        //  loads the location
        //
	    function initForm(oForm) {
	        var iRowId = "<%=RowId%>";
	        oForm.doFindByRowId("Locnotes", iRowId );
            oForm.getDD("locnotes").onAfterSave.addListener(onSavedRecord);
            oForm.getDD("locnotes").onAfterClear.addListener(onClearedRecord);
	     	oForm.getDD("locnotes").onBeforeDelete.addListener(doConfirmClose);
            oForm.getDD("locnotes").onAfterDelete.addListener(onDeletedRecord);
        }

    </script>
</head>

<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" name="Locnotes_form" autocomplete="off" vdfControlType="form" vdfControlName="Locnotes_form" vdfMainTable="Locnotes" vdfServerTable="Locnotes" vdfWebObject="oCallCenterUpdateItem" vdfInitializer="initForm">
        <!-- Status fields -->
        <input type="hidden" name="Customer__rowid" value="" />
        <input type="hidden" name="Areas__rowid" value="" />
        <input type="hidden" name="Location__rowid" value="" />
        <!--<input type="hidden" name="Project__rowid" value="" />-->
        <input type="hidden" name="Order__rowid" value="" />
        <input type="hidden" name="Reqtypes__rowid" value="" />
        <input type="hidden" name="Locnotes__rowid" value="" />
        <input type="hidden" name="sUserId" value=<%=sUserId%> />

        <table width="100%">
            <tr>
                <td>
                    <h3>Call Center Item Update</h3>
                </td>
            </tr>
            <tr>
                <td>
                    <!-- Include the toolbar for the Find buttons, etc -->
                    <!-- #Include FILE="ToolbarCallCenter.inc.asp" -->
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
                                <td class="Label"></td>
                                <td class="Data"><input type="text" value="" name="Locnotes__Createdtime" title="Time." size="10" /></td>
                            </tr>
                            <tr>
                                <td class="Label">Status</td>
                                <td class="Data"> <select title="Status." name="Locnotes__Status" /> </td>
                            </tr>
                            <tr>
                                <td class="Label">Location Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Location__Name" title="Location Name." size="50" vdfSuggestSource="find" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Organization Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Customer__Name" title="Customer Name." size="50" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Caller Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Locnotes__CallerName" title="Locnotes CallerName." size="30" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Caller Phone</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Locnotes__CallerPhone" title="Locnotes CallerPhone." size="30" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Caller Email</td>
                                <td>
                                    <input type="buton" class="Data" type="text" value="" name="Locnotes__CallerEmail" title="Locnotes Email" size="30" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Request Type</td>
                                <td class="Data"><input type="text" value="" name="Reqtypes__Description" title="Request Type." size="40" /></td>
                            </tr>
                            <tr>
                                <td class="Label">Note</td>
                                <td Class="Data"><textarea name="Locnotes__Note" title="Note." cols="60" rows="4"></textarea></td>
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
    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
</body>
</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->
