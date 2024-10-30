# -*- coding: utf-8 -*-
from odoo import models, fields, api


class ModemWizardSpecific(models.TransientModel):
    _name = "modem.wizard.specific"
    _description = "Modem Wizard Specific"

    action = fields.Selection(
        selection=[
            ('enable_wireless', "Enable Wireless"),
            ('disable_wireless', "Disable Wireless"),
            ('enable_ssid1', "Enable SSID1"),
            ('disable_ssid1', "Disable SSID1"),
            ('enable_ssid2', "Enable SSID2"),
            ('disable_ssid2', "Disable SSID2"),
            ('enable_ssid3', "Enable SSID3"),
            ('disable_ssid3', "Disable SSID3"),
            ('upgrade', "Upgrade Firmware"),
            ('reboot', "Reboot"),
        ],
        string="Alan Seçin",
        default="enable_wireless",
        required="True",
    )

    # wizard's save button
    def update_modem_specific_information(self):
        # find active modems
        active_ids = self.env.context.get("active_ids", [])
        modems = self.env["modem.profile"].browse(active_ids)
        for modem in modems:
            if self.action == 'enable_wireless':
                if not modem.enable_wireless:
                    modem.enable_wireless = True
            elif self.action == 'disable_wireless':
                if modem.enable_wireless:
                    modem.enable_wireless = False
            elif self.action == 'enable_ssid1':
                if not modem.enable_ssid1:
                    modem.enable_ssid1 = True
            elif self.action == 'disable_ssid1':
                if modem.enable_ssid1:
                    modem.enable_ssid1 = False
            elif self.action == 'enable_ssid2':
                if not modem.enable_ssid2:
                    modem.enable_ssid2 = True
            elif self.action == 'disable_ssid2':
                if modem.enable_ssid2:
                    modem.enable_ssid2 = False
            elif self.action == 'enable_ssid3':
                if not modem.enable_ssid3:
                    modem.enable_ssid3 = True
            elif self.action == 'disable_ssid3':
                if modem.enable_ssid3:
                    modem.enable_ssid3 = False
            elif self.action == 'upgrade':
                modem.upgrade = True
            elif self.action == 'reboot':
                modem.reboot = True

            modem.check_context()
        # close the wizard
        return {"type": "ir.actions.act_window_close"}
