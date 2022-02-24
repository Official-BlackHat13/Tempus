<!-- #include FILE="pagetop.inc.asp" -->
<% ' user must be logged in
	If (bUserLoggedIn = False) Then
		Response.Redirect "Login.asp"
	End If
%>
<% 
    Dim RowId
    RowId = Request("RowId")
    ' Response.Write RowId
    bEditRights = True
%>

<html>
<head>
    <title>Email the Property Manager</title>

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
    <form action="none" name="Locnotes_form" autocomplete="off" vdfControlType="form" vdfControlName="Locnotes_form" vdfMainTable="Locnotes" vdfServerTable="Locnotes" vdfWebObject="oFollowupEmail" vdfInitializer="initForm">
        <!-- Status fields -->
        <input type="hidden" name="Customer__rowid" value="" />
        <input type="hidden" name="Areas__rowid" value="" />
        <input type="hidden" name="Location__rowid" value="" />
        <input type="hidden" name="Order__rowid" value="" />
        <input type="hidden" name="Locnotes__rowid" value="" />
        <input type="hidden" name="sUserId" value=<%=sUserId%> />

        <table width="100%">
            <tr>
                <td>
                    <h3>Email the Property Manager</h3>
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
                                <td class="Label">Location Name</td>
                                <td><input name="Location__Name" type="text" class="Data" title="Location Name" value="" size="60" vdfNoEnter="True" /></td>
                            </tr>                            
                            
                            <tr>
								<td><input type="button" name="save" value="Send Email" onClick="vdf.core.findForm(this).doSave();" title="Email" /></td>
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
