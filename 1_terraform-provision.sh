#!/bin/sh

. terraform/iyo.env # ". iyo.env" after "cd terraform" returned iyo.env not found on ubuntu
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
cd ..

echo "Login to the above machine's IP address with user ansible and port 2222"
