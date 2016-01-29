'STATS GATHERING----------------------------------------------------------------------------------------------------
name_of_script = "BULK - FIND PANEL UPDATE DATE.vbs"
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
STATS_manualtime = 28                      'manual run time in seconds
STATS_denomination = "I"       						 'I is for each ITEM
'END OF stats block==============================================================================================

'=====FUNCTIONS=====
FUNCTION build_hh_array(hh_array)
	hh_array = ""
	panel_row = 5
	DO
		EMReadScreen hh_member, 2, panel_row, 3
		IF hh_member <> "  " THEN
			hh_array = hh_array & hh_member & ","
			panel_row = panel_row + 1
		END IF
	LOOP UNTIL hh_member = "  "
	hh_array = trim(hh_array)
	hh_array = split(hh_array, ",")
END FUNCTION

'=====DIALOGS=====
BeginDialog panel_update_check_dlg, 0, 0, 231, 195, "Panels to Check"
  EditBox 70, 15, 105, 15, workers_list
  CheckBox 20, 80, 30, 10, "JOBS", JOBS_checkbox
  CheckBox 60, 80, 35, 10, "UNEA", UNEA_checkbox
  CheckBox 100, 80, 30, 10, "BUSI", BUSI_checkbox
  CheckBox 140, 80, 35, 10, "SPON", SPON_checkbox
  CheckBox 180, 80, 30, 10, "RBIC", RBIC_checkbox
  CheckBox 20, 120, 35, 10, "COEX", COEX_checkbox
  CheckBox 60, 120, 30, 10, "DCEX", DCEX_checkbox
  CheckBox 100, 120, 30, 10, "HEST", HEST_checkbox
  CheckBox 140, 120, 30, 10, "SHEL", SHEL_checkbox
  CheckBox 180, 120, 35, 10, "WKEX", WKEX_checkbox
  DropListBox 110, 145, 115, 15, "Select one..."+chr(9)+"Updated in prev. 30 days"+chr(9)+"Updated in prev. 6 mos"+chr(9)+"Not updated more than 12 mos"+chr(9)+"Not updated more than 24 mos", time_period
  ButtonGroup ButtonPressed
    OkButton 10, 170, 50, 15
    CancelButton 60, 170, 50, 15
  Text 10, 20, 55, 10, "Worker Number"
  Text 15, 35, 150, 10, "* Please enter only 7-digit worker numbers."
  Text 15, 45, 205, 10, "* For multiple workers, separate worker numbers by a comma."
  GroupBox 10, 65, 210, 30, "Income Panels to Check"
  GroupBox 10, 105, 210, 30, "Expense Panels to Check"
  Text 10, 150, 95, 10, "Select time period to check:"
EndDialog

'>>>>> THE SCRIPT <<<<<
EMConnect ""

CALL check_for_MAXIS(True)

'>>>>> LOADING THE DIALOG <<<<<
DO
	err_msg = ""
	DIALOG panel_update_check_dlg
		cancel_confirmation
		IF time_period = "Select one..." THEN err_msg = err_msg & vbCr & "* Please select a date range for the script to analyze."

	'Breaking down the workers_list to determine if the user entered multiple workers or if the script is going to be run for just one worker.
	IF InStr(workers_list, ",") <> 0 THEN
		workers_list = replace(workers_list, " ", "")
		workers_list = split(workers_list, ",")
	ELSEIF InStr(workers_list, ",") = 0 THEN
		'multiple_workers = split(workers_list)
		workers_list = split(workers_list)
	END IF

	'>>>>> ADDING TO err_msg IF THE USER SELECTS NO STAT PANELS. <<<<<
	IF JOBS_checkbox = 0 AND _
		UNEA_checkbox = 0 AND _
		BUSI_checkbox = 0 AND _
		RBIC_checkbox = 0 AND _
		SPON_checkbox = 0 AND _
		COEX_checkbox = 0 AND _
		DCEX_checkbox = 0 AND _
		HEST_checkbox = 0 AND _
		SHEL_checkbox = 0 AND _
		WKEX_checkbox = 0 THEN err_msg = err_msg & vbCr & "* You must select at least one STAT panel to check."

	IF err_msg <> "" THEN MsgBox "*** NOTICE!!! ***" & vbCr & err_msg & vbCr & vbCr & "Please resolve for the script to continue."
