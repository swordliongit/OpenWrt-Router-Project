# -*- coding: utf-8 -*-

from datetime import datetime, timedelta

import requests
from odoo import models, fields, api, exceptions, _
import logging
from threading import Thread, Timer

_logger = logging.getLogger(__name__)


class Modem(models.Model):
    _name = "modem.profile"

    name = fields.Char(string="Name", default="artinmodem", required="True")
    uptime = fields.Char(string="Uptime")
    # wireless_status = fields.Char(string="Wireless Status")
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
    subnet = fields.Char(string="Subnet")
    gateway = fields.Char(string="Gateway")
    dhcp_server = fields.Boolean(string="DHCP Server")
    dhcp_client = fields.Boolean(string="DHCP Client")
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
    # manual_time = fields.Char(string="Manual Time")
    new_password = fields.Char(string="New Password")
    update_date = fields.Char(string="Güncellenme Tarihi")
    reboot = fields.Boolean(string="Reboot")
    site = fields.Many2one("modem.profile.site", string="Site")
    lostConnection = fields.Boolean(string="Lost Connection")
    last_heartbeat_date = fields.Char("Last Heartbeat Received")
    upgrade = fields.Boolean(string="Upgrade Firmware")
    vlanId = fields.Char(string="Vlan Id", default="1", required="True")
    ram = fields.Char(string="RAM")
    cpu = fields.Char(string="CPU")
    disk = fields.Char(string="Disk")
    log = fields.Binary(string="Log Data", widget="attachment", attachment=True)
    log_filename = fields.Char(string="Log File Name")
    lastTimeLogTrimmed = fields.Char(string="Last Time Log Trimmed")
    terminal = fields.Char(string="Remote Terminal")
    monitor = fields.Binary(string="Remote Monitor", widget="attachment", attachment=True)
    advanced = fields.Boolean(string="Gelişmiş")
    firmwareVersion = fields.Char(string="Firmware")
    modem_lock = fields.Boolean(string="Lock Modem")

    context_changed = fields.Boolean(string="Context Changed")
    show_warning = fields.Boolean(string="Show Warning")

    # OVERRIDERS

    # Called on Save if there's change of field values
    def write(self, values):
        # for field, new_value in values.items():
        # _logger.info(f"Field {field} is being updated with the value {new_value}")
        changed_fields = list(values.keys())
        if (
            not 'modem_lock' in changed_fields
            and not 'lostConnection' in changed_fields
            and not 'last_heartbeat_date' in changed_fields
            and not 'context_changed' in changed_fields
            and not 'show_warning' in changed_fields
            and not 'uptime' in changed_fields
        ):
            # _logger.info("X" * 50)
            # _logger.info(changed_fields)
            # _logger.info("X" * 50)
            values['context_changed'] = True
            return super(Modem, self).write(values)
        else:
            return super(Modem, self).write(values)

    # def unlink(self):
    #     raise exceptions.UserError("Modem Silemezsiniz.")

    ...
    # @ Scheduled Action (Active, 35s) -> Cloud Master Modem - Connection Checker
    # list_modems = env["modem.profile"].search([("lostConnection", "=", False)])
    # for modem in list_modems:
    #     last_heartbeat_date = datetime.datetime.strptime(modem.last_heartbeat_date, "%d-%m-%Y %H:%M:%S")
    #     # _logger.info("\n\n\n" + str(update_date) + "\n\n\n")
    #     current_datetime = datetime.datetime.now() + datetime.timedelta(hours=3)

    #     # Format current_datetime to match the format of update_date
    #     current_datetime_formatted = current_datetime.strftime("%Y-%m-%d %H:%M:%S")
    #     # _logger.info("\n\n\n" + str(current_datetime_formatted) + "\n\n\n")

    #     # Calculate the time difference in seconds
    #     time_difference = (
    #         datetime.datetime.strptime(current_datetime_formatted, "%Y-%m-%d %H:%M:%S") - last_heartbeat_date
    #     ).total_seconds()

    #     log(str(modem.mac) + " " + str(time_difference), level="info")

    #     if abs(time_difference) > 35:
    #         modem["lostConnection"] = True

    # MODEL METHODS

    @api.model
    def lock_modem(self):
        active_ids = self.env.context.get("active_ids", [])
        modems = self.env["modem.profile"].browse(active_ids)

        for modem in modems:
            modem["modem_lock"] = True

    @api.model
    def unlock_modem(self):
        active_ids = self.env.context.get("active_ids", [])
        modems = self.env["modem.profile"].browse(active_ids)

        for modem in modems:
            modem["modem_lock"] = False
            if modem['context_changed']:
                modem['show_warning'] = True

    # EVENTS

    @api.onchange("site")
    def apply_site(self):
        # _logger = logging.getLogger(__name__)
        site = self.env["modem.profile.site"].sudo().search([("id", "=", self.site.id)], limit=1)
        # _logger.info("\n\n\n\n\n" + "X" * 50 + "\n\n\n\n\n")
        # _logger.info(str(site) + " " + str(site.name))
        # _logger.info("\n\n\n\n\n" + "X" * 50 + "\n\n\n\n\n")
        self.sudo().write(
            {
                "channel": site.channel,
                "enable_wireless": site.enable_wireless,
                "ssid1": site.ssid1,
                "ssid2": site.ssid2,
                "ssid3": site.ssid3,
                "enable_ssid1": site.enable_ssid1,
                "enable_ssid2": site.enable_ssid2,
                "enable_ssid3": site.enable_ssid3,
                "passwd_1": site.passwd_1,
                "passwd_2": site.passwd_2,
                "passwd_3": site.passwd_3,
                "vlanId": site.vlanId,
            }
        )

    # METHODS

    def check_context(self):
        if self.context_changed:
            self.show_warning = True

    def gif_dummy(self):
        pass

        # # Your Python code here

        # # Choose or define a channel and notification type
        # channel = 'record_updates'
        # notification_type = 'record_updated'
        # # Example data to include in the notification payload
        # record_id = 123
        # record_name = 'Sample Record'

        # # Construct the dictionary with relevant parameters
        # dict_parameters = {
        #     'record_id': record_id,
        #     'record_name': record_name,
        # }
        # # Send a notification to trigger the JavaScript function
        # self.env['bus.bus']._sendone(channel, notification_type, dict_parameters)

    # @ Automated Action ( Active ) -> Apply Site to Created Modems
    # site = env["modem.profile.site"].search([("id", "=", record.site.id)], limit=1)
    # record.write(
    #     {
    #         "channel": site.channel,
    #         "enable_wireless": site.enable_wireless,
    #         "ssid1": site.ssid1,
    #         "ssid2": site.ssid2,
    #         "ssid3": site.ssid3,
    #         "enable_ssid1": site.enable_ssid1,
    #         "enable_ssid2": site.enable_ssid2,
    #         "enable_ssid3": site.enable_ssid3,
    #         "passwd_1": site.passwd_1,
    #         "passwd_2": site.passwd_2,
    #         "passwd_3": site.passwd_3,
    #         "vlanId": site.vlanId,
    #     }
    # )
    ...
    # @ Automated Action ( Active ) -> Log Trimmer Time Updater
    # date_text = record.lastTimeLogTrimmed

    # if date_text != "Log not trimmed yet":
    #     initial_date = datetime.datetime.strptime(date_text, "%Y-%m-%d %H:%M:%S")
    #     # Add 3 hours to the initial date
    #     result_date = initial_date + datetime.timedelta(hours=3)
    #     # Format the result as a string
    #     result_text = result_date.strftime("%Y-%m-%d %H:%M:%S")
    #     record["lastTimeLogTrimmed"] = result_text


