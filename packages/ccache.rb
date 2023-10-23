require 'package'

class Ccache < Package
  description 'Compiler cache that speeds up recompilation by caching previous compilations'
  homepage 'https://ccache.samba.org/'
  version '4.8.3'
  license 'GPL-3 and LGPL-3'
  compatibility 'all'
  source_url "https://github.com/ccache/ccache/releases/download/v#{version}/ccache-#{version}.tar.xz"
  source_sha256 'e47374c810b248cfca3665ee1d86c7c763ffd68d9944bc422d9c1872611f2b11'

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/ccache/4.8.3_armv7l/ccache-4.8.3-chromeos-armv7l.tar.zst',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/ccache/4.8.3_armv7l/ccache-4.8.3-chromeos-armv7l.tar.zst',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/ccache/4.8.3_i686/ccache-4.8.3-chromeos-i686.tar.zst',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/ccache/4.8.3_x86_64/ccache-4.8.3-chromeos-x86_64.tar.zst'
  })
  binary_sha256({
    aarch64: '8a70dd0613001a060b6abe38ceebd9b5349782161a109776c01fc21290c8d9c4',
     armv7l: '8a70dd0613001a060b6abe38ceebd9b5349782161a109776c01fc21290c8d9c4',
       i686: '011dbc560981470a4af0ce7b32278b8601be9efaf354efe8b8ea55ac1cbc61c2',
     x86_64: '85a098065edc90e41092640acb41a5d37529374c4109b1f1903f22373489b432'
  })

  depends_on 'gcc_dev' # R
  depends_on 'gcc_lib' # R
  depends_on 'glibc' # R
  depends_on 'ruby_asciidoctor' => :build
  depends_on 'xdg_base'
  depends_on 'zstd' # R

  def self.build
    system "cmake -B builddir -G Ninja \
      #{CREW_CMAKE_OPTIONS} \
      -DCMAKE_INSTALL_SYSCONFDIR=#{CREW_PREFIX}/etc \
      -DENABLE_IPO=ON \
      -DENABLE_TESTING=OFF \
      -DZSTD_FROM_INTERNET=OFF \
      -DHIREDIS_FROM_INTERNET=ON"
    system "#{CREW_NINJA} -C builddir"
    File.write 'ccache_env', <<~CCACHEEOF
      # ccache configuration
      if [[ $PATH != *"ccache/bin"* ]]; then
        PATH="#{CREW_LIB_PREFIX}/ccache/bin:$PATH"
      fi
    CCACHEEOF
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} #{CREW_NINJA} -C builddir install"
    FileUtils.mkdir_p "#{CREW_DEST_LIB_PREFIX}/ccache/bin"
    Dir.chdir "#{CREW_DEST_LIB_PREFIX}/ccache/bin" do
      %w[gcc g++ c++].each do |bin|
        FileUtils.ln_s '../../../bin/ccache', bin
      end
      %w[cc clang clang++].each do |bin|
        FileUtils.ln_s '../../../bin/ccache', bin
      end
    end
    FileUtils.install 'ccache_env', "#{CREW_DEST_PREFIX}/etc/env.d/00-ccache", mode: 0o644
  end
end
