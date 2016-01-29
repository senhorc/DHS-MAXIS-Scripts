'STATS GATHERING----------------------------------------------------------------------------------------------------
name_of_script = "NOTES - COUNTY BURIAL APPLICATION.vbs"
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
STATS_counter = 1               'sets the stats counter at one
STATS_manualtime = 90           'manual run time in seconds
STATS_denomination = "C"        'C is for each case
'END OF stats block=========================================================================================================

'Dialog---------------------------------------------------------------------------------------------------------------------------
BeginDialog County_Burial_Application_Received, 0, 0, 266, 175, "County Burial Application Received"
  EditBox 55, 5, 60, 15, case_number
  EditBox 200, 5, 60, 15, date_received
  EditBox 55, 25, 60, 15, date_of_death
  EditBox 200, 25, 30, 15, CFR_resp
  EditBox 35, 50, 225, 15, assets
  EditBox 80, 75, 180, 15, Total_Counted_Assets
  EditBox 55, 100, 205, 15, other_notes
  EditBox 55, 125, 205, 15, action_taken
  EditBox 65, 150, 90, 15, worker_signature
  ButtonGroup ButtonPressed
    OkButton 160, 150, 50, 15
    CancelButton 210, 150, 50, 15
  Text 145, 10, 50, 10, "Date received: "
  Text 5, 105, 40, 10, "Other notes: "
  Text 175, 30, 20, 10, "CFR:"
  Text 5, 130, 50, 10, "Actions taken: "
  Text 5, 10, 50, 10, "Case Number: "
  Text 5, 155, 60, 10, "Worker Signature: "
  Text 5, 55, 25, 10, "Assets:"
  Text 5, 30, 50, 10, "Date of death:"
  Text 5, 80, 75, 10, "Total Counted Assets:"
EndDialog

'THE SCRIPT--------------------------------------------------------------------------------------------------------------------------------------
'connecting to BlueZone, and grabbing the case number
EMConnect ""
Call MAXIS_case_number_finder(case_number)

'calling the dialog---------------------------------------------------------------------------------------------------------------
DO
	Dialog County_Burial_Application_Received
	IF buttonpressed = 0 THEN stopscript
	IF case_number = "" THEN MsgBox "You must have a case number to continue!"
	IF worker_signature = "" THEN MsgBox "You must enter a worker signature."
LOOP until case_number <> "" and worker_signature <> ""

'checking for an active MAXIS session
CALL check_for_MAXIS(FALSE)

'The case note---------------------------------------------------------------------------------------------------------------------
start_a_blank_CASE_NOTE
CALL write_variable_in_CASE_NOTE("***County Burial Application Received")
CALL write_bullet_and_variable_in_CASE_NOTE("Date Received", Date_Received)
CALL write_bullet_and_variable_in_CASE_NOTE("Date of death", Date_of_death)
CALL write_bullet_and_variable_in_CASE_NOTE("CFR", CFR_resp)
CALL write_bullet_and_variable_in_CASE_NOTE("Assets", Assets)
CALL write_bullet_and_variable_in_CASE_NOTE("Total Counted Assets", Total_Counted_Assets)
CALL write_bullet_and_variable_in_CASE_NOTE("Other notes", other_notes)
CALL write_bullet_and_variable_in_CASE_NOTE("Action taken", action_taken)
CALL write_variable_in_CASE_NOTE("---")
CALL write_variable_in_CASE_NOTE(worker_signature)

Script_end_procedure("")
