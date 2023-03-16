#------------------------------------------------------------------------------#
#---------------------------     PHRDW Querying     ---------------------------#
#------------------------------------------------------------------------------#
# Header ----
# Author: Kevin Yang
# Date created : January 19, 2023
# Purpose: To define functions for querying from PHRDW mart
# v1.0
#
# Special considerations:
# - Considering the PHRDW data marts contain different dimensions and thus
#   different data fields available, only the essential dimensions/fields are
#   included by default. These include: PHN, name, gender, DoB, CID, accession,
#   collection date and full result description. Other fields can be added by 
#   the user.
# - Currently, defined filter critera only include test code, proficiency flag 
#   and test performed flag. Other filter criteria may be added but require
#   knowledge of the exact strings to use in a WHERE clause.
# - Be careful that the script may run for an extended amount of time for
#   queries that return sizable amount of data. Future development is to
#   implement parallel processes to speed up the data pull.
#
# Update history:
# 20230130KY - added function to pull order and test codes
#
#------------------------------------------------------------------------------#

# Function to construct an MDX ----
PHRDW_pullResults <- function(mart = NULL, collectiondate_start = NULL, 
                              collectiondate_end = NULL, orderdate_start = NULL,
                              orderdate_end = NULL, additional_fields = NULL, 
                              testcode = NULL, proficiency = NULL,
                              testperformed = T, criteria = NULL) {
  # Define the list of marts
  marts = list(LADW = list(Database = "PHRDW_TAT", Cube = "TAT_LADW"),
               Enteric = list(Database = "PHRDW_Enteric_Panorama", 
                              Cube = "EntericDM_LADW"),
               Respiratory = list(Database = "PHRDW_Respiratory", 
                                  Cube = "RespiratoryDM"),
               STIBBI = list(Database = "PHRDW_STIBBI", Cube = "StibbiDM_LADW"))
  # Check parameters
  message("Checking parameters...")
  ## Check that a valid mart name is provided
  if (!(mart %in% names(marts))) {
    stop("A valid mart name must be provided and should be one of LADW, Enteric, Respiratory or STIBBI")
  }
  ## Check the dates are in the correct format of YYYY-MM-DD
  dcheck <- c(collectiondate_start, collectiondate_end, orderdate_start, orderdate_end)
  if (!is.null(dcheck)) {
    if (!all(sapply(dcheck, function(x) nchar(x) == 10 & grepl("\\d{4}-\\d{2}-\\d{2}", x)))) {
      stop("Supplied date(s) must be in the format: YYYY-MM-DD.")
    }
  }
  ## Check that only collection date range or order date range is supplied
  if (any(!is.null(collectiondate_start), !is.null(collectiondate_end)) &
      any(!is.null(orderdate_start), !is.null(orderdate_end))) {
    stop("Currently, the use of both a collection and an order date range is not supported.")
  }
  ## Check that if order date range is supplied, the mart is either LADW or Enteric
  if (any(!is.null(orderdate_start), !is.null(orderdate_end)) & !(mart %in% c("LADW", "Enteric"))) {
    stop("Currently, order date range can only be applied to LADW to Enteric mart queries.")
  }
  # Use test count as a placeholder for the required measure
  q_col <- "SELECT [Measures].[LIS Test Count] ON COLUMNS,"
  # Put together dimensions
  ## By default PHN, name, gender, DoB, CID, accession, collection date and full result description are pulled
  ### Note that the respiratory mart has a different dimension name for patient mater
  if (mart == "Respiratory") {
    dim_patient <- "[PMS - Patient Master]"
  } else {
    dim_patient <- "[Patient - Patient Master]"
  }
  phn <- paste0(dim_patient, ".[PHN].[PHN]")
  lastname <- paste0(dim_patient, ".[Name Last].[Name Last]")
  firstname <- paste0(dim_patient, ".[Name First].[Name First]")
  gender <- paste0(dim_patient, ".[Gender].[Gender]")
  dob <- paste0(dim_patient, ".[Birth Date].[Birth Date]")
  ### The enteric mart has a different dimension name for sample IDs and collection dates
  if (mart == "Enteric") {
    dim_id <- "[Case - IDs]"
    dim_cdate <- "[LIS - Date - Collection Date]"
  } else {
    dim_id <- "[LIS - IDs]"
    dim_cdate <- "[LIS - Date - Collection]"
  }
  ### Return order date column if order date range provided
  if (any(!is.null(orderdate_start), !is.null(orderdate_end))) {
    date <- "[LIS - Date - Order Entry].[Date].[Date]"
  } else {
    date <- paste0(dim_cdate, ".[Date].[Date]")
  }
  cid <- paste0(dim_id, ".[Container ID].[Container ID]")
  acc <- paste0(dim_id, ".[Accession Number].[Accession Number]")
  res <- paste0("[LIS - Result Attributes]",
                ".[Result Full Description].[Result Full Description]")
  ### Other fields to pull
  if (!is.null(additional_fields)) {
    addlfield <- additional_fields %>%
      str_replace(., ",", "*") %>%
      paste0("*", .)
  } else {
    addlfield <- ""
  }
  ### Combine dimension strings
  q_row <- paste0(" NON EMPTY{",
                  phn, "*", lastname, "*", firstname, "*", gender, "*",
                  dob, "*", cid, "*", acc, "*", date, "*", res, addlfield,
                  "} ON ROWS")
  # Cube to pull from; subselect if a date is provided
  if (is.null(dcheck)) {
    q_from <- paste0(" FROM ", "[", marts[[mart]][["Cube"]], "]")
    print(paste("Applying query to the entire", mart, "mart since no date range was provided..."))
  } else {
    date_start <- c(collectiondate_start, orderdate_start)
    date_end <- c(collectiondate_end, orderdate_end)
    if (is.null(date_start)) {
      date_start <- "1900-01-01"
      print(paste("Since a date range is supplied without a start date,",
                  "the start date is set to 1900-01-01 to capture all records."))
    }
    if (is.null(date_end)) {
      date_end <- Sys.date()
      print(paste0("Since a date range is supplied without an end date, ",
                  "the end date is set to today:", date_end, "."))
    }
    if (any(!is.null(collectiondate_start), !is.null(collectiondate_end))) {
      date_start <- paste0(dim_cdate, ".[Date].&[", date_start,
                           "T00:00:00]")
      date_end <- paste0(dim_cdate, ".[Date].&[", date_end,
                         "T00:00:00]")
    } else if (any(!is.null(orderdate_start), !is.null(orderdate_end))) {
      date_start <- paste0("[LIS - Date - Order Entry].[Date].&[",
                           date_start, "T00:00:00]")
      date_end <- paste0("[LIS - Date - Order Entry].[Date].&[",
                         date_end, "T00:00:00]")
    }
    q_from <- paste0(" FROM (SELECT ", date_start, ":", date_end, " ON COLUMNS ",
                     paste0("FROM ", "[", marts[[mart]][["Cube"]], "])"))
  }
  # Filter criteria
  ## Test code
    if (is.null(testcode)) {
      filt_testcode <- ""
    }  else {
      filt_testcode <- paste0("[LIS - Test].[Test Code].&[", testcode, "]")
    }
  ## Proficiency flag
  if (!is.null(proficiency)) {
    if (mart == "STIBBI") {
      dim_prof <- "[LIS - Flag - Proficiency Test].[Yes No]"
    } else {
      dim_prof <- "[LIS - Flag - Proficiency Test].[Proficiency Test]"
    }
    filt_prof <- paste0(dim_prof, ".&[", proficiency, "]")
  } else {
    filt_prof <- ""
  }
  ## Test performed flag
  if (testperformed) {
    filt_perf <- "[LIS - Flag - Test Performed].[Test Performed].&[Yes]"
  } else {
    filt_perf <- ""
  }
  ## Assemble all filters including additional criteria if any
  if (any(filt_testcode != "", filt_prof != "", filt_perf != "", criteria != NULL)) {
    q_filter <- paste0(" WHERE (", 
                       c(filt_testcode, filt_prof, filt_perf, criteria) %>%
                         .[nzchar(.)] %>% paste(., collapse = ","), 
                       ")")
  } else {
    q_filter <- ""
  }
  # Combine all strings into an MDX query
  query <- paste0(q_col, q_row, q_from, q_filter)
  # Establish connection
  connection <- paste0("Data Source=SPRSASBI001.PHSABC.EHCNET.CA;",
                       "Initial Catalog=", marts[[mart]][["Database"]], ";",
                       "Provider=MSOLAP;") %>%
    OlapConnection
  # Execute query and rename columns
  ## Prepare column names
  cnames <- c("PHN", "LastName", "FirstName", "Gender", "DoB", "CID", "Accession")
  if (any(!is.null(orderdate_start), !is.null(orderdate_end))) {
    cnames <- c(cnames, "Date_Ordered")
  } else {
    cnames <- c(cnames, "Date_Collection")
  }
  cnames <- c(cnames, "Results_FulLDescription")
  ### Add additional fields if applicable
  if (addlfield != "") {
    cnames <- additional_fields %>% 
      str_split(., ",") %>%
      .[[1]] %>%
      str_split(., "\\.") %>%
      sapply(., function(x) x[3] %>% str_remove_all(., "\\[|\\]")) %>%
      c(cnames, .)
  }
  ### Add TestCount to colnames
  cnames <- c(cnames, "TestCount")
  ## Run query and set column names
  message("Pulling from the ", mart, "mart...")
  res <- execute2D(connection, query) %>%
    set_colnames(cnames) %>%
    select(-TestCount)
  # Return output
  return(res)
}

