;extends

; CUDA injection
(
  (comment) @_comment
  (#match? @_comment "^# ?\\@cuda$")
  .
  (expression_statement
    (assignment
      left: (identifier) @_id
      right: (string (string_content) @injection.content)))
  (#set! injection.language "cuda"))