class Site(models.Model):
    _name = "modem.profile.site"

    name = fields.Char(string="Name", required="True")

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
    enable_wireless = fields.Boolean(string="Enable Wireless")
    ssid1 = fields.Char(string="SSID1")
    ssid2 = fields.Char(string="SSID2")
    ssid3 = fields.Char(string="SSID3")
    enable_ssid1 = fields.Boolean(string="Enable SSID1")
    enable_ssid2 = fields.Boolean(string="Enable SSID2")
    enable_ssid3 = fields.Boolean(string="Enable SSID3")
    passwd_1 = fields.Char(string="SSID1 Password")
    passwd_2 = fields.Char(string="SSID2 Password")
    passwd_3 = fields.Char(string="SSID3 Password")
    vlanId = fields.Char(string="Vlan Id", default="1", required="True")
    modems_locked = fields.Boolean(string="Modems Locked")

    # OVERRIDERS

    def write(self, values):
        # Prevent editing the base record
        if self.name == "artinsite":
            raise exceptions.UserError("Varsayılan Site Değiştirilemez")
        else:
            modems = self.env["modem.profile"].sudo().search([("site.id", "=", self.id)])
            operation_in_progress = [modem.show_warning for modem in modems]
            if any(operation_in_progress):
                raise exceptions.UserError(
                    "Bu Site'a bağlı olan ve henüz değişikliği bitmemiş modemler var. Lütfen operasyonun bitmesini bekleyin."
                )
            else:
                return super(Site, self).write(values)

    def unlink(self):
        # Prevent deletion of the base record
        if self.name == "artinsite":
            # return super(Site, self).unlink()
            raise exceptions.UserError("Varsayılan Site silinemez")
        else:
            modems = self.env["modem.profile"].sudo().search([("site.id", "=", self.id)])
            if modems:
                raise exceptions.UserError(
                    "Bu Site'ı silmek için ilk önce bu Site'a bağlı olan modemleri başka bir Site'a taşıyın"
                )
            else:
                return super(Site, self).unlink()

    # METHODS

    def apply_site_options(self):
        modems = self.env["modem.profile"].sudo().search([("site.id", "=", self.id)])

        site_fields = [
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
        ]
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
            ]

            if modem_fields != site_fields:
                modem.write(
                    {
                        "channel": self.channel,
                        "enable_wireless": self.enable_wireless,
                        "ssid1": self.ssid1,
                        "ssid2": self.ssid2,
                        "ssid3": self.ssid3,
                        "enable_ssid1": self.enable_ssid1,
                        "enable_ssid2": self.enable_ssid2,
                        "enable_ssid3": self.enable_ssid3,
                        "passwd_1": self.passwd_1,
                        "passwd_2": self.passwd_2,
                        "passwd_3": self.passwd_3,
                        "vlanId": self.vlanId,
                    }
                )
            modem.check_context()

    def gif_dummy(self):
        pass
