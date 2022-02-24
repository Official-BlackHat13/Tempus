Use Windows.pkg
Use DFClient.pkg

Deferred_View Activate_oDashboard for ;
Object oDashboard is a dbView
    Set Border_Style to Border_None
    Set Size to 320 20
    Set Location to 2 2
    Set Label to "Dashboard"
    Set Maximize_Icon to False
    Set Sysmenu_Icon to False
    Set Caption_Bar to False
    Set pbSizeToClientArea to False


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
        Set Size to 14 15
        Set Location to 152 3
        Set Label to '>>'
        Set peAnchors to anBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            //Toggle
            Send ToggleSlide of oDashboard
        End_Procedure 
    End_Object

//    Procedure DoAlignObject Handle hoParent Handle hoChild String sVertAlign String sHorAlign
//        //Formula:
//        If (sVertAlign="Center") Begin
//            
//        End
//        //  Hi((HightOfParent/2) - (HightOfChild/2))
//        //  Low((WidthOfParent/2) - (WidthOfChild/2))
//    End_Procedure

    Procedure ToggleSlide  
        Handle hoView hoButton hoClient
        Integer iClientSize iDashboardWindowSize iButtonSize
        Integer iHi iLow
        //
        //Object
        Move oDashboard to hoView
        Get GuiWindowSize of hoView to iDashboardWindowSize // get the size of the window area
        //Client Size
        Get Client_Id to hoClient
        Get GuiClientSize of hoClient to iClientSize  // get the size of the client area
        //Button Size
        Move oToggleDashboardButton to hoButton
        Get Size of oToggleDashboardButton to iButtonSize
        
        If (Low(iDashboardWindowSize) <= 50) Begin // MAXIMIZING
            //Size and Color
            //Set Color to clBtnFace
            //Set Border_Style of oDashboard to Border_None
            Set GuiSize of hoView to (Hi(iClientSize)) (Low(iClientSize))  // set the size of the view to fill the client area
            // Button Label
            Set Label of oToggleDashboardButton to "<<"
            // Adjust the Button after window has been resized
            Get GuiWindowSize of hoView to iDashboardWindowSize // get the size of the window area
            Move ((((Hi(iDashboardWindowSize))/2)-((Hi(iButtonSize))/2))/2) to iHi
            Move (((Low(iDashboardWindowSize))/2)+((Low(iButtonSize))*6)) to iLow
            Set Location of oToggleDashboardButton to iHi iLow
            Set peAnchors of oToggleDashboardButton to anBottomRight
        End
        Else Begin // MINIMIZING
            //Size and Color
            //Set Color to clDkGray
            //Set Border_Style of oDashboard to Border_StaticEdge
            Set GuiSize of hoView to (Hi(iClientSize)) (Low(iClientSize-iClientSize)+30)  // set the size of the view to fill the hight and 30px
            Set Label of hoButton to ">>"
            // Adjust the Button after window has been resized
            Get GuiWindowSize of hoView to iDashboardWindowSize // get the size of the window area
            Move ((((Hi(iDashboardWindowSize))/2)-((Hi(iButtonSize))/2))/2) to iHi
            Move ((Low(iDashboardWindowSize))/2-((Low(iButtonSize)))+1) to iLow
            Set Location of oToggleDashboardButton to iHi iLow
            Set peAnchors of oToggleDashboardButton to anBottomRight
        End
    End_Procedure  

    Procedure Exiting_Scope Handle hoNewScope
        Forward Send Exiting_Scope hoNewScope
        Send ToggleSlide of oDashboard
    End_Procedure

    Procedure Activating
        Forward Send Activating
        Send ToggleSlide of oDashboard
    End_Procedure

Cd_End_Object
