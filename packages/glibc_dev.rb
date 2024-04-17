require 'package'
require_relative 'glibc'
require_relative 'glibc_build235'
require_relative 'glibc_build237'

class Glibc_dev < Package
  description 'glibc: everything except what is in glibc_lib'
  homepage Glibc.homepage
  license Glibc.license
  source_url 'SKIP'

  is_fake

  case LIBC_VERSION
  when '2.35'
    version Glibc_build235.version
    compatibility Glibc_build235.compatibility
    depends_on 'glibc_dev235'
  when '2.37'
    version Glibc_build237.version
    compatibility Glibc_build237.compatibility
    depends_on 'glibc_dev237'
  else
    version Glibc.version
    compatibility Glibc.compatibility
    depends_on 'glibc'
  end
end
