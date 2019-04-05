#!/bin/sh

cd terraform
. iyo.env
terraform init
terraform plan
terraform apply
cd ..
