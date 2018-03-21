# ansible-role-nfsv4-server-freebsd

Manages NFSv4 server daemons on FreeBSD.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `nfsv4_server_freebsd_exports_file` | Path to `exports(5)` | `/etc/exports` |
| `nfsv4_server_freebsd_exports` | Content of `exports(5)` | `""` |
| `nfsv4_server_freebsd_nfsuserd_enable` | Enable `nfsuserd(8)` when `yes` | `yes` |
| `nfsv4_server_freebsd_nfsuserd_flags` | Arguments to `nfsuserd(8)` | `""` |
| `nfsv4_server_freebsd_mountd_flags` | Arguments to `mountd(8)` | `""` |
| `nfsv4_server_freebsd_rpcbind_flags` | Arguments to `rpcbind(8)` | `""` |
| `nfsv4_server_freebsd_nfsd_flags` | Arguments to `nfsd(8)` | `""` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-nfsv4-server-freebsd
  vars:
    nfsv4_server_freebsd_mountd_flags: -r -S -l
    nfsv4_server_freebsd_rpcbind_flags: "-h {{ ansible_default_ipv4.address }}"
    nfsv4_server_freebsd_nfsd_flags: "-u -t -h {{ ansible_default_ipv4.address }} -n 6"
    nfsv4_server_freebsd_nfsuserd_flags: -domain example.org
    nfsv4_server_freebsd_exports: |
      V4: /usr/local
      /usr/local -sec=sys -ro -network {{ ansible_em0.ipv4[0].network }} -mask {{ ansible_em0.ipv4[0].netmask }}
```

# License

```
Copyright (c) 2018 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
