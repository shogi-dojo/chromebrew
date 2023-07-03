require 'package'

class Perl_parse_yapp < Package
  description 'Parse::Yapp - Perl extension for generating and using LALR parsers.'
  homepage 'https://metacpan.org/pod/Parse::Yapp'
  version '1.21-perl5.38'
  license 'GPL'
  compatibility 'all'
  source_url 'https://cpan.metacpan.org/authors/id/W/WB/WBRASWELL/Parse-Yapp-1.21.tar.gz'
  source_sha256 '3810e998308fba2e0f4f26043035032b027ce51ce5c8a52a8b8e340ca65f13e5'

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/perl_parse_yapp/1.21-perl5.38_armv7l/perl_parse_yapp-1.21-perl5.38-chromeos-armv7l.tar.zst',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/perl_parse_yapp/1.21-perl5.38_armv7l/perl_parse_yapp-1.21-perl5.38-chromeos-armv7l.tar.zst',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/perl_parse_yapp/1.21-perl5.38_i686/perl_parse_yapp-1.21-perl5.38-chromeos-i686.tar.zst',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/perl_parse_yapp/1.21-perl5.38_x86_64/perl_parse_yapp-1.21-perl5.38-chromeos-x86_64.tar.zst'
  })
  binary_sha256({
    aarch64: '304950660fbbe7f5ec73741ad6fbde700aa3e5c12358798cd920c0c48e3368e4',
     armv7l: '304950660fbbe7f5ec73741ad6fbde700aa3e5c12358798cd920c0c48e3368e4',
       i686: 'f4532e4e157d589d8ebde6b9bd2754ad936f22f9c4e8255b8937fa354d10dab7',
     x86_64: '0b16bf60787ec109f9a76ce363f86cb59d05ed4385a734d944864142f519cd69'
  })

  def self.prebuild
    system 'perl', 'Makefile.PL'
    system "sed -i 's,/usr/local,#{CREW_PREFIX},g' Makefile"
  end

  def self.build
    system 'make'
  end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end
end
