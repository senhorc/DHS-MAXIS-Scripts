'STATS GATHERING----------------------------------------------------------------------------------------------------
name_of_script = "ACTIONS - ABAWD BANKED MONTHS FIATER.vbs"
start_time = timer

'LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN	'Shouldn't load FuncLib if it already loaded once
	IF run_locally = FALSE or run_locally = "" THEN		'If the scripts are set to run locally, it skips this and uses an FSO below.
		IF use_master_branch = TRUE THEN			'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/master/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		Else																		'Everyone else should use the release branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/RELEASE/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		End if
		SET req = CreateObject("Msxml2.XMLHttp.6.0")				'Creates an object to get a FuncLib_URL
		req.open "GET", FuncLib_URL, FALSE							'Attempts to open the FuncLib_URL
		req.send													'Sends request
		IF req.Status = 200 THEN									'200 means great success
			Set fso = CreateObject("Scripting.FileSystemObject")	'Creates an FSO
			Execute req.responseText								'Executes the script code
		ELSE														'Error message, tells user to try to reach github.com, otherwise instructs to contact Veronica with details (and stops script).
			MsgBox 	"Something has gone wrong. The code stored on GitHub was not able to be reached." & vbCr &_
					vbCr & _
					"Before contacting Veronica Cary, please check to make sure you can load the main page at www.GitHub.com." & vbCr &_
					vbCr & _
					"If you can reach GitHub.com, but this script still does not work, ask an alpha user to contact Veronica Cary and provide the following information:" & vbCr &_
					vbTab & "- The name of the script you are running." & vbCr &_
					vbTab & "- Whether or not the script is ""erroring out"" for any other users." & vbCr &_
					vbTab & "- The name and email for an employee from your IT department," & vbCr & _
					vbTab & vbTab & "responsible for network issues." & vbCr &_
					vbTab & "- The URL indicated below (a screenshot should suffice)." & vbCr &_
					vbCr & _
					"Veronica will work with your IT department to try and solve this issue, if needed." & vbCr &_
					vbCr &_
					"URL: " & FuncLib_URL
					script_end_procedure("Script ended due to error connecting to GitHub.")
		END IF
	ELSE
		FuncLib_URL = "C:\BZS-FuncLib\MASTER FUNCTIONS LIBRARY.vbs"
		Set run_another_script_fso = CreateObject("Scripting.FileSystemObject")
		Set fso_command = run_another_script_fso.OpenTextFile(FuncLib_URL)
		text_from_the_other_script = fso_command.ReadAll
		fso_command.Close
		Execute text_from_the_other_script
	END IF
END IF
'END FUNCTIONS LIBRARY BLOCK================================================================================================


'-------------------------------FUNCTIONS WE INVENTED THAT WILL SOON BE ADDED TO FUNCLIB
FUNCTION date_array_generator(initial_month, initial_year, date_array)
	'defines an intial date from the initial_month and initial_year parameters
	initial_date = initial_month & "/1/" & initial_year
	'defines a date_list, which starts with just the initial date
	date_list = initial_date

	'This loop creates a list of dates
	Do
		working_date = dateadd("m", 1, right(date_list, len(date_list) - InStrRev(date_list,"|")))	'the working_date is the last-added date + 1 month. We use dateadd, then grab the rightmost characters after the "|" delimiter, which we determine the location of using InStrRev
		date_list = date_list & "|" & working_date	'Adds the working_date to the date_list
	Loop until datediff("m", date, working_date) = 1	'Loops until we're at current month plus one

	'Splits this into an array
	date_array = split(date_list, "|")
End function


'-------------------------------END FUNCTIONS


'Defining variables----------------------------------------------------------------------------------------------------
'Dim gross_wages, busi_income, gross_RSDI, gross_SSI, gross_VA, gross_UC, gross_CS, gross_other
'Dim deduction_FMED, deduction_DCEX, deduction_COEX

