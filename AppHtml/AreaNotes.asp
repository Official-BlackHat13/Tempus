<!-- #include FILE="pagetop.inc.asp" -->
<% ' user must be logged in
	If (bUserLoggedIn = False) Then
		Response.Redirect "Login.asp"
	End If
%>
<html>
<head>
    <title>Tempus - Area Notes</title>
    
    <meta name="GENERATOR" content=Visual DataFlex Studio">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <!-- #include FILE="head.inc.asp" -->

    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
</head>
<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" autocomplete="off" name="Areanote_form" vdfControlName="Areanote_form" vdfWebServiceUrl="webservice.wso" vdfControlType="form" vdfMainTable="Areanote" vdfServerTable="Areanote" vdfWebObject="oAreaNotes" vdfAutoClearDeoState="false" >
    <!-- Status fields -->
    <input type="hidden" size="15" name="sUserId" value=<%=sUserId%> />

        <!-- Include the toolbar for the Find buttons, etc -->
        <!-- #Include FILE="VdfAjaxLib/2-3/Toolbar.inc.asp" -->

        <table>
            <tr>
                <td>Note date</td>
                <td>
                    <input name="Areanote__Notedate" vdfDataType="date" style="width:10em;" />
                    <span id="Areanote__Notedate__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Area Number</td>
                <td>
                    <input name="Areas__Areanumber"  style="width:4em;" />
                    <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oAreaNotes" vdfLookupTable="Areas" vdfLookupFields="areas__name, areas__areanumber" />
                    <span id="Areas__Areanumber__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Area Name</td>
                <td>
                    <input name="Areas__Name" readonly="readonly" style="width:50em;" />
                    <span id="Areas__Name__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Note</td>
                <td>
                    <textarea name="Areanote__Note" title="Additional Comments and Notes." cols="50" rows="10"></textarea>
                    <span id="Areanote__Note__error" Class="Error" />
                </td>
            </tr>
        </table>
    </form>
    <!-- #INCLUDE FILE="bodybottom.inc.asp" -->
</body>

</html>
<!-- #INCLUDE FILE="pagebottom.inc.asp" -->
