All this content comes from https://github.com/jtudelag/ocp4-abi-installation/blob/main/roles/install-vsphere/README.md.


https://access.redhat.com/articles/6393361

```bash
pip3 install --user -r ./requirements.txt

ansible-galaxy install -r requirements.yml

ansible-playbook -vvv -i inventory create-vms.yaml
```

