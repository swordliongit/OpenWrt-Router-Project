# -*- coding: utf-8 -*-
import logging
from odoo import models, fields, api, _
from odoo.exceptions import UserError

_logger = logging.getLogger(__name__)
import base64


class ModemWizard(models.TransientModel):
    _name = "modem.wizard"
    _description = "Modem Wizard"

    name = fields.Char(string="Name", default="artinmodem", required="True")
    uptime = fields.Char(string="Uptime")
    # ip = fields.Char(string="IP")
    # subnet = fields.Char(string="Subnet")
    # gateway = fields.Char(string="Gateway")
    # dhcp_server = fields.Boolean(string="DHCP Server")
    # dhcp_client = fields.Boolean(string="DHCP Client")
    channel = fields.Selection(
        selection=[
            ('auto', "Auto"),
            ('1', "1"),
            ('2', "2"),
            ('3', "3"),
            ('4', "4"),
            ('5', "5"),
            ('6', "6"),
            ('7', "7"),
            ('8', "8"),
            ('9', "9"),
            ('10', "10"),
            ('11', "11"),
            ('12', "12"),
            ('13', "13"),
        ],
        string="Wireless Channel",
        default="auto",
        required="True",
    )
    mac = fields.Char(string="MAC")
    device_info = fields.Char(string="Device Info")
    ip = fields.Char(string="IP")
    enable_wireless = fields.Boolean(string="Enable Wireless")
    ssid1 = fields.Char(string="SSID1")
    ssid2 = fields.Char(string="SSID2")
    ssid3 = fields.Char(string="SSID3")
    enable_ssid1 = fields.Boolean(string="Enable SSID1")
    enable_ssid2 = fields.Boolean(string="Enable SSID2")
    enable_ssid3 = fields.Boolean(string="Enable SSID3")
    passwd_1 = fields.Char(string="SSID1 Password", default="")
    passwd_2 = fields.Char(string="SSID2 Password", default="")
    passwd_3 = fields.Char(string="SSID3 Password", default="")
    update_date = fields.Char(string="Güncellenme Tarihi")
    reboot = fields.Boolean(string="Reboot")
    site = fields.Many2one("modem.profile.site", string="Site", default="artinsite", required="True")
    lostConnection = fields.Boolean(string="Lost Connection")
    last_heartbeat_date = fields.Char("Last Heartbeat Received")
    upgrade = fields.Boolean(string="Upgrade Firmware")
    vlanId = fields.Char(string="Vlan Id", default="1", required="True")
    ram = fields.Char(string="RAM")
    cpu = fields.Char(string="CPU")
    disk = fields.Char(string="Disk")
    lastTimeLogTrimmed = fields.Char(string="Last Time Log Trimmed")
    terminal = fields.Char(string="Remote Terminal")
    firmwareVersion = fields.Char(string="Firmware")
    modem_lock = fields.Boolean(string="Lock Modem")

    context_changed = fields.Boolean(string="Context Changed")
    show_warning = fields.Boolean(string="Show Warning")

    # def fields_view_get(self, view_id=None, view_type="form", toolbar=False, submenu=False):
    #     res = super(ModemWizard, self).fields_view_get(
    #         view_id=view_id, view_type=view_type, toolbar=toolbar, submenu=submenu
    #     )
    #     active_ids = self.env.context.get("active_ids", [])
    #     modems = self.env["modem.profile"].browse(active_ids)

    @api.model
    def default_get(self, fields):
        defaults = super(ModemWizard, self).default_get(fields)

        active_ids = self.env.context.get("active_ids", [])
        # if len(active_ids) == 1:
        # Read active_id from context
        active_id = self.env.context.get('default_active_id')
        if active_id:
            # Fetch the selected record
            modem = self.env["modem.profile"].browse(active_id)
            # Set values as default
            defaults['name'] = modem.name
            defaults['site'] = modem.site.id
            defaults['update_date'] = modem.update_date
            defaults['uptime'] = modem.uptime
            defaults['channel'] = modem.channel
            defaults['mac'] = modem.mac
            defaults['ip'] = modem.ip
            defaults['device_info'] = modem.device_info
            defaults['enable_wireless'] = modem.enable_wireless
            defaults['ssid1'] = modem.ssid1
            defaults['ssid2'] = modem.ssid2
            defaults['ssid3'] = modem.ssid3
            defaults['enable_ssid1'] = modem.enable_ssid1
            defaults['enable_ssid2'] = modem.enable_ssid2
            defaults['enable_ssid3'] = modem.enable_ssid3
            defaults['passwd_1'] = modem.passwd_1
            defaults['passwd_2'] = modem.passwd_2
            defaults['passwd_3'] = modem.passwd_3
            defaults['vlanId'] = modem.vlanId
            defaults['ram'] = modem.ram
            defaults['cpu'] = modem.cpu
            defaults['disk'] = modem.disk
            defaults['lastTimeLogTrimmed'] = modem.lastTimeLogTrimmed
            defaults['firmwareVersion'] = modem.firmwareVersion

        return defaults

    # def reject_modem_information(self):
    #     active_ids = self.env.context.get("active_ids", [])
    #     modems = self.env["modem.profile"].browse(active_ids)
    #     for modem in modems:
    #         self.env['modem.profile'].sudo().unlock_modem()
    #     return {"type": "ir.actions.act_window_close"}

    # wizard's save button
    def update_modem_information(self):
        # find active modems
        active_ids = self.env.context.get("active_ids", [])
        modems = self.env["modem.profile"].browse(active_ids)
        # _logger.info("X" * 50 + "\n" + str(self) + "\n" + "X" * 50)

        wizard_fields = [
            self.channel,
            self.enable_wireless,
            self.ssid1,
            self.ssid2,
            self.ssid3,
            self.enable_ssid1,
            self.enable_ssid2,
            self.enable_ssid3,
            self.passwd_1,
            self.passwd_2,
            self.passwd_3,
            self.vlanId,
            self.reboot,
            self.upgrade,
        ]

        # ip_lastdigit_shifter = 0
        for modem in modems:
            modem_fields = [
                modem.channel,
                modem.enable_wireless,
                modem.ssid1,
                modem.ssid2,
                modem.ssid3,
                modem.enable_ssid1,
                modem.enable_ssid2,
                modem.enable_ssid3,
                modem.passwd_1,
                modem.passwd_2,
                modem.passwd_3,
                modem.vlanId,
                modem.reboot,
                modem.upgrade,
            ]
            if modem_fields != wizard_fields:
                modem.write(
                    {
                        # 'ip': ip_digits[0] + '.' + ip_digits[1] + '.' + ip_digits[2] + '.' + str(int(ip_digits[3])+ip_lastdigit_shifter),
                        # 'subnet': self.subnet if self.subnet != False else modem.subnet,
                        # 'gateway': self.gateway if self.gateway != False else modem.gateway,
                        # 'dhcp_server': self.dhcp_server if self.dhcp_server != False else modem.dhcp_server,
                        # 'dhcp_client': self.dhcp_client if self.dhcp_client != False else modem.dhcp_client,
                        "channel": self.channel,
                        "enable_wireless": self.enable_wireless,
                        "ssid1": self.ssid1,
                        "ssid2": self.ssid2,
                        "ssid3": self.ssid3,
                        # 'ssid4': self.ssid4 if self.ssid4 != False else modem.ssid4,
                        "enable_ssid1": self.enable_ssid1,
                        "enable_ssid2": self.enable_ssid2,
                        "enable_ssid3": self.enable_ssid3,
                        # 'enable_ssid4': self.enable_ssid4 if self.enable_ssid4 != False else modem.enable_ssid4,
                        "passwd_1": self.passwd_1,
                        "passwd_2": self.passwd_2,
                        "passwd_3": self.passwd_3,
                        "vlanId": self.vlanId,
                        "upgrade": self.upgrade,
                        "terminal": self.terminal,
                        # 'passwd_4': self.passwd_4 if self.passwd_4 != False else modem.passwd_4,
                        # 'manual_time': self.manual_time,
                        # 'new_password': self.new_password if self.new_password != False else modem.new_password,
                        "upgrade": self.upgrade,
                        "reboot": self.reboot,
                    }
                )
            modem.check_context()
        # close the wizard
        return {"type": "ir.actions.act_window_close"}
