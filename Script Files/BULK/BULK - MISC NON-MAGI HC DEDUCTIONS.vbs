'GATHERING STATS----------------------------------------------------------------------------------------------------
name_of_script = "BULK - MISC NON-MAGI HC DEDUCTION.vbs"
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


'Required for statistical purposes==========================================================================================
STATS_counter = 1                          'sets the stats counter at one
STATS_manualtime = 39                      'manual run time in seconds
STATS_denomination = "C"       						 'C is for each CASE
'END OF stats block==============================================================================================

'CUSTOM FUNCTIONS---------------------------------------------------------------------------------------------
'This one creates a quasi-two-dimensional array of all cases, using "|" to split cases and "~" to split case info within cases.
Function combine_CEI_data_to_array(info_array)
	If case_number_01 <> "" then info_array = info_array & case_number_01 & "~" & CEI_amount_01 & "~" & Mo_Yr_01 & "~" & date_01 & "|"
	If case_number_02 <> "" then info_array = info_array & case_number_02 & "~" & CEI_amount_02 & "~" & Mo_Yr_02 & "~" & date_02 & "|"
	If case_number_03 <> "" then info_array = info_array & case_number_03 & "~" & CEI_amount_03 & "~" & Mo_Yr_03 & "~" & date_03 & "|"
	If case_number_04 <> "" then info_array = info_array & case_number_04 & "~" & CEI_amount_04 & "~" & Mo_Yr_04 & "~" & date_04 & "|"
	If case_number_05 <> "" then info_array = info_array & case_number_05 & "~" & CEI_amount_05 & "~" & Mo_Yr_05 & "~" & date_05 & "|"
	If case_number_06 <> "" then info_array = info_array & case_number_06 & "~" & CEI_amount_06 & "~" & Mo_Yr_06 & "~" & date_06 & "|"
End function

'CONNECTS TO MAXIS & grabs footer month/year
EMConnect ""
Call MAXIS_footer_finder(MAXIS_footer_month, MAXIS_footer_year)

'DIALOG TO DETERMINE WHERE TO GO IN MAXIS TO GET THE INFO
BeginDialog misc_non_magi_hcdeduction_list_generator_dialog, 0, 0, 156, 115, "MISC NON-MAGI HC DEDUCTION list generator dialog"
  DropListBox 65, 5, 85, 15, "REPT/ACTV"+chr(9)+"REPT/REVS"+chr(9)+"REPT/REVW", REPT_panel
  EditBox 55, 25, 20, 15, MAXIS_footer_month
  EditBox 130, 25, 20, 15, MAXIS_footer_year
  EditBox 75, 45, 75, 15, worker_number
  ButtonGroup ButtonPressed
    OkButton 20, 95, 50, 15
    CancelButton 85, 95, 50, 15
  Text 5, 10, 55, 10, "Create list from:"
  Text 5, 30, 45, 10, "Footer month:"
  Text 85, 30, 40, 10, "Footer year:"
  Text 5, 50, 65, 10, "Worker number(s):"
  Text 5, 65, 145, 25, "Enter 7 digits of each, (ex: x######). If entering multiple workers, separate each with a comma."
EndDialog

DO
	'DISPLAYS DIALOG
	Dialog misc_non_magi_hcdeduction_list_generator_dialog
		If buttonpressed = cancel then stopscript
		IF MAXIS_footer_month = "" OR MAXIS_footer_year = "" THEN MsgBox "Please provide a footer month & year."
		IF worker_number = "" THEN MsgBox "Please provide a worker number."
LOOP UNTIL MAXIS_footer_month <> "" AND MAXIS_footer_year <> "" AND worker_number <> "" AND ButtonPressed = -1

'checks for active MAXIS session
CALL check_for_MAXIS(True)

'NAVIGATES BACK TO SELF TO FORCE THE FOOTER MONTH, THEN NAVIGATES TO THE SELECTED SCREEN
back_to_self
EMWriteScreen "________", 18, 43
call navigate_to_MAXIS_screen("rept", right(REPT_panel, 4))
If right(REPT_panel, 4) = "REVS" then
	current_month_plus_one = datepart("m", dateadd("m", 1, date))
	If len(current_month_plus_one) = 1 then current_month_plus_one = "0" & current_month_plus_one
	current_month_plus_one_year = datepart("yyyy", dateadd("m", 1, date))
	current_month_plus_one_year = right(current_month_plus_one_year, 2)
	EMWriteScreen current_month_plus_one, 20, 43
	EMWriteScreen current_month_plus_one_year, 20, 46
	transmit
	EMWriteScreen MAXIS_footer_month, 20, 55
	EMWriteScreen MAXIS_footer_year, 20, 58
	transmit
	MAXIS_footer_month = current_month_plus_one
	MAXIS_footer_year = current_month_plus_one_year
