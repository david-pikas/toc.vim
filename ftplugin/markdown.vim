let b:toc_nesting='contextfree'
let b:toc_pattern='\v^\s*##+'
function! s:toc_parse_match(match)
    return { 'name': substitute(a:match.text, '\v^\s*##+(.*)\s*$', '\1', ''),
           \ 'level': strlen(substitute(a:match.text, '\v^\s*#(#+).*$', '\1', ''))
           \ }
endfunction
let b:toc_parse_match = function("s:toc_parse_match")
