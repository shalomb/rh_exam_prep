# Import the CI/CD environment configuration

# This directory should be switched out for another depending on the
# environment in which the deployment happens by the deployment
# entry-point e.g. deploy.sh

# e.g.
# dev   -> ln -s modules/ukcloud-dev   modules/ci-env
# stage -> ln -s modules/ukcloud-stage modules/ci-env
# prod  -> ln -s modules/ukcloud-prod  modules/ci-env

module "ci-env" {
  source = "modules/ci-env"
}

