# Root module
module RbSys
  # Helper class for creating Rust Makefiles
  module Mkmf
    # Config that delegates to CargoBuilder if needded
    class Config
      attr_accessor :force_install_rust_toolchain, :clean_after_install, :target_dir, :auto_install_rust_toolchain, :rubygems_clean_dirs

      def initialize(builder)
        @builder = builder
        @force_install_rust_toolchain = false
        @auto_install_rust_toolchain = true
        @clean_after_install = rubygems_invoked?
        @rubygems_clean_dirs = ["./cargo-vendor"]
      end

      def cross_compiling?
        RbConfig::CONFIG["CROSS_COMPILING"] == "yes"
      end

      def method_missing(name, *args, &blk)
        @builder.send(name, *args, &blk)
      end

      def respond_to_missing?(name, include_private = false)
        @builder.respond_to?(name) || super
      end

      # Seems to be the only way to reliably know if we were invoked by Rubygems.
      # We want to know this so we can cleanup the target directory after an
      # install, to remove bloat.
      def rubygems_invoked?
        ENV.key?("SOURCE_DATE_EPOCH")
      end
    end
  end
end
