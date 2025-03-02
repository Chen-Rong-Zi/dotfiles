" Vim syntax file
" Language:     Quickfix window
" Maintainer:   The Vim Project <https://github.com/vim/vim>
" Last Change:  2023 Aug 10
" Former Maintainer:    Bram Moolenaar <Bram@vim.org>

" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" The default highlighting.
hi def link qfFileName Directory
hi def link qfLineNr   LineNr
" hi def link qfError    Error
hi qfError cterm=underline guifg=#E06C75
hi def link Output     Error
" hi def Nothing gui=bold
" syntax region SpellCap matchgroup=Nontext start=/\v`/ end=/\v`/ oneline display concealends

syntax match qfError /错误/
syntax match Preproc /附注/
syntax match Preproc /警告/
syntax match qfError /error/
syntax match Preproc /\vwarn(ing)/
" syntax match Preproc /\v_+\^/ display


" syntax match Nontext /\v\|/ conceal cchar=│
syntax match Error   /\v(\^\^\^)?-{2,}/

syntax match Error /\v\[[[:digit:];]+m/ conceal
syntax match Error /\v/ conceal

syntax keyword Keyword int      conceal cchar=𝗜
syntax keyword Keyword typedef  conceal cchar=𝕋
syntax keyword Keyword float    conceal cchar=𝔽
syntax keyword Keyword integer  conceal cchar=𝗜
syntax keyword Keyword double   conceal cchar=𝔻
syntax keyword Keyword char     conceal cchar=ℂ
syntax keyword Keyword bool     conceal cchar=𝔹
syntax keyword Keyword void     conceal cchar=∅
syntax keyword Keyword long     conceal cchar=𝕃
syntax keyword Keyword unsigned conceal cchar=𝕌
syntax keyword Keyword return   conceal cchar=▶
syntax keyword Keyword continue conceal cchar=↺
syntax keyword Keyword break    conceal cchar=✖

" syntax match Function /\v\h+\ze\(/                      contains=@Spell
" syntax match Preproc  /\v\s([\+\-^\*\/%]|[>\=<!]\=?)\s/ contains=keyword,Identifier,@Spell "               +  -  *  /  >= <= ==
" syntax match cType    /\v<\u\w{-}\l>\(@!/               contains=@Spell
" syntax match keyword  /[,|&]!=\@!/                      contains=@Spell                    "               |  &  !
" syntax match keyword  /\v[<>&]{2}/                contains=@Spell                    "               ++ -- && || >> <<
" syntax match keyword  /\v\s[|\+\-\*\/]?\=\s/            contains=@Spell                    "               += -= *= /= =
" syntax match Nontext  /\v[{}]$|;|^%( *)@>}/                             contains=@Spell "  {  }  ;
" 
" syntax cluster hidden add=Preproc,Nontext,Identifier,Constant,cString,cNumbers,Keyword,constants,cCharacter,cConstant,Function,Nothing,@cStringGroup
" syntax region Nothing    matchgroup=Identifier start=/\v\h*\[/    end=/]/  oneline contains=@hidden,@Spell        display
" syntax region diffchange matchgroup=Constant   start=/\vg[c+]{2}/ end=/$/  oneline contains=@hidden,@Spell,Output display nextgroup=Output
" syntax region output     matchgroup=Constant   start=/\v-o\s/     end=/\s/ oneline contains=@hidden,@Spell        display contained

hi def link RustCanNot Yellow
" " A bunch of useful C keywords
syntax region Yellow matchgroup=Error start=/\v(^\|\| *\|.*)@<=[-^]+\~*/ end=/$/ oneline


syntax match Error      /\v\+*$/
syntax match Error      /\v- cannot .*$/     contains=RustCanNot
syntax match RustCanNot /\v(- cannot )@<=.*$/  contained
" syntax match Nontext    /\v;/

syntax match qfFileName /\v^[^|]*/
syntax match LineNR   /|/ conceal cchar=│ contains=Nontext
syntax match Nontext /\v^\|\|/ conceal contained
" 
" syntax region keyword matchgroup=Error start=/\v\[%(-Werror\=)@=/ end=/\v\]/ oneline 
" syntax region Comment matchgroup=Nontext start=/|/ matchgroup=Nontext end=/|/ oneline concealends cchar= 