LOOP UNTIL err_msg = ""

'>>>>> EXECUTING THE PANEL UPDATE SEARCH FOR EACH WORKER <<<<<
FOR EACH maxis_worker IN workers_list
	IF maxis_worker <> "" THEN
		'>>>>> CREATING A UNIQUE EXCEL FILE <<<<<
		Set objExcel = CreateObject("Excel.Application")
		objExcel.Visible = True
		Set objWorkbook = objExcel.Workbooks.Add()
		objExcel.DisplayAlerts = True

		'>>>>> SETTING EXCEL HEADERS
		objExcel.Cells(1, 1).Value = "X NUMBER"
		objExcel.Cells(1, 2).Value = "CASE NUMBER"
		objExcel.Cells(1, 3).Value = "CLIENT NAME"
		col_to_use = 4
		IF JOBS_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "JOBS"
			JOBS_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF UNEA_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "UNEA"
			UNEA_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF BUSI_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "BUSI"
			BUSI_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF RBIC_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "RBIC"
			RBIC_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF SPON_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "SPON"
			SPON_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF COEX_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "COEX"
			COEX_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF DCEX_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "DCEX"
			DCEX_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF HEST_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "HEST"
			HEST_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF SHEL_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "SHEL"
			SHEL_col = col_to_use
			col_to_use = col_to_use + 1
		END IF
		IF WKEX_checkbox = 1 THEN
			objExcel.Cells(1, col_to_use).Value = "WKEX"
			WKEX_col = col_to_use
			col_to_use = col_to_use + 1
		END IF

		FOR i = 1 TO col_to_use
			objExcel.Cells(1, i).Font.Bold = True
		NEXT

		objExcel.Columns(col_to_use).ColumnWidth = 1
		objExcel.Columns(col_to_use + 1).ColumnWidth = 1
		objExcel.Cells(1, col_to_use + 2).Value = "Time Criteria: "
		objExcel.Cells(1, col_to_use + 3).Value = time_period
		objExcel.Cells(1, col_to_use + 2).Font.Bold = True
		objExcel.Cells(1, col_to_use + 3).Font.Bold = True
		objExcel.Columns(col_to_use + 2).AutoFit()
		objExcel.Columns(col_to_use + 3).AutoFit()

		'>>>>> BUILDING A LIST OF CASE NUMBERS AND CLIENTS <<<<<
		CALL navigate_to_MAXIS_screen("REPT", "ACTV")
		EMReadScreen ACTV_Xnumber, 7, 21, 13
		IF UCase(maxis_worker) <> UCase(ACTV_Xnumber) THEN CALL write_value_and_transmit(maxis_worker, 21, 13)  'if the script transmits on the current worker with their own x# it will skip first page.
		excel_row = 2
		DO
			rept_row = 7
			EMReadScreen last_page, 21, 24, 2
			DO
				EMReadScreen case_number, 8, rept_row, 12
				case_number = trim(case_number)
				EMReadScreen client_name, 20, rept_row, 21
				client_name = trim(client_name)
				IF case_number <> "" THEN
					'>>>>> ADDING WORKER NUMBER, CASE NUMBER, AND CLIENT NAME TO EXCEL <<<<<
					objExcel.Cells(excel_row, 1).Value = maxis_worker
					objExcel.Cells(excel_row, 2).Value = case_number
					objExcel.Cells(excel_row, 3).Value = client_name
					excel_row = excel_row + 1
				END IF
				rept_row = rept_row + 1
			LOOP UNTIL rept_row = 19
			PF8
		LOOP UNTIL last_page = "THIS IS THE LAST PAGE"

		'>>>>> GOING BACK THROUGH THE EXCEL LIST TO SEARCH FOR PANEL UPDATE DATE <<<<<
		excel_row = 2
		DO
			back_to_SELF
			case_number = objExcel.Cells(excel_row, 2).Value
			EMWriteScreen "STAT", 16, 43
			EMWriteScreen "________", 18, 43
			EMWriteScreen case_number, 18, 43
			transmit

			'>>>>> PRIVILEGED CHECK <<<<<
			row = 1
			col = 1
			EMSearch "PRIVILEGED", row, col
			'SELF check protecting against background cases.
			DO
				EMWriteScreen "STAT", 16, 43
				EMWriteScreen "________", 18, 43
				EMWriteScreen case_number, 18, 43
				transmit
				EMReadScreen self_check, 4, 2, 50
				IF row = 24 THEN EXIT DO
			LOOP until self_check <> "SELF"

			IF row <> 24 THEN
				IF JOBS_checkbox = 1 THEN
				STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("JOBS", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "JOBS")
					END IF
					CALL build_hh_array(JOBS_array)
					FOR EACH person IN JOBS_array
						IF person <> "" THEN
							STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, JOBS_col).Value = objExcel.Cells(excel_row, JOBS_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, JOBS_col).Value = objExcel.Cells(excel_row, JOBS_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, JOBS_col).Value = objExcel.Cells(excel_row, JOBS_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, JOBS_col).Value = objExcel.Cells(excel_row, JOBS_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
				IF UNEA_checkbox = 1 THEN
				STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("UNEA", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "UNEA")
					END IF
					CALL build_hh_array(UNEA_array)
					FOR EACH person IN UNEA_array
						IF person <> "" THEN
						STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, UNEA_col).Value = objExcel.Cells(excel_row, UNEA_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, UNEA_col).Value = objExcel.Cells(excel_row, UNEA_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, UNEA_col).Value = objExcel.Cells(excel_row, UNEA_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, UNEA_col).Value = objExcel.Cells(excel_row, UNEA_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
				IF BUSI_checkbox = 1 THEN
					STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("BUSI", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "BUSI")
					END IF
					CALL build_hh_array(BUSI_array)
					FOR EACH person IN BUSI_array
						IF person <> "" THEN
							STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, BUSI_col).Value = objExcel.Cells(excel_row, BUSI_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, BUSI_col).Value = objExcel.Cells(excel_row, BUSI_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, BUSI_col).Value = objExcel.Cells(excel_row, BUSI_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, BUSI_col).Value = objExcel.Cells(excel_row, BUSI_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
				IF RBIC_checkbox = 1 THEN
					STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("RBIC", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "RBIC")
					END IF
					CALL build_hh_array(RBIC_array)
					FOR EACH person IN RBIC_array
						IF person <> "" THEN
							STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, RBIC_col).Value = objExcel.Cells(excel_row, RBIC_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, RBIC_col).Value = objExcel.Cells(excel_row, RBIC_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, RBIC_col).Value = objExcel.Cells(excel_row, RBIC_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, RBIC_col).Value = objExcel.Cells(excel_row, RBIC_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
				IF SPON_checkbox = 1 THEN
					STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("SPON", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "SPON")
					END IF
					CALL build_hh_array(SPON_array)
					FOR EACH person IN SPON_array
						IF person <> "" THEN
							STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, SPON_col).Value = objExcel.Cells(excel_row, SPON_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, SPON_col).Value = objExcel.Cells(excel_row, SPON_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, SPON_col).Value = objExcel.Cells(excel_row, SPON_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, SPON_col).Value = objExcel.Cells(excel_row, SPON_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
				IF COEX_checkbox = 1 THEN
					STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("COEX", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "COEX")
					END IF
					CALL build_hh_array(COEX_array)
					FOR EACH person IN COEX_array
						IF person <> "" THEN
						 	STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, COEX_col).Value = objExcel.Cells(excel_row, COEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, COEX_col).Value = objExcel.Cells(excel_row, COEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, COEX_col).Value = objExcel.Cells(excel_row, COEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, COEX_col).Value = objExcel.Cells(excel_row, COEX_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
				IF DCEX_checkbox = 1 THEN
					STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("DCEX", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "DCEX")
					END IF
					CALL build_hh_array(DCEX_array)
					FOR EACH person IN DCEX_array
						IF person <> "" THEN
							STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, DCEX_col).Value = objExcel.Cells(excel_row, DCEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, DCEX_col).Value = objExcel.Cells(excel_row, DCEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, DCEX_col).Value = objExcel.Cells(excel_row, DCEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, DCEX_col).Value = objExcel.Cells(excel_row, DCEX_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
				IF HEST_checkbox = 1 THEN
					STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("HEST", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "HEST")
					END IF
					EMReadScreen updated_date, 8, 21, 55
					updated_date = replace(updated_date, " ", "/")
					IF updated_date <> "////////" THEN
						IF time_period = "Updated in prev. 30 days" THEN
							IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, HEST_col).Value = updated_date & "; "
						ELSEIF time_period = "Updated in prev. 6 mos" THEN
							IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, HEST_col).Value = updated_date & "; "
						ELSEIF time_period = "Not updated more than 12 mos" THEN
							IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, HEST_col).Value = updated_date & "; "
						ELSEIF time_period = "Not updated more than 24 mos" THEN
							IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, HEST_col).Value = updated_date & "; "
						END IF
					END IF
				END IF
				IF SHEL_checkbox = 1 THEN
				 	STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("SHEL", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "SHEL")
					END IF
					CALL build_hh_array(SHEL_array)
					FOR EACH person IN SHEL_array
						IF person <> "" THEN
							STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, SHEL_col).Value = objExcel.Cells(excel_row, SHEL_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, SHEL_col).Value = objExcel.Cells(excel_row, SHEL_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, SHEL_col).Value = objExcel.Cells(excel_row, SHEL_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, SHEL_col).Value = objExcel.Cells(excel_row, SHEL_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
				IF WKEX_checkbox = 1 THEN
					STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
					EMReadScreen in_stat, 4, 20, 21
					IF in_stat = "STAT" THEN     'prevents error where navigate_to_MAXIS_screen jumps back out for each read
						CALL write_value_and_transmit("WKEX", 20, 71)
					ELSE
						CALL navigate_to_MAXIS_screen("STAT", "WKEX")
					END IF
					CALL build_hh_array(WKEX_array)
					FOR EACH person IN WKEX_array
						IF person <> "" THEN
							STATS_counter = STATS_counter + 1                      'adds one instance to the stats counter
							CALL write_value_and_transmit(person, 20, 76)
							EMReadScreen updated_date, 8, 21, 55
							updated_date = replace(updated_date, " ", "/")
							IF updated_date <> "////////" THEN
								IF time_period = "Updated in prev. 30 days" THEN
									IF DateDiff("D", updated_date, date) <= 30 THEN objExcel.Cells(excel_row, WKEX_col).Value = objExcel.Cells(excel_row, WKEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Updated in prev. 6 mos" THEN
									IF DateDiff("D", updated_date, date) <= 180 THEN objExcel.Cells(excel_row, WKEX_col).Value = objExcel.Cells(excel_row, WKEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 12 mos" THEN
									IF DateDiff("D", updated_date, date) > 365 THEN objExcel.Cells(excel_row, WKEX_col).Value = objExcel.Cells(excel_row, WKEX_col).Value & person & ", " & updated_date & "; "
								ELSEIF time_period = "Not updated more than 24 mos" THEN
									IF DateDiff("D", updated_date, date) > 730 THEN objExcel.Cells(excel_row, WKEX_col).Value = objExcel.Cells(excel_row, WKEX_col).Value & person & ", " & updated_date & "; "
								END IF
							END IF
						END IF
					NEXT
				END IF
			END IF
			excel_row = excel_row + 1
		LOOP UNTIL objExcel.Cells(excel_row, 1).Value = ""
		FOR i = 1 to col_to_use
			objExcel.Columns(i).AutoFit()
		NEXT
	END IF
NEXT
back_to_SELF
STATS_counter = STATS_counter - 1                      'subtracts one from the stats (since 1 was the count, -1 so it's accurate)
script_end_procedure("Success!")
