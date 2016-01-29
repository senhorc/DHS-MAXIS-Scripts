'STATS GATHERING----------------------------------------------------------------------------------------------------
name_of_script = "MEMOS - MAIN MENU.vbs"
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
BeginDialog MEMOS_scripts_main_menu_dialog, 0, 0, 451, 285, "Memos scripts main menu dialog"
  ButtonGroup ButtonPressed
    PushButton 5, 20, 65, 10, "12 month contact", TWELVE_MONTH_CONTACT_button
    PushButton 5, 45, 115, 10, "ABAWD with child in HH WCOM", ABAWD_WITH_CHILD_IN_HH_WCOM_button
    PushButton 5, 60, 65, 10, "Appointment letter", APPOINTMENT_LETTER_button
    PushButton 5, 75, 100, 10, "Duplicate assistance WCOM", DUPLICATE_ASSISTANCE_button
    PushButton 5, 90, 110, 10, "DWP/MFIP CS Disregard WCOM", CS_DISREGARD_button
    PushButton 5, 105, 125, 10, "GRH overpayment (client left facility)", GRH_OP_CL_LEFT_FACI_button
    PushButton 5, 135, 70, 10, "LTC - Asset transfer", LTC_ASSET_TRANSFER_button
    PushButton 5, 150, 115, 10, "MAEPD - No initial premium paid", MAEPD_NO_PREMIUM_button
    PushButton 5, 120, 60, 10, "Method B WCOM", METHOD_B_WCOM_button
    PushButton 5, 165, 60, 10, "MFIP orientation", MFIP_ORIENTATION_button
    PushButton 5, 180, 55, 10, "MNsure memo", MNSURE_MEMO_button
    PushButton 5, 195, 25, 10, "NOMI", NOMI_button
    PushButton 5, 210, 55, 10, "Overdue baby", OVERDUE_BABY_button
    PushButton 5, 235, 80, 10, "Postponed WREG verif", POSTPONED_WREG_button
    PushButton 5, 260, 70, 10, "SNAP E and T letter", SNAP_E_AND_T_LETTER_button
    PushButton 375, 5, 65, 10, "SIR instructions", SIR_instructions_button
    CancelButton 395, 265, 50, 15
  Text 5, 5, 235, 10, "Memos scripts main menu: select the script to run from the choices below."
  Text 125, 45, 320, 10, "---NEW 01/2016 Adds a WCOM to a notice for an ABAWD adult receiving child under 18 exemption."
  Text 75, 20, 375, 20, "--- Sends a MEMO to the client reminding them of their reporting responsibilities (required for SNAP 2-year certification periods, per POLI/TEMP TE02.08.165)."
  Text 75, 60, 300, 10, "--- Sends a MEMO containing the appointment letter (with text from POLI/TEMP TE02.05.15)."
  Text 110, 75, 305, 10, "--- Adds a WCOM to a notice for duplicate assistance explaining why the client was ineligible."
  Text 120, 90, 320, 10, "--- NEW 01/2016!! Adds required WCOM to a notice when applying the CS Disregard to DWP/MFIP."
  Text 135, 105, 310, 10, "--- Sends a MEMO to a facility indicating that an overpayment is due because a client left."
  Text 70, 120, 360, 10, "--- NEW 01/2016!!! Makes detailed WCOM regarding spenddown vs. recipient amount for method B HC cases."
  Text 80, 135, 200, 10, "--- Sends a MEMO to a LTC client regarding asset transfers."
  Text 130, 150, 225, 10, "--- Sends a WCOM on a denial for no initial MA-EPD premium."
  Text 70, 165, 185, 10, "--- Sends a MEMO to a client regarding MFIP orientation."
  Text 65, 180, 160, 10, "--- Sends a MEMO to a client regarding MNsure."
  Text 35, 195, 375, 10, "--- Sends the SNAP notice of missed interview (NOMI) letter, following rules set out in POLI/TEMP TE02.05.15."
  Text 65, 210, 355, 20, "--- Sends a MEMO informing client that they need to report information regarding the birth of their child, and/or pregnancy end date, within 10 days or their case may close."
  Text 95, 235, 345, 20, "--- Sends a WCOM informing the client of postponed verifications that MAXIS won't add to notice correctly by itself."
  Text 80, 260, 315, 10, "--- Sends a SPEC/LETR informing client that they have an Employment and Training appointment."