End if

'CHECKS TO MAKE SURE WE'VE MOVED PAST SELF MENU. IF WE HAVEN'T, THE SCRIPT WILL STOP. AN ERROR MESSAGE SHOULD DISPLAY ON THE BOTTOM OF THE MENU.
EMReadScreen SELF_check, 4, 2, 50
If SELF_check = "SELF" then script_end_procedure("Can't get past SELF menu. Check error message and try again!")

'DEFINES THE EXCEL_ROW VARIABLE FOR WORKING WITH THE SPREADSHEET
excel_row = 2

'OPENS A NEW EXCEL SPREADSHEET
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = True
Set objWorkbook = objExcel.Workbooks.Add()

'FORMATS THE EXCEL SPREADSHEET WITH THE HEADERS, AND SETS THE COLUMN WIDTH
ObjExcel.Cells(1, 1).Value = "WORKER"
objExcel.Cells(1, 1).Font.Bold = TRUE
ObjExcel.Cells(1, 2).Value = "M#"
objExcel.Cells(1, 2).Font.Bold = TRUE
objExcel.Cells(1, 2).ColumnWidth = 9
ObjExcel.Cells(1, 3).Value = "Name"
objExcel.Cells(1, 3).Font.Bold = TRUE
objExcel.Cells(1, 3).ColumnWidth = 27
ObjExcel.Cells(1, 4).Value = "Pickle Disregard"
objExcel.Cells(1, 4).Font.Bold = TRUE
objExcel.Cells(1, 4).ColumnWidth = 15
ObjExcel.Cells(1, 5).Value = "Disabled Widow Diregard"
objExcel.Cells(1, 5).Font.Bold = TRUE
objExcel.Cells(1, 5).ColumnWidth = 24
ObjExcel.Cells(1, 6).Value = "Disabled Adult Child"
objExcel.Cells(1, 6).Font.Bold = TRUE
objExcel.Cells(1, 6).ColumnWidth = 20
ObjExcel.Cells(1, 7).Value = "Widow/ers Disregard"
objExcel.Cells(1, 7).Font.Bold = TRUE
objExcel.Cells(1, 7).ColumnWidth = 20
ObjExcel.Cells(1, 8).Value = "Other Unearned Income Disregard"
objExcel.Cells(1, 8).Font.Bold = TRUE
objExcel.Cells(1, 8).ColumnWidth = 31
ObjExcel.Cells(1, 9).Value = "Other Earned Income Disregard"
objExcel.Cells(1, 9).Font.Bold = TRUE
objExcel.Cells(1, 9).ColumnWidth = 29


'Splitting array for use by the for...next statement
worker_number_array = split(worker_number, ",")

