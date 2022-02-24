Use Windows.pkg
Use DFClient.pkg
Use cDbScrollingContainer.pkg
Use cTimer.pkg
Use cScrollingContainer.pkg
//Use cDynamicAiReport.pkg

Activate_View Activate_oDashboard for oDashboard
Object oDashboard is a View
    Set Size to 320 586
    Set Location to 0 0
    Set Label to "Dashboard"
    //Set Maximize_Icon to True
    Set Minimize_Icon to False
    //Set View_Mode to Viewmode_Zoom
    //Set pbSizeToClientArea to True
    Set Border_Style to Border_None
    Set Caption_Bar to False
    
    Property Integer piFullSize
    Property Boolean pbIsMaximized False

    Object oAutoHideDashboardTimer is a cTimer
        Set piTimeout to 10000

        Procedure OnTimer
            Forward Send OnTimer
            Set pbIsMaximized to True
            Send PositionToggleSwitch of oDashboard
            Set pbEnabled to False
        End_Procedure
        
    End_Object

    Object DashboardRefreshTimer is a cTimer
        Set piTimeout to 10000
        Set pbEnabled to True

        Procedure OnTimer
            Forward Send OnTimer
            Set Label_FontWeight of oForm1 to FW_BOLD
            Set Label_TextColor of oForm1 to clRed
            //Send Bell
        End_Procedure
        
    End_Object

//    Procedure Page Integer iPageObject
//        Handle hoClient
//        Integer iClientSize
//        
//        Get Client_Id to hoClient
//        Get GuiClientSize of hoClient to iClientSize  // get the size of the client area
//        Set GuiSize to (Hi(iClientSize)) (Low(iClientSize))  // set the size of the view to fill the client area
//        //Send ToggleSlide of oDashboard
//        Set peAnchors to anAll
//        Forward Send Page iPageObject
//        //
//        //Send ToggleSlide of oDashboard
//    End_Procedure

//    Object oGroup1 is a Group
//        Set Size to 10 10
//        Set Location to 0 0
//        Set Label to 'Sales'
//
//        Procedure Activating
//            Integer iDashboardWindowSize
//            Get GuiWindowSize(Self) to iDashboardWindowSize
//            Forward Send Activating
//            If (gsUserGroup="Sales") Begin
//                Set Size to (Hi(iDashboardWindowSize)) (Low(iDashboardWindowSize))
//            End
//        End_Procedure
//
//
//        
//    End_Object
//
//    Object oGroup2 is a Group
//        Set Size to 20 20
//        Set Location to 0 0
//        Set Label to 'Operations'
//    End_Object
//
//    Object oGroup3 is a Group
//        Set Size to 30 30
//        Set Location to 0 0
//        Set Label to 'Administration'
//    End_Object
//
//    Object oGroup4 is a Group
//        Set Size to 40 40
//        Set Location to 0 0
//        Set Label to 'Management'
//    End_Object
//
//    Object oGroup5 is a Group
//        Set Size to 315 533
//        Set Location to 1 1
//        Set Label to 'System Administrator'
//        Set peAnchors to anAll
//    End_Object

    Object oToggleDashboardButton is a Button
        Set Size to 321 15
        Set Location to 0 571
        Set Label to '<<'
        Set peAnchors to anTopBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            //Toggle
            Send PositionToggleSwitch of oDashboard
        End_Procedure 
    End_Object

    Object oDashboardContainer is a Container3d
        Set Size to 320 572
        Set Location to 0 0

        Object oScrollingContainer1 is a cScrollingContainer
            Object oScrollingClientArea1 is a cScrollingClientArea
                
                Object oForm1 is a Form
                    Set Size to 13 100
                    Set Location to 28 101
                    Set Enabled_State to False
                    Set Label to "Invoice History"
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    
                
                    // OnChange is called on every changed character
                //    Procedure OnChange
                //        String sValue
                //    
                //        Get Value to sValue
                //    End_Procedure
                
                End_Object
                
                
                
                
                
            End_Object
        End_Object

        Set peAnchors to anAll
    End_Object

//    Procedure DoAlignObject Handle hoParent Handle hoChild String sVertAlign String sHorAlign
//        //Formula:
//        If (sVertAlign="Center") Begin
//            
//        End
//        //  Hi((HightOfParent/2) - (HightOfChild/2))
//        //  Low((WidthOfParent/2) - (WidthOfChild/2))
//    End_Procedure

