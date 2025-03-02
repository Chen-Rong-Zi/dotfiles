let b:current_syntax = "ans"

" vim: ts=8

syn match ansiSuppress conceal '\e\[[0-9;]*[^m]'
syn match ansiSuppress conceal '\e\[?\d*[^m]'
syn match ansiSuppress conceal '\b'
syn match ansiConceal contained conceal "\e\[\(\d*;\)*\d*m"

syn region ansiNone              start="\e\[[01;]m"                                 end="\e\["me=e-2 contains=ansiConceal
syn region ansiNone              start="\e\[m"                                      end="\e\["me=e-2 contains=ansiConceal

syn region ansiBlack             start="\e\[;\=0\{0,2};\=30m"                       end="\e\["me=e-2 contains=ansiConceal
syn region ansiRed               start="\e\[;\=0\{0,2};\=31m"                       end="\e\["me=e-2 contains=ansiConceal
syn region ansiGreen             start="\e\[;\=0\{0,2};\=32m"                       end="\e\["me=e-2 contains=ansiConceal
syn region ansiYellow            start="\e\[;\=0\{0,2};\=33m"                       end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlue              start="\e\[;\=0\{0,2};\=34m"                       end="\e\["me=e-2 contains=ansiConceal
syn region ansiMagenta           start="\e\[;\=0\{0,2};\=35m"                       end="\e\["me=e-2 contains=ansiConceal
syn region ansiCyan              start="\e\[;\=0\{0,2};\=36m"                       end="\e\["me=e-2 contains=ansiConceal
syn region ansiWhite             start="\e\[;\=0\{0,2};\=37m"                       end="\e\["me=e-2 contains=ansiConceal

syn region ansiBlackBg           start="\e\[;\=0\{0,2};\=\%(1;\)\=40\%(1;\)\=m"     end="\e\["me=e-2 contains=ansiConceal
syn region ansiRedBg             start="\e\[;\=0\{0,2};\=\%(1;\)\=41\%(1;\)\=m"     end="\e\["me=e-2 contains=ansiConceal
syn region ansiGreenBg           start="\e\[;\=0\{0,2};\=\%(1;\)\=42\%(1;\)\=m"     end="\e\["me=e-2 contains=ansiConceal
syn region ansiYellowBg          start="\e\[;\=0\{0,2};\=\%(1;\)\=43\%(1;\)\=m"     end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlueBg            start="\e\[;\=0\{0,2};\=\%(1;\)\=44\%(1;\)\=m"     end="\e\["me=e-2 contains=ansiConceal
syn region ansiMagentaBg         start="\e\[;\=0\{0,2};\=\%(1;\)\=45\%(1;\)\=m"     end="\e\["me=e-2 contains=ansiConceal
syn region ansiCyanBg            start="\e\[;\=0\{0,2};\=\%(1;\)\=46\%(1;\)\=m"     end="\e\["me=e-2 contains=ansiConceal
syn region ansiWhiteBg           start="\e\[;\=0\{0,2};\=\%(1;\)\=47\%(1;\)\=m"     end="\e\["me=e-2 contains=ansiConceal

syn region ansiBoldBlack         start="\e\[;\=0\{0,2};\=\%(1;30\|30;1\)m"          end="\e\["me=e-2 contains=ansiConceal
syn region ansiBoldRed           start="\e\[;\=0\{0,2};\=\%(1;31\|31;1\)m"          end="\e\["me=e-2 contains=ansiConceal
syn region ansiBoldGreen         start="\e\[;\=0\{0,2};\=\%(1;32\|32;1\)m"          end="\e\["me=e-2 contains=ansiConceal
syn region ansiBoldYellow        start="\e\[;\=0\{0,2};\=\%(1;33\|33;1\)m"          end="\e\["me=e-2 contains=ansiConceal
syn region ansiBoldBlue          start="\e\[;\=0\{0,2};\=\%(1;34\|34;1\)m"          end="\e\["me=e-2 contains=ansiConceal
syn region ansiBoldMagenta       start="\e\[;\=0\{0,2};\=\%(1;35\|35;1\)m"          end="\e\["me=e-2 contains=ansiConceal
syn region ansiBoldCyan          start="\e\[;\=0\{0,2};\=\%(1;36\|36;1\)m"          end="\e\["me=e-2 contains=ansiConceal
syn region ansiBoldWhite         start="\e\[;\=0\{0,2};\=\%(1;37\|37;1\)m"          end="\e\["me=e-2 contains=ansiConceal

