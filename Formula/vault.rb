# Please don't update this formula until the release is official via
# mailing list or blog post. There's a history of GitHub tags moving around.
# https://github.com/hashicorp/vault/issues/1051
class Vault < Formula
  desc "Secures, stores, and tightly controls access to secrets"
  homepage "https://vaultproject.io/"
  url "https://github.com/hashicorp/vault.git",
      :tag      => "v1.3.0",
      :revision => "0f5c835d1cf91c00d01cb29a0048732d91357afa"
  head "https://github.com/hashicorp/vault.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "38d5259e448cfc9ed592c80e55c062f9472cb672f30e87b3e7915a0b014ea52e" => :catalina
    sha256 "86ed3fa4e12a3a6fef990157c1bc60264c79c1c0a39ffaf4c3eae82856f9ac32" => :mojave
    sha256 "984e67cb1e2382b21b6c8174d3528b5612659e80793789a5c7c1ca4050cef4d7" => :high_sierra
  end

  option "with-dynamic", "Build dynamic binary with CGO_ENABLED=1"

  depends_on "go@1.12" => :build
  depends_on "gox" => :build

  def install
    ENV["GOPATH"] = buildpath

    contents = buildpath.children - [buildpath/".brew_home"]
    (buildpath/"src/github.com/hashicorp/vault").install contents

    (buildpath/"bin").mkpath

    cd "src/github.com/hashicorp/vault" do
      target = build.with?("dynamic") ? "dev-dynamic" : "dev"
      system "make", target
      bin.install "bin/vault"
      prefix.install_metafiles
    end
  end

  test do
    pid = fork { exec bin/"vault", "server", "-dev" }
    sleep 1
    ENV.append "VAULT_ADDR", "http://127.0.0.1:8200"
    system bin/"vault", "status"
    Process.kill("TERM", pid)
  end
end
