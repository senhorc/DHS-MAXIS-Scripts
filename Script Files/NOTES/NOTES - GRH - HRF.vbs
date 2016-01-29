'STATS----------------------------------------------------------------------------------------------------
name_of_script = "NOTES - GRH - HRF.vbs"
start_time = timer

'BY USING THIS SCRIPT, WE ARE ASSUMING THE USER IS RUNNING IT ON POST PAY CASES ONLY'-----------------------------------------

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
STATS_manualtime = 480           'manual run time in seconds
STATS_denomination = "C"        'C is for each case
'END OF stats block=========================================================================================================

'DATE CALCULATIONS----------------------------------------------------------------------------------------------------
prev_month = dateadd("m", -1, date)
footer_month = datepart("m", prev_month)
If len(footer_month) = 1 then footer_month = "0" & footer_month
footer_year = right(datepart("yyyy", prev_month), 2)

'DIALOGS-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BeginDialog case_number_dialog, 0, 0, 181, 100, "Case number dialog"
  EditBox 80, 5, 70, 15, case_number
  EditBox 65, 25, 30, 15, footer_month
  EditBox 140, 25, 30, 15, footer_year
  CheckBox 10, 60, 30, 10, "GRH", GRH_check
  CheckBox 50, 60, 30, 10, "HC", HC_check
  ButtonGroup ButtonPressed
    OkButton 35, 80, 50, 15
    CancelButton 95, 80, 50, 15
  Text 25, 10, 50, 10, "Case number:"
  Text 10, 30, 50, 10, "Footer month:"
  Text 110, 30, 25, 10, "Year:"
  GroupBox 5, 45, 85, 30, "Programs recertifying"
  Text 95, 45, 80, 30, "Please note: this script assumes you're working a postpay case."
EndDialog

BeginDialog HRF_dialog, 0, 0, 451, 260, "HRF dialog"
  EditBox 65, 25, 50, 15, HRF_datestamp
  DropListBox 170, 25, 75, 15, "(select one...)"+chr(9)+"complete"+chr(9)+"incomplete", HRF_status
  EditBox 65, 45, 380, 15, earned_income
  EditBox 70, 65, 375, 15, unearned_income
  EditBox 55, 85, 390, 15, faci
  EditBox 30, 105, 90, 15, YTD
  EditBox 170, 105, 275, 15, changes
  EditBox 100, 125, 345, 15, FIAT_reasons
  EditBox 50, 145, 395, 15, other_notes
  CheckBox 240, 165, 150, 10, "Sent forms to AREP?", sent_arep_checkbox
  EditBox 240, 180, 205, 15, verifs_needed
  EditBox 235, 200, 210, 15, actions_taken
  CheckBox 125, 225, 180, 10, "Check here to case note grant info from ELIG/GRH.", grab_GRH_info_check
  EditBox 235, 240, 65, 15, date_check_sent_to_facility
  EditBox 380, 220, 65, 15, worker_signature
  ButtonGroup ButtonPressed
    OkButton 340, 240, 50, 15
    CancelButton 395, 240, 50, 15
    PushButton 280, 15, 20, 10, "GRH", ELIG_GRH_button 'previously this was assign to elig/mfip
    PushButton 300, 15, 20, 10, "HC", ELIG_HC_button
    PushButton 335, 15, 45, 10, "prev. panel", prev_panel_button
    PushButton 335, 25, 45, 10, "next panel", next_panel_button
    PushButton 395, 15, 45, 10, "prev. memb", prev_memb_button
    PushButton 395, 25, 45, 10, "next memb", next_memb_button
    PushButton 10, 175, 25, 10, "BUSI", BUSI_button
    PushButton 35, 175, 25, 10, "JOBS", JOBS_button
    PushButton 10, 185, 25, 10, "RBIC", RBIC_button
    PushButton 35, 185, 25, 10, "UNEA", UNEA_button
    PushButton 75, 175, 25, 10, "ACCT", ACCT_button
    PushButton 100, 175, 25, 10, "CARS", CARS_button
    PushButton 125, 175, 25, 10, "CASH", CASH_button
    PushButton 150, 175, 25, 10, "OTHR", OTHR_button
    PushButton 75, 185, 25, 10, "REST", REST_button
    PushButton 100, 185, 25, 10, "SECU", SECU_button
    PushButton 125, 185, 25, 10, "TRAN", TRAN_button
    PushButton 10, 215, 25, 10, "MEMB", MEMB_button
    PushButton 35, 215, 25, 10, "MEMI", MEMI_button
    PushButton 60, 215, 25, 10, "MONT", MONT_button
    PushButton 85, 215, 20, 10, "FACI", FACI_button
  GroupBox 275, 5, 50, 25, "ELIG panels"
  GroupBox 330, 5, 115, 35, "STAT-based navigation"
  Text 5, 30, 55, 10, "HRF datestamp:"
  Text 125, 30, 40, 10, "HRF status:"
  Text 5, 50, 55, 10, "Earned income:"
  Text 5, 70, 60, 10, "Unearned income:"
  Text 5, 90, 40, 10, "Facility Info:"
  Text 5, 110, 20, 10, "YTD:"
  Text 130, 110, 35, 10, "Changes?:"
  Text 5, 130, 95, 10, "FIAT reasons (if applicable):"
  Text 5, 150, 45, 10, "Other notes:"
  GroupBox 5, 165, 60, 35, "Income panels"
  GroupBox 70, 165, 110, 35, "Asset panels"
  Text 185, 185, 50, 10, "Verifs needed:"
  Text 185, 205, 50, 10, "Actions taken:"
  GroupBox 5, 205, 105, 25, "other STAT panels"
  Text 315, 225, 65, 10, "Worker signature:"
  Text 70, 245, 160, 10, "If post-pay check sent to facility, enter date sent:"
