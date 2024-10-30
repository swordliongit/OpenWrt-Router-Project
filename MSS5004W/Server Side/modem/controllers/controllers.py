# -*- coding: utf-8 -*-
from datetime import datetime
from odoo import http
import pytz
import logging
import requests
import json
import base64
import tempfile
import os

_logger = logging.getLogger(__name__)


class CloudController(http.Controller):
    @http.route('/cc/heartbeat', type='json', auth='none', methods=['POST'])
    def heartbeat_receiver(self):
        # Process the ping status
        # _logger.info("X" * 50 + "\n" + str(heartbeat) + "\n" + "X" * 50)
        heartbeat = json.loads(http.request.httprequest.data)
        if heartbeat.get('success'):
            modem = http.request.env["modem.profile"].sudo().search([("mac", "=", heartbeat.get("mac"))], limit=1)
            if modem:
                Turkiye_timezone = pytz.timezone("Europe/Istanbul")
                current_time = datetime.now(tz=Turkiye_timezone)
                formatted_time = current_time.strftime("%d-%m-%Y %H:%M:%S")
                modem.sudo().write(
                    {
                        'lostConnection': False,
                        'last_heartbeat_date': formatted_time,
                        'uptime': heartbeat.get("uptime"),
                    }
                )
            else:
                return {'status': "modem not found in database"}
            return {'status': 'ok'}
        else:
            return {'status': 'failed'}

    @http.route(["/cc/read_record"], type="json", auth="public", methods=["POST"], cors="*", csrf=False)
    def read_receiver(self):
        wanted_fields = json.loads(http.request.httprequest.data)
        # {"fields":["name","site","channel","enable_wireless","ssid1","passwd_1","ssid2","passwd_2","ssid3","passwd_3","enable_ssid1","enable_ssid2","enable_ssid3","new_password","reboot","upgrade","vlanId","terminal"],"mac":"1c:18:4a:3b:e2:3"}
        modem_existing = (
            http.request.env["modem.profile"].sudo().search([("mac", "=", wanted_fields.get("mac"))], limit=1)
        )
        if modem_existing:
            response_payload = {}
            if modem_existing.modem_lock == False:
                for field in wanted_fields.get("fields"):
                    if field == "site":
                        response_payload.update({field: modem_existing[field].name})
                    else:
                        response_payload.update({field: modem_existing[field]})

                # _logger.info("\n\n\n" + str(modem_existing) + "\n\n\n")
                return {"success": True, "modem": response_payload}
            else:
                return {"success": False, "modem": response_payload}
        else:
            temp_modem = {'mac': wanted_fields.get("mac"), 'name': "artinmodem"}
            self.MapModem(modem=temp_modem, profile_data=temp_modem)
            return {"success": False, "modem": {}}

    @http.route(
        ["/cc/create_or_update_record"],
        type="json",
        auth="public",
        methods=["POST"],
        cors="*",
        csrf=False,
    )
    def write_receiver(self):
        modem = json.loads(http.request.httprequest.data)
        # server_action = http.request.env["ir.actions.server"].sudo().search([("name", "=", "Call Backend Method")], limit=1)
        # server_action.run()
        # _logger.info("\n\n\n" + str(server_action.name) + "\n\n\n")
        # modem_existing = http.request.env["modem.profile"].sudo().search([("mac", "=", modem["mac"])], limit=1)
        # _logger.info("\n\n\n" + str(modem_existing) + "\n\n\n")

        # Get the current time

        Turkiye_timezone = pytz.timezone("Europe/Istanbul")
        current_time = datetime.now(tz=Turkiye_timezone)
        # Format the current time as a string in the desired format
        formatted_time = current_time.strftime("%d-%m-%Y %H:%M:%S")

        log_text = modem["log"]
        # Create a temporary text file
        with tempfile.NamedTemporaryFile(delete=False, mode="w", encoding="utf-8") as temp_file_log:
            temp_file_log.write(log_text)  # log_text is your log data
        # Get the path of the temporary file
        temp_file_path_log = temp_file_log.name

        monitor_text = modem["monitor"]
        # Create a temporary text file
        with tempfile.NamedTemporaryFile(delete=False, mode="w", encoding="utf-8") as temp_file_monitor:
            temp_file_monitor.write(monitor_text)  # log_text is your log data
        # Get the path of the temporary file
        temp_file_path_monitor = temp_file_monitor.name

        modem_existing = http.request.env["modem.profile"].sudo().search([("mac", "=", modem["mac"])], limit=1)

        profile_data = {
            "name": modem["name"],
            "site": False,
            "update_date": formatted_time,
            "channel": modem["channel"],
            "mac": modem["mac"],
            "device_info": modem["device_info"],
            "ip": modem["ip"],
            "subnet": modem["subnet"],
            "gateway": modem["gateway"],
            "enable_wireless": modem["enable_wireless"],
            "ssid1": modem["ssid1"],
            "passwd_1": modem["passwd_1"],
            "ssid2": modem["ssid2"],
            "passwd_2": modem["passwd_2"],
            "ssid3": modem["ssid3"],
            "passwd_3": modem["passwd_3"],
            # 'ssid4': modem_existing['ssid4'],
            # 'passwd_4': modem_existing['passwd_4'],
            "enable_ssid1": modem["enable_ssid1"],
            "enable_ssid2": modem["enable_ssid2"],
            "enable_ssid3": modem["enable_ssid3"],
            # 'enable_ssid4': modem_existing['enable_ssid4'],
            # "new_password": False,
            "reboot": False,
            "upgrade": False,
            "lostConnection": False,
            "vlanId": modem["vlanId"],
            "ram": modem["ram"],
            "cpu": modem["cpu"],
            "disk": modem["disk"],
            "log": base64.b64encode(open(temp_file_path_log, "rb").read()),
            "lastTimeLogTrimmed": modem["lastTimeLogTrimmed"],
            "advanced": False,
            "terminal": False,
            "monitor": False,
            "firmwareVersion": modem["firmwareVersion"],
        }

        version_list = [
            # "0.9.9.5",
            # "0.9.9.7",
            # "1.0.0",
            # "1.0.2",
            # "1.0.4",
            # "1.0.5",
            # "1.0.6",
            # "1.0.7",
            # "1.0.7.1",
            # "1.0.7.2",
            # "1.0.7.3",
            # "1.0.7.4",
            # "1.0.7.5",
            # "1.0.7.6",
            # "1.0.7.7",
            # "1.0.7.8",
            # "1.0.7.9",
            # "1.0.8.0",
            # "1.0.8.1",
            # "1.0.8.2",
            # "1.0.8.3",
            # "1.0.8.4",
            "1.0.8.5",
            "1.0.8.6",
            "1.0.8.7",
            "1.0.8.8",
            "1.0.9",
            "1.0.9.1",
            "1.0.9.3",
            "1.0.9.5",
            "1.0.9.7",
            "1.0.9.9",
            "1.1.0",
            "1.1.2",
            "1.1.4",
            "1.1.5",
        ]

        success = False
        message = ""

        if modem["firmwareVersion"] in version_list:
            if modem["pra"]:  # previous read attempt successful or not
                self.MapModem(modem, profile_data, temp_file_path_monitor)
                success = True
                message = ""
            else:
                success = False
                message = "Previous Read attempt unsuccessful"
        else:
            pass

        os.remove(temp_file_path_log)
        os.remove(temp_file_path_monitor)

        return {"success": success, "message": message}

    def MapModem(self, modem, profile_data, temp_file_path_monitor=False):
        # _logger.info("\n\n\n" + str(bool(modem_existing)) + "\n\n\n")
        modem_existing = http.request.env["modem.profile"].sudo().search([("mac", "=", modem["mac"])], limit=1)
        if not modem_existing:
            site = http.request.env["modem.profile.site"].sudo().search([("name", "=", "artinsite")])
            profile_data["site"] = site.id
            http.request.env["modem.profile"].sudo().create(profile_data)
        elif modem_existing.modem_lock == False:
            site = http.request.env["modem.profile.site"].sudo().search([("name", "=", modem["site"])], limit=1)
            profile_data["site"] = site.id
            profile_data["monitor"] = base64.b64encode(open(temp_file_path_monitor, "rb").read())
            modem_existing.sudo().write(profile_data)
            modem_existing.sudo().write({'context_changed': False, 'show_warning': False})
            # _logger.info("X" * 50 + "\n" + str(modem_existing.mac) + "\n" + "X" * 50)
