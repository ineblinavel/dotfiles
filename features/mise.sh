feature_install() {
  if command_exists mise; then
    info "mise já está instalado"
  else
    warn "mise não é instalado automaticamente: siga https://mise.jdx.dev/getting-started.html"
  fi
}
