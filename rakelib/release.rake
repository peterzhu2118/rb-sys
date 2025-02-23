namespace :release do
  desc "Bump the gem version"
  task bump: ["readme", "data:derive"] do
    require_relative "./../gem/lib/rb_sys/version"
    old_version = RbSys::VERSION

    printf "What is the new version (current: #{old_version})?: "
    new_version = $stdin.gets.chomp

    sh "fastmod", "--extensions=md", "--accept-all", old_version.to_s, new_version.to_s
    sh "fastmod", "--extensions=toml", "--accept-all", "^version = \"#{old_version}\"", "version = #{new_version.inspect}"
    sh "fastmod", "--extensions=toml", "--accept-all", "^rb-sys = \\{ version = \"#{old_version}\"", "rb-sys = { version = #{new_version.inspect}"
    sh "fastmod", "--extensions=toml", "--accept-all", "^rb-sys-build = \\{ version = \"#{old_version}\"", "rb-sys-build = { version = #{new_version.inspect}"
    sh "fastmod", "--extensions=rb", "--accept-all", "^  VERSION = \"#{old_version}\"", "  VERSION = #{new_version.inspect}"
    sh "cargo check"
    Dir.chdir("examples/rust_reverse") { sh("cargo", "check") }
    sh "bundle"
    sh "rake test:examples"
  end

  desc "Publish the crates and gems"
  task :publish do
    Dir.chdir("gem") do
      sh "bundle exec rake release"
    end

    ["crates/rb-sys-build", "crates/rb-sys"].each do |dir|
      Dir.chdir(dir) do
        sh "cargo publish || true"
        sleep 30
      end
    end

    require_relative "./../gem/lib/rb_sys/version"

    sh "gh", "release", "create", "v#{RbSys::VERSION}", "--generate-notes"
  end
end