# Function to return all test codes
PHRDW_getCodes <- function(mart) {
  # Define the list of marts
  marts = list(LADW = list(Database = "PHRDW_TAT", Cube = "TAT_LADW"),
               Enteric = list(Database = "PHRDW_Enteric_Panorama", 
                              Cube = "EntericDM_LADW"),
               Respiratory = list(Database = "PHRDW_Respiratory", 
                                  Cube = "RespiratoryDM"),
               STIBBI = list(Database = "PHRDW_STIBBI", Cube = "StibbiDM_LADW"))
  # Check that a valid mart name is provided
  if (!(mart %in% names(marts))) {
    stop("A valid mart name must be provided and should be one of LADW, Enteric, Respiratory or STIBBI")
  } else {
    print(paste("Pulling test codes from the", mart, "mart..."))
  }
  # Make query; SIBBI cube does not have the Order Item dimension
  if (mart == "STIBBI") {
    query <- paste0("SELECT [Measures].[LIS Test Count] ON COLUMNS, ",
                    "NON EMPTY {",
                    "[LIS - Test].[Order Code].[Order Code]",
                    "*[LIS - Test].[Test Code].[Test Code]",
                    "*[LIS - Test].[Test Name].[Test Name]} ON ROWS ",
                    "FROM ", "[", marts[[mart]]$Cube, "]")
    cnames <- c("OrderCode", "TestCode", "TestName")
  } else {
    query <- paste0("SELECT [Measures].[LIS Test Count] ON COLUMNS, ",
                    "NON EMPTY {",
                    "[LIS - Order Item].[Order Code].[Order Code]",
                    "*[LIS - Order Item].[Order Name].[Order Name]",
                    "*[LIS - Test].[Test Code].[Test Code]",
                    "*[LIS - Test].[Test Name].[Test Name]} ON ROWS ",
                    "FROM ", "[", marts[[mart]]$Cube, "]")
    cnames <- c("OrderCode", "OrderName", "TestCode", "TestName")
  }
  # Establish connection
  connection <- paste0("Data Source=SPRSASBI001.PHSABC.EHCNET.CA;",
                       "Initial Catalog=", marts[[mart]][["Database"]], ";",
                       "Provider=MSOLAP;") %>%
    OlapConnection
  # Execute query and rename columns
  res <- execute2D(connection, query) %>%
    select(-(ncol(.))) %>%
    set_colnames(cnames) %>%
    distinct
  # Return result
  return(res)
}
