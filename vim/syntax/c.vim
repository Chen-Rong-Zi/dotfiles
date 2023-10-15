"let python_highlight_all = 1
syn keyword Identifier reversed sorted self
" match The Function and Methods!!!
"syntax match Special /\w+\{-}(?=()/
"syntax match Special /\v(\w+)(\()\@=/
" syntax match Special /\v\w+(\?=\()/
" syntax match Special /)/
" syntax match Special /(/

" 高亮函数调用
" syntax match Function "\<\w\+\>\s*(" contains=Function transparent syntax match Function "\<\w\+\>\ze\s*(" contains=Function " "+ , -  ,*  ,/  ,==  ,+=  ,%" syntax match Preproc /\s\/\s/
syntax match Preproc /\s==\s/
" syntax match Preproc /\s\*\s/
" syntax match Preproc /\s\*\*\s/
syntax match Preproc /\s\/\s/
syntax match Preproc /\s%\s/
syntax match Preproc /\s\++=\s\+/
syntax match Identifier /\s\+=\s\+/
match Comment /^ \+\ze./

syntax match LineNr /^\s*{$/
syntax match LineNr /^\s*}$/
syntax match LineNr /\s*{$/
syntax match LineNr /{$/
syntax match LineNr /^};$/

" syntax match Preproc /\s\+\-\s\+/
" syntax match Preproc /\v\s\+\s+/
syntax match keyword  /,\s/

" class method
syntax match Constant /\.\w\+\./
" syntax match Identifier /\.\w\+(\w*)\./
" syntax match Identifier /\.\w\+\s/
" syntax match Identifier /\.\w\+,/
syntax match Type /int/      conceal cchar=𝗜
syntax match Type /float/    conceal cchar=𝔽
syntax match Type /double/   conceal cchar=𝔻
syntax match Type /char/     conceal cchar=ℂ
syntax match Type /str/      conceal cchar=𝐒
syntax match Type /bool/     conceal cchar=𝔹
syntax match Type /void/     conceal cchar=∅
syntax match Type /long/     conceal cchar=𝕃
syntax match Type /unsigned/ conceal cchar=𝕌
" syn region keyword  /password/ conceal cchar=*
" syntax match Constant "return" conceal cchar=▶ contains=return
hi link Conceal Type

