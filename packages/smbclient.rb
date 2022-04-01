require 'package'

class Smbclient < Package
  description 'Tools to access a servers filespace and printers via SMB'
  homepage 'https://www.samba.org'
  version '4.16.0'
  license 'GPLv3'
  compatibility 'all'
  source_url 'https://download.samba.org/pub/samba/stable/samba-4.16.0.tar.gz'
  source_sha256 '97c47de35915d1637b254f02643c3230c3e73617851700edc7a2a8c958a3310c'

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/smbclient/4.16.0_armv7l/smbclient-4.16.0-chromeos-armv7l.tar.zst',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/smbclient/4.16.0_armv7l/smbclient-4.16.0-chromeos-armv7l.tar.zst',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/smbclient/4.16.0_i686/smbclient-4.16.0-chromeos-i686.tar.zst',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/smbclient/4.16.0_x86_64/smbclient-4.16.0-chromeos-x86_64.tar.zst'
  })
  binary_sha256({
    aarch64: '984271933e93cff22899d51494abceccce92aa98b94d040ed7f8159ae890ef2a',
     armv7l: '984271933e93cff22899d51494abceccce92aa98b94d040ed7f8159ae890ef2a',
       i686: '050592f2bab1c417a23b1d6571330e97ac644d0dceadbbcffd0cca5c71b434db',
     x86_64: 'cf2a5478cec8d024f85dc5fdf22bd802d0c99afbb231157fad47370bcc8d73e4'
  })

  depends_on 'avahi' # R
  depends_on 'cmocka' => :build
  depends_on 'cups' => :build
  depends_on 'docbook_xsl' => :build
  depends_on 'gpgme' => :build
  depends_on 'jansson' => :build
  depends_on 'ldb' # R
  depends_on 'libbsd' # R
  depends_on 'libcap' # R
  depends_on 'libunwind' # R
  depends_on 'liburing' => :build
  depends_on 'linux_pam' # R
  depends_on 'lmdb' => :build
  depends_on 'perl_json' => :build
  depends_on 'perl_parse_yapp' => :build
  depends_on 'popt' => :build
  depends_on 'py3_dnspython' => :build
  depends_on 'py3_markdown' => :build
  depends_on 'talloc' # R
  depends_on 'tdb' # R
  depends_on 'tevent' # R

  @samba4_idmap_modules = 'idmap_ad,idmap_rid,idmap_adex,idmap_hash,idmap_tdb2'
  @samba4_pdb_modules = 'pdb_tdbsam,pdb_ldap,pdb_ads,pdb_smbpasswd,pdb_wbc_sam,pdb_samba4'
  @samba4_auth_modules = 'auth_unix,auth_wbc,auth_server,auth_netlogond,auth_script,auth_samba4'

  @smbclient_bins = %w[smbclient rpcclient smbspool smbtree smbcacls
                       smbcquotas smbget net nmblookup smbtar]
  @smbclient_pkgconfig = %w[smbclient netapi wbclient]

  @xml_catalog_files = ENV['XML_CATALOG_FILES']

  def self.patch
    system "sed -e 's:<gpgme\.h>:<gpgme/gpgme.h>:' \
    -i source4/dsdb/samdb/ldb_modules/password_hash.c"
    system "sed -i 's,/etc/xml/catalog,#{@xml_catalog_files},g' docs-xml/Makefile"
    system "sed -i 's,file:///etc/xml/catalog,#{@xml_catalog_files},g' buildtools/wafsamba/wafsamba.py"
  end

  def self.build
    system './configure --help'
    system "python_LDFLAGS='' ./configure --enable-fhs \
      #{CREW_OPTIONS.sub(/--program-suffix.*/, '')} \
      --sysconfdir=#{CREW_PREFIX}/etc \
      --sbindir=#{CREW_PREFIX}/bin \
      --libdir=#{CREW_LIB_PREFIX} \
      --libexecdir=#{CREW_LIB_PREFIX}/samba \
      --localstatedir=#{CREW_PREFIX}/var \
      --with-configdir=#{CREW_PREFIX}/etc/samba \
      --with-lockdir=#{CREW_PREFIX}/var/cache/samba \
      --builtin-libraries=NONE \
      --bundled-libraries=!tdb,!talloc,!pytalloc-util,!tevent,!popt,!ldb,!pyldb-util,NONE \
      --disable-python \
      --disable-rpath \
      --disable-rpath-install \
      --with-acl-support \
      --with-ads \
      --with-ldap \
      --with-pam \
      --with-pammodulesdir=#{CREW_LIB_PREFIX}/security \
      --with-piddir=/run \
      --with-profiling-data \
      --with-shared-modules=#{@samba4_idmap_modules},#{@samba4_pdb_modules},#{@samba4_auth_modules},vfs_io_uring \
      --with-sockets-dir=/run/samba \
      --without-ad-dc \
      --with-winbind \
      --without-systemd"
    system 'make'
    # We only need some files from the build, so just install into a
    # staging directory during build.
    FileUtils.mkdir_p 'staging'
    system 'make V=1 DESTDIR=staging install'
    FileUtils.cp 'source3/script/smbtar', "staging/#{CREW_PREFIX}/bin/"
  end

  def self.install
    @dest_dirs = ["#{CREW_DEST_PREFIX}/bin", "#{CREW_DEST_LIB_PREFIX}/samba",
                  "#{CREW_DEST_LIB_PREFIX}/pkgconfig", "#{CREW_DEST_MAN_PREFIX}/man1",
                  "#{CREW_DEST_MAN_PREFIX}/man7", "#{CREW_DEST_MAN_PREFIX}/man8",
                  "#{CREW_DEST_PREFIX}/include/samba-4.0", "#{CREW_DEST_LIB_PREFIX}/cups/backend",
                  "#{CREW_DEST_PREFIX}/etc/samba"]
    @dest_dirs.each do |dir|
      FileUtils.mkdir_p dir
    end
    @smbclient_bins.each do |item|
      FileUtils.install "staging#{CREW_PREFIX}/bin/#{item}", "#{CREW_DEST_PREFIX}/bin/#{item}",
                        mode: 0o755
    end
    FileUtils.mv Dir.glob("staging#{CREW_LIB_PREFIX}/lib*.so*"), "#{CREW_DEST_LIB_PREFIX}/"
    FileUtils.mv Dir.glob("staging#{CREW_LIB_PREFIX}/samba/lib*.so*"), "#{CREW_DEST_LIB_PREFIX}/samba/"
    @smbclient_pkgconfig.each do |item|
      FileUtils.mv Dir.glob("staging#{CREW_LIB_PREFIX}/pkgconfig/#{item}.pc"), "#{CREW_DEST_LIB_PREFIX}/pkgconfig/"
    end
    @smbclient_bins.each do |item|
      if File.exist?("staging#{CREW_MAN_PREFIX}/man1/#{item}.1")
        FileUtils.mv "staging#{CREW_MAN_PREFIX}/man1/#{item}.1",
                     "#{CREW_DEST_MAN_PREFIX}/man1/#{item}.1"
      end
      if File.exist?("staging#{CREW_MAN_PREFIX}/man8/#{item}.8")
        FileUtils.mv "staging#{CREW_MAN_PREFIX}/man8/#{item}.8",
                     "#{CREW_DEST_MAN_PREFIX}/man8/#{item}.8"
      end
    end
    FileUtils.mv "staging#{CREW_MAN_PREFIX}/man7/libsmbclient.7",
                 "#{CREW_DEST_MAN_PREFIX}/man7/libsmbclient.7"
    FileUtils.mv "staging#{CREW_PREFIX}/include/samba-4.0/libsmbclient.h",
                 "#{CREW_DEST_PREFIX}/include/samba-4.0/"
    FileUtils.mv "staging#{CREW_PREFIX}/include/samba-4.0/netapi.h",
                 "#{CREW_DEST_PREFIX}/include/samba-4.0/"
    FileUtils.mv "staging#{CREW_PREFIX}/include/samba-4.0/wbclient.h",
                 "#{CREW_DEST_PREFIX}/include/samba-4.0/"
    FileUtils.ln_s "#{CREW_PREFIX}/bin/smbspool", "#{CREW_DEST_LIB_PREFIX}/cups/backend/smb"
    FileUtils.touch "#{CREW_DEST_PREFIX}/etc/samba/smb.conf"
  end
end
