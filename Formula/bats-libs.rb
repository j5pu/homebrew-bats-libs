class BatsLibs < Formula
  description=name.demodulize.underscore.split("_").map(&:capitalize).join(" ")
  repo="https://github.com/bats-core/bats-core"
  tag=`git ls-remote --refs --tags --quiet "#{repo}" | cut -d '/' -f3 | sort -Vr | head -1`.strip
  download="#{repo}/archive/#{tag}.tar.gz"
  sha=`curl -fsSL "#{download}" | openssl sha256`.strip

  desc description.to_s
  homepage repo.to_s
  url download.to_s
  version tag.to_s
  sha256 sha.to_s
  license "MIT"
  head repo.to_s, { branch: "master" }

  depends_on "bats-core"
  depends_on "bats-core/bats-core/bats-assert"
  depends_on "bats-core/bats-core/bats-file"
  depends_on "bats-core/bats-core/bats-support"

  def cellar
    prefix/"bin"/filename
  end

  def filename
    "#{name}.bash"
  end

  def homebrew_bin
    HOMEBREW_PREFIX/"bin"
  end

  def homebrew_lib(libname)
    HOMEBREW_PREFIX/"lib"/libname
  end

  def install
    cellar.write <<~EOS
      #!/usr/bin/env bats
      load '#{homebrew_lib "bats-assert"}/load.bash'
      load '#{homebrew_lib "bats-file"}/load.bash'
      load '#{homebrew_lib "bats-support"}/load.bash'
    EOS
    chmod "+x", cellar
  end

  test do
    (testpath/"test.bats").write <<~EOS
      setup() {
        load '#{homebrew_bin}/#{filename}'
      }

      @test "assert true" {
        assert true
      }

      @test 'assert_file_exist() <file>: returns 0 if <file> exists' {
        local -r file="myfile"
        run assert_file_exist "$file"
        [ "$status" -eq 0 ]
        [ "${#lines[@]}" -eq 0 ]
      }
    EOS
    File.write("myfile", "")
    system "#{homebrew_bin}/bats", "test.bats"
  end
end
