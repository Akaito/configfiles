if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
    " setf == setfiletype
    " Web stuff
    au! BufRead,BufNewFile *.hbs         setfiletype handlebars
    au! BufRead,BufNewFile *.htmlj       setfiletype htmljinja
    "au! BufRead,BufNewFile *.html        setfiletype html
    au! BufRead,BufNewFile *.html        setfiletype htmljinja

    " Jenkins
    au! BufRead,BufNewFile *.jenkinsfile setfiletype groovy

    " Misc.
    au! BufRead,BufNewFile *.md          setfiletype markdown

    " Unreal
    au! BufRead,BufNewFile *.uplugin     setfiletype json
    au! BufRead,BufNewFile *.uproject    setfiletype json
augroup END

