
# This file is a generated template, your changes will not be overwritten

mergevariablesClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "mergevariablesClass",
    inherit = mergevariablesBase,
    private = list(
        .run = function() {

             # Only execute when the Run button has been clicked
             if (is.null(self$options$runTrigger) || ! self$options$runTrigger)
                 return()

             vars <- self$options$variables
             if (is.null(vars) || length(vars) == 0) {
                 self$results$text$setContent("Please select at least one variable to merge.")
                 return()
             }

             targetName <- self$options$targetName
             if (is.null(targetName) || nchar(trimws(targetName)) == 0) {
                 self$results$text$setContent("Please enter a name for the target variable.")
                 return()
             }

             n <- nrow(self$data)
             if (is.null(n) || n == 0) {
                 self$results$text$setContent("No data available.")
                 return()
             }

             # Collect each selected column as character (NA -> empty string)
             cols <- lapply(vars, function(v) {
                 x <- self$data[[v]]
                 if (is.null(x))
                     return(rep("", n))
                 x <- as.character(x)
                 x[is.na(x)] <- ""
                 x
             })

             # Merge text values with ';' separator, skipping empty parts
             merged <- character(n)
             for (i in seq_len(n)) {
                 parts <- vapply(cols, function(c) c[i], FUN.VALUE = "")
                 parts <- parts[parts != ""]
                 merged[i] <- paste(parts, collapse = ";")
             }

             # Create the new merged variable (text -> nominal measure type)
             self$results$newColumn$set(
                 keys = "1",
                 titles = targetName,
                 descriptions = targetName,
                 measureTypes = "nominal"
             )

             self$results$newColumn$setValues(index = 1, merged)

             self$results$text$setContent(
                 paste0("Merged ", length(vars), " variable(s) into '", targetName, "'."))
         })
)
