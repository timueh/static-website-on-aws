.PHONY: build_lambda, fmt, init, apply
pkg ?= pkg
lambda_folder ?= lambda-go
email ?= timueh@googlemail.com

build_lambda:
	rm ${pkg}.zip || true
	GOOS=linux GOARCH=amd64 go build -C ${lambda_folder} -o main main.go
	cd ${lambda_folder} && zip -X ../${pkg}.zip main
	openssl dgst -sha256 -binary pkg.zip | openssl enc -base64 > ${pkg}.zip.sha256

fmt:
	terraform fmt
	terraform validate

init:
	terraform init

apply: fmt
	terraform apply -var="subscription_email=${email}"