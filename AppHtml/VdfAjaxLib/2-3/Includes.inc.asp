        <!-- Visual DataFlex AJAX Library 2.3 includes -->

        <!-- CSS files from the <%=sAjaxTheme %> theme -->
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/Library.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/Balloon.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/Calendar.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/CollapsePanel.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/DropDownMenu.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/List.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/ModalDialog.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/Scrollbar.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/TabContainer.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/TreeView.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/SpinForm.css" />

<% 
    '   Get GET parameter or cookie (GET goes before cookie)
    If (IsEmpty(sAjaxLibVersion)) Then
        If (IsEmpty(Request("ajaxlib"))) Then
            If (Not(IsEmpty(Request.cookies("ajaxlib")))) Then
                sAjaxLibVersion = Request.cookies("ajaxlib")
            End If
        Else
            sAjaxLibVersion = Request("ajaxlib")
        End If
    End If
    
    '   Switch between the different versions
    If (sAjaxLibVersion = "full") Then
%>        <!-- JavaScript files, full debug version (full source in separate files) -->
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/library.js?language=<%=sAjaxLanguage %>"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/dataStructs.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/events.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/errors.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/lang.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/Control.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/Balloon.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/Calendar.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/CollapsePanel.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/CustomMenu.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/DropDownMenu.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/ModalDialog.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/PopupCalendar.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/Scrollbar.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/TabContainer.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/TreeView.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/gui/AjaxTreeView.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/settings.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/sys.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/sys/fx.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/ajax/PriorityPipe.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/ajax/RequestQueue.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/ajax/HttpRequest.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/ajax/xmlSerializer.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/ajax/jsonSerializer.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/ajax/JSONCall.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/ajax/SoapCall.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/ajax/VdfCall.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/Action.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/ClientDataDictionary.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/DEO.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/Field.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/init.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/Label.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/List.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/LookupDialog.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/MetaData.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/FormBase.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/FormMeta.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/Form.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/TextField.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/core/Toolbar.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Checkbox.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/DatePicker.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/DOM.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Grid.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Hidden.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Lookup.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Password.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Radio.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Select.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/SpinForm.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Text.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/deo/Textarea.js"></script>
<% 
    ElseIf (sAjaxLibVersion = "debug") Then 
%>        <!-- JavaScript files, debug version (without comments in a single file)  -->
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/library-full-debug.js?language=<%=sAjaxLanguage %>"></script>
<%  
    Else 
%>        <!-- JavaScript files, production version (minified in a single file)-->
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/library-full.js?language=<%=sAjaxLanguage %>"></script>
<% 
    End If 
%>
        <!-- Language file with translations in JSON format -->
        <script type="text/javascript" src="VdfAjaxLib/2-3/vdf/lang/translations_<%=sAjaxLanguage %>.js"></script>
        
        <!-- .PNG TRANSPARENT FIX FOR IE 5.5 AND IE 6 -->    
        <!--[if lte IE 6]><style type="text/css">li, img, div, .pngfix, a { behavior: url("VdfAjaxLib/2-3/extern/iepngfix/iepngfix.htc") }</style><![endif]-->   
        
<%
    If (LCase(Trim(Request("debugbuffer"))) = "true") Then
%>
<!-- #include File="DebugBuffer.inc.asp" -->
<%
    End If
%>