EndDialog


BeginDialog case_note_dialog, 0, 0, 136, 51, "Case note dialog"
  ButtonGroup ButtonPressed
    PushButton 15, 20, 105, 10, "Yes, take me to case note.", yes_case_note_button
    PushButton 5, 35, 125, 10, "No, take me back to the script dialog.", no_case_note_button
  Text 10, 5, 125, 10, "Are you sure you want to case note?"
EndDialog


'VARIABLES WHICH NEED DECLARING------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
HH_memb_row = 5
Dim row
Dim col


'THE SCRIPT----------------------------------------------------------------------------------------------------
'Connecting to BlueZone
EMConnect ""

'Grabbing case number and footer year/month
call MAXIS_case_number_finder(case_number)
call MAXIS_footer_finder(MAXIS_footer_month, MAXIS_footer_year)


'Showing case number dialog
Do
	Dialog case_number_dialog
	cancel_confirmation
	If case_number = "" or IsNumeric(case_number) = False or len(case_number) > 8 then MsgBox "You need to type a valid case number."
Loop until case_number <> "" and IsNumeric(case_number) = True and len(case_number) <= 8

'Checking for MAXIS
call check_for_MAXIS(False)

'NAV to MEMB
call navigate_to_MAXIS_screen("stat", "memb")

'Creating a custom dialog for determining who the HH members are
call HH_member_custom_dialog(HH_member_array)

'Autofilling info for case note
call autofill_editbox_from_MAXIS(HH_member_array, "BUSI", earned_income)
call autofill_editbox_from_MAXIS(HH_member_array, "JOBS", earned_income)
call autofill_editbox_from_MAXIS(HH_member_array, "MONT", HRF_datestamp)
call autofill_editbox_from_MAXIS(HH_member_array, "RBIC", earned_income)
call autofill_editbox_from_MAXIS(HH_member_array, "UNEA", unearned_income)
'call autofill_editbox_from_MAXIS(HH_member_array, "FACI", faci)
'Custom pull from FACI to grab Difficulty of Care
For each HH_member in HH_member_array
	  CALL navigate_to_MAXIS_screen("STAT", "FACI")
      EMWriteScreen HH_member, 20, 76
      EMWriteScreen "01", 20, 79
      transmit
      EMReadScreen FACI_total, 1, 2, 78
      If FACI_total <> 0 then
        row = 14
        Do
          EMReadScreen date_in_check, 4, row, 53
		  EMReadScreen date_in_month_day, 5, row, 47
          EMReadScreen date_out_check, 4, row, 77
		  date_in_month_day = replace(date_in_month_day, " ", "/") & "/"
          If (date_in_check <> "____" and date_out_check <> "____") or (date_in_check = "____" and date_out_check = "____") then row = row + 1
          If row > 18 then
            EMReadScreen FACI_page, 1, 2, 73
            If FACI_page = FACI_total then 
              FACI_status = "Not in facility"
            Else
              transmit
              row = 14
            End if
          End if
        Loop until (date_in_check <> "____" and date_out_check = "____") or FACI_status = "Not in facility"
        EMReadScreen client_FACI, 30, 6, 43
        client_FACI = replace(client_FACI, "_", "")
        FACI_array = split(client_FACI)
		EMReadScreen client_DOC, 8, 13, 45
		'formatting client_DOC
		client_DOC = replace(client_DOC, "_", "")
        For each a in FACI_array
          If a <> "" then
            b = ucase(left(a, 1))
            c = LCase(right(a, len(a) -1))
            new_FACI = new_FACI & b & c & " "
          End if
        Next
        client_FACI = new_FACI
        If FACI_status = "Not in facility" then
          client_FACI = ""
        Else
          variable_written_to = variable_written_to & "Member " & HH_member & "- "
          variable_written_to = variable_written_to & client_FACI & " Date in: " & date_in_month_day & date_in_check
		  IF client_DOC <> "" THEN variable_written_to = variable_written_to & " GRH DOC AMT: $" & client_DOC & "; "
        End if
     End if
