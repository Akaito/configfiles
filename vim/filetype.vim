if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.htmlj      setfiletype htmljinja
  "au! BufRead,BufNewFile *.html       setfiletype html
  au! BufRead,BufNewFile *.html       setfiletype htmljinja
  au! BufRead,BufNewFile *.md         setfiletype markdown
augroup END
