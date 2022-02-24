// JCDEPT.vw

Use cTempusDbView.pkg
Use cGlblDbForm.pkg

Use cJcdeptDataDictionary.dd

Activate_View Activate_oDepartments for oDepartments
Object oDepartments is a cTempusDbView

    property boolean pbReadOnly FALSE
    
    Set Label to "Departments"
    Set Location to 6 6
    Set Size to 97 262


    Object Jcdept_DD is a cJcdeptDataDictionary
    End_Object    // Jcdept_DD

    Set Main_DD to Jcdept_DD
    Set Server to Jcdept_DD

    Object Container1 is a dbContainer3d
        Set Size to 86 252
        Set Location to 6 5
        Object Jcdept_Idno is a cGlblDbForm
            Entry_Item Jcdept.Idno
            Set Label to "ID #"
            Set Size to 13 29
            Set Location to 5 27
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set pbDataLoss to True
        End_Object    // Jcdept_Idno

        Object Jcdept_Name is a dbForm
            Entry_Item Jcdept.Name
            Set Label to "Description"
            Set Size to 13 130
            Set Location to 5 106
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcdept_Name

        Object Jcdept_Nickname is a dbForm
            Entry_Item Jcdept.Nickname
            Set Label to "Short Desc."
            Set Size to 13 60
            Set Location to 20 106
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcdept_Nickname

        Object Jcdept_Depthead is a dbForm
            Entry_Item Jcdept.Depthead
            Set Label to "Manager"
            Set Size to 13 130
            Set Location to 34 106
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcdept_Depthead

        Object Jcdept_Markup is a dbForm
            Entry_Item Jcdept.Markup
            Set Label to "Factor"
            Set Size to 13 20
            Set Location to 50 106
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcdept_Markup

        Object Jcdept_Count is a dbForm
            Entry_Item Jcdept.Count
            Set Label to "Assigned C.C.'s"
            Set Size to 13 20
            Set Location to 65 106
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcdept_Count

    End_Object    // Container1

//    procedure AttachRecords
//        Integer hJcdeptDD iDept
//        //
//        Move (Jcdept_DD(Self)) to hJcdeptDD
//        move Jcdept.Recnum to iDept
//        send Clear to hJcdeptDD
//        send Find_By_Recnum to hJcdeptDD Jcdept.File_number iDept
//        send Activate_View
//    end_procedure
    
//    register_object oViewFloatingMenu
//    // right mouse button down
//    procedure Mouse_Down2
//        integer hDD
//        //
//        get Server to hDD
//        if (NOT(Current_Record(hDD))) procedure_return
//        send Refind_Records of hDD
//        set Item_Shadow_State of oViewFloatingMenu item 0 to TRUE
//        send Popup of oViewFloatingMenu
//        set Item_Shadow_State of oViewFloatingMenu item 0 to FALSE
//    end_procedure
    
//    Procedure Activating
//        boolean bReadOnly 
//        get pbReadonly of ghoApplication to bReadOnly
//        set pbReadonly to bReadOnly
//        set Read_Only_State of Jcdept_DD to bReadOnly
//        if bReadOnly Set Label to "Departments - READ ONLY"
//        Else Set Label to "Departments"
//    End_Procedure
    
//    Procedure Request_Save
//        boolean bReadOnly
//        get pbReadOnly to bReadOnly
//        if bReadOnly Begin
//            send request_assign to Jcdept_DD
//            procedure_return
//        end
//        forward send request_save
//    End_Procedure

End_Object    // Departments
