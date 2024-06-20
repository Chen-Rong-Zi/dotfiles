" "+ , -  ,*  ,/  ,==  ,+=  ,%" 
" syntax match Preproc /\s\/\s/
" syntax match Preproc /\s==\s/
" syntax match Preproc /\s!=\s/
" syntax match Preproc /\s\*\s/
" syntax match Preproc /\s\*\*\s/
" syntax match Preproc /\s\/\s/
" syntax match Preproc /\s%\s/
" syntax match Preproc /\s\++=\s\+/
" syntax match Identifier /\s\+=\s\+/

" syntax match LineNr /^\s*}$/
" syntax match LineNr /\s*{$/
" syntax match LineNr /[{;]$/
" syntax match LineNr /^};$/
hi Nothing gui=bold
hi link cBracket1  Nontext
hi link cBracket2  Structure
hi link cBracket3  Special
hi link cBracket4  Keyword
hi link inBracket1 Nothing
hi link inBracket2 Nothing
hi link inBracket3 Nothing
hi link inBracket4 Nothing

syntax match Function       /\v\i+\ze\(/                         display contains=@Spell
syntax match Preproc        /\v\s([\+\-^\*\/%]|[>\=<!]\=?)\s/    display contains=@Spell    " + - * / >= <= ==
syntax match Type          /\v<\u\w{-}>/                        display contains=TOP
syntax match keyword        /[,|&]\|!=\@!/                       display contains=@Spell                              " | & !
syntax match keyword        /++\|--\|&&\|>>\|<</                 display contains=@Spell                               " ++ -- && || >> <<
syntax match purple        /\v\s[|\+\-\*\/^]?\=\s/               display contains=@Spell                                 " += -= *= /= =
syntax match Identifier     /\v\*+\s@!\w*|[:?.]|-\>/              display contains=Function                             " array[.*] and *pointers and dereference ->
syntax match Nontext        /\v[{}]$|;|^%( *)@>}/                display contains=@Spell                               " { } ;

" syntax cluster hidden add=cBitField,cBlock,cCharacter,cComment,cCommentL,cConstant,cCppInWrapper,cCppOutWrapper,cCppString,cDefine,cLabel,cMulti,cNumbers,cOperator,cout,cPragma,cPreCondit,cPreConditMatch,cPreProc,cRepeat,cSpecialCharacter,cStatement,cStorageClass,cString,cStructure,cType,Ctype,cTypedef,cUserCont,cWrongComTail,Function,Identifier,inBracket1,keyword,Keyword,Nontext,Nothing,Preproc
syntax cluster hidden contains=TOP


" 这个困扰我好久的问题就这么解决了？第一个region是解法一，但是解法二显然更好
" syntax region Nothing matchgroup=Nontext    start=/\v%(<while>|<for>|<if>)@<= \(/ end=/\v\)[^)]{-}$/ oneline contains=@hidden,@Spell keepend display
syntax region Nothing matchgroup=Identifier start=/\v\h*\[/ end=/]/ display oneline contains=@hidden

syntax region inBracket1 matchgroup=cBracket1 start=/(/ end=/)/ display contains=@hidden,inBracket2 nextgroup=inBracket2 oneline
syntax region inBracket2 matchgroup=cBracket2 start=/(/ end=/)/ display contains=@hidden,inBracket3 contained nextgroup=inBracket3 oneline
syntax region inBracket3 matchgroup=cBracket3 start=/(/ end=/)/ display contains=@hidden,inBracket4 contained nextgroup=inBracket4 oneline
syntax region inBracket4 matchgroup=cBracket4 start=/(/ end=/)/ display contains=@hidden,inBracket1 contained oneline

syntax region inBracket1 matchgroup=cBracket1 start=/</ end=/>/ display contains=@hidden,inBracket2 nextgroup=inBracket2 oneline
syntax region inBracket2 matchgroup=cBracket2 start=/</ end=/>/ display contains=@hidden,inBracket3 contained nextgroup=inBracket3 oneline
syntax region inBracket3 matchgroup=cBracket3 start=/</ end=/>/ display contains=@hidden,inBracket4 contained nextgroup=inBracket4 oneline
syntax region inBracket4 matchgroup=cBracket4 start=/</ end=/>/ display contains=@hidden,inBracket1 contained oneline

" syntax match Nontext /\v((for|while|if).*)@60<=\)\s*\{=$/    " (  ) after if or while or for
" syntax match LineNr /\v((for|while|if) )@<=\(/
" match keyword /\v(<for>|<while>|<if>)/
" syntax match Constant /\%(if\|while\|for\)\s*([^)]*)\s*{/          " Constant defined by #define or const
syntax match cConstant /\v<[[:upper:]_]{2,}>/    " Constant defined by #define or const

syntax match Keyword /\v\zs<else *if/   display conceal cchar=ℰ
syntax match Keyword /\v<else>%( if)@!/ display conceal cchar=𝘌
syntax keyword Keyword final    conceal cchar=𝙁
syntax keyword Keyword if       conceal cchar=𝘐
syntax keyword Keyword int      conceal cchar=𝕀
syntax keyword Keyword Integer  conceal cchar=𝗜
syntax keyword Keyword short    conceal cchar=𝕤
syntax keyword Keyword typedef  conceal cchar=𝕋
syntax keyword Keyword float    conceal cchar=𝔽
syntax keyword Keyword double   conceal cchar=𝔻
syntax keyword Keyword char     conceal cchar=ℂ
syntax keyword Keyword bool     conceal cchar=𝔹
syntax keyword Keyword void     conceal cchar=∅
syntax keyword Keyword long     conceal cchar=𝕃
syntax keyword Keyword unsigned conceal cchar=𝕌
syntax keyword Keyword return   conceal cchar=⌲
syntax keyword Keyword continue conceal cchar=↺
syntax keyword Keyword break    conceal cchar=✖
syntax keyword Keyword template conceal cchar=𝘛
syntax keyword Keyword typename conceal cchar=𝕥
syntax keyword Keyword this     conceal cchar=𝕋
syntax keyword Keyword vector   conceal cchar=𝗏
syntax keyword Keyword decltype conceal cchar=𝘿
syntax keyword Keyword const    conceal cchar=𝘾
syntax keyword Keyword catch    conceal cchar=𝔼
syntax match   Keyword /\[=\]/  conceal cchar=λ
" syntax keyword Keyword return   conceal cchar=▶
" syntax keyword Keyword vector   conceal cchar=𝘷
" syn region keyword  /password/ conceal cchar=*
" syntax match Constant "return" conceal cchar= contains=return

hi! link conceal Keyword
