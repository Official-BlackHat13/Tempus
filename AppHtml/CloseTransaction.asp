<!-- #include FILE="pagetop.inc.asp" -->
<% 
    Dim RowId
    RowId = Request("RowId")
    ' Response.Write RowId
%>

<html>

<head>
    <title>Tempus - Close Transaction</title>
    
    <meta name="GENERATOR" content=Visual DataFlex Studio">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <!-- #include FILE="head.inc.asp" -->

    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">

    <script type="text/javascript">
        //
        //  loads the transaction
        //
        function initForm(){
            var iRowId = "<%=RowId%>";
            vdf.getControl("Trans_form").doFindByRowId("trans", iRowId );
        }
    </script>
</head>

<body>
    <!-- #include FILE="bodytop.inc.asp" -->
    <form action="none" autocomplete="off" name="Trans_form" vdfControlName="Trans_form" vdfWebServiceUrl="webservice.wso" vdfControlType="form" vdfMainTable="Trans" vdfServerTable="Trans" vdfWebObject="oCloseTransaction" vdfInitializer="initForm" >
    <!-- Status fields -->
    <input type="hidden" size="15" name="trans__rowid" value="" />

    <table width="100%">
        <tr>
            <td>
                <% If (bEditRights) then %><h3>Close Transaction</h3>
                <% else %><h3>Please login to close this transaction</h3><% end if %>
            </td>
        </tr>
        <tr>
            <td>
<!-- #INCLUDE FILE="toolbarnofind.inc.asp" -->
            </td>
        </tr>
        <tr>
            <td>
                <!-- Entry fields -->
                <blockquote class="EntryBlock">
                    <table class="EntryTable">
                        <tr>
                            <td class="Label">Employee ID</td>
                            <td class="Data">
                                <input type="text" readonly="readonly" name="Trans__Employeeidno"  style="width:4em;" />
                            </td>
                            <td Class="Error" id="Trans__Employeeidno__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Last name</td>
                            <td class="Data">
                                <input type="text" readonly="readonly" name="Employee__Lastname" vdfSuggestSource="find" style="width:15em;" />
                            </td>
                            <td Class="Error" id="Employee__Lastname__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Phone</td>
                            <td class="Data">
                                <input type="text" readonly="readonly" name="Trans__Callerid" style="width:8em;" />
                            </td>
                            <td Class="Error" id="Trans__Callerid__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Start date</td>
                            <td class="Data">
                                <input type="text" readonly="readonly" name="Trans__Startdate" style="width:8em;" />
                            </td>
                            <td Class="Error" id="Trans__Startdate__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Start time</td>
                            <td class="Data">
                                <input type="text" readonly="readonly" name="Trans__Starttime"  style="width:8em;" />
                            </td>
                            <td Class="Error" id="Trans__Starttime__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Stop date</td>
                            <td class="Data">
                                <input type="text" name="Trans__Stopdate"  style="width:8em;" />
                            </td>
                            <td Class="Error" id="Trans__Stopdate__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Stop time</td>
                            <td class="Data">
                                <input type="text" name="Trans__Stoptime" style="width:8em;" />
                            </td>
                            <td Class="Error" id="Trans__Stoptime__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Location</td>
                            <td class="Data">
                                <input type="text" readonly="readonly" name="Location__Name"  style="width:30em;" />
                            </td>
                            <td Class="Error" id="Location__Name__error"></td>
                        </tr>
                        <tr>
                            <td class="Label">Operation</td>
                            <td class="Data">
                                <input type="text" readonly="readonly" name="Opers__Name" style="width:30em;" />
                            </td>
                            <td Class="Error" id="Opers__Name__error"></td>
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
