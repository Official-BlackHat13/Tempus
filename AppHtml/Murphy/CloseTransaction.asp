<!-- #Include FILE="VdfAjaxLib/1-2/PageTop.inc.asp" -->
<% 
    Dim RowId
%>

<html>

<head>
    <title>AJAX Web Application</title>
    
    <meta name="GENERATOR" content=Visual DataFlex Studio">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <!-- Include all necessary Java Script libraries for the source code -->
    <!-- #Include FILE="./VdfAjaxLib/1-2/includes.inc.asp" -->

    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
</head>

<body>
    <form action="none" autocomplete="off" name="Trans_form" vdfControlName="Trans_form" vdfWebServiceUrl="webservice.wso" vdfControlType="form" vdfMainTable="Trans" vdfWebObject="oCloseTransaction" >

        <!-- Include the toolbar for the Find buttons, etc -->
        <!-- #Include FILE="VdfAjaxLib/1-2/Toolbar.inc.asp" -->

        <table>
            <tr>
                <td>Employee ID</td>
                <td>
                    <input name="Trans__Employeeidno"  style="width:4em;" />
                    <span id="Trans__Employeeidno__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Last name</td>
                <td>
                    <input name="Employee__Lastname" vdfSuggestSource="find" style="width:15em;" />
                    <span id="Employee__Lastname__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Start date</td>
                <td>
                    <input name="Trans__Startdate" style="width:8em;" />
                    <span id="Trans__Startdate__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Start time</td>
                <td>
                    <input name="Trans__Starttime"  style="width:8em;" />
                    <span id="Trans__Starttime__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Stop date</td>
                <td>
                    <input name="Trans__Stopdate"  style="width:8em;" />
                    <span id="Trans__Stopdate__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Stop time</td>
                <td>
                    <input name="Trans__Stoptime"  style="width:8em;" />
                    <span id="Trans__Stoptime__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Location</td>
                <td>
                    <input name="Location__Name"  style="width:30em;" />
                    <span id="Location__Name__error" Class="Error" />
                </td>
            </tr>
            <tr>
                <td>Operation</td>
                <td>
                    <input name="Opers__Name"  style="width:30em;" />
                    <span id="Opers__Name__error" Class="Error" />
                </td>
            </tr>
        </table>
    </form>
</body>

<% 
    RowId = Request("RowId")

    Response.Write RowId
    Err = oCloseTransaction.RequestFindByRowId("Trans", RowId)

%>

</html>
