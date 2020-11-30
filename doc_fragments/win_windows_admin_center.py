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
module: win_windows_admin_center
short_description: Manipulate the configuration of Windows Admin Center
author:
    - Stéphane Bilqué (@sbilque) Informatique CDC
description:
    - This Ansible role allows to change the Windows Admin Center configuration.
    - This role is a wrapper of the M(win_windows_admin_center) embedded module.
options:
    wac_pop_console_at_sm_launch:
        description:
            - Specifies whether the dialog box offering the option ty "Try managing servers with Windows Admin Center (WindowsAdminCenter)" opens when the console starts.
        type: bool
        choices: [ true, false ]
        default: false
    wac_open_server_manager_at_logon:
        description:
            - Specifies whether the Server Manager application opens automatically at logon.
            - When C(wac_open_server_manager_at_logon=false) will ensure the Server Manager application does not open when the end user logs on.
            - When C(wac_open_server_manager_at_logon=true) will ensure the Server Manager application opens when the end user logs on.
        type: bool
        choices: [ true, false ]
        default: false
    wac_open_initial_configuration_tasks_at_logon:
        description:
            - Specifies whether the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.
            - If it opens automatically, then the Server Manager will not open until the Initial Configuration Tasks application is closed.
            - When C(wac_open_initial_configuration_tasks_at_logon=false) will ensure the Initial Configuration Tasks application does not open automatically when the end user logs on for the first time.
            - When C(wac_open_initial_configuration_tasks_at_logon=true) will ensure the Initial Configuration Tasks application opens automatically when the end user logs on for the first time.
            - Depending the operating system, this setting is deprecated. Use I(wac_open_server_manager_at_logon) instead.
        type: bool
        choices: [ true, false ]
        default: false
'''

EXAMPLES = r'''
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
'''