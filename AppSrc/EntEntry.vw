// C:\Visual DataFlex Projects\InterstateCompanies\AppSrc\EntEntry.vw
// Employee Entry/Edit
//

Use DFClient.pkg
Use DFEntry.pkg

Use Employer.DD
Use Employee.DD

ACTIVATE_VIEW Activate_oEmpEntry FOR oEmpEntry
Object oEmpEntry Is A dbView
    Set Location to 119 233
    Set Size to 138 320
    Set Label To "Employee Entry/Edit"
    Set Border_Style to Border_Thick


    Object oEmployer_DD Is A Employer_DataDictionary
    End_Object // oEmployer_DD

    Object oEmployee_DD Is A Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
        Set Constrain_file to Employer.File_Number
    End_Object // oEmployee_DD

    Set Main_DD To oEmployee_DD
    Set Server  To oEmployee_DD



    Object oEmployerEmployer_Idno Is A dbForm
        Entry_Item Employer.Employer_Idno
        Set Size to 13 42
        Set Location to 5 64
        Set peAnchors to anLeftRight
        Set Label to "Employer Idno"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 59
        Set Label_row_Offset to 0
    End_Object // oEmployerEmployer_Idno

    Object oEmployerName Is A dbForm
        Entry_Item Employer.Name
        Set Size to 13 246
        Set Location to 20 64
        Set peAnchors to anLeftRight
        Set Label to "Name"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 59
        Set Label_row_Offset to 0
    End_Object // oEmployerName

    Object oEmployeeEmployee_Number Is A dbForm
        Entry_Item Employee.Employee_Number
        Set Size to 13 42
        Set Location to 35 64
        Set peAnchors to anLeftRight
        Set Label to "Employee Number"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 59
        Set Label_row_Offset to 0
    End_Object // oEmployeeEmployee_Number

    Object oEmployeeLastname Is A dbForm
        Entry_Item Employee.Lastname
        Set Size to 13 186
        Set Location to 50 64
        Set peAnchors to anLeftRight
        Set Label to "Lastname"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 59
        Set Label_row_Offset to 0
    End_Object // oEmployeeLastname

    Object oEmployeeFirstname Is A dbForm
        Entry_Item Employee.Firstname
        Set Size to 13 186
        Set Location to 65 64
        Set peAnchors to anLeftRight
        Set Label to "Firstname"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 59
        Set Label_row_Offset to 0
    End_Object // oEmployeeFirstname

    Object oEmployeeAddress Is A dbForm
        Entry_Item Employee.Address
        Set Size to 13 216
        Set Location to 80 64
        Set peAnchors to anLeftRight
        Set Label to "Address"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 59
        Set Label_row_Offset to 0
    End_Object // oEmployeeAddress

    Object oEmployeeAddress2 Is A dbForm
        Entry_Item Employee.Address2
        Set Size to 13 216
        Set Location to 95 64
        Set peAnchors to anLeftRight
        Set Label to "Address2"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 59
        Set Label_row_Offset to 0
    End_Object // oEmployeeAddress2


End_Object // oEmpEntry
