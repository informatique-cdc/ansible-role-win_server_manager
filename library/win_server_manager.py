#!/usr/bin/python
# -*- coding: utf-8 -*-

# This is a role documentation stub.

# Copyright 2020 Informatique CDC. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

from __future__ import absolute_import, division, print_function
__metaclass__ = type


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: win_server_manager
short_description: Manipulate the configuration of Server Manager
author:
    - Stéphane Bilqué (@sbilque) Informatique CDC
description:
    - This Ansible module allows to change the Windows Server Manager configuration.
options:
    pop_wac_console_at_sm_launch:
        description:
            - Specifies whether the dialog box offering the option ty "Try managing servers with Windows Admin Center (WindowsAdminCenter)" opens when the console starts.
        type: bool
        choices: [ true, false ]
    open_server_manager_at_logon:
        description:
            - Specifies whether the Server Manager application opens automatically at logon.
            - When C(open_server_manager_at_logon=false) will ensure the Server Manager application does not open when the end user logs on.
            - When C(open_server_manager_at_logon=true) will ensure the Server Manager application opens when the end user logs on.
        type: bool
        choices: [ true, false ]
    open_initial_configuration_tasks_at_logon:
        description:
            - Specifies whether the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.
            - If it opens automatically, then the Server Manager will not open until the Initial Configuration Tasks application is closed.
            - When C(open_initial_configuration_tasks_at_logon=false) will ensure the Initial Configuration Tasks application does not open automatically when the end user logs on for the first time.
            - When C(open_initial_configuration_tasks_at_logon=true) will ensure the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.
            - Depending the operating system, this setting is deprecated. Use I(open_server_manager_at_logon) instead.
        type: bool
        choices: [ true, false ]
'''

EXAMPLES = r'''
---
- name: test the win_server_manager module
  hosts: all
  gather_facts: false

  roles:
    - win_server_manager

  tasks:
    - name: Disable the message "Try managing servers with Windows Admin Center".
      win_server_manager:
        pop_wac_console_at_sm_launch: false

    - name: Specifies that the Server Manager application does not open automatically at logon.
      win_server_manager:
        open_server_manager_at_logon: false

    - name: Specifies that the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.
      win_server_manager:
        open_initial_configuration_tasks_at_logon: false
'''

RETURN = r'''
config:
    description: Detailed information about Windows Admin Center.
    returned: always
    type: dict
    contains:
        pop_wac_console_at_sm_launch:
            description:
                - Indicates whether the dialog box offering the option ty "Try managing servers with Windows Admin Center (WindowsAdminCenter)" opens the end user opens the console.
            type: bool
            returned: always
            sample: true
        open_server_manager_at_logon:
            description:
                - Indicates whether the Server Manager application opens automatically at logon for all users.
            type: bool
            returned: always
            sample: true
        open_initial_configuration_tasks_at_logon:
            description:
                - Indicates whether the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.
            type: bool
            returned: always
            sample: true
        checked_unattend_launch_setting:
            description:
                - Indicates whether Server Manager is disabled for the current user.
            type: bool
            returned: always
            sample: true
'''