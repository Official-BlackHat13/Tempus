            <!-- Navigation buttons -->
            <table class="Toolbar" >
                <tr>
                    <td class="TextCell">Navigation:</td>
                    <td class="ButtonCell"><input id="First" class="NavigationButton" type="button" name="findfirst" value="" onclick="findForm(this).doFind(dfFirst);" title="Find First (Ctrl - Home)" /></td>
                    <td class="ButtonCell"><input id="Previous" class="NavigationButton" type="button" name="findprev" value="" onclick="findForm(this).doFind(dfLT);" title="Find Previous (F7)" /></td>
                    <td class="ButtonCell"><input id="Equal" class="NavigationButton" type="button" name="find" value="" onclick="findForm(this).doFind(dfGE);" title="Find Equal (F9)" /></td>
                    <td class="ButtonCell"><input id="Next" class="NavigationButton" type="button" name="findnext" value="" onclick="findForm(this).doFind(dfGT);" title="Find Next (F8)" /></td>
                    <td class="ButtonCell"><input id="Last" class="NavigationButton" type="button" name="findlast" value="" onclick="findForm(this).doFind(dfLast);" title="Find Last (Ctrl - End)" /></td>
                    <td>&nbsp;</td>
                
                <% If (bEditRights) Then %>
                    <td class="TextCell">Editing:</td>
                    <% If (oSessionManager.call("get_HasRights", sSessionKey, "save", "", "")) Then %>
                    <td class="ButtonCell"><input id="Save" class="NavigationButton" type="button" name="save" value="" onclick="findForm(this).doSave();" title="Save (F2)" /></td>
                    <% End If %>
                    <% If (oSessionManager.call("get_HasRights", sSessionKey, "delete", "", "")) Then %>
                    <td class="ButtonCell"><input id="Delete" class="NavigationButton" type="button" name="delete" value="" onclick="findForm(this).doDelete();" title="Delete (Shift - F2)" /> </td>
                    <% End If %>
                    <% If (oSessionManager.call("get_HasRights", sSessionKey, "clear", "","")) Then %>
                    <td class="ButtonCell"><input id="Clear" class="NavigationButton" type="button" name="clear" value="" onclick="findForm(this).doClear();" title="Clear (F5)" /></td>
                    <td>&nbsp;</td>
                    <% End If %>
                <% End If %>
				</tr>
            </table>
