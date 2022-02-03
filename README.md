# Ansible Role: my_common_defaults

My Common Defaults for Red Hat and Debian based OS.

## Requirements

None

## Role Variables

Basic settings:

```yaml
ntp_servers:
  - 0.centos.pool.ntp.org
  - 1.centos.pool.ntp.org
```

## Dependencies

None.

## Example Playbook

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  become: yes

  roles:
    - my_common_defaults
```

## License

MIT

## Author Information

This role was created in 2016 by [petr.ruzicka@gmail.com](mailto:petr.ruzicka@gmail.com)
