require 'buildsystems/python'

class Py3_pyproject_hooks < Python
  description 'This package contains wrappers to call hooks on build backends for pyproject.toml -based projects'
  homepage 'https://pyproject-hooks.readthedocs.io/'
  version '1.0.0-py3.12'
  license 'MIT'
  compatibility 'all'
  source_url 'https://github.com/pypa/pyproject-hooks.git'
  git_hashtag "v#{version.split('-').first}"
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '85dc082e0188d4e202957bf5c9bfb9405e4ce8432ab38a311dbddfe0529f4ecc',
     armv7l: '85dc082e0188d4e202957bf5c9bfb9405e4ce8432ab38a311dbddfe0529f4ecc',
       i686: '320ca6f093e9dfd90ef604dc602bd6c92775d5314c83027ccb3595805f59c7ba',
     x86_64: 'd411f26747f2f0f5b55fa094cfe2fc0622c522f476bd3c6ae97934bdfddf1dc9'
  })

  depends_on 'python3'
  depends_on 'py3_tomli'
end
