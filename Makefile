.PHONY: build_lambda, apply
pkg ?= pkg
lambda_folder ?= lambda-go
email ?= timueh@googlemail.com

build_lambda:
	rm ${pkg}.zip || true
	GOOS=linux GOARCH=amd64 go build -C ${lambda_folder} -o main main.go
	cd ${lambda_folder} && zip ../${pkg}.zip main

fmt:
	terraform fmt
	terraform validate

apply: fmt build_lambda
	terraform apply --auto-approve -var="subscription_email=${email}"