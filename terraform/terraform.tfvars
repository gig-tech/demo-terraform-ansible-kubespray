# OVC Account name, your IYO account must have access to it.
account = "GIG demos"

# IYO client id and client secret.
client_id = ""
client_secret = ""

# G8 api url
server_url= "https://be-gnt-dc01-01.gig.tech"

# cloudspace name
cs_name = "demo-terraform-ansible-kubespray"

# image id of the image that will be used to create virtual machines
# Needs to be looked up through the admin interface
image_id = 53

# Needs to be looked up through the API!
# Size id (define how many cpus / ram )  you can get that from ovc first
# disk size in GB you can get that from ovc first
size_id = 3
disksize = 10

# The description of the VM
vm_description = "demo-terraform-ansible-kubespray"

master_count = 1
worker_count = 1
