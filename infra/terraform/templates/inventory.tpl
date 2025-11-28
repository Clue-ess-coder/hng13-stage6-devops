[microservices]
${server_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_key_path}

[microservices:vars]
ansible_python_interpreter=/usr/bin/python3
domain_name=${domain_name}
acme_email=${acme_email}
git_repo_url=${git_repo_url}
git_branch=${git_branch}
jwt_secret=${jwt_secret}
