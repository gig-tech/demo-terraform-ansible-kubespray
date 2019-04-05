#!/bin/sh

cd terraform
. iyo.env
terraform init
terraform plan
terraform apply -auto-approve
cd ..

echo "Login to the above machine's IP address with user ansible and port 2222"
