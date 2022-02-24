Use Windows.pkg
Use DFClient.pkg
Use Employer.DD
Use Employee.DD
Use Customer.DD
//Use Equipment.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use MastOps.DD
Use Opers.DD
Use Trans.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use szcalendar.pkg

Deferred_View Activate_oTransEdit2 for ;
Object oTransEdit2 is a dbView
    
    Property Integer piEquipIdno
    Property String psEquipmentID

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object
    
    
    
    Object oMastOps_DD is a Mastops_DataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set Constrain_File to Location.File_Number
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Property Date    pdTrans
        Property Integer piOrder
        
        Set Constrain_File to Order.File_Number
        
        Set DDO_Server to oOpers_DD
        Set DDO_Server to oOrder_DD
        Set DDO_Server to oEmployee_DD
        Set DDO_Server to oMastOps_DD
        //
        Procedure OnConstrain
            Constrain Trans.StartDate eq (pdTrans(Self))
        End_Procedure
        

    
     Procedure Creating
            Integer iEquipIdno
            String  sEquipmentID
 
            Forward Send Creating

            Get piEquipIdno   to iEquipIdno
            Get psEquipmentID to sEquipmentID
            Move iEquipIdno   to Trans.EquipIdno
            Move sEquipmentID to Trans.EquipmentID
     End_Procedure
     
        Procedure Clear
            Integer iOrder
              Get piOrder to iOrder
            Forward Send Clear
         End_Procedure
    
    
    End_Object

    Set Main_DD to oTrans_DD
    Set Server to oTrans_DD

    Set Border_Style to Border_Thick
    Set Size to 367 727
    Set Location to 1 61

    Object oOrder_JobNumber is a cGlblDbForm
        Entry_Item Order.JobNumber
        Set Location to 28 99
        Set Size to 13 54
        Set Label to "JobNumber:"
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 44 99
        Set Size to 13 200
        Set Label to "Customer:"
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Location to 60 99
        Set Size to 13 200
        Set Label to "Location:"
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oTransactionGrid is a cDbCJGrid
        Set Size to 200 637
        Set Location to 108 53

        
        Object oTrans_EmployeeIdno is a cDbCJGridColumn
            Entry_Item Employee.EmployeeIdno
            Set piWidth to 72
            Set psCaption to "EmployeeIdno"
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object

        Object oEmployee_LastName is a cDbCJGridColumn
            Entry_Item Employee.LastName
            Set piWidth to 100
            Set psCaption to "LastName"
        End_Object

        Object oTrans_OpersIdno is a cDbCJGridColumn
            Entry_Item Opers.OpersIdno
            Set piWidth to 72
            Set psCaption to "OpersIdno"
        End_Object

        Object oOpers_Name is a cDbCJGridColumn
            Entry_Item Opers.Name
            Set piWidth to 200
            Set psCaption to "Name"
            Set Prompt_Button_Mode to PB_PromptOn
        End_Object

        Object oTrans_StartTime is a cDbCJGridColumn
            Entry_Item Trans.StartTime
            Set piWidth to 90
            Set psCaption to "StartTime"
        End_Object

//        Object oTrans_StartDate is a cDbCJGridColumn
//            Entry_Item Trans.StartDate
//            Set piWidth to 90
//            Set psCaption to "StartDate"
//        End_Object

        Object oTrans_StopDate is a cDbCJGridColumn
            Entry_Item Trans.StopDate
            Set piWidth to 90
            Set psCaption to "StopDate"
        End_Object

        Object oTrans_StopTime is a cDbCJGridColumn
            Entry_Item Trans.StopTime
            Set piWidth to 90
            Set psCaption to "StopTime"
        End_Object

        Object oTrans_ElapsedMinutes is a cDbCJGridColumn
            Entry_Item Trans.ElapsedMinutes
            Set piWidth to 54
            Set psCaption to "ElapsedMinutes"
        End_Object

        Object oTrans_Quantity is a cDbCJGridColumn
            Entry_Item Trans.Quantity
            Set piWidth to 72
            Set psCaption to "Quantity"
        End_Object
    End_Object
    
//        Function Row_Save Returns Integer
//            Integer iRetval
//            Date    dStart
//            //
//            If (not(HasRecord(oTrans_DD))) Begin
//                Get Value               of oTrans_StartDate                to dStart
//                Set Field_Changed_Value of oTrans_DD Field Trans.StartDate to dStart
//            End
//            //
//            Forward Get Row_Save to iRetval
//            //
//            Function_Return iRetval
//        End_Function
        
//        Function IsEquipmentValid Integer iLocationIdno Integer iEquipIdno Returns Integer
//            Clear Equipmnt MastOps Opers
//            Move iEquipIdno to Equipmnt.EquipIdno
//            Showln iEquipIdno
//            Find eq Equipmnt.EquipIdno
//            If (Found) Begin
//                Set piEquipIdno   to Equipmnt.EquipIdno
//                Set psEquipmentID to Equipmnt.EquipmentID
//                Relate Equipmnt
//                If (MastOps.Recnum <> 0) Begin
//                    Move iLocationIdno       to Opers.LocationIdno 
//                    Move MastOps.MastOpsIdno to Opers.MastOpsIdno  /// code to check Mastop# present in location opers records
//                    Find eq Opers by Index.4
//                    If (Found) Begin
//                        Function_Return Opers.OpersIdno
//                    End
//                End
//            End
//        End_Function
//        
        
        

    Object oTrans_StartDate1 is a cszDatePicker
      //  Entry_Item Trans.StartDate
        Set Location to 76 98
        Set Size to 13 66
        Set Label to "Start Date:"
        
         Procedure OnChange
                Date dTrans
                //
                Get Value to dTrans
                If (dTrans <> 0) Begin
                    Set pdTrans              of oTrans_DD to dTrans
                    Send Rebuild_Constraints of oTrans_DD
                    //Send Beginning_of_Data   of oTransactionGrid
                End
            End_Procedure
               
                  
              
          
       
        
    End_Object

Cd_End_Object