Next

faci = variable_written_to

'Cleaning up info for case note
HRF_computer_friendly_month = footer_month & "/01/" & footer_year
retro_month_name = monthname(datepart("m", (dateadd("m", -2, HRF_computer_friendly_month))))
pro_month_name = monthname(datepart("m", (HRF_computer_friendly_month)))
HRF_month = pro_month_name 'retro_month_name & "/" & pro_month_name

'checking for an active MAXIS session
Call check_for_MAXIS(False)

'The case note dialog, complete with panel navigation, reading the ELIG/GRH screen, and navigation to case note, as well as logic for certain sections to be required.
Do
	Do
		DO
			Dialog HRF_dialog
			cancel_confirmation
			MAXIS_dialog_navigation
		LOOP UNTIL ButtonPressed = -1
		If HRF_status = "(select one...)" then MsgBox "You must indicate a HRF status, either ''complete'' or ''incomplete''!"
	Loop until HRF_status <> "(select one...)"
	If HRF_status = " " or earned_income = "" or actions_taken = "" or HRF_datestamp = "" or worker_signature = "" then MsgBox "You need to fill in the datestamp, HRF status, earned income, and actions taken sections, as well as sign your case note. Check these items after pressing ''OK''."
Loop until HRF_status <> " " and earned_income <> "" and actions_taken <> "" and HRF_datestamp <> "" and worker_signature <> ""
		
If grab_GRH_info_check = 1 then
		call navigate_to_MAXIS_screen("elig", "grh")
		EMReadScreen GRPR_check, 4, 3, 47
		If GRPR_check <> "GRPR" then
			MsgBox "The script couldn't find ELIG/GRH. It will now jump to case note."
		Else
			EMWriteScreen "GRSM", 20, 71
			transmit
			EMReadScreen GRH_approved, 3, 3, 3
			IF GRH_approved = "APP" THEN  'checking if the version the script found has been approved
				EMReadScreen GRSM_line_01, 69, 10, 3
				EMReadScreen GRSM_line_02, 69, 11, 3
				EMReadScreen GRSM_line_03, 69, 12, 3
				EMReadScreen GRSM_line_04, 69, 13, 3
				EMReadScreen GRSM_Obligation, 9, 18, 31
			ELSE
				MsgBox "The most recent results in ELIG/GRH for " & footer_month & " have not been approved. It will now jump to case note."
			END IF
		End if	
	End if
	
'creating header for programs checked
IF GRH_check = checked THEN 
	program_header = "GRH"
	IF HC_check = checked THEN program_header = program_header & "/HC"
ELSE IF GRH_check <> checked AND HC_check = checked THEN 
		program_header = "HC"
	END IF
END IF

'Enters the case note
Call start_a_blank_CASE_NOTE
Call write_variable_in_CASE_NOTE("***" & HRF_month & " " & program_header & " HRF received " & HRF_datestamp & ": " & HRF_status & "***")
call write_bullet_and_variable_in_case_note("Earned income", earned_income)
call write_bullet_and_variable_in_case_note("Unearned income", unearned_income)
CALL write_bullet_and_variable_in_case_note("Facility info", faci)
call write_bullet_and_variable_in_case_note("YTD", YTD)
call write_bullet_and_variable_in_case_note("Changes", changes)
call write_bullet_and_variable_in_case_note("FIAT reasons", FIAT_reasons)
call write_bullet_and_variable_in_case_note("Other notes", other_notes)
IF Sent_arep_checkbox = checked THEN CALL write_variable_in_case_note("* Sent form(s) to AREP.")
call write_bullet_and_variable_in_case_note("Verifs needed", verifs_needed)
call write_bullet_and_variable_in_case_note("Actions taken", actions_taken)
call write_bullet_and_variable_in_case_note("Date check sent to facility", date_check_sent_to_facility)
call write_variable_in_CASE_NOTE("---")
If GRPR_check = "GRPR" then
	call write_variable_in_CASE_NOTE("   " & GRSM_line_01)
	call write_variable_in_CASE_NOTE("   " & GRSM_line_02)
	call write_variable_in_CASE_NOTE("   " & GRSM_line_03)
	call write_variable_in_CASE_NOTE("   " & GRSM_line_04)
	call write_variable_in_CASE_NOTE("Client Obligation: $" & GRSM_Obligation)
	call write_variable_in_CASE_NOTE("---")
End if

call write_variable_in_CASE_NOTE(worker_signature)
 
call script_end_procedure("")
