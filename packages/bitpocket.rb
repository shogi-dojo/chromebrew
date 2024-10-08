require 'package'

class Bitpocket < Package
  description '"DIY Dropbox" or "2-way directory (r)sync with proper deletion"'
  homepage 'https://github.com/ku1ik/bitpocket'
  version '0.2'
  license 'MIT'
  compatibility 'all'
  source_url 'https://github.com/ku1ik/bitpocket/archive/v0.2.tar.gz'
  source_sha256 'f3952374a1139465700f9122d7a929227be5cdeb681679cbe00bb93658adbd1f'
  binary_compression 'tar.xz'

  binary_sha256({
    aarch64: '7b94a65b172e2c93a8a35bd6c6642d61023b0c91ab9f2ba9a8db7f7dca9c150e',
     armv7l: '7b94a65b172e2c93a8a35bd6c6642d61023b0c91ab9f2ba9a8db7f7dca9c150e',
       i686: '42fcb4adb063c62d0a5907739b420e9a75457d51df44b64aa6b1600d2e81b3bf',
     x86_64: '65b995eb9ea17bbce09c47d786cb1c38afac27952f2795fbcc4208b971e9de4a'
  })

  def self.install
    system "install -Dm755 bin/bitpocket #{CREW_DEST_PREFIX}/bin/bitpocket"
  end
end
