            <!-- Navigation buttons -->
            <table class="Toolbar" vdfControlType="vdf.core.Toolbar" vdfName="main_toolbar" cellpadding="0" cellspacing="0"> 
                <tr>
                <% If (bEditRights) Then %>
                    <td class="TextCell"> </td>
                    <% If (oSessionManager.call("get_HasRights", sSessionKey, "save", "", "")) Then %>
                    <td class="ButtonCell"><input id="Save" class="NavigationButton" type="button" name="save" value="" onclick="vdf.core.findForm(this).doSave();" title="Save (F2)" /></td>
                    <% End If %>
                    <% If (oSessionManager.call("get_HasRights", sSessionKey, "clear", "","")) Then %>
                    <td class="ButtonCell"><input id="Clear" class="NavigationButton" type="button" name="clear" value="" onclick="vdf.core.findForm(this).doClear();" title="Clear (F5)" /></td>
                    <td>&nbsp;</td>
                    <% End If %>
                <% End If %>
				</tr>
            </table>
