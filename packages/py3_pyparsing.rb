require 'buildsystems/python'

class Py3_pyparsing < Python
  description 'The pyparsing module is an alternative approach to creating and executing simple grammars, vs. the traditional lex/yacc approach, or the use of regular expressions.'
  homepage 'https://github.com/pyparsing/pyparsing/'
  version '3.1.1-py3.12'
  license 'MIT'
  compatibility 'all'
  source_url 'https://github.com/pyparsing/pyparsing.git'
  git_hashtag version.split('-').first
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'fae7cd1b45e3f9f03c5184eb96435cb0493bb09059a2601cebf956f7adea097f',
     armv7l: 'fae7cd1b45e3f9f03c5184eb96435cb0493bb09059a2601cebf956f7adea097f',
       i686: '08ecb776d1fc561f00dcc8aae2cc7296a21f2fcdef6085d593b9f3031a99bbbf',
     x86_64: '5f02a7f3f7b6b857a162914563d26e6878bb35eef0a2ae2bb2373d4508b1be43'
  })

  depends_on 'python3'
  depends_on 'py3_flit_core'
end