//    Procedure PositionToggleSwitch Boolean bMaxStatus
//        Handle hoView hoButton hoClient
//        Integer iWCurSize iCurClientSize iCurGuiSize iButtonSize 
//        Integer iWCurDiaSize iWCurHeight iWCurWidth iWDiaHeight iWDiaWidth
//        Integer iBCurHeight iBCurWidth iBNewHeight iBNewWidth 
//        //
//        //Current GUI Size
//        Get GuiSize to iCurGuiSize
//        //Current Client Size
//        Get GuiClientSize of oDashboard to iCurClientSize
//        //Current Button Size
//        Get Size of oToggleDashboardButton to iButtonSize
//        Move (Hi(iButtonSize)) to iBCurHeight
//        Move (Low(iButtonSize)) to iBCurWidth
//        //Current Window Size
//        Get GuiWindowSize of Self to iWCurSize  // get the size of the client area
//        Move (Hi(iWCurSize)) to iWCurHeight
//        Move (Low(iWCurSize)) to iWCurWidth
//        //translate gui to dialog size
//        Get GuiToDialog iWCurHeight iWCurWidth to iWCurDiaSize
//        Move (Hi(iWCurDiaSize)) to iWDiaHeight 
//        Move (Low(iWCurDiaSize)) to iWDiaWidth
//        //Resize the toggle switch
//        Move iWDiaHeight to iBNewHeight //Button Height needs to be adjusted to match window height
//        Move iBCurWidth to iBNewWidth //Width does not require adjustment
//        Set Size of oToggleDashboardButton to (iBNewHeight-20) iBNewWidth
//        //Position the toggle switch
//        Set Location of oToggleDashboardButton to 0 (iWDiaWidth-iBNewWidth-10)
//        
//        
////        
////        If (Low(iDashboardWindowSize) <= 50) Begin // MAXIMIZING
////            //Size and Color
////            //Set Color to clBtnFace
////            //Set Border_Style of oDashboard to Border_None
////            Set GuiSize of hoView to (Hi(iClientSize)) (Low(iClientSize))  // set the size of the view to fill the client area
////            // Button Label
////            Set Label of oToggleDashboardButton to "<<"
////            // Adjust the Button after window has been resized
////            Get GuiWindowSize of hoView to iDashboardWindowSize // get the size of the window area
////            Move ((((Hi(iDashboardWindowSize))/2)-((Hi(iButtonSize))/2))/2) to iHi
////            Move (((Low(iDashboardWindowSize))/2)+((Low(iButtonSize))*6)) to iLow
////            Set Location of oToggleDashboardButton to iHi iLow
////            Set peAnchors of oToggleDashboardButton to anBottomRight
////        End
////        Else Begin // MINIMIZING
////            //Size and Color
////            //Set Color to clDkGray
////            //Set Border_Style of oDashboard to Border_StaticEdge
////            Set GuiSize of hoView to (Hi(iClientSize)) (Low(iClientSize-iClientSize)+30)  // set the size of the view to fill the hight and 30px
////            Set Label of hoButton to ">>"
////            // Adjust the Button after window has been resized
////            Get GuiWindowSize of hoView to iDashboardWindowSize // get the size of the window area
////            Move ((((Hi(iDashboardWindowSize))/2)-((Hi(iButtonSize))/2))/2) to iHi
////            Move ((Low(iDashboardWindowSize))/2-((Low(iButtonSize)))+1) to iLow
////            Set Location of oToggleDashboardButton to iHi iLow
////            Set peAnchors of oToggleDashboardButton to anBottomRight
////        End
//    End_Procedure  


    Procedure PositionToggleSwitch
        Boolean bIsMaximized
        Handle hoClient
        Integer iClientSize iWCurSize iWCurHeight iWCurWidth iWCurDiaSize iWDiaHeight iWDiaWidth
        //
        //Current Window Size
        Get Client_Id to hoClient
        Get GuiClientSize of hoClient to iWCurSize  // get the size of the client area
        Move (Hi(iWCurSize)) to iWCurHeight
        Move (Low(iWCurSize)) to iWCurWidth
        //translate gui to dialog size
        Get GuiToDialog iWCurHeight iWCurWidth to iWCurDiaSize
        Move (Hi(iWCurDiaSize)) to iWDiaHeight 
        Move (Low(iWCurDiaSize)) to iWDiaWidth
        //
        Get pbIsMaximized of oDashboard to bIsMaximized
        If (bIsMaximized) Begin
            //When the View is maximized, we want to minimize it and change status and button value to reflect
            Set pbIsMaximized of oDashboard to False
            Set Location of oDashboard to 0 0
            Set Size of oDashboard to iWDiaHeight 15
            Set Label of oToggleDashboardButton to ">>"
        End
        If (not(bIsMaximized)) Begin
            Set Enabled_State of oDashboardContainer to False
            Set pbEnabled of oAutoHideDashboardTimer to False
            Integer iDiaFullSize iDiaFHeight iDiaFWidth
            Get GuiToDialog (Hi(iWCurSize)) (Low(iWCurSize)) to iDiaFullSize
            Move (Hi(iDiaFullSize)) to iDiaFHeight
            Move (Low(iDiaFullSize)) to iDiaFWidth
            Set Size of oDashboard to iDiaFHeight iDiaFWidth
            Set Location of oDashboard to 0 0
            Set pbIsMaximized of oDashboard to True
            Set Label of oToggleDashboardButton to "<<"
        End
    End_Procedure

    Procedure Entering_Scope Returns Integer
        Integer iRetVal
        Forward Get msg_Entering_Scope to iRetVal
        Set pbIsMaximized of oDashboard to False
        Send PositionToggleSwitch of oDashboard
        Set pbEnabled of oAutoHideDashboardTimer to False
        Procedure_Return iRetVal
    End_Procedure

End_Object
