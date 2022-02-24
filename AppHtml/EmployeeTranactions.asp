<!-- #Include FILE="VdfAjaxLib/2-3/PageTop.inc.asp" -->

<html>
    
<head>
    <title>AJAX Web Application</title>

    <meta name="GENERATOR" content=Visual DataFlex Studio">
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <!-- Include all necessary Java Script libraries for the source code -->
    <!-- #Include FILE="./VdfAjaxLib/2-3/includes.inc.asp" -->

    <link rel="stylesheet" href="Css/WebApp.css" type="text/css">
</head>

<body>

<form action="none" autocomplete="off" name="Employee_form" vdfControlType="form" vdfControlName="Employee_form" vdfWebServiceUrl="webservice.wso" vdfServerTable="Employee" vdfMainTable="Employee" vdfServerTable="Employee" vdfWebObject="oEmployeeTranactions" >
<input type="hidden" size="15" name="Employer__rowid" value="" />
<input type="hidden" size="15" name="Employee__rowid" value="" />
<input type="hidden" size="15" name="Customer__rowid" value="" />
<input type="hidden" size="15" name="Areas__rowid" value="" />
<input type="hidden" size="15" name="Location__rowid" value="" />
<input type="hidden" size="15" name="MastOps__rowid" value="" />
<input type="hidden" size="15" name="Opers__rowid" value="" />
<input type="hidden" size="15" name="Order__rowid" value="" />
<input type="hidden" size="15" name="Trans__rowid" value="" />

<table width="100%">
    <tr>
        <td>
            <!-- Include the toolbar for the Find buttons, etc -->
            <!-- #Include FILE="VdfAjaxLib/2-3/Toolbar.inc.asp" -->
        </td>
    </tr>
    <tr>
        <td>
            <table>
                <tr>
                    <td>Employeeidno</td>
                    <td>
                        <input name="Employee__Employeeidno"  size="8" />
                        <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oEmployeeTranactions" vdfLookupTable="Employee" vdfLookupFields="employee__lastname, employee__firstname, employee__middlename, employee__employeeidno" />
                        <span id="Employee__Employeeidno__error" Class="Error" />
                    </td>
                </tr>
                <tr>
                    <td>Lastname</td>
                    <td>
                        <input name="Employee__Lastname" vdfSuggestSource="find" size="30" />
                        <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oEmployeeTranactions" vdfLookupTable="Employee" vdfLookupFields="employee__lastname, employee__firstname, employee__middlename, employee__employeeidno" />
                        <span id="Employee__Lastname__error" Class="Error" />
                    </td>
                </tr>
                <tr>
                    <td>Firstname</td>
                    <td>
                        <input name="Employee__Firstname"  size="30" />
                        <span id="Employee__Firstname__error" Class="Error" />
                    </td>
                </tr>
                <tr>
                    <td>Name</td>
                    <td>
                        <input name="Employer__Name" vdfSuggestSource="find" size="60" />
                        <input Class="LookupButton" type="button" title="List of all records" tabindex="-1" vdfControlType="lookupdialog" vdfWebObject="oEmployeeTranactions" vdfLookupTable="Employer" vdfLookupFields="employer__name, employer__employeridno" />
                        <span id="Employer__Name__error" Class="Error" />
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <table class="VdfGrid" vdfControlType="grid" vdfControlName="Trans_grid" vdfServerTable="Trans" vdfMainTable="Trans" vdfIndex="3" vdfRowLength="10" vdfCssEmptyRow="EmptyRow" vdfCssNewRow="NewRow">
                <tr vdfRowType="header">
                    <th vdfDataBinding="Trans__Startdate">Startdate</th>
                    <th vdfDataBinding="Trans__Starttime">Starttime</th>
                    <th vdfDataBinding="Location__Name">Name</th>
                    <th vdfDataBinding="Opers__Name">Name</th>
                </tr>
                <tr vdfRowType="display">
                    <td vdfDataBinding="Trans__Startdate">&nbsp;</td>
                    <td vdfDataBinding="Trans__Starttime">&nbsp;</td>
                    <td vdfDataBinding="Location__Name">&nbsp;</td>
                    <td vdfDataBinding="Opers__Name">&nbsp;</td>
                </tr>
                <tr vdfRowType="edit">
                    <td>
                        <input type="text" size="10" name="Trans__Startdate" value="" />
                    </td>
                    <td>
                        <input type="text" size="10" name="Trans__Starttime" value="" />
                    </td>
                    <td>
                        <input type="text" size="40" name="Location__Name" value="" />
                    </td>
                    <td>
                        <input type="text" size="50" name="Opers__Name" value="" />
                    </td>
                </tr>
            </table>       
        </td>
    </tr>                                    
</table>

</form>

</body>

</html>


        



