
# This file is a generated template, your changes will not be overwritten

multipleencodingClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "multipleencodingClass",
    inherit = multipleencodingBase,
    private = list(
        .run = function() {

             # Only execute when the Run button has been clicked
             if (is.null(self$options$runTrigger) || ! self$options$runTrigger)
                 return()

             if (is.null(self$options$columnToSplit))
                 return()

             # Get the variable to split
             var_to_split <- self$data[[self$options$columnToSplit]]

             if (is.null(var_to_split) || length(var_to_split) == 0) {
                 self$results$text$setContent("No data available in the selected column.")
                 return()
             }

             # Get the separator from user input
             separator <- self$options$separator

             # If separator is empty or NULL, default to comma
             if (is.null(separator) || nchar(trimws(separator)) == 0) {
                 separator <- ","
             }

             # Convert variable to character (keep NAs as empty strings)
             var_to_split <- as.character(var_to_split)
             var_to_split[is.na(var_to_split)] <- ""

             # Single, vectorized strsplit over the whole column
             split_list <- strsplit(var_to_split, separator, fixed = TRUE)

             # Trim ONLY each part after splitting (internal spaces preserved),
             # then drop empty parts
             trimmed <- lapply(split_list, function(parts) {
                 parts <- trimws(parts)
                 parts[parts != ""]
             })

             # Collect the unique values (sorted for stable ordering)
             all_values <- unique(unlist(trimmed))
             all_values <- sort(all_values)

             if (length(all_values) == 0) {
                 self$results$text$setContent("No values found after splitting.")
                 return()
             }

             n <- length(var_to_split)

             # Vectorized membership check for each row (no per-row strsplit)
             matches <- lapply(trimmed, function(parts) which(all_values %in% parts))

             # Build the binary matrix
             bin <- matrix(0L, nrow = n, ncol = length(all_values))
             for (i in seq_len(n)) {
                 idx <- matches[[i]]
                 if (length(idx) > 0)
                     bin[i, idx] <- 1L
             }

             # Create keys, titles, and descriptions for each unique value
             keys <- as.character(seq_along(all_values))
             titles <- paste0(self$options$columnToSplit, "_", all_values)
             descriptions <- all_values          # description = only the unique value
             measureTypes <- rep("nominal", length(all_values))

             # Set the factor scores output
             self$results$newColumns$set(
                 keys=keys,
                 titles=titles,
                 descriptions=descriptions,
                 measureTypes=measureTypes
             )

             # Set the values for each component
             for (i in seq_along(all_values)) {
                 self$results$newColumns$setValues(index=i, bin[, i])
             }

             # Set the results text
             result_message <- paste0(
                 "Analysis of column '", self$options$columnToSplit, "':\n\n",
                 "Separator used: ", separator, "\n",
                 "Number of unique values found: ", length(all_values), "\n\n",
                 "List of unique values:\n",
                 paste("- ", all_values, collapse = "\n")
             )
             self$results$text$setContent(result_message)

         })
)
