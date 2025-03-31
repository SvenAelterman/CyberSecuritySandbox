// Component selection (by default, none are deployed)
deploy_bastion    = true
deploy_dc         = true
deploy_firewall   = true
deploy_natgw      = true
deploy_windows_vm = true

subscription_id_soc_sandbox = "00000000-0000-0000-0000-000000000000"

workload_name = "soc"
environment   = "sbx"
instance      = 1
location      = "eastus"

// Use this if you are unable or unwilling to use the data.http.runner_ip data source,
// which calls ipecho.net to get the public IP of the runner.
remote_access_ip = "1.2.3.4"
