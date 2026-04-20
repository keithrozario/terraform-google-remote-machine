# Private Remote Server on GCP

GCP has this amazing feature called `iap-tunnel` that is enabled in `gcloud`. This allows you to create a private tunnel from your local machine to a remote machine on GCP without granting the remote machine an internet/external ip.

The tunnel also works with regular GCP credentials, so we don't use ssh keys or anything else. We login to the remote using our regular GCP credentials.

This means the remote is fully secure from a network (no external ip) and identity (no static passwords) perspective. The tunnel emulates ssh completely (unlike session manager in AWS), and is complete enough for us to even use it as a vscode remote.

This project:

* Creates a VPC Network
* Creates a NAT router on the network
* Creates a special subnetwork in a region
* Deploys an ubuntu compute instance on the subnetwork
* Enables firewall rules for the IAP service to access the ubuntu compute instance (port 22, and port 8080)
* Has a example `~/.ssh/config` file for your configuration

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where resources will be created | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region where resources will be deployed | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The GCP zone where compute instances will be deployed | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources created by this module | `string` | `"remote-machine"` | no |
| <a name="input_network"></a> [network](#input\_network) | The self-link or name of an existing VPC network. If null, a new network and subnet are created automatically | `string` | `null` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The self-link or name of an existing subnetwork. Required when `network` is provided; ignored when `network` is null | `string` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | The CIDR range for the auto-created subnet. Only used when `network` is null | `string` | `"10.0.0.0/16"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type for compute instances | `string` | `"e2-standard-2"` | no |
| <a name="input_image"></a> [image](#input\_image) | The source image family or self-link for the instance boot disk | `string` | `"ubuntu-os-cloud/ubuntu-2504-amd64"` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | The size of the boot disk in GB | `number` | `50` | no |
| <a name="input_disk_iops"></a> [disk\_iops](#input\_disk\_iops) | Provisioned IOPS for the boot disk. Only valid for hyperdisk disk types; leave null for standard persistent disks | `number` | `null` | no |
| <a name="input_disk_throughput"></a> [disk\_throughput](#input\_disk\_throughput) | Provisioned throughput in MB/s for the boot disk. Only valid for hyperdisk disk types; leave null for standard persistent disks | `number` | `null` | no |
| <a name="input_static_ip"></a> [static\_ip](#input\_static\_ip) | Static internal IP address for the primary instance. If null, an IP is assigned automatically | `string` | `null` | no |
| <a name="input_allowed_ports"></a> [allowed\_ports](#input\_allowed\_ports) | TCP ports opened through the IAP firewall when the network is auto-created. Defaults to SSH only | `list(number)` | `[22]` | no |
| <a name="input_create_windows_instance"></a> [create\_windows\_instance](#input\_create\_windows\_instance) | Whether to create a secondary compute instance alongside the primary | `bool` | `true` | no |
| <a name="input_schedule_timezone"></a> [schedule\_timezone](#input\_schedule\_timezone) | The IANA timezone for the weekday start/stop schedule (e.g. `Asia/Singapore`, `America/New_York`) | `string` | `"Asia/Singapore"` | no |
| <a name="input_enable_apis"></a> [enable\_apis](#input\_enable\_apis) | Whether to enable required GCP APIs. Set to false if APIs are already enabled or managed externally | `bool` | `true` | no |

# Installation

Modify `variables.tf` to change the region and stack_name, then:

 tf init
 tf apply --auto-approve

Modify `config` below and then paste into your own location, on macOS this is typically `~/.ssh/config`.

    Host krozario.remote.machine
        HostName <PRIVATE_IP_ADDRESS>
        IdentityFile ~/.ssh/google_compute_engine
        UserKnownHostsFile ~/.ssh/google_compute_known_hosts
        ProxyCommand gcloud compute start-iap-tunnel "<INSTANCE_NAME>" %p --listen-on-stdin --project "<PROJECT_ID>" --zone=<ZONE_NAME> --verbosity=warning
     StrictHostKeyChecking no
     User <USERNAME_REPLACE_ALL_@_AND_DOT_WITH_UNDERSCORE> # e.g. k@k.com ==> k_k_com

# Usage

 ssh <hostname>

Because it works like normal ssh, you can even use remote VSCode for this, the host will appear when you try to logon to a remote machine because it references the ssh config file.

# Port Binding

Sometimes you want to bind ports on the remote to your local, so you can host webserver on the remote and access it via localhost on your local:

 $ gcloud compute start-iap-tunnel remote-machine 8080 \
   --local-host-port=localhost:8080 \
   --zone=<ZONE_NAME> \
   --project=<PROJECT_ID>

Because of the firewall rules set via terraform only port 8080 is open for now. You can modify this if you want to bind another port on the remote by changing the firewall rules to allow other ports for the IAP access.

## Windows

A note on windows, for Windows, we bind port 3389. We also set the password using the following command:

    gcloud compute reset-windows-password remote-machine-windows --project=remote-machine-b7af52b6 --zone=asia-southeast1-a

Then we create a iap tunnel and bind to our localhost:

    $ gcloud compute start-iap-tunnel remote-machine-windows 3389 \
    --local-host-port=localhost:3389 \
    --zone=<ZONE_NAME>  \
    --project=<PROJECT_ID>

Finally using the windows app on MacOS (or some other RDP client), we connect to localhost:3389

## Extra: Updating MOTD

On Linux boxes like Ubuntu we can update the "message of the day" so that the port binding instructions are printed directly when you login. If you run `99-get-gcp-info`, you'll get the required port binding command for your local straight from the VM (without needing to check zones or project IDs), my preferred option is to copy this file to `/etc/update-motd.d/` to display this message on every logon. That way I don't have to remember anything.


