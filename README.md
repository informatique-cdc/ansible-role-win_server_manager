# win_server_manager - Manipulate the configuration of Server Manager

## Synopsis

* This Ansible role allows to change the Server Manager configuration.
* This role is a wrapper of the [win_server_manager] embedded module.

## Parameters

| Parameter     | Choices/<font color="blue">Defaults</font> | Comments |
| ------------- | ---------|--------- |
|__wsm_pop_console_at_sm_launch__<br><font color="purple">bool</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Specifies whether the dialog box offering the option ty "Try managing servers with Windows Admin Center (WindowsAdminCenter)" opens when the console starts. |
|__wsm_open_server_manager_at_logon__<br><font color="purple">bool</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Specifies whether the Server Manager application opens automatically at logon.<br>When `wsm_open_server_manager_at_logon=false` will ensure the Server Manager application does not open when the end user logs on.<br>When `wsm_open_server_manager_at_logon=true` will ensure the Server Manager application opens when the end user logs on. |
|__wsm_open_initial_configuration_tasks_at_logon__<br><font color="purple">bool</font></font> | __Choices__: <ul><li><font color="blue">__no &#x2190;__</font></li><li>yes</li></ul> | Specifies whether the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.<br>If it opens automatically, then the Server Manager will not open until the Initial Configuration Tasks application is closed.<br>When `wsm_open_initial_configuration_tasks_at_logon=false` will ensure the Initial Configuration Tasks application does not open automatically when the end user logs on for the first time.<br>When `wsm_open_initial_configuration_tasks_at_logon=true` will ensure the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.<br>Depending the operating system, this setting is deprecated. Use _wsm_open_server_manager_at_logon_ instead. |

## Examples

```yaml
---
- name: test the win_server_manager role
  hosts: all
  gather_facts: false

  roles:
    - role: win_server_manager
      vars:
        wsm_pop_console_at_sm_launch: no
        wsm_open_server_manager_at_logon: no
        wsm_open_initial_configuration_tasks_at_logon: no

```

## Authors

* Stéphane Bilqué (@sbilque) Informatique CDC

## License

This project is licensed under the Apache 2.0 License.

See [LICENSE](LICENSE) to see the full text.
