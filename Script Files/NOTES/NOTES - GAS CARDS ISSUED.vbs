'Option Explicit
name_of_script = "NOTES - GAS CARDS ISSUED.vbs"
start_time = timer

'DIM card_amt, amt_given_yr_to_date, check, worker_signature, url, req, fso, gas_card_dialog, client_signed_stmt_check, ButtonPressed, case_number, client_signed_stmt, beta_agency, date_cards_given, case_number_finder, thirty_days_from_now

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
STATS_counter = 1               'sets the stats counter at one
STATS_manualtime = 90           'manual run time in seconds
STATS_denomination = "C"        'C is for each case
'END OF stats block=========================================================================================================

'The Dialog--------------------------------------------------------------
BeginDialog gas_card_dialog, 0, 0, 286, 125, "Gas Card Dialog"
  EditBox 55, 5, 70, 15, case_number
  EditBox 225, 5, 50, 15, date_cards_given
  DropListBox 100, 25, 65, 15, "Select One..."+chr(9)+"10"+chr(9)+"20"+chr(9)+"30"+chr(9)+"40", card_amt
  EditBox 160, 45, 45, 15, amt_given_yr_to_date
  EditBox 95, 65, 75, 15, card_number
  CheckBox 5, 90, 145, 10, "Client Signed Fuel Card Acknowledgement", client_signed_stmt_check
  EditBox 80, 105, 75, 15, worker_signature
  ButtonGroup ButtonPressed
    OkButton 175, 105, 50, 15
    CancelButton 230, 105, 50, 15
  Text 5, 50, 150, 10, "Total amount given this year (including today):"
  Text 150, 10, 70, 10, "Gas Cards issued on:"
  Text 5, 30, 95, 10, "Amount of Gas Cards given:"
  Text 10, 110, 70, 10, "Gas Card Issued By:"
  Text 5, 70, 90, 10, "Gas Card Numbers Given:"
  Text 5, 10, 50, 10, "Case Number:"
EndDialog

'Connects to BlueZone
EMConnect ""

'Grabs the MAXIS case number
CALL MAXIS_case_number_finder(case_number)

'Shows DIALOG
DO
	DO
		DO
			Dialog gas_card_dialog
			IF ButtonPressed = 0 THEN StopScript
			IF worker_signature = "" THEN MsgBox "You must sign your case note!"
		LOOP UNTIL worker_signature <> ""
		IF IsNumeric(case_number) = FALSE THEN MsgBox "You must type a valid numeric case number."
	LOOP UNTIL IsNumeric(case_number) = TRUE
	IF card_amt = "Select One..." THEN MsgBox "You must select 'Amount of Gas Cards Given'"
LOOP UNTIL card_amt <> "Select One..."

'Checks for active MAXIS session
CALL check_for_MAXIS(FALSE)

amt_given_yr_to_date = "$" & amt_given_yr_to_date
card_amt = "$" & card_amt

'Writes the case note
start_a_blank_CASE_NOTE
CALL write_variable_in_case_note ("=$= GAS CARDS ISSUED: TODAY " & card_amt & ", YTD TOTAL " & amt_given_yr_to_date & " =$=")       'Writes title in Case note
CALL write_bullet_and_variable_in_case_note("Gas Cards issued on", date_cards_given)                                                'Writes date cards were issued on next line
CALL write_bullet_and_variable_in_case_note("Amount of Fuel Cards Given", card_amt)                                                 'Write the amt given this
CALL write_bullet_and_variable_in_case_note("Gas Card Numbers", card_number)                                                        'Writes the gas card numbers
CALL write_bullet_and_variable_in_case_note("Total Amount Given This Year Including Today", amt_given_yr_to_date)   	       	    'Writes amt given year to date
IF client_signed_stmt_check = 1 THEN CALL write_variable_in_CASE_NOTE("* Client signed Fuel Card Acknowledgement Form")             'Writes if the client signed stmt if that box was checked

IF card_amt >= 40 THEN
	thirty_days_from_now = DateAdd ("d", 30, date)
	CALL write_bullet_and_variable_in_case_note("Next Gas Card Can be Given On", thirty_days_from_now)                  'If $40 is selected, then will write a line telling FW when the next cards can be issued
END IF

CALL write_variable_in_case_note ("---")   
CALL write_variable_in_CASE_NOTE(worker_signature)    'Writes worker signature in note

script_end_procedure("")
