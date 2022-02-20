let b:toc_nesting='indent'
let b:toc_pattern='\v(def|class)\s+\w+\('
function! s:toc_parse_match(match)
    return { 'name': substitute(a:match.text, '\v(def|class)\s+(\w+)\(.*', '\2', '') }
endfunction
let b:toc_parse_match = function("s:toc_parse_match")
