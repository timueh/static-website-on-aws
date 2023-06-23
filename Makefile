.PHONY: build_lambda, fmt, init, apply
pkg ?= pkg
lambda_folder ?= lambda-go

build_lambda:
	rm ${pkg}.zip || true
	GOOS=linux GOARCH=amd64 go build -C ${lambda_folder} -o main main.go
	cd ${lambda_folder} && zip ../${pkg}.zip main

fmt:
	terraform fmt
	terraform validate

init:
	terraform init

apply: fmt build_lambda
	terraform apply --auto-approve