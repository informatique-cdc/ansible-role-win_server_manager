# win_windows_admin_center - Manipulate the configuration of Windows Admin Center

## Synopsis

* This Ansible role allows to change the Windows Admin Center configuration.
* This role is a wrapper of the [win_windows_admin_center] embedded module.

## Parameters

| Parameter     | Choices/<font color="blue">Defaults</font> | Comments |
| ------------- | ---------|--------- |
|__wac_pop_console_at_sm_launch__<br><font color="purple">bool</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Indicates to pop-up the dialog box offering the option ty "Try managing servers with Windows Admin Center (WindowsAdminCenter)" |

## Examples

```yaml
---
- name: test the win_windows_admin_center role
  hosts: all
  gather_facts: false

  roles:
    - win_windows_admin_center
      vars:
        wac_pop_console_at_sm_launch: no

```

## Authors

* Stéphane Bilqué (@sbilque) Informatique CDC

## License

This project is licensed under the Apache 2.0 License.

See [LICENSE](LICENSE) to see the full text.
