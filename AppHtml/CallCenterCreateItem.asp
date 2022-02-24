<!-- #include FILE="pagetop.inc.asp" -->
<% ' user must be logged in
	If (bUserLoggedIn = False) Then
		Response.Redirect "Login.asp"
	End If
%>
<html>
<head>
    <title>Call Center Item Creation</title>

    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta name="GENERATOR" content="Visual DataFlex Studio">

    <!-- #include FILE="head.inc.asp" -->

    <!-- Global stylesheet -->
    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
    <link rel="stylesheet" media="print" href="Css/Print.css" type="text/css">

    <script type="text/javascript">
        //
        // sets the defaults
        //
        
        function onSavedRecord(oEvent) {
            window.alert("Your record has been created.");
            window.location = "OpenCallCenterItems.asp";
        }
        
        function initForm(oForm){
            oForm.doClear();
            oForm.getDD("locnotes").onAfterSave.addListener(onSavedRecord);
        }
    </script>
</head>

<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" name="Locnotes_form" autocomplete="off" vdfControlType="form" vdfControlName="Locnotes_form" vdfMainTable="Locnotes" vdfServerTable="Locnotes" vdfWebObject="oCallCenterCreateItem" vdfAutoClearDeoState="false" vdfInitializer="initForm">
        <!-- Status fields -->
	    <input type="hidden" size="15" name="sUserId" value=<%=sUserId%> />

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
                    <h3>Call Center Item Creation</h3>
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
                                <td class="Label">Organization Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Order__Organization" title="Customer Name" size="50" />
                                    <input class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfIndex="5" vdfControlType="lookupdialog" vdfWebObject="oCallCenterCreateItem" vdfLookupTable="Order" vdfLookupFields="order__organization, order__locationname, order__jobnumber, order__propertymanager" />
                                </td>
                            </tr>                            
                            <tr>
                                <td class="Label">Location Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Order__LocationName" title="Location Name" size="50" vdfSuggestSource="find" />
                                    <input class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfIndex="8" vdfControlType="lookupdialog" vdfWebObject="oCallCenterCreateItem" vdfLookupTable="Order" vdfLookupFields="order__locationname, order__organization, order__jobnumber, order__propertymanager" />
                                </td>
                            </tr>                        
                            <tr>
                                <td class="Label">Address</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Location__Address1" title="Location Address1" size="30" />
                                </td>
                            </tr>                            
                            <tr>
                                <td class="Label"></td>
                                <td>
                                    <input class="Data" type="text" value="" name="Location__City" title="Location City" size="10" />
                                    <input class="Data" type="text" value="" name="Location__State" title="Location State" size="5" />
                                    <input class="Data" type="text" value="" MAXLENGTH="5" name="Location__Zip" title="Location Zip" size="9" />
                                </td>
                            </tr>                        
                            <tr>
                                <td class="Label">Job Number</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Order__Jobnumber" title="Job Number" size="10" vdfSuggestSource="find" />
                                    <input class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfIndex="1" vdfControlType="lookupdialog" vdfWebObject="oCallCenterCreateItem" vdfLookupTable="Order" vdfLookupFields="order__jobnumber, order__organization, order__locationname, order__propertymanager" />
                                </td>
                            </tr>                        
                            <tr>
                                <td class="Label">Status</td>
                                <td class="Data"> <input type="text" disabled title="Status" name="Locnotes__Status" /> </td>
                            </tr>
                            <tr>
                                <td class="Label">Caller Name</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Locnotes__CallerName" title="Locnotes CallerName" size="30" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Caller Phone</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Locnotes__CallerPhone" title="Locnotes CallerPhone" size="30" />
                                </td>
                            </tr>
                            <tr>
                            <td class="Label">Caller Email</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Locnotes__CallerEmail" title="Locnotes Caller Email" size="30" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Request Type</td>
                                <td>
                                    <input class="Data" type="text" value="" name="Reqtypes__Reqtypescode" title="Request Code." size="10" vdfSuggestSource="find" />
                                    <input class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oCallCenterCreateItem" vdfLookupTable="Reqtypes" vdfLookupFields="reqtypes__reqtypescode, reqtypes__description" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Label">Request Description</td>
                                <td class="Data"><input type="text" value="" name="Reqtypes__Description" title="Request Description." size="50" /></td>
                            </tr>
                            <tr>
                                <td class="Label">Assigned To</td>
                                <td class="Data"> <select title="Assigned To." name="Locnotes__Assignedto" /> </td>
                            </tr>
                            <tr>
                                <td class="Label">Note</td>
                                <td Class="Data"><textarea name="Locnotes__Note" title="Note." cols="55" rows="5"></textarea></td>
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