'Dialogs----------------------------------------------------------------------------------------------------
BeginDialog case_number_dialog, 0, 0, 251, 230, "ABAWD BANKED MONTHS FIATER"
  EditBox 105, 10, 60, 15, case_number
  EditBox 105, 30, 25, 15, initial_month
  EditBox 140, 30, 25, 15, initial_year
  ButtonGroup ButtonPressed
    OkButton 75, 50, 50, 15
    CancelButton 130, 50, 50, 15
  Text 50, 15, 50, 10, "Case Number:"
  Text 5, 35, 100, 10, "Initial month/year of package:"
  Text 30, 90, 200, 25, "This script will FIAT eligibility results, income and deductions for each HH member with pending SNAP results for months where ABAWD banked months are being used. "
  GroupBox 20, 75, 215, 70, "Per Bulletin #15-01-01 SNAP banked month policy/procedures:"
  Text 30, 170, 200, 10, "* All STAT panels must be updated before using this script."
  Text 30, 190, 200, 20, "* Do NOT mark partial counted months with an ""M"". Partial months are not counted, only full months are counted."
  Text 30, 125, 200, 20, "If you are unsure of how/why/when you should be applying this process, please refer to the Bulletin."
  GroupBox 20, 155, 215, 60, "Before you begin:"
EndDialog

BeginDialog income_deductions_dialog, 0, 0, 326, 280, "ABAWD banked months income and deductions dialog"
  ButtonGroup ButtonPressed
    OkButton 260, 155, 50, 15
    CancelButton 260, 175, 50, 15
  EditBox 55, 45, 50, 15, gross_wages
  EditBox 55, 65, 50, 15, busi_income
  EditBox 55, 85, 50, 15, gross_RSDI
  EditBox 55, 105, 50, 15, gross_SSI
  EditBox 55, 125, 50, 15, gross_VA
  EditBox 55, 145, 50, 15, gross_UC
  EditBox 55, 165, 50, 15, gross_CS
  EditBox 55, 185, 50, 15, gross_other
  EditBox 185, 45, 35, 15, SHEL_rent
  EditBox 185, 65, 35, 15, SHEL_tax
  EditBox 185, 85, 35, 15, SHEL_insa
  EditBox 185, 105, 35, 15, SHEL_other
  EditBox 185, 125, 35, 15, deduction_FMED
  EditBox 275, 45, 35, 15, HEST_elec
  EditBox 275, 65, 35, 15, HEST_heat
  EditBox 275, 85, 35, 15, HEST_phone
  EditBox 275, 105, 35, 15, deduction_COEX
  EditBox 275, 125, 35, 15, deduction_DCEX
  ButtonGroup ButtonPressed
    PushButton 20, 15, 25, 10, "BUSI",  BUSI_button
    PushButton 45, 15, 25, 10, "JOBS", JOBS_button
    PushButton 70, 15, 25, 10, "RBIC", RBIC_button
    PushButton 95, 15, 25, 10, "SPON", SPON_button
    PushButton 120, 15, 25, 10, "UNEA", UNEA_button
    PushButton 175, 15, 25, 10, "COEX", COEX_button
    PushButton 200, 15, 25, 10, "DCEX", DCEX_button
    PushButton 225, 15, 25, 10, "FMED", FMED_button
    PushButton 250, 15, 25, 10, "HEST", HEST_button
    PushButton 275, 15, 25, 10, "SHEL", SHEL_button
    PushButton 130, 165, 45, 10, "prev. panel", prev_panel_button
    PushButton 130, 175, 45, 10, "next panel", next_panel_button
    PushButton 185, 165, 45, 10, "prev. memb", prev_memb_button
    PushButton 185, 175, 45, 10, "next memb", next_memb_button
  Text 35, 150, 15, 10, "UC:"
  Text 245, 130, 25, 10, "DCEX:"
  Text 30, 190, 20, 10, "Other:"
  Text 35, 170, 15, 10, "CS:"
  Text 155, 130, 25, 10, "FMED:"
  Text 240, 50, 30, 10, "Electric:"
  Text 245, 110, 25, 10, "COEX:"
  Text 35, 110, 15, 10, "SSI:"
  Text 230, 70, 40, 10, "Heating/air:"
  Text 125, 90, 60, 10, "House insurance:"
  Text 230, 90, 40, 10, "Telephone:"
  Text 130, 50, 50, 10, "Mortgage/rent:"
  Text 160, 110, 20, 10, "Other:"
  Text 30, 70, 20, 10, "BUSI:"
  Text 135, 70, 45, 10, "Property tax:"
  GroupBox 125, 155, 110, 35, "STAT-based navigation"
  GroupBox 170, 5, 135, 25, "Deduction based MAXIS panels:"
  Text 60, 35, 50, 10, "Gross Amount"
  Text 25, 35, 25, 10, "UI type"
  GroupBox 15, 5, 135, 25, "Income based MAXIS panels:"
  Text 30, 90, 20, 10, "RSDI:"
  GroupBox 15, 210, 300, 50, "BEFORE YOU HIT THE OK BUTTON"
  Text 20, 220, 285, 35, "The information pulled into the editboxes above are the amounts that are being FIATed into the SNAP budget in the selected budget month. Please use the navigation buttons on this dialog if you want to check what is listed on your MAXIS panels. If this informaiton is not corret, please press cancel now, and review your case.  "
  Text 35, 130, 10, 10, "VA:"
  Text 20, 50, 30, 10, "WAGES:"
