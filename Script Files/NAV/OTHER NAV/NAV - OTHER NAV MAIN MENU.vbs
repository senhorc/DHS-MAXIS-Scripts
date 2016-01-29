'STATS GATHERING----------------------------------------------------------------------------------------------------
name_of_script = "NAV - OTHER NOTES MAIN MENU.vbs"
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


'DIALOGS----------------------------------------------------------------------------------------------------
BeginDialog OTHER_NAV_scripts_main_menu_dialog, 0, 0, 456, 140, "Other NAV scripts main menu dialog"
  ButtonGroup ButtonPressed
    CancelButton 400, 120, 50, 15
    PushButton 375, 5, 65, 10, "SIR instructions", SIR_instructions_button
    PushButton 5, 20, 100, 10, "Look up MAXIS case in MMIS", 			LOOK_UP_MAXIS_CASE_IN_MMIS_button
    PushButton 5, 35, 100, 10, "Look up MMIS PMI in MAXIS", 			LOOK_UP_MMIS_PMI_IN_MAXIS_button
    PushButton 5, 50, 120, 10, "Move production screen to inquiry", 	MOVE_PRODUCTION_SCREEN_TO_INQUIRY_button
    PushButton 5, 65, 80, 10, "Phone number look-up", PHONE_NUMBER_LOOK_UP_button
    PushButton 5, 90, 50, 10, "REPT search", 							REPT_SEARCH_button
    PushButton 5, 105, 40, 10, "View INFC", 								VIEW_INFC_button
  Text 5, 5, 245, 10, "Other nav scripts main menu: select the script to run from the choices below."
  Text 110, 20, 250, 10, "--- Navigates to RELG in MMIS for a selected case. Navigates to person 01."
  Text 110, 35, 140, 10, "--- Jumps from MMIS to MAXIS for a case."
  Text 130, 50, 195, 10, "--- Moves a screen from MAXIS production to MAXIS inquiry."
  Text 90, 65, 360, 20, "--- Checks every case on PND1, PND2, ACTV, REVW, or INAC, to find a case number when all you have is a phone number."
  Text 60, 90, 190, 10, "--- Searches for a specific case on multiple REPT screens."
  Text 50, 105, 400, 10, "--- Views an INFC panel for a case."
EndDialog


'Variables to declare
IF script_repository = "" THEN script_repository = "https://raw.githubusercontent.com/MN-Script-Team/DHS-MAXIS-Scripts/master/Script Files"		'If it's blank, we're assuming the user is a scriptwriter, ergo, master branch.

'THE SCRIPT----------------------------------------------------------------------------------------------------

'Shows main menu dialog, which asks user which script to run. Loops until a button other than the SIR instructions button is clicked.
Do
	dialog OTHER_NAV_scripts_main_menu_dialog
	If buttonpressed = cancel then stopscript
	If buttonpressed = SIR_instructions_button then CreateObject("WScript.Shell").Run("https://www.dhssir.cty.dhs.state.mn.us/MAXIS/blzn/scriptwiki/Wiki%20Pages/Navigation%20scripts.aspx")
Loop until buttonpressed <> SIR_instructions_button

'Connecting to BlueZone
EMConnect ""

If buttonpressed = LOOK_UP_MAXIS_CASE_IN_MMIS_button						then call run_from_GitHub(script_repository & "/NAV/OTHER NAV/NAV - LOOK UP MAXIS CASE IN MMIS.vbs")
If buttonpressed = LOOK_UP_MMIS_PMI_IN_MAXIS_button							then call run_from_GitHub(script_repository & "/NAV/OTHER NAV/NAV - LOOK UP MMIS PMI IN MAXIS.vbs")
If buttonpressed = MOVE_PRODUCTION_SCREEN_TO_INQUIRY_button					then call run_from_GitHub(script_repository & "/NAV/OTHER NAV/NAV - MOVE PRODUCTION SCREEN TO INQUIRY.vbs")
IF ButtonPressed = PHONE_NUMBER_LOOK_UP_button								then call run_from_GitHub(script_repository & "/NAV/OTHER NAV/NAV - PHONE NUMBER LOOK UP.vbs")
If buttonpressed = REPT_SEARCH_button										then call run_from_GitHub(script_repository & "/NAV/OTHER NAV/NAV - REPT SEARCH.vbs")
If buttonpressed = VIEW_INFC_button											then call run_from_GitHub(script_repository & "/NAV/OTHER NAV/NAV - VIEW INFC.vbs")

'Logging usage stats
script_end_procedure("If you see this, it's because you clicked a button that, for some reason, does not have an outcome in the script. Contact your alpha user to report this bug. Thank you!")
