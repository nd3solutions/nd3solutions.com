SRC=$(PWD)/src/
DEPLOY=$(PWD)/deploy/

.PHONY: prep
prep:
	mkdir -p $(PWD)/.bin
	wget -O $(PWD)/.bin/aws-vault https://github.com/99designs/aws-vault/releases/download/v4.7.1/aws-vault-linux-amd64
	chmod +x $(PWD)/.bin/aws-vault
	wget -O $(PWD)/.bin/aws-assume-role https://github.com/mitchelldavis/aws-assume-role/releases/download/v1.0.0/aws-assume-role_linux_amd64
	chmod +x $(PWD)/.bin/aws-assume-role
.PHONY: build
build:
	$(MAKE) -C $(SRC) build
.PHONY: test
test:
	$(MAKE) -C $(DEPLOY) deploy WORKSPACE=Testing
	$(MAKE) -C $(SRC) \
		DEPLOY_BUCKET="test.nd3solutions.com" \
		DEPLOY_ACCOUNT=080722658636 \
		DEPLOY_ROLE=OrganizationAccountAccessRole \
		ASSUME_ROLE=$(PWD)/.bin/aws-assume-role \
		deploy
	$(MAKE) -C $(SRC) DEPLOY_BUCKET="test.nd3solutions.com" test
	$(MAKE) -C $(DEPLOY) destroy
	$(MAKE) -C $(DEPLOY) deploy WORKSPACE=Testing
.PHONY: deploy
deploy:
	export WORKSPACE=Production
	$(MAKE) -C $(DEPLOY) deploy
	$(MAKE) -C $(SRC) \
		DEPLOY_BUCKET="www.nd3solutions.com" \
		DEPLOY_ACCOUNT=402591671293 \
		DEPLOY_ROLE=OrganizationAccountAccessRole \
		ASSUME_ROLE=$(PWD)/.bin/aws-assume-role \
		deploy
