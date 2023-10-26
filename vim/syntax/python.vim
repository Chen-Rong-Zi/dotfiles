" "let python_highlight_all = 1
" syntax sync clear
" syntax keyword Identifier self
" 
" " match The Function and Methods!!!
" "syntax match Special /\w+\{-}(?=()/
" "syntax match Special /\v(\w+)(\()\@=/
" " syntax match Special /\v\w+(\?=\()/
" " syntax match Special /)/
" " syntax match Special /(/
" " 高亮函数调用
" " syntax match Function "\<\w\+\>(" contains=Function transparent
" " syntax match Function "\<\w\+\>\ze(" contains=Function
" syntax match Function "\<\w\+\>\ze("
" " syntax match pythonFunction "\w\+\ze("
" 
" " "+ , -  ,*  ,/  ,==  ,+=  ,%"
" syntax match Preproc /\s\/\s/
" syntax match Preproc /\s==\s/
" syntax match Preproc /\s\*\s/
" " syntax match Preproc /\s\*\*\s/
" " syntax match Preproc /\s\/\s/
" syntax match Preproc /\s%\s/
" syntax match Preproc /\s+=\s/
" " syntax match Identifier /\s\+=\s\+/
" 
" syntax match Preproc /\s\-\s/
" syntax match Preproc /\s+\s/
" syntax match keyword  /,\s/
" 
" " class method
" syntax match Constant /\.\w\+\./
" " syntax match Identifier /\.\w\+(\w*)\./
" " syntax match Identifier /\.\w\+\s/
" " syntax match Identifier /\.\w\+,/
" syntax match Constant /^\ \+\ze./
" syntax keyword keyword lambda conceal cchar=λ
" syntax keyword keyword  None   conceal cchar=∅
" " syntax keyword Keyword return conceal cchar=𐅙
" " syntax keyword Keyword return conceal cchar=⇶⇰
" syntax keyword Keyword return conceal cchar=▶
" syntax keyword Keyword assert conceal cchar=𝔸
" hi! link conceal keyword
