; extends

( (comment) @jps (#match? @jps "^\\# ?\\%\\%") )@code_cell.inner

(
(comment) @com (#match? @com "# ?\\@cuda")
(expression_statement
  (assignment
    left: (identifier)
    right: (string
             (string_start)
             (string_content) @cuda_string
             (string_end))))
)
