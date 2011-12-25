syn match archiveHeader '^File:'
syn match archiveHeader '^Format:'
syn match archiveHeader '^Size:'

syn match archiveHeaderDelimiter '=\{5,}'

syn match archiveDirectory  '\%>5l\f*/'
syn match archiveFileNumber '^\d\+\.'

hi link archiveHeader          Identifier
hi link archiveHeaderDelimiter Operator
hi link archiveDirectory       Directory
hi link archiveFileNumber      Number
