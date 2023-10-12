"let python_highlight_all = 1
syn keyword Identifier reversed sorted sum self

" match The Function and Methods!!!
"syntax match Special /\w+\{-}(?=()/
"syntax match Special /\v(\w+)(\()\@=/
" syntax match Special /\v\w+(\?=\()/
" syntax match Special /)/
" syntax match Special /(/

" 高亮函数调用
" syntax match Function "\<\w\+\>\s*(" contains=Function transparent
syntax match Function "\<\w\+\>\ze\s*(" contains=Function

" "+ , -  ,*  ,/  ,==  ,+=  ,%"
syntax match Preproc /\s\/\s/
syntax match Preproc /\s==\s/
syntax match Preproc /\s\*\s/
" syntax match Preproc /\s\*\*\s/
syntax match Preproc /\s\/\s/
syntax match Preproc /\s%\s/
syntax match Preproc /\s\++=\s\+/
syntax match Identifier /\s\+=\s\+/

syntax match Preproc /\s\+\-\s\+/
syntax match Preproc /\v\s\+\s+/
syntax match keyword  /,\s/
syntax match LineNr /^\s\?};$/

" class method
syntax match Constant /\.\w\+\./
" syntax match Identifier /\.\w\+(\w*)\./
" syntax match Identifier /\.\w\+\s/
" syntax match Identifier /\.\w\+,/
syntax match Constant /^\ \+\ze./
syntax match Type '\v<int(\(|[^\s)\],:])@!' conceal cchar=ℤ
syntax keyword Constant lambda conceal cchar=λ
