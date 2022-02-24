Use Windows.pkg
Use DFClient.pkg
Use cCJGridPromptList.pkg

Object oAttachment is a dbModalPanel
    Set Size to 133 292
    Set Location to 3 5
    Set Border_Style to Border_Thick

    Property tDataSourceRow[] TheData
    String[][] sAttachmentArray
    Property Boolean pbSelected
    Property Integer piSelected

    Object oSelList is a cCJGridPromptList
        Set peAnchors to anAll
        Set Size      to 105 280
        Set Location  to 6 6
        Set pbAutoOrdering to False
        Set pbAllowColumnReorder to False
        Set pbAllowColumnRemove to False
        Set pbEditOnTyping to False

        Object oAttachmentIdno is a cCJGridColumn
            Set piWidth to 82
            Set psCaption to "AttachIdno"
            Set pbAllowDrag to False
            Set pbAllowRemove to False
            Set pbEditable to False
        End_Object
        
        Object oAttachmentDiscription is a cCJGridColumn
            Set piWidth to 408
            Set psCaption to "Disciption"
            Set pbAllowDrag to False
            Set pbAllowRemove to False
            Set pbEditable to False
        End_Object
        
        Procedure LoadData
            Handle hoDataSource
            tDataSourceRow[] TheData
            Integer iRows iAttachLabel iAttachIdno iArrayLength i
            
            Get phoDataSource to hoDataSource
            
            //Get DataSource indexes
            Get piColumnId of oAttachmentIdno           to iAttachIdno
            Get piColumnId of oAttachmentDiscription    to iAttachLabel
            
            
            //Get length of StringArray
            Move (SizeOfArray(sAttachmentArray)) to iArrayLength          
            //Move StringArray into the datasource array
            For i from 0 to (iArrayLength-1)
                Move sAttachmentArray[i][iAttachLabel] to TheData[i].sValue[iAttachLabel]
                Move sAttachmentArray[i][iAttachIdno] to TheData[i].sValue[iAttachIdno]
                Increment iRows
            Loop

            // Initialize Grid with new data
            Send InitializeData TheData
            Send MovetoFirstRow
        End_Procedure
        
        
        Procedure Activating
            Forward Send Activating
            Send LoadData
        End_Procedure

        Procedure OnComRowDblClick Variant llRow Variant llItem
            Forward Send OnComRowDblClick llRow llItem
            Send KeyAction of oOk_bn
        End_Procedure
        
    End_Object

    Object oOK_bn is a Button
        Set Label     to "&OK"
        Set Location  to 115 128
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Ok of oSelList
        End_Procedure

    End_Object

    Object oCancel_bn is a Button
        Set Label     to "&Cancel"
        Set Location  to 115 182
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object

    Object oSearch_bn is a Button
        Set Label     to "&Search..."
        Set Location  to 115 236
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function AttachSelection String[][] sAttachArray Returns Integer
        Integer iSelected
        Move sAttachArray to sAttachmentArray
        Send Popup
        Function_Return (piSelected(Self))
    End_Function

End_Object

