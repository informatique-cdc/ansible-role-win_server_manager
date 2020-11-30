# win_windows_admin_center - Manipulate the configuration of Windows Admin Center

## Synopsis

* This Ansible role allows to change the Windows Admin Center configuration.
* This role is a wrapper of the [win_windows_admin_center] embedded module.

## Parameters

| Parameter     | Choices/<font color="blue">Defaults</font> | Comments |
| ------------- | ---------|--------- |
|__wac_pop_console_at_sm_launch__<br><font color="purple">bool</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Specifies whether the dialog box offering the option ty "Try managing servers with Windows Admin Center (WindowsAdminCenter)" opens when the console starts. |
|__wac_open_server_manager_at_logon__<br><font color="purple">bool</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Specifies whether the Server Manager application opens automatically at logon.<br>When `open_server_manager_at_logon=false` will ensure the Server Manager application does not open when the end user logs on.<br>When `open_server_manager_at_logon=true` will ensure the Server Manager application opens when the end user logs on. |
|__wac_open_initial_configuration_tasks_at_logon__<br><font color="purple">bool</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Specifies whether the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.<br>If it opens automatically, then the Server Manager will not open until the Initial Configuration Tasks application is closed.<br>When `open_initial_configuration_tasks_at_logon=false` will ensure the Initial Configuration Tasks application does not open automatically when the end user logs on for the first time.<br>When `open_initial_configuration_tasks_at_logon=true` will ensure the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.<br>Depending the operating system, this setting is deprecated. Use _wac_open_server_manager_at_logon_ instead. |

## Examples

```yaml
---
- name: test the win_windows_admin_center role
  hosts: all
  gather_facts: false

  roles:
    - role: win_windows_admin_center
      vars:
        wac_pop_console_at_sm_launch: no
        wac_open_server_manager_at_logon: no
        wac_open_initial_configuration_tasks_at_logon: no

```

## Authors

* Stéphane Bilqué (@sbilque) Informatique CDC

## License

This project is licensed under the Apache 2.0 License.

See [LICENSE](LICENSE) to see the full text.