EndDialog




'Variables to declare
IF script_repository = "" THEN script_repository = "https://raw.githubusercontent.com/MN-Script-Team/DHS-MAXIS-Scripts/master/Script Files"		'If it's blank, we're assuming the user is a scriptwriter, ergo, master branch.

'THE SCRIPT----------------------------------------------------------------------------------------------------
'Shows main menu dialog, which asks user which memo to generate. Loops until a button other than the SIR instructions button is clicked.
Do
	dialog MEMOS_scripts_main_menu_dialog
	If buttonpressed = cancel then stopscript
	If buttonpressed = SIR_instructions_button then CreateObject("WScript.Shell").Run("https://www.dhssir.cty.dhs.state.mn.us/MAXIS/blzn/Script%20Instructions%20Wiki/Memos%20scripts.aspx")
Loop until buttonpressed <> SIR_instructions_button

'Connecting to BlueZone
EMConnect ""

'Hennepin handling (they don't use the Appt Letter or NOMI scripts because they have permission (at least temporarily) to schedule using a time range instead of a single time. Because of this, the NOMI and Appt letter scripts would technically cause incorrect information to be sent to the clients. This is a simple solution until their procedures are updated.)
If ucase(worker_county_code) = "X127" then
	IF ButtonPressed = APPOINTMENT_LETTER_button 	THEN script_end_procedure("The Appointment Letter script is not available to Hennepin users at this time. Contact an alpha user or your supervisor if you have questions.")
End if

IF ButtonPressed = TWELVE_MONTH_CONTACT_button 	        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - 12 MONTH CONTACT.vbs")
IF ButtonPressed = ABAWD_WITH_CHILD_IN_HH_WCOM_button 	THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - ABAWD WITH CHILD IN HH WCOM.vbs")
IF ButtonPressed = APPOINTMENT_LETTER_button 	        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - APPOINTMENT LETTER.vbs")
IF ButtonPressed = DUPLICATE_ASSISTANCE_button          THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - DUPLICATE ASSISTANCE WCOM.vbs")
IF ButtonPressed = CS_DISREGARD_button 		            THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - CS DISREGARD WCOM.vbs")
IF ButtonPressed = GRH_OP_CL_LEFT_FACI_button	        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - GRH OP CL LEFT FACI.vbs")
IF ButtonPressed = LTC_ASSET_TRANSFER_button 	        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - LTC - ASSET TRANSFER.vbs")
IF ButtonPressed = MAEPD_NO_PREMIUM_button		        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - MA-EPD NO INITIAL PREMIUM.vbs")
IF ButtonPressed = METHOD_B_WCOM_button 		        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - METHOD B WCOM.vbs")
IF ButtonPressed = MFIP_ORIENTATION_button 		        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - MFIP ORIENTATION.vbs")
IF ButtonPressed = MNSURE_MEMO_button 			        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - MNSURE MEMO.vbs")
IF ButtonPressed = NOMI_button 					        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - NOMI.vbs")
IF ButtonPressed = OVERDUE_BABY_button			        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - OVERDUE BABY.vbs")
IF ButtonPressed = POSTPONED_WREG_button		        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - POSTPONED WREG VERIFS.vbs")
IF ButtonPressed = SNAP_E_AND_T_LETTER_button	        THEN CALL run_from_GitHub(script_repository & "/MEMOS/MEMOS - SNAP E AND T LETTER.vbs")

'Logging usage stats
script_end_procedure("If you see this, it's because you clicked a button that, for some reason, does not have an outcome in the script. Contact your alpha user to report this bug. Thank you!")
