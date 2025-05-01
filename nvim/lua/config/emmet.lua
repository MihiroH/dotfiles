vim.cmd([[
  autocmd FileType html,css,javascriptreact,typescriptreact,jst,scss,sass,embedded_template,vue imap <buffer><expr><tab>
      \ emmet#isExpandable() ? "\<plug>(emmet-expand-abbr)" :
      \ "\<tab>"

  let g:user_emmet_settings = {
  \  'javascript' : {
  \      'extends' : 'jsx',
  \  },
  \  'typescript' : {
  \      'extends' : 'jsx',
  \  },
  \  'variables' : {
  \    'lang' : "ja"
  \  },
  \  'html' : {
  \    'indentation' : '  ',
  \    'snippets' : {
  \      'html:5': "<!DOCTYPE html>\n"
  \        ."<html lang=\"${lang}\">\n"
  \        ."<head>\n"
  \        ."\t<meta charset=\"${charset}\">\n"
  \        ."\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"
  \        ."\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
  \        ."\t<title></title>\n"
  \        ."</head>\n"
  \        ."<body>\n\t${child}|\n</body>\n"
  \        ."</html>",
  \    }
  \  },
  \  'jst' : {
  \    'indentation' : '  ',
  \    'snippets' : {
  \      'html:5': "<!DOCTYPE html>\n"
  \        ."<html lang=\"${lang}\">\n"
  \        ."<head>\n"
  \        ."\t<meta charset=\"${charset}\">\n"
  \        ."\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"
  \        ."\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
  \        ."\t<title></title>\n"
  \        ."</head>\n"
  \        ."<body>\n\t${child}|\n</body>\n"
  \        ."</html>",
  \    }
  \  }
  \}
]])