syn region ansiStandoutBlack     start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;30\|30;3\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiStandoutRed       start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;31\|31;3\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiStandoutGreen     start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;32\|32;3\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiStandoutYellow    start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;33\|33;3\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiStandoutBlue      start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;34\|34;3\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiStandoutMagenta   start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;35\|35;3\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiStandoutCyan      start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;36\|36;3\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiStandoutWhite     start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;37\|37;3\)m" end="\e\["me=e-2 contains=ansiConceal

syn region ansiItalicBlack       start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;30\|30;2\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiItalicRed         start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;31\|31;2\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiItalicGreen       start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;32\|32;2\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiItalicYellow      start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;33\|33;2\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiItalicBlue        start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;34\|34;2\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiItalicMagenta     start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;35\|35;2\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiItalicCyan        start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;36\|36;2\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiItalicWhite       start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;37\|37;2\)m" end="\e\["me=e-2 contains=ansiConceal

syn region ansiUnderlineBlack    start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;30\|30;4\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiUnderlineRed      start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;31\|31;4\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiUnderlineGreen    start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;32\|32;4\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiUnderlineYellow   start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;33\|33;4\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiUnderlineBlue     start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;34\|34;4\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiUnderlineMagenta  start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;35\|35;4\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiUnderlineCyan     start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;36\|36;4\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiUnderlineWhite    start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;37\|37;4\)m" end="\e\["me=e-2 contains=ansiConceal

syn region ansiBlinkBlack        start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;30\|30;5\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlinkRed          start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;31\|31;5\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlinkGreen        start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;32\|32;5\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlinkYellow       start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;33\|33;5\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlinkBlue         start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;34\|34;5\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlinkMagenta      start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;35\|35;5\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlinkCyan         start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;36\|36;5\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiBlinkWhite        start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;37\|37;5\)m" end="\e\["me=e-2 contains=ansiConceal

syn region ansiRapidBlinkBlack   start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;30\|30;6\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRapidBlinkRed     start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;31\|31;6\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRapidBlinkGreen   start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;32\|32;6\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRapidBlinkYellow  start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;33\|33;6\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRapidBlinkBlue    start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;34\|34;6\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRapidBlinkMagenta start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;35\|35;6\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRapidBlinkCyan    start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;36\|36;6\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRapidBlinkWhite   start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;37\|37;6\)m" end="\e\["me=e-2 contains=ansiConceal

syn region ansiRVBlack           start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;30\|30;7\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRVRed             start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;31\|31;7\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRVGreen           start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;32\|32;7\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRVYellow          start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;33\|33;7\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRVBlue            start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;34\|34;7\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRVMagenta         start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;35\|35;7\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRVCyan            start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;36\|36;7\)m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiRVWhite           start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;37\|37;7\)m" end="\e\["me=e-2 contains=ansiConceal

setlocal hl=8:Ignore,~:EndOfBuffer,@:NonText,d:Directory,e:ErrorMsg,i:IncSearch,l:Search,y:CurSearch,m:MoreMsg,M:ModeMsg,n:LineNr,a:LineNrAbove,b:LineNrBelow,N:CursorLineNr,G:CursorLineSign,O:CursorLineFold,r:Question,s:StatusLine,S:StatusLineNC,c:VertSplit,t:Title,v:Visual,V:VisualNOS,w:WarningMsg,W:WildMenu,f:Folded,F:FoldColumn,A:DiffAdd,C:DiffChange,D:DiffDelete,T:DiffText,>:SignColumn,-:Conceal,B:SpellBad,P:SpellCap,R:SpellRare,L:SpellLocal,+:Pmenu,=:PmenuSel,k:PmenuMatch,<:PmenuMatchSel,[:PmenuKind,]:PmenuKindSel,{:PmenuExtra,}:PmenuExtraSel,x:PmenuSbar,X:PmenuThumb,*:TabLine,#:TabLineSel,_:TabLineFill,!:CursorColumn,.:CursorLine,o:ColorColumn,q:QuickFixLine,z:StatusLineTerm,Z:StatusLineTermNC,g:MsgArea
hi ansiMEH1 cterm=NONE ctermfg=9
hi ansiMEH2 cterm=NONE ctermfg=12
hi ansiMEH3 cterm=NONE ctermfg=green

hi ansiBlack             ctermfg=black      guifg=black                                        cterm=none         gui=none
hi ansiRed               ctermfg=red        guifg=red                                          cterm=none         gui=none
hi ansiGreen             ctermfg=green      guifg=green                                        cterm=none         gui=none
hi ansiYellow            ctermfg=yellow     guifg=yellow                                       cterm=none         gui=none
hi ansiBlue              ctermfg=blue       guifg=blue                                         cterm=none         gui=none
hi ansiMagenta           ctermfg=magenta    guifg=magenta                                      cterm=none         gui=none
hi ansiCyan              ctermfg=cyan       guifg=cyan                                         cterm=none         gui=none
hi ansiWhite             ctermfg=white      guifg=white                                        cterm=none         gui=none

hi ansiBlackBg           ctermbg=black      guibg=black                                        cterm=none         gui=none
hi ansiRedBg             ctermbg=red        guibg=red                                          cterm=none         gui=none
hi ansiGreenBg           ctermbg=green      guibg=green                                        cterm=none         gui=none
hi ansiYellowBg          ctermbg=yellow     guibg=yellow                                       cterm=none         gui=none
hi ansiBlueBg            ctermbg=blue       guibg=blue                                         cterm=none         gui=none
hi ansiMagentaBg         ctermbg=magenta    guibg=magenta                                      cterm=none         gui=none
hi ansiCyanBg            ctermbg=cyan       guibg=cyan                                         cterm=none         gui=none
hi ansiWhiteBg           ctermbg=white      guibg=white                                        cterm=none         gui=none

hi ansiBoldBlack         ctermfg=black      guifg=black                                        cterm=bold         gui=bold
hi ansiBoldRed           ctermfg=red        guifg=red                                          cterm=bold         gui=bold
hi ansiBoldGreen         ctermfg=green      guifg=green                                        cterm=bold         gui=bold
hi ansiBoldYellow        ctermfg=yellow     guifg=yellow                                       cterm=bold         gui=bold
hi ansiBoldBlue          ctermfg=blue       guifg=blue                                         cterm=bold         gui=bold
hi ansiBoldMagenta       ctermfg=magenta    guifg=magenta                                      cterm=bold         gui=bold
hi ansiBoldCyan          ctermfg=cyan       guifg=cyan                                         cterm=bold         gui=bold
hi ansiBoldWhite         ctermfg=white      guifg=white                                        cterm=bold         gui=bold

hi ansiStandoutBlack     ctermfg=black      guifg=black                                        cterm=standout     gui=standout
hi ansiStandoutRed       ctermfg=red        guifg=red                                          cterm=standout     gui=standout
hi ansiStandoutGreen     ctermfg=green      guifg=green                                        cterm=standout     gui=standout
hi ansiStandoutYellow    ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=standout
hi ansiStandoutBlue      ctermfg=blue       guifg=blue                                         cterm=standout     gui=standout
hi ansiStandoutMagenta   ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=standout
hi ansiStandoutCyan      ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=standout
hi ansiStandoutWhite     ctermfg=white      guifg=white                                        cterm=standout     gui=standout

hi ansiItalicBlack       ctermfg=black      guifg=black                                        cterm=italic       gui=italic
hi ansiItalicRed         ctermfg=red        guifg=red                                          cterm=italic       gui=italic
hi ansiItalicGreen       ctermfg=green      guifg=green                                        cterm=italic       gui=italic
hi ansiItalicYellow      ctermfg=yellow     guifg=yellow                                       cterm=italic       gui=italic
hi ansiItalicBlue        ctermfg=blue       guifg=blue                                         cterm=italic       gui=italic
hi ansiItalicMagenta     ctermfg=magenta    guifg=magenta                                      cterm=italic       gui=italic
hi ansiItalicCyan        ctermfg=cyan       guifg=cyan                                         cterm=italic       gui=italic
hi ansiItalicWhite       ctermfg=white      guifg=white                                        cterm=italic       gui=italic

hi ansiUnderlineBlack    ctermfg=black      guifg=black                                        cterm=underline    gui=underline
hi ansiUnderlineRed      ctermfg=red        guifg=red                                          cterm=underline    gui=underline
hi ansiUnderlineGreen    ctermfg=green      guifg=green                                        cterm=underline    gui=underline
hi ansiUnderlineYellow   ctermfg=yellow     guifg=yellow                                       cterm=underline    gui=underline
hi ansiUnderlineBlue     ctermfg=blue       guifg=blue                                         cterm=underline    gui=underline
hi ansiUnderlineMagenta  ctermfg=magenta    guifg=magenta                                      cterm=underline    gui=underline
hi ansiUnderlineCyan     ctermfg=cyan       guifg=cyan                                         cterm=underline    gui=underline
hi ansiUnderlineWhite    ctermfg=white      guifg=white                                        cterm=underline    gui=underline

hi ansiBlinkBlack        ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
hi ansiBlinkRed          ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
hi ansiBlinkGreen        ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
hi ansiBlinkYellow       ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
hi ansiBlinkBlue         ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
hi ansiBlinkMagenta      ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
hi ansiBlinkCyan         ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
hi ansiBlinkWhite        ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl

hi ansiRapidBlinkBlack   ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
hi ansiRapidBlinkRed     ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
hi ansiRapidBlinkGreen   ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
hi ansiRapidBlinkYellow  ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
hi ansiRapidBlinkBlue    ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
hi ansiRapidBlinkMagenta ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
hi ansiRapidBlinkCyan    ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
hi ansiRapidBlinkWhite   ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl

hi ansiRVBlack           ctermfg=black      guifg=black                                        cterm=reverse      gui=reverse
hi ansiRVRed             ctermfg=red        guifg=red                                          cterm=reverse      gui=reverse
hi ansiRVGreen           ctermfg=green      guifg=green                                        cterm=reverse      gui=reverse
hi ansiRVYellow          ctermfg=yellow     guifg=yellow                                       cterm=reverse      gui=reverse
hi ansiRVBlue            ctermfg=blue       guifg=blue                                         cterm=reverse      gui=reverse
hi ansiRVMagenta         ctermfg=magenta    guifg=magenta                                      cterm=reverse      gui=reverse
hi ansiRVCyan            ctermfg=cyan       guifg=cyan                                         cterm=reverse      gui=reverse
hi ansiRVWhite           ctermfg=white      guifg=white                                        cterm=reverse      gui=reverse

hi ansiBlackBlack        ctermfg=black      ctermbg=black      guifg=Black      guibg=Black    cterm=none         gui=none
hi ansiRedBlack          ctermfg=black      ctermbg=black      guifg=Black      guibg=Black    cterm=none         gui=none
hi ansiRedBlack          ctermfg=red        ctermbg=black      guifg=Red        guibg=Black    cterm=none         gui=none
hi ansiGreenBlack        ctermfg=green      ctermbg=black      guifg=Green      guibg=Black    cterm=none         gui=none
hi ansiYellowBlack       ctermfg=yellow     ctermbg=black      guifg=Yellow     guibg=Black    cterm=none         gui=none
hi ansiBlueBlack         ctermfg=blue       ctermbg=black      guifg=Blue       guibg=Black    cterm=none         gui=none
hi ansiMagentaBlack      ctermfg=magenta    ctermbg=black      guifg=Magenta    guibg=Black    cterm=none         gui=none
hi ansiCyanBlack         ctermfg=cyan       ctermbg=black      guifg=Cyan       guibg=Black    cterm=none         gui=none
hi ansiWhiteBlack        ctermfg=white      ctermbg=black      guifg=White      guibg=Black    cterm=none         gui=none

hi ansiBlackRed          ctermfg=black      ctermbg=red        guifg=Black      guibg=Red      cterm=none         gui=none
hi ansiRedRed            ctermfg=red        ctermbg=red        guifg=Red        guibg=Red      cterm=none         gui=none
hi ansiGreenRed          ctermfg=green      ctermbg=red        guifg=Green      guibg=Red      cterm=none         gui=none
hi ansiYellowRed         ctermfg=yellow     ctermbg=red        guifg=Yellow     guibg=Red      cterm=none         gui=none
hi ansiBlueRed           ctermfg=blue       ctermbg=red        guifg=Blue       guibg=Red      cterm=none         gui=none
hi ansiMagentaRed        ctermfg=magenta    ctermbg=red        guifg=Magenta    guibg=Red      cterm=none         gui=none
hi ansiCyanRed           ctermfg=cyan       ctermbg=red        guifg=Cyan       guibg=Red      cterm=none         gui=none
hi ansiWhiteRed          ctermfg=white      ctermbg=red        guifg=White      guibg=Red      cterm=none         gui=none

hi ansiBlackGreen        ctermfg=black      ctermbg=green      guifg=Black      guibg=Green    cterm=none         gui=none
hi ansiRedGreen          ctermfg=red        ctermbg=green      guifg=Red        guibg=Green    cterm=none         gui=none
hi ansiGreenGreen        ctermfg=green      ctermbg=green      guifg=Green      guibg=Green    cterm=none         gui=none
hi ansiYellowGreen       ctermfg=yellow     ctermbg=green      guifg=Yellow     guibg=Green    cterm=none         gui=none
hi ansiBlueGreen         ctermfg=blue       ctermbg=green      guifg=Blue       guibg=Green    cterm=none         gui=none
hi ansiMagentaGreen      ctermfg=magenta    ctermbg=green      guifg=Magenta    guibg=Green    cterm=none         gui=none
hi ansiCyanGreen         ctermfg=cyan       ctermbg=green      guifg=Cyan       guibg=Green    cterm=none         gui=none
hi ansiWhiteGreen        ctermfg=white      ctermbg=green      guifg=White      guibg=Green    cterm=none         gui=none

hi ansiBlackYellow       ctermfg=black      ctermbg=yellow     guifg=Black      guibg=Yellow   cterm=none         gui=none
hi ansiRedYellow         ctermfg=red        ctermbg=yellow     guifg=Red        guibg=Yellow   cterm=none         gui=none
hi ansiGreenYellow       ctermfg=green      ctermbg=yellow     guifg=Green      guibg=Yellow   cterm=none         gui=none
hi ansiYellowYellow      ctermfg=yellow     ctermbg=yellow     guifg=Yellow     guibg=Yellow   cterm=none         gui=none
hi ansiBlueYellow        ctermfg=blue       ctermbg=yellow     guifg=Blue       guibg=Yellow   cterm=none         gui=none
hi ansiMagentaYellow     ctermfg=magenta    ctermbg=yellow     guifg=Magenta    guibg=Yellow   cterm=none         gui=none
hi ansiCyanYellow        ctermfg=cyan       ctermbg=yellow     guifg=Cyan       guibg=Yellow   cterm=none         gui=none
hi ansiWhiteYellow       ctermfg=white      ctermbg=yellow     guifg=White      guibg=Yellow   cterm=none         gui=none

hi ansiBlackBlue         ctermfg=black      ctermbg=blue       guifg=Black      guibg=Blue     cterm=none         gui=none
hi ansiRedBlue           ctermfg=red        ctermbg=blue       guifg=Red        guibg=Blue     cterm=none         gui=none
hi ansiGreenBlue         ctermfg=green      ctermbg=blue       guifg=Green      guibg=Blue     cterm=none         gui=none
hi ansiYellowBlue        ctermfg=yellow     ctermbg=blue       guifg=Yellow     guibg=Blue     cterm=none         gui=none
hi ansiBlueBlue          ctermfg=blue       ctermbg=blue       guifg=Blue       guibg=Blue     cterm=none         gui=none
hi ansiMagentaBlue       ctermfg=magenta    ctermbg=blue       guifg=Magenta    guibg=Blue     cterm=none         gui=none
hi ansiCyanBlue          ctermfg=cyan       ctermbg=blue       guifg=Cyan       guibg=Blue     cterm=none         gui=none
hi ansiWhiteBlue         ctermfg=white      ctermbg=blue       guifg=White      guibg=Blue     cterm=none         gui=none

hi ansiBlackMagenta      ctermfg=black      ctermbg=magenta    guifg=Black      guibg=Magenta  cterm=none         gui=none
hi ansiRedMagenta        ctermfg=red        ctermbg=magenta    guifg=Red        guibg=Magenta  cterm=none         gui=none
hi ansiGreenMagenta      ctermfg=green      ctermbg=magenta    guifg=Green      guibg=Magenta  cterm=none         gui=none
hi ansiYellowMagenta     ctermfg=yellow     ctermbg=magenta    guifg=Yellow     guibg=Magenta  cterm=none         gui=none
hi ansiBlueMagenta       ctermfg=blue       ctermbg=magenta    guifg=Blue       guibg=Magenta  cterm=none         gui=none
hi ansiMagentaMagenta    ctermfg=magenta    ctermbg=magenta    guifg=Magenta    guibg=Magenta  cterm=none         gui=none
hi ansiCyanMagenta       ctermfg=cyan       ctermbg=magenta    guifg=Cyan       guibg=Magenta  cterm=none         gui=none
hi ansiWhiteMagenta      ctermfg=white      ctermbg=magenta    guifg=White      guibg=Magenta  cterm=none         gui=none

hi ansiBlackCyan         ctermfg=black      ctermbg=cyan       guifg=Black      guibg=Cyan     cterm=none         gui=none
hi ansiRedCyan           ctermfg=red        ctermbg=cyan       guifg=Red        guibg=Cyan     cterm=none         gui=none
hi ansiGreenCyan         ctermfg=green      ctermbg=cyan       guifg=Green      guibg=Cyan     cterm=none         gui=none
hi ansiYellowCyan        ctermfg=yellow     ctermbg=cyan       guifg=Yellow     guibg=Cyan     cterm=none         gui=none
hi ansiBlueCyan          ctermfg=blue       ctermbg=cyan       guifg=Blue       guibg=Cyan     cterm=none         gui=none
hi ansiMagentaCyan       ctermfg=magenta    ctermbg=cyan       guifg=Magenta    guibg=Cyan     cterm=none         gui=none
hi ansiCyanCyan          ctermfg=cyan       ctermbg=cyan       guifg=Cyan       guibg=Cyan     cterm=none         gui=none
hi ansiWhiteCyan         ctermfg=white      ctermbg=cyan       guifg=White      guibg=Cyan     cterm=none         gui=none

hi ansiBlackWhite        ctermfg=black      ctermbg=white      guifg=Black      guibg=White    cterm=none         gui=none
hi ansiRedWhite          ctermfg=red        ctermbg=white      guifg=Red        guibg=White    cterm=none         gui=none
hi ansiGreenWhite        ctermfg=green      ctermbg=white      guifg=Green      guibg=White    cterm=none         gui=none
hi ansiYellowWhite       ctermfg=yellow     ctermbg=white      guifg=Yellow     guibg=White    cterm=none         gui=none
hi ansiBlueWhite         ctermfg=blue       ctermbg=white      guifg=Blue       guibg=White    cterm=none         gui=none
hi ansiMagentaWhite      ctermfg=magenta    ctermbg=white      guifg=Magenta    guibg=White    cterm=none         gui=none
hi ansiCyanWhite         ctermfg=cyan       ctermbg=white      guifg=Cyan       guibg=White    cterm=none         gui=none
hi ansiWhiteWhite        ctermfg=white      ctermbg=white      guifg=White      guibg=White    cterm=none         gui=none

syn region ansiMEH1 start="\e\[38;5;9m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiMEH2 start="\e\[38;5;12m" end="\e\["me=e-2 contains=ansiConceal
syn region ansiMEH3 start="\e\[38;5;10m" end="\e\["me=e-2 contains=ansiConceal



