<div id="Table">
    <div id="header">
        <div id="header-left">
        </div>
        <div id="header-main">
            <div id="company-logo">
            </div>
            <div vdfControlType="vdf.gui.CustomMenu">
                <ul class="mainmenu">
                    <li vdfElement="item"><a href="Default.asp"><div>Home</div></a></li>
                    <li vdfElement="item"><a href="Login.asp"><div>Login</div></a></li>
                    <li vdfElement="item" vdfSubMenu="reports"><a href="javascript: vdf.sys.nothing();"><div>Reporting</div></a></li>
                    <li vdfElement="item" vdfSubMenu="callcenter"><a href="javascript: vdf.sys.nothing();"><div>Call Center</div></a></li>
                    <li vdfElement="item" vdfSubMenu="events"><a href="javascript: vdf.sys.nothing();"><div>Events</div></a></li>
                </ul>
                <ul vdfElement="menu" vdfName="reports" class="submenu" style="display:none">
                    <li vdfElement="item"><a href="OpenTransactions.asp">Open Employee Transactions</a></li>
                    <li vdfElement="item"><a href="EmployeeHistory.asp">Employee Transaction History</a></li>
				</ul>
                <ul vdfElement="menu" vdfName="callcenter" class="submenu" style="display:none">
                    <li vdfElement="item"><a href="CallCenterCreateItem.asp">Item Creation</a></li>
                    <li vdfElement="item"><a href="OpenCallCenterItems.asp">Open Item List</a></li>
                </ul>
                 <ul vdfElement="menu" vdfName="events" class="submenu" style="display:none">
                    <li vdfElement="item"><a href="EventEntry.asp">Enter Event</a></li>
                    <li vdfElement="item"><a href="EventOverview.asp">Event Overview</a></li>
                </ul>
            </div>
        </div>
        <div id="header-main-right">
        	<div id="callcenter-text">
            </div>
        </div>   
        <div id="login-box">
            <% If (bUserLoggedIn) Then %>
                Logged in as: <b><%=sLoginName%></b> <a href="login.asp?action=logout">[logout]</a>
            <% Else %>
                Not logged in <a href="login.asp">[login]</a>
            <% End If %>
        </div>
   
        <div id="header-right">
        </div>            
    </div>
    
	<div id="content"> 
