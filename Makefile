define tf_prep
	terraform version
	terraform providers
	terraform init -reconfigure
	terraform validate -check-variables=true
endef

define tf_plan
	terraform plan -refresh
endef

define tf_apply
	terraform plan -refresh
endef

all:
	@echo "usage: make init"
	@echo "       make plan"
	@echo "       make apply"
	@echo "       make state"

init:
	$(tf_init)

plan:
	$(tf_prep)
	$(tf_plan)

apply:
	$(tf_prep)
	$(tf_plan)
	$(tf_apply)

state:
	terraform state pull | python -c 'import sys, yaml, json; j=json.loads(sys.stdin.read()); print yaml.safe_dump(j)'
