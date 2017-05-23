pkg_origin=devigned
pkg_name=rails-todo
pkg_version=0.1.0
pkg_maintainer="David Justice"
pkg_license=('MIT')
pkg_upstream_url=https://github.com/devigned/hab-rails-todo
pkg_source=nosuchfile.tar.gz
pkg_deps=(
  core/ruby/2.4.1
  core/cacerts
  core/bundler
  core/coreutils  
  core/openssl
)
pkg_build_deps=(
  core/gcc-libs
  core/gcc
  core/make
  core/patch
  core/node
)
pkg_exports=( [port]=rails_port )
pkg_exposes=(port)
pkg_svc_user=root

do_download() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  return 0
}

do_prepare() {
  build_line "Setting link for /usr/bin/env to 'coreutils'"
  ln -sfv "$(pkg_path_for core/coreutils)/bin/env" /usr/bin/env
  return 0
}

do_build() {
  cp -R $PLAN_CONTEXT/../src/* $HAB_CACHE_SRC_PATH/$pkg_dirname
  bundle install --deployment --jobs 2 --retry 5
}

do_install() {
  cp -R . "${pkg_prefix}/static"
  chown -R hab:hab "${pkg_prefix}/static/log"

  for binstub in ${pkg_prefix}/static/bin/*; do
    [[ -f $binstub ]] && sed -e "s#/usr/bin/env ruby#$(pkg_path_for core/ruby)/bin/ruby#" -i "$binstub"
  done
}
