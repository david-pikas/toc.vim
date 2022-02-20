let b:toc_nesting='nesting'
let b:toc_pattern='\v^\s*(extern\s+|static\s+)?(const\s+)?(unsigned\s+)?\w+(\_s+|\_s+\*+\_s*|\*+\_s+)\w+\('
let b:toc_multiline=1
function! s:toc_parse_match(match)
    if match(a:match.text, '\<return\>') != -1
        return 0
    else
        return { 'name': substitute( a:match.text, '\v[^(]*\_s(\w+)\(.*', '\1', '' ),
                \ 'region': TocCurlyBracketEnd(a:match.lnum)
                \ }
endfunction
let b:toc_parse_match = function("s:toc_parse_match")
