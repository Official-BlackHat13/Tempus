        <!-- Visual DataFlex AJAX Library 2.0 includes -->

        <!-- CSS files from the <%=sAjaxTheme %> theme -->
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/Library.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/Balloon.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/Calendar.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/DropDownMenu.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/List.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/ModalDialog.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/Scrollbar.css" />
        <link rel="stylesheet" href="Css/VdfAjaxLib/<%=sAjaxTheme %>/TabContainer.css" />

<% 
    '   Get GET parameter or cookie (GET goes before cookie)
    If (IsEmpty(Request("ajaxlib"))) Then
        If (Not(IsEmpty(Request.cookies("ajaxlib")))) Then
            sAjaxLibVersion = Request.cookies("ajaxlib")
        End If
    Else
        sAjaxLibVersion = Request("ajaxlib")
    End If

    '   Switch between the different versions
    If (sAjaxLibVersion = "full") Then
%>        <!-- JavaScript files, full debug version (full source in separate files) -->
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/library.js?language=<%=sAjaxLanguage %>"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/dataStructs.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/events.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/errors.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/lang.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/gui/Balloon.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/gui/Calendar.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/gui/CustomMenu.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/gui/DropDownMenu.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/gui/ModalDialog.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/gui/PopupCalendar.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/gui/Scrollbar.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/gui/TabContainer.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/settings.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/sys.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/ajax/PriorityPipe.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/ajax/RequestQueue.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/ajax/HttpRequest.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/ajax/xmlSerializer.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/ajax/jsonSerializer.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/ajax/JSONCall.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/ajax/SoapCall.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/ajax/VdfCall.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/Action.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/ClientDataDictionary.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/DEO.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/Field.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/init.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/List.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/LookupDialog.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/MetaData.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/Form.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/TextField.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/core/Toolbar.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Checkbox.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/DatePicker.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/DOM.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Grid.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Hidden.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Lookup.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Password.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Radio.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Select.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Text.js"></script>
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/deo/Textarea.js"></script>
<% 
    ElseIf (sAjaxLibVersion = "debug") Then 
%>        <!-- JavaScript files, debug version (without comments in a single file)  -->
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/library-full-debug.js?language=<%=sAjaxLanguage %>"></script>
<%  
    Else 
%>        <!-- JavaScript files, production version (minified in a single file)-->
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/library-full.js?language=<%=sAjaxLanguage %>"></script>
<% 
    End If 
%>
        <!-- Language file with translations in JSON format -->
        <script type="text/javascript" src="VdfAjaxLib/2-0/vdf/lang/translations_<%=sAjaxLanguage %>.js"></script>
        
        <!-- .PNG TRANSPARENT FIX FOR IE 5.5 AND IE 6 -->    
        <!--[if lte IE 6]><style type="text/css">li, img, div, .pngfix, input, a { behavior: url("VdfAjaxLib/2-0/extern/iepngfix/iepngfix.htc") }</style><![endif]-->   