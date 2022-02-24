<div id="Table">
    <div id="header">
        <div id="header-left">
        </div>
        <div id="header-main">
            <div vdfControlType="vdf.gui.CustomMenu">
                <ul class="mainmenu">
                    <li vdfElement="item"><a href="Default.asp"><div>Home</div></a></li>
                    <li vdfElement="item"><a href="Login.asp"><div>Login</div></a></li>
                    <li vdfElement="item" vdfSubMenu="dataentry"><a href="javascript: vdf.sys.nothing();"><div>Data Entry</div></a></li>
                    <li vdfElement="item" vdfSubMenu="reports"><a href="javascript: vdf.sys.nothing();"><div>Reporting</div></a></li>
                    <li vdfElement="item" vdfSubMenu="callcenter"><a href="javascript: vdf.sys.nothing();"><div>Call Center</div></a></li>
                </ul>
                <ul vdfElement="menu" vdfName="dataentry" class="submenu" style="display:none">
                    <li vdfElement="item"><a href="AreaNotes.asp">Area Notes</a></li>
                    <li vdfElement="item"><a href="LocationNotes.asp">Location Notes</a></li>
                </ul>
                <ul vdfElement="menu" vdfName="reports" class="submenu" style="display:none">
                    <% ' If (bUserLoggedIn) Then %>
                    <li vdfElement="item"><a href="OpenTransactions.asp">Open Employee Transactions</a></li>
                    <li vdfElement="item"><a href="EmployeeHistory.asp">Employee Transaction History</a></li>
                    <% ' End If %>
				</ul>
                <ul vdfElement="menu" vdfName="callcenter" class="submenu" style="display:none">
                    <li vdfElement="item"><a href="CallCenterCreateItem.asp">Item Creation</a></li>
                    <li vdfElement="item"><a href="OpenCallCenterItems.asp">Open Item List</a></li>
                </ul>
            </div>
        </div>
        <div id="header-right">
        </div>
        <div id="company-logo">
            <% If (bUserLoggedIn) Then %>
                Logged in as: <b><%=sLoginName%></b> <a href="login.asp?action=logout">[logout]</a>
            <% Else %>
                Not logged in <a href="login.asp">[login]</a>
            <% End If %>
        </div>
        
    </div>
    
	<div id="content"> 