EndDialog

'----------------------DEFINING CLASSES WE'LL NEED FOR THIS SCRIPT
class ABAWD_month_data
	public gross_Wages
	public BUSI_income
	public gross_RSDI
	public gross_SSI
	public gross_VA
	public gross_UC
	public gross_CS
	public gross_other
	public deduction_FMED
	public deduction_DCEX
	public deduction_COEX
	public SHEL_rent
	public SHEL_tax
	public SHEL_insa
	public SHEL_other
	public HEST_elect
	public HEST_heat
	public HEST_phone
end class

'-------------------------END CLASSES

'VARIABLES WE'LL NEED TO DECLARE (NOTE, IT'S LIKELY THESE WILL NEED TO MOVE FURTHER DOWN IN THE SCRIPT)----------------------------


'The script----------------------------------------------------------------------------------------------------
EMConnect ""
call check_for_maxis(false)

call maxis_case_number_finder(case_number)

DO
	err_msg = ""
	dialog case_number_dialog
	If buttonpressed = 0 THEN stopscript
	IF isnumeric(case_number) = false THEN err_msg = err_msg & vbCr & "You must enter a valid case number."
	IF len(initial_month) > 2 or isnumeric(initial_month) = FALSE THEN err_msg = err_msg & vbCr & "You must enter a valid 2 digit initial month."
	IF len(initial_year) > 2 or isnumeric(initial_year) = FALSE THEN err_msg = err_msg & vbCr & "You must enter a valid 2 digit initial year."
	IF err_msg <> "" THEN msgbox err_msg & vbCr & "Please resolve to continue."
LOOP UNTIL err_msg = ""

'Uses the custom function to create an array of dates from the initial_month and initial_year variables, ends at CM + 1.
	'We will need to remove the string "/1/" from each element in the array
call date_array_generator(initial_month, initial_year, footer_month_array)

'Create an array of all the counted months
DIM ABAWD_months_array()	'Minus one because arrays
REDIM ABAWD_months_array(ubound(footer_month_array))	'Minus one because arrays

check_for_maxis(true)
'Create hh_member_array
call HH_member_custom_dialog(HH_member_array)

maxis_background_check

'The following performs case accuracy checks.
call navigate_to_maxis_screen("ELIG", "FS")
redim ABAWD_member_array(0)

For each member in hh_member_array
	row = 6
	col = 1
	EMSearch member, row, col 'Finding the row this member is on
	EMWritescreen "x", row, 5
	transmit 'Now on FFPR
	EMReadscreen inelig_test, 6, 6, 20 'This reads the ABAWD 3/36 month test
	IF inelig_test = "FAILED" THEN 'This member is failing this test, add them to the ABAWD member array
		If ABAWD_member_array(0) <> "" Then ReDim Preserve ABAWD_member_array(UBound(ABAWD_member_array)+1) 
		ABAWD_member_array(UBound(ABAWD_member_array)) = member
	END IF
	transmit
Next
IF ABAWD_member_array(0) = "" THEN script_end_procedure("ERROR: There are no members on this case with ineligible ABAWDs.  The script will stop.")

err_msg = ""
For each member in ABAWD_member_array 'This loop will check that WREG is coded correctly
	call navigate_to_maxis_screen("STAT", "WREG")
	EMWritescreen member, 20, 76
	Transmit
	EMReadscreen wreg_status, 2, 8, 50
	IF wreg_status <> "30" THEN err_msg = err_msg & vbCr & "Member " & member & " does not have FSET code 30."
	EMReadscreen abawd_status, 2, 13, 50
	IF abawd_status <> "10" THEN err_msg = err_msg & vbCr & "Member " & member & " does not have ABAWD code 10."
	'This section pulls up the counted months popup and checks for 3 months counted before Jan. 16
	EmWriteScreen "x", 13, 57 
	transmit
	bene_mo_col = 55
	bene_yr_row = 8
    WREG_months = 0
    second_abawd_period = 0
 	DO 'This loop actually reads every month in the time period
  	    EMReadScreen is_counted_month, 1, bene_yr_row, bene_mo_col
  		IF is_counted_month = "X" or is_counted_month = "M" THEN WREG_months = WREG_months + 1
		IF is_counted_month = "Y" or is_counted_month = "N" THEN second_abawd_period = second_abawd_period + 1
   		bene_mo_col = bene_mo_col + 4
    		IF bene_mo_col > 63 THEN
        		bene_yr_row = bene_yr_row + 1
   	     		bene_mo_col = 19
   	   	    END IF
   	LOOP until bene_yr_row = 11 'Stops when it reaches 2016
  	IF WREG_months < 3 THEN err_msg = err_msg & vbCr & "Member " & member & " does not have 3 ABAWD months coded before 01/2016"
	row = 11
	col = 19
	EMSearch "M", row, col 'This looks to make sure there is an intial banked month coded on WREG.
	IF row > 11 THEN err_msg = err_msg & vbCr & "Member " & member & " does not have an initial banked month coded on WREG."
	PF3
Next

IF err_msg <> "" THEN 'This means the WREG panel(s) are coded incorrectly.
	msgbox "Please resolve the following errors before continuing. The script will now stop." & vBcr & err_msg
	script_end_procedure("")
END IF

	

'The following loop will take the script throught each month in the package, from appl month. to CM+1


	
	For i = 0 to ubound(footer_month_array)
		footer_month = datepart("m", footer_month_array(i)) 'Need to assign footer month / year each time through
		if len(footer_month) = 1 THEN footer_month = "0" & footer_month
		footer_year = right(datepart("YYYY", footer_month_array(i)), 2)
		
		Set ABAWD_months_array(i) = new ABAWD_month_data
		Call navigate_to_MAXIS_screen("STAT", "HEST")		'<<<<< Navigates to STAT/HEST
		EMReadScreen HEST_heat, 6, 13, 75 					'<<<<< Pulls information from the prospective side of HEAT/AC standard allowance
		IF HEST_heat <> "      " then						'<<<<< If there is an amount on the hest line then the electric and phone allowances are not used
			HEST_elect = "" AND HEST_phone = ""				'<<<<< Ignores the electric and phone standards if HEAT/AC is used
		Else
			HEST_heat = ""									'<<<<< Sets the class property to a void if line is blank
			EMReadScreen HEST_elect, 6, 14, 75				'<<<<< Pulls information from prospective side of Electric standard if HEAT/AC is not used
			EMReadScreen HEST_phone, 6, 15, 75				'<<<<< Pulls information from prospective side of Phone standard if HEAT/AC is not used
			If HEST_elect = "      " then HEST_elect = ""	'<<<<< Sets the class property to a void if line is blank
			If HEST_phone = "      " then HEST_phone = ""
		End If
		
		For each hh_member in HH_member_array
			Call navigate_to_MAXIS_screen("STAT", "SHEL")		'<<<<< Goes to SHEL for this person
			EMWriteScreen hh_member, 20, 76 
			EMReadScreen rent_verif, 2, 11, 67
			If rent_verif <> "__" and rent_verif <> "NO" and rent_verif <> "?_" then EMReadScreen rent, 8, 11, 56
			If rent_verif = "__" or rent_verif = "NO" or rent_verif = "?_" then rent = "0"		'<<<<< Gets rent amount
			EMReadScreen lot_rent_verif, 2, 12, 67
			If lot_rent_verif <> "__" and lot_rent_verif <> "NO" and lot_rent_verif <> "?_" then EMReadScreen lot_rent, 8, 12, 56
			If lot_rent_verif = "__" or lot_rent_verif = "NO" or lot_rent_verif = "?_" then lot_rent = "0"		'<<<<< gets Lot Rent amount
			EMReadScreen mortgage_verif, 2, 13, 67
			If mortgage_verif <> "__" and mortgage_verif <> "NO" and mortgage_verif <> "?_" then EMReadScreen mortgage, 8, 13, 56
			If mortgage_verif = "__" or mortgage_verif = "NO" or mortgage_verif = "?_" then mortgage = "0"		'<<<<<< gets Mortgage amount
			EMReadScreen insurance_verif, 2, 14, 67
			If insurance_verif <> "__" and insurance_verif <> "NO" and insurance_verif <> "?_" then EMReadScreen insurance, 8, 14, 56
			If insurance_verif = "__" or insurance_verif = "NO" or insurance_verif = "?_" then SHEL_insa = "0"	'<<<<<< gets insurance amount and adds it to the class property
			EMReadScreen taxes_verif, 2, 15, 67
			If taxes_verif <> "__" and taxes_verif <> "NO" and taxes_verif <> "?_" then EMReadScreen taxes, 8, 15, 56
			If taxes_verif = "__" or taxes_verif = "NO" or taxes_verif = "?_" then SHEL_taxes = "0"				'<<<<<<< gets taxes amount and adds it to the class property
			EMReadScreen room_verif, 2, 16, 67
			If room_verif <> "__" and room_verif <> "NO" and room_verif <> "?_" then EMReadScreen room, 8, 16, 56
			If room_verif = "__" or room_verif = "NO" or room_verif = "?_" then room = "0"						'<<<<<<< gets room/board amount
			EMReadScreen garage_verif, 2, 17, 67
			If garage_verif <> "__" and garage_verif <> "NO" and garage_verif <> "?_" then EMReadScreen garage, 8, 17, 56
			If garage_verif = "__" or garage_verif = "NO" or garage_verif = "?_" then garage = "0"				'<<<<<<< gets garage amount
			SHEL_rent = cint(rent) + cint(mortgage)						'<<<<<<  Adds rent amount and mortage amount together to get the Rent line for elig and adds to Class property 
			SHEL_other = cint(lot_rent) + cint(room) + cint(garage) 	'<<<<<<  Adds lot rent, room, and garage amounts together to get the Other line for elig and adds to Class property
		Next
'//////////// Going to pull UNEA information
		For i = 0 to ubound(HH_member_array)
		Set HH_member_array(i) = new HH_member_data
		Call navigate_to_MAXIS_screen("STAT", "UNEA")		'<<<<< Goes to SHEL for this person
		EMWriteScreen HH_member_array(i), 20, 76 
		EMReadScreen number_of_unea_panels, 1, 2, 78 
			For i = 1 to number_of_unea_panels				'<<<<<< Starting at 1 becuase this is a panel count and it makes sense to use this as a standard count
				EMWriteScreen "0" & i, 20, 79
				transmit
				EMReadScreen unea_type, 2, 5, 37 			'<<<<<< Reads each type of UNEA panel and adds the amounts togetther within a type
				If unea_type = "01" OR "02" then 			'<<<<<< RSDI
					EMWriteScreen "x", 10, 26 
					transmit
					EMReadScreen rsdi_amount, 8, 18, 56 
					If gross_RSDI = "" then
						gross_RSDI = rsdi_amount
					Else 
						gross_RSDI = gross_RSDI + rsdi_amount
					End If
					transmit
				Else If unea_type = "03" then 				'<<<<<< SSI
					EMWriteScreen "x", 10, 26 
					transmit
					EMReadScreen ssi_amount, 8, 18, 56 
					If gross_SSI = "" then
						gross_SSI = ssi_amount
					Else 
						gross_SSI = gross_SSI + ssi_amount
					End If
					transmit
				Else If unea_type = "11" OR "12" OR "13" OR "38" then 	'<<<<<< VA
					EMWriteScreen "x", 10, 26 
					transmit
					EMReadScreen va_amount, 8, 18, 56 
					If gross_VA = "" then
						gross_VA = va_amount
					Else 
						gross_VA = gross_VA + va_amount
					End If
					transmit
				Else If unea_type = "14" then 				'<<<<<< UC
					EMWriteScreen "x", 10, 26 
					transmit
					EMReadScreen uc_amount, 8, 18, 56 
					If gross_UC = "" then
						gross_UC = uc_amount
					Else 
						gross_UC = gross_UC + uc_amount
					End If
					transmit
				Else If unea_type = "08" OR "36" OR "39" then 	'<<<<<< CS
					EMWriteScreen "x", 10, 26 
					transmit
					EMReadScreen cs_amount, 8, 18, 56 
					If gross_CS = "" then
						gross_CS = cs_amount
					Else 
						gross_CS = gross_CS + cs_amount
					End If
					transmit
				Else If unea_type = "06" OR "15" OR "16" OR "17" OR "18" OR "23" OR "24" OR "25" OR "26" OR "27" OR "28" OR "29" OR "31" OR "35" OR "37" OR "40" then 	'<<<<<< Other UNEA
					EMWriteScreen "x", 10, 26 
					transmit
					EMReadScreen other_unea_amount, 8, 18, 56 
					If gross_other = "" then
						gross_other = other_unea_amount
					Else 
						gross_other = gross_other + other_unea_amount
					End If
					transmit
				End If
			Next
		Next	
		
		
	'	'<<<<<<<<<<<<<SAMPLE IDEA FOR ARRAY'
	'	For i = 0 to ubound(ABAWD_counted_months)
	'		'Defines the ABAWD_months_array as an obejct of ABAWD month data'
	'		set ABAWD_months_array(i) = new ABAWD_month_data
	'		'>>>>NAVIGATE TO WHERE YOU NEED TO GO'
	'		EMReadScreen x, 8, 18, 56	'<<<<READ THE STUFF'
	'		ABAWD_months_array(i).gross_RSDI = x	'<<<<ADD THE STUFF TO THE ARRAY'
	'		'>>>>>>DO THE ABOVE TWO LINES OVER AND OVER AGAIN UNTIL YOU HAVE ALL THE STUFF FOR THIS MONTH'
	'		'//// <<<<<<GET TO THE NEXT MONTH AT THE END'
	'	Next
	'	'<<<<<<<<<<<<<<<<<END SAMPLE'
	dialog income_deductions_dialog

	'Go to FIAT
	back_to_self
	EMwritescreen "FIAT", 16, 43
	EMWritescreen case_number, 18, 43
	EMwritescreen footer_month, 20, 43
	EMWritescreen footer_year, 20, 46
	transmit
	EMReadscreen results_check, 4, 14, 46 'We need to make sure results exist, otherwise stop.
	IF results_check = "    " THEN script_end_procedure("The script was unable to find unapproved SNAP results for the benefit month, please check your case and try again.")
	EMWritescreen "03", 4, 34 'entering the FIAT reason
	EMWritescreen "x", 14, 22
	transmit 'This should take us to FFSL
	'The following loop will enter person tests screen and pass for each member on grant
	For each member in hh_member_array
		row = 6
		col = 1
		EMSearch member, row, col 'Finding the row this member is on
		EMWritescreen "x", row, 5
		transmit 'Now on FFPR
		EMWritescreen "PASSED", 9, 12
		transmit
		PF3 'back to FFSL
	Next
	'Ready to head into case test / budget screens
		EMWritescreen "x", 16, 5
		EMWritescreen "x", 17, 5
		Transmit
		'Passing all case tests
		EMWritescreen "PASSED", 10, 7
		EMWritescreen "PASSED", 13, 7
		EMWritescreen "PASSED", 14, 7
		PF3
		'Now the BUDGET (FFB1) NO
		EMWritescreen ABAWD_months_array(i).gross_wages, 5, 32
		EMWritescreen ABAWD_months_array(i).busi_income, 6, 32
		EMWritescreen ABAWD_months_array(i).gross_RSDI, 11, 32
		EMWritescreen ABAWD_months_array(i).gross_SSI, 12, 32
		EMWritescreen ABAWD_months_array(i).gross_VA, 13, 32
		EMWritescreen ABAWD_months_array(i).gross_UC, 14, 32
		EMWritescreen ABAWD_months_array(i).gross_CS, 15, 32
		EMWritescreen ABAWD_months_array(i).gross_other, 16, 32
		EMWritescreen ABAWD_months_array(i).deduction_FMED, 12, 72
		EMWritescreen ABAWD_months_array(i).deduction_DCEX, 13, 72
		EMWritescreen ABAWD_months_array(i).deduction_COEX, 14, 72
		transmit
		'Now on FFB2
		EMWritescreen ABAWD_months_array(i).SHEL_rent, 5, 29
		EMWritescreen ABAWD_months_array(i).SHEL_tax, 6, 29
		EMWritescreen ABAWD_months_array(i).SHEL_insa, 7, 29
		EMWritescreen ABAWD_months_array(i).HEST_elect, 8, 29
		EMWritescreen ABAWD_months_array(i).HEST_heat, 9, 29
		EMWritescreen ABAWD_months_array(i).HEST_phone, 10, 29
		transmit
		EMReadScreen warning_check, 4, 18, 9 'We need to check here for a warning on potential expedited cases..
		IF warning_check = "FIAT" Then '... and enter two extra transmits to bypass.
			transmit 
			transmit
		END IF
		'Now on SUMM screen, which shouldn't matter
		PF3 'back to FFSL
		PF3 'This should bring up the "do you want to retain" popup
	EMWritescreen "Y", 13, 41
	transmit
	EMReadscreen final_month_check, 4, 10, 53 'This looks for a popup that only comes up in the final month, and clears it.
	IF final_month_check = "ELIG" THEN
		EMWritescreen "Y", 11, 52
		EMWritescreen initial_month, 13, 37
		EMWritescreen initial_year, 13, 40
		transmit
		
	END IF
	next

script_end_procedure("Success. The FIAT results have been generated. Please review before approving.")

