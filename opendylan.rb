require "formula"

class Opendylan < Formula
  desc "Open Dylan implementation of Dylan programming language"
  homepage "https://opendylan.org/"
  sha256 "7d77ddd3b6f815e6d77bba343175603b31a284e6d49ce864a1e278ac678a561c"

  stable do
    url "https://github.com/dylan-lang/opendylan/releases/download/v2022.1.0/opendylan-2022.1-x86_64-darwin.tar.bz2"

    depends_on "bdw-gc"
  end

  head do
    url "https://github.com/dylan-lang/opendylan.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bdw-gc" => :build
  end

  depends_on :arch => :intel

  def install

    ENV.deparallelize

    if build.head?
      ohai "Compilation takes a long time; use `brew install -v opendylan` to see progress" unless ARGV.verbose?
      system "./autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make 3-stage-bootstrap"
      system "make install"
    else
      libexec.install Dir["*"]
      bin.install_symlink "#{libexec}/bin/dylan-compiler"
      bin.install_symlink "#{libexec}/bin/make-dylan-app"
      bin.install_symlink "#{libexec}/bin/dswank"
    end
  end

  test do
    app_name = "hello-world"
    system bin/"make-dylan-app", app_name
    cd app_name do
      system bin/"dylan-compiler", "-build", app_name
      assert_equal 0, $?.exitstatus
    end
    assert_equal "Hello, world!\n",
                 `#{ app_name }/_build/bin/#{ app_name }`
    assert_equal 0, $?.exitstatus
  end
end