For each worker in worker_number_array

	If trim(worker) = "" then exit for

	worker_ID = trim(worker)

	If REPT_panel = "REPT/ACTV" then 'THE REPT PANEL HAS THE worker NUMBER IN DIFFERENT COLUMNS. THIS WILL DETERMINE THE CORRECT COLUMN FOR THE worker NUMBER TO GO
		worker_ID_col = 13
	Else
		worker_ID_col = 6
	End if
	EMReadScreen default_worker_number, 7, 21, worker_ID_col 'CHECKING THE CURRENT worker NUMBER. IF IT DOESN'T NEED TO CHANGE IT WON'T. OTHERWISE, THE SCRIPT WILL INPUT THE CORRECT NUMBER.
	If ucase(worker_ID) <> ucase(default_worker_number) then
		EMWriteScreen worker_ID, 21, worker_ID_col
		transmit
	End if


	'THIS DO...LOOP DUMPS THE CASE NUMBER AND NAME OF EACH CLIENT INTO A SPREADSHEET
	Do

		EMReadScreen last_page_check, 21, 24, 02

		'This Do...loop checks for the password prompt.
		Do
			EMReadScreen password_prompt, 38, 2, 23
			IF password_prompt = "ACF2/CICS PASSWORD VERIFICATION PROMPT" then MsgBox "You are locked out of your case. Type your password then try again."
		Loop until password_prompt <> "ACF2/CICS PASSWORD VERIFICATION PROMPT"

		row = 7 'defining the row to look at
		Do
			If REPT_panel = "REPT/ACTV" then
				EMReadScreen case_number, 8, row, 12 'grabbing case number
				EMReadScreen client_name, 18, row, 21 'grabbing client name
			Else
				EMReadScreen case_number, 8, row, 6 'grabbing case number
				EMReadScreen client_name, 15, row, 16 'grabbing client name
			End if
			IF trim(case_number) <> "" THEN
				ObjExcel.Cells(excel_row, 1).Value = worker_ID
				ObjExcel.Cells(excel_row, 2).Value = trim(case_number)
				ObjExcel.Cells(excel_row, 3).Value = trim(client_name)
			END IF
			excel_row = excel_row + 1
			row = row + 1
		Loop until row = 19 or trim(case_number) = ""

		PF8 'going to the next screen


	Loop until last_page_check = "THIS IS THE LAST PAGE"

Next

'NOW THE SCRIPT IS CHECKING STAT/PDED FOR EACH CASE.----------------------------------------------------------------------------------------------------

excel_row = 2 'Resetting the case row to investigate.

do until ObjExcel.Cells(excel_row, 2).Value = "" 'shuts down when there's no more case numbers
	case_number = ObjExcel.Cells(excel_row, 2).Value
	If case_number = "" then exit do

	'This Do...loop gets back to SELF
	back_to_self

	'NAVIGATES TO STAT/PDED
	call navigate_to_MAXIS_screen("STAT", "PDED")

	'NAVIGATES TO PDED, LOOKS FOR CODED DISREGARDS, AND ADDS TO SPREADSHEET
	EMReadScreen pickle_disregard, 1, 6, 60
	If pickle_disregard = "_" then
		pickle_disregard = ""
	ELSEIF pickle_disregard = "1" THEN
		pickle_disregard = "Pickle Elig"
	ELSEIF pickle_disregard = "2" THEN
		pickle_disregard = "Potentially Pickle Elig"
	END IF
	ObjExcel.Cells(excel_row, 4).Value = pickle_disregard
	EMReadScreen disabled_widow_disregard, 1, 7, 60
	If disabled_widow_disregard = "_" then disabled_widow_disregard = ""
	ObjExcel.Cells(excel_row, 5).Value = diabled_widow_disregard
	EMReadScreen disabled_adult_child_disregard, 1, 8, 60
	If disabled_adult_child_disregard = "_" then disabled_adult_child_disregard = ""
	ObjExcel.Cells(excel_row, 6).Value = diabled_adult_child_disregard
	EMReadScreen widowers_disregard, 1, 9, 60
	If widowers_disregard = "_" then widowers_disregard = ""
	ObjExcel.Cells(excel_row, 7).Value = widowers_disregard
	EMReadScreen other_unearned_disregard, 8, 10, 62
	other_unearned_disregard = replace(other_unearned_disregard, "_", "")
	ObjExcel.Cells(excel_row, 8).Value = other_unearned_disregard
	EMReadScreen other_earned_disregard, 8, 11, 62
	other_earned_disregard = replace(other_earned_disregard, "_", "")
	ObjExcel.Cells(excel_row, 9).Value = other_earned_disregard

	'Deleting blank rows
	IF objExcel.Cells(excel_row, 4).Value = "" AND _
	  objExcel.Cells(excel_row, 5).Value = "" AND _
	  objExcel.Cells(excel_row, 6).Value = "" AND _
	  objExcel.Cells(excel_row, 7).Value = "" AND _
	  objExcel.Cells(excel_row, 8).Value = "" AND _
	  objExcel.Cells(excel_row, 9).Value = "" THEN
			SET objRange = objExcel.Cells(excel_row, 1).EntireRow
			objRange.Delete
			excel_row = excel_row - 1
	END IF

	excel_row = excel_row + 1 'setting up the script to check the next row.
	STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
loop

STATS_counter = STATS_counter - 1                      'subtracts one from the stats (since 1 was the count, -1 so it's accurate)
script_end_procedure("Success! Your list has been created.")
