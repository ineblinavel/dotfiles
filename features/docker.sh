feature_install() {
  install_feature_packages docker.io
  install_first_available docker-compose-v2 docker-compose-plugin docker-compose
}
