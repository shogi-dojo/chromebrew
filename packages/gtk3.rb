require 'package'

class Gtk3 < Package
  description 'GTK+ is a multi-platform toolkit for creating graphical user interfaces.'
  homepage 'https://developer.gnome.org/gtk3/3.0/'
  @_ver = '3.24.29'
  @_ver_prelastdot = @_ver.rpartition('.')[0]
  version @_ver
  license 'LGPL-2.1'
  compatibility 'all'
  source_url 'https://gitlab.gnome.org/GNOME/gtk.git'
  git_hashtag @_ver

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/gtk3/3.24.29_armv7l/gtk3-3.24.29-chromeos-armv7l.tpxz',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/gtk3/3.24.29_armv7l/gtk3-3.24.29-chromeos-armv7l.tpxz',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/gtk3/3.24.29_i686/gtk3-3.24.29-chromeos-i686.tpxz',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/gtk3/3.24.29_x86_64/gtk3-3.24.29-chromeos-x86_64.tpxz'
  })
  binary_sha256({
    aarch64: '05caf4c5661d197f4c82d3cf1ed919a5379fd82ac7df8b2ec0734c50984f49a1',
     armv7l: '05caf4c5661d197f4c82d3cf1ed919a5379fd82ac7df8b2ec0734c50984f49a1',
       i686: 'd23792469f08482573d02aaca7c3042e85c1f1f4b54ba9bd661ec473cdb1cf2c',
     x86_64: '848d47ac2546f4bc554b9f6f0af8e148741d7c55ef52d83f4a5fbf51c07aa9eb'
  })

  # L = Logical Dependency, R = Runtime Dependency
  depends_on 'docbook' => :build
  depends_on 'ghostscript' => :build
  depends_on 'gobject_introspection' => :build
  depends_on 'iso_codes' => :build
  depends_on 'libspectre' => :build
  depends_on 'mesa' => :build
  depends_on 'valgrind' => :build
  depends_on 'graphene' => :build # Do we need this?
  depends_on 'graphite' => :build # Do we need this?
  depends_on 'libdeflate' => :build # Do we need this?
  depends_on 'libjpeg' => :build # Do we need this?
  depends_on 'py3_six' => :build # Do we need this?
  depends_on 'adwaita_icon_theme' # L
  depends_on 'cantarell_fonts' # L
  depends_on 'gnome_icon_theme' # L
  depends_on 'hicolor_icon_theme' # L
  depends_on 'shared_mime_info' # L
  depends_on 'xdg_base' # L
  depends_on 'atk' # R
  depends_on 'at_spi2_atk' # R
  depends_on 'cairo' # R
  depends_on 'cups' # R
  depends_on 'fontconfig' # R
  depends_on 'freetype' # R
  depends_on 'fribidi' # R
  depends_on 'gdk_pixbuf' # R
  depends_on 'glib' # R
  depends_on 'harfbuzz' # R
  depends_on 'json_glib' # R
  depends_on 'libepoxy' # R
  depends_on 'libx11' # R
  depends_on 'libxcomposite' # R
  depends_on 'libxcursor' # R
  depends_on 'libxdamage' # R
  depends_on 'libxext' # R
  depends_on 'libxfixes' # R
  depends_on 'libxinerama' # R
  depends_on 'libxi' # R
  depends_on 'libxkbcommon' # R
  depends_on 'libxrandr' # R
  depends_on 'pango' # R
  depends_on 'rest' # R
  depends_on 'wayland' # R

  def self.patch
    # Use locally build subprojects
    @deps = %w[cairo librsvg]
    @deps.each do |dep|
      FileUtils.rm_rf "subprojects/#{dep}" if Dir.exist?("subprojects/#{dep}")
      FileUtils.rm_rf "subprojects/#{dep}.wrap" if File.exist?("subprojects/#{dep}.wrap")
    end
  end

  def self.build
    system "meson #{CREW_MESON_OPTIONS} \
      -Dbroadway_backend=true \
      -Ddemos=false \
      -Dexamples=false \
      -Dgtk_doc=false \
      builddir"
    system 'meson configure builddir'
    system 'ninja -C builddir'
    @gtk3settings = <<~GTK3_CONFIG_HEREDOC
      [Settings]
      gtk-icon-theme-name = Adwaita
      gtk-fallback-icon-theme = gnome
      gtk-theme-name = Adwaita
      gtk-font-name = Cantarell 11
      gtk-application-prefer-dark-theme = false
    GTK3_CONFIG_HEREDOC
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} ninja -C builddir install"
    system "sed -i 's,null,,g'  #{CREW_DEST_LIB_PREFIX}/pkgconfig/gtk*.pc"
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/etc/gtk-3.0"
    File.write("#{CREW_DEST_PREFIX}/etc/gtk-3.0/settings.ini", @gtk3settings)
  end

  def self.postinstall
    # generate schemas
    system "#{CREW_PREFIX}/bin/glib-compile-schemas #{CREW_PREFIX}/share/glib-2.0/schemas"
    # update mime database
    system "#{CREW_PREFIX}/bin/update-mime-database #{CREW_PREFIX}/share/mime"
    # update icon cache, but only if gdk_pixbuf is already installed.
    @device = JSON.parse(File.read("#{CREW_CONFIG_PATH}device.json"), symbolize_names: true)
    return unless @device[:installed_packages].any? 'gdk_pixbuf'

    system "#{CREW_PREFIX}/bin/gtk-update-icon-cache -ft #{CREW_PREFIX}/share/icons/*"
  end
end
