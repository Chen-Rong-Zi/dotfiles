" syntax keyword cType auto double int long char float short unsigned signed void volatile union const struct enum extern
" syntax keyword cStatement break else switch case register typedef return for default goto sizeof while do if continue  static
syntax clear
syntax case match

highlight Nothing gui=bold
highlight link cType          Type
highlight link cStatement     Statement
highlight link cComment       Comment
highlight link cString        String
highlight link cTodo          Todo
highlight link cNumber        Number
highlight link cInclude       Include
highlight link cIncluded      String
highlight link cIf            cStatement
highlight link cBracket       LineNr
highlight link cFunction      Function
highlight link cArithmetic    Preproc
highlight link cBit           Function
highlight link cRalational    Constant
highlight link cLogic         SpecialChar
highlight link cSufix         Identifier
highlight link cPrefix        Identifier
highlight link cAssiginment   Keyword
highlight link cString        String
highlight link cInclude       Include
highlight link cIncluded      String
highlight link cDefine        Include
highlight link cDefined       Constant
highlight link cIfdef         Include
highlight link cIfndef        Include
highlight link cEndif         Include
highlight link cPart1         Nothing
highlight link cPart2         Nothing
highlight link cPart3         Nothing
highlight link cPart4         Nothing
highlight link cFirstBracket  cComment
highlight link cSecondBracket String
highlight link cThirdBracket  Preproc
highlight link cFourBracket   Constant

syntax match cType          /\v<cType>|<double>|<int>|<long>|<char>|<float>|<short>|<unsigned>|<signed>/
syntax match cType          /\v<void>|<volatile>|<union>|<const>|<struct>|<enum>|<extern>|bool/
syntax match keyword        /\v<break>|<else>|<switch>|<case>|<register>|<typedef>|<return>|<for>/
syntax match keyword        /\v<default>|<goto>|<sizeof>|<while>|<do>|<if>|<continue>|<static>/
syntax match cComment       /\v\/\/.{-}$/
syntax match cComment       /\v\/\*\_.{-}\*\//
syntax match cFunction      /\v<\h*>\(@=/
syntax match cArithmetic    /\v @>%([\+\-\*\/%]|\>\>|\<\<) @>/
syntax match cBit           /\v @>[&\|^] @=/
syntax match cRalational    /\v @>%([\<\>]\=?|[\=!]\=) @>/
syntax match cLogic         /\v @>%(\&\&|\|\||!) @=/
syntax match cSufix         /\v[[\].]|-[>\-]|\+\+/
syntax match cPrefix        /\v\*{-1,} @!\w+/
syntax match cAssiginment   /\v @>%([\+\-\*\/\%]|\>\>|\<\<)?\= @>/
syntax match cString        /\v"[^"]{-}"/
syntax match cInclude       /\v^#%( *)@>include/
syntax match cIncluded      /\v%(^# *include *)@<=[\<"].*$/
syntax match cDefine        /\v^# *define/
syntax match cDefined       /\v^# *define *.*$/
syntax match cIfdef         /\v^# *ifdef *.*$/
syntax match cIfndef        /\v^# *ifndef *.*$/
syntax match cEndif         /\v^# *endif *.*$/
syntax match cType          /\v\u\w*\l>/

sy region cPart1 matchgroup=cFirstBracket  start=/(/ end=/)/ contains=ALLBUT,cPart3,cPart4,cPart1 oneline
sy region cPart2 matchgroup=cSecondBracket start=/(/ end=/)/ contains=ALLBUT,cPart4,cPart1,cPart2 contained oneline
sy region cPart3 matchgroup=cThirdBracket  start=/(/ end=/)/ contains=ALLBUT,cPart3,cPart1,cPart2 contained oneline
sy region cPart4 matchgroup=cFourBracket   start=/(/ end=/)/ contains=ALLBUT,cPart3,cPart4,cPart2 contained oneline
" syntax match cNumber /\v\d+/
" syntax match cInclude /\v^#\s{-}include>/ contains=cIncluded
" syntax match cIncluded /\v(^#\s*include>)@<=\s{-}\<.{-}\>/
" syntax match cFunction /\v\i{-}\(@=/

" syntax region cString start=/"/ skip=/\\"/ end=/"/ contains=cNumber
" syntax region cComment start=/\v\/\*/ end=/\v\*\//
" <++> 续行
