'GATHERING STATS----------------------------------------------------------------------------------------------------
name_of_script = "MEMOS - LTC - ASSET TRANSFER.vbs"
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
STATS_manualtime = 70                               'manual run time in seconds
STATS_denomination = "C"       'C is for each CASE
'END OF stats block==============================================================================================

BeginDialog LTC_asset_transfer_dialog, 0, 0, 126, 82, "LTC asset transfer dialog"
  EditBox 35, 0, 85, 15, client
  EditBox 35, 20, 85, 15, spouse
  EditBox 70, 40, 50, 15, renewal_footer_month_year
  ButtonGroup LTC_asset_transfer_dialog_ButtonPressed
    OkButton 10, 60, 50, 15
    CancelButton 65, 60, 50, 15
  Text 5, 5, 30, 10, "Client:"
  Text 5, 25, 30, 10, "Spouse:"
  Text 5, 45, 65, 10, "ER date (MM/YY):"
EndDialog

'The script------------------------
'connecting to MAXIS
EMConnect ""
Do
  Dialog LTC_asset_transfer_dialog
  If LTC_asset_transfer_dialog_ButtonPressed = 0 then stopscript
  EMSendKey "<enter>"
  EMWaitReady 1, 1
  EMReadScreen WCOM_input_check, 27, 2, 28
  If WCOM_input_check <> "Worker Comment Input Screen" and WCOM_input_check <> "  Client Memo Input Screen " then MsgBox "You need to be on a notice in SPEC/WCOM or SPEC/MEMO for this to work. Please try again."
Loop until WCOM_input_check = "Worker Comment Input Screen" or WCOM_input_check = "  Client Memo Input Screen "

EMSendKey "<home>" + "The ownership of " + client + "'s assets must be transferred to " + spouse + " to avoid having them counted in future eligibility determinations. You are encouraged to do this as soon as possible. This transfer of assets must be done before " + client + "'s first annual renewal for " + renewal_footer_month_year + ". Verification of the transfer can be provided at any time. " + "<newline>" + "<newline>"
EMSendKey "At the first annual renewal in " + renewal_footer_month_year + " the value of all assets that list " + client + " as an owner or co-owner will be applied towards the Medical Assistance Asset limit of $3,000.00.  If the total value of all countable assets for " + client + " is more than $3,000.00, Medical Assistance may be closed for " + renewal_footer_month_year + "."

script_end_procedure("")
