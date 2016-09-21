require 'formula'

class FreedomRoutes < Formula
  homepage 'https://github.com/SaberSalv/freedom-routes'
  if Hardware.is_32_bit?
    url 'http://downloads.gutenye.com/freedom-routes/freedom-routes.homebrew.386-1.0.0.tar.gz'
    sha1 'aab3e45c172df5623819f6b7e1a31767e22bed08'
  else
    url 'http://downloads.gutenye.com/freedom-routes/freedom-routes.homebrew.amd64-1.0.0.tar.gz'
    sha1 '3f79a441a2ad5dc593c10f1942306d05bdbcbd23'
  end

  def install
    bin.install 'freedom-routes'
    (share+'freedom-routes').install 'templates'
    etc.install 'freedom-routes.etc' => 'freedom-routes'
  end
end